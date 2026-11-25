---
name: fastapi-stack
description: Use when building a production FastAPI backend in Python, including Pydantic v2 schemas, SQLAlchemy 2.0 or SQLModel models, Alembic migrations, JWT authentication, dependency injection, background tasks, OpenAPI documentation, pytest testing, Docker, and deployment.
---

# FastAPI Stack
Build a production FastAPI backend the way a senior team would: typed schemas at every boundary, a clean router/service/repository split, real authentication, Alembic migrations for every schema change, and tests that run before every deploy. No endpoint ships without its schema, its validation, its auth check, and its test.
## When to Use This Skill
- The user asks for a Python API with FastAPI, Pydantic, and SQLAlchemy.
- A new FastAPI project needs scaffolding, structure, or a production setup.
- An existing FastAPI app needs auth, migrations, background tasks, or Docker.
- The backend must expose clean OpenAPI docs and a typed client contract.
## When Not to Use It
- The backend is Node.js only: use the MERN or PERN skill instead.
- The app is a static site with no API or database.
- The workload is a long-running batch job with no HTTP surface.
## Tech Choices
- Python 3.12, FastAPI 0.115 or later, Pydantic v2, SQLAlchemy 2.0 or SQLModel.
- PostgreSQL 16 in production; SQLite only for local throwaway tests.
- Alembic for migrations; never change the database by hand in production.
- JWT access tokens (15 minutes) plus rotating refresh tokens (7 days).
- Uvicorn as the server, Gunicorn plus Uvicorn workers in production.
- pytest plus httpx for tests; Ruff for linting, Mypy in strict mode for services and schemas.
## 1. Scaffold the Project
```bash
mkdir my-api && cd my-api
python3 -m venv .venv && source .venv/bin/activate
pip install fastapi "uvicorn[standard]" sqlalchemy sqlmodel alembic pydantic-settings passlib[bcrypt] python-jose[cryptography] python-multipart
pip install -D pytest httpx pytest-asyncio ruff mypy
mkdir -p app/{api/v1,core,models,schemas,services,repositories,db}
mkdir -p tests
alembic init alembic
touch app/__init__.py app/main.py app/core/config.py app/core/security.py
```
Pin exact versions in `requirements.txt` with `pip freeze > requirements.txt`, commit it, add `.env.example` with every variable the app needs, and never commit a real `.env` file.
## 2. Starter File Tree
```text
my-api/
  app/
    main.py                  # create_app, middleware, routers, health
    core/config.py core/security.py core/deps.py  # settings, JWT, deps
    db/session.py db/base.py models/user.py models/item.py
    schemas/user.py schemas/item.py schemas/common.py
    services/auth_service.py services/item_service.py
    repositories/item_repo.py
    api/v1/auth.py api/v1/items.py api/v1/deps.py
    tasks/email.py           # background tasks
  alembic/ versions/ env.py alembic.ini
  tests/ conftest.py test_auth.py test_items.py
  Dockerfile docker-compose.yml requirements.txt .env.example README.md
```
Rules: routers parse request and response only; services hold business logic; repositories hold database queries; schemas define the API contract. A router that queries the database directly is a defect, not a shortcut. Keep the dependency direction one way: router to service to repository to database.
## 3. Settings and Database Session
```python
# app/core/config.py
from pydantic_settings import BaseSettings
class Settings(BaseSettings):
    database_url: str
    jwt_secret: str; jwt_algorithm: str = "HS256"
    access_token_minutes: int = 15; refresh_token_days: int = 7
    class Config:
        env_file = ".env"
settings = Settings()
```
```python
# app/db/session.py
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
engine = create_engine(settings.database_url, pool_size=10, max_overflow=20, pool_pre_ping=True)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```
Validate settings at startup so a missing `DATABASE_URL` fails fast instead of failing on the first request. Use `pool_pre_ping=True` so a stale pooled connection is detected before use, and always close the session in `get_db`, even when the request raises.
## 4. Models with SQLAlchemy 2.0
```python
# app/models/item.py
from sqlalchemy import String, ForeignKey, Enum as SAEnum
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.db.base import Base
import enum, uuid
class ItemStatus(str, enum.Enum):
    DRAFT = "draft"; PUBLISHED = "published"; ARCHIVED = "archived"
class Item(Base):
    __tablename__ = "items"
    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    owner_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    title: Mapped[str] = mapped_column(String(200), nullable=False)
    status: Mapped[ItemStatus] = mapped_column(SAEnum(ItemStatus), default=ItemStatus.DRAFT, index=True)
    owner = relationship("User", back_populates="items")
```
Use `Mapped` and `mapped_column` typed style, add an index for every field used in a filter or sort, set a length limit on user text, and add `created_at` and `updated_at` timestamps to every model. Never store a plain-text password or a raw refresh token in the database.
## 5. Pydantic v2 Schemas
```python
# app/schemas/item.py
from pydantic import BaseModel, Field, ConfigDict
class ItemCreate(BaseModel):
    title: str = Field(min_length=1, max_length=200)
    status: str = "draft"
class ItemRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: str; title: str; status: str; owner_id: str
class PaginatedItems(BaseModel):
    data: list[ItemRead]; page: int; limit: int; total: int; total_pages: int
```
Keep three schema shapes per resource: Create for input, Update for partial input with all fields optional, and Read for output with `from_attributes=True`. Never return a SQLAlchemy model directly from an endpoint, and never accept a model as input. Use `Field` constraints for lengths, ranges, and patterns so invalid input is rejected before any service code runs.
## 6. Alembic Migrations
```bash
alembic revision --autogenerate -m "add items table"
alembic upgrade head
```
Create a migration for every schema change, read the generated file before applying it, and fix autogenerate misses by hand: indexes, enums, and server defaults are the usual gaps. Never edit an applied migration in place; create a new revision instead. Run `alembic upgrade head` as part of the deploy, and verify the downgrade path in development so a bad deploy can be rolled back.
## 7. Authentication: JWT Plus Refresh Tokens
- Register: hash the password with bcrypt via Passlib, never log it.
- Login: verify the password, issue a short access token and a refresh token. Store the refresh token hashed in the database with an expiry.
- Access token: 15 minutes, payload holds only `user_id` and `role`.
- Refresh: client calls `POST /api/v1/auth/refresh` with the refresh token in an `httpOnly`, `secure`, `sameSite=strict` cookie. Rotate the token on every use; reuse of an old token revokes the family.
- Logout: delete the stored refresh token row and clear the cookie.
- Protect routes with a dependency: `current_user = Depends( get_current_user)`. Check ownership in the service layer with a query filter on `owner_id`, so an id in the URL can never leak another user's data.
```python
# app/core/deps.py
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer
async def get_current_user(token: str = Depends(HTTPBearer())):
    payload = verify_token(token.credentials)
    if not payload:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
    return payload
```
## 8. Dependency Injection and Routers
```python
# app/api/v1/items.py
from fastapi import APIRouter, Depends
router = APIRouter(prefix="/items", tags=["items"])
@router.get("", response_model=PaginatedItems)
def list_items(page: int = 1, limit: int = 20, db: Session = Depends(get_db),
               user: dict = Depends(get_current_user)):
    return item_service.list_items(db, owner_id=user["user_id"], page=page, limit=limit)
```
Inject the database session and the current user through `Depends`, never through globals. This makes every endpoint testable: tests can override `get_db` with a test session and `get_current_user` with a fixed user. Keep routers thin, keep one router per resource, version the API under `/api/v1`, and never change a v1 response shape without a new version or a migration note.
## 9. Validation, Errors, Pagination, and Background Tasks
- Validation is automatic: Pydantic rejects bad input with a 422 and a detailed error body before the endpoint runs. Add custom checks in the service layer and raise `HTTPException` with the right code.
- Return one error shape for application errors: `{ "detail": "Item not found" }` for FastAPI errors, and a consistent code field for business errors. Use 400 for bad input, 401 for missing auth, 403 for a forbidden owner, 404 for a missing resource, 409 for a duplicate, and 500 only for real server failures.
- Pagination: `GET /api/v1/items?page=2&limit=20&status=published`. Clamp `limit` to 100, default 20, reject negative pages, and always return `total` and `total_pages` with the data.
- Background tasks: use FastAPI `BackgroundTasks` for fast fire-and- forget work such as sending a welcome email, and Celery plus Redis for anything slow, retryable, or scheduled. Never block a request on an email, a webhook, or a file conversion.
## 10. OpenAPI Docs and File Uploads
- FastAPI generates docs automatically: `/docs` for Swagger UI and `/redoc` for ReDoc. Keep them accurate by using `response_model`, `status_code`, and `summary` on every route, and by writing a real description for each endpoint. Check `/docs` after every new route.
- Uploads: accept files with `UploadFile`, limit size to 5 MB, allow only an explicit list of content types, and rename files with a UUID, never the user-supplied filename. Store files in S3 or Cloudinary in production, never on the server's local disk. Store only the file URL in the database, delete the old file when a record is updated or removed, and serve uploads through a signed URL or a CDN.
## 11. Testing with pytest
```bash
pytest -q
ruff check app tests && ruff format --check app tests
mypy app
```
Cover at minimum: duplicate-email register returns 409, wrong-password login returns 401, an unauthenticated protected request returns 401, a user cannot read another user's item, validation rejects an empty title, a migration upgrades and downgrades cleanly, and pagination returns the correct `total`. Use a dedicated test database, override `get_db` in `conftest.py` with a test session, and roll back or recreate tables between tests. Keep coverage above 70 percent on services and auth; a passing suite, plus Ruff and Mypy clean, is required before any deploy.
## 12. Docker and Deployment
```dockerfile
# Dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["sh", "-c", "alembic upgrade head && gunicorn app.main:app -w 2 -k uvicorn.workers.UvicornWorker -b 0.0.0.0:8000"]
```
```yaml
# docker-compose.yml (local development)
services:
  db:
    image: postgres:16
    environment: { POSTGRES_PASSWORD: devpass, POSTGRES_DB: myapp }
    ports: ["5432:5432"]
  api:
    build: .
    ports: ["8000:8000"]
```
Deploy to Render, Railway, or Fly.io as a Web Service with a managed Postgres database. Set `DATABASE_URL`, `JWT_SECRET`, and `CORS_ORIGINS` in the dashboard, never in code. Enable a health check on `/health`, set the start command to run migrations before the server starts, and verify the live build with `curl` on `/health` and `/docs`.
## Checklist
- [ ] Routers, services, repositories split; schemas define the contract.
- [ ] Settings validated at startup; `.env.example` complete; no secrets committed.
- [ ] Alembic migration for every schema change; downgrade verified.
- [ ] Passwords hashed with bcrypt; refresh tokens hashed and rotated.
- [ ] Pydantic validation on every endpoint; one error shape everywhere.
- [ ] Indexes on filtered and sorted fields; ownership checked in services.
- [ ] Pagination clamped, `total` returned, search bounded.
- [ ] Uploads size-limited, type-checked, stored off the server disk.
- [ ] Background work off the request path; slow work in Celery.
- [ ] Tests pass: auth, ownership, validation, pagination, migrations.
- [ ] Docker build clean; migrations run on deploy; health endpoint live.
## Pitfalls
- **Returning a SQLAlchemy model directly.** It leaks internal fields and breaks serialization; always return a Pydantic Read schema.
- **Editing an applied migration.** Create a new revision instead; editing history breaks every other environment.
- **A new database session per query.** Use one session per request through `get_db`; share the engine, never create it per request.
- **Trusting the client for ownership.** Always filter by `owner_id` in the service layer on the server.
- **Blocking the request on slow work.** Send email and call webhooks from a background task or a queue, never inline in the endpoint.
