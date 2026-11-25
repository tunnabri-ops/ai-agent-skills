---
name: nestjs-backend
description: Use when building, reviewing, or fixing a production NestJS backend API, including modules, controllers, services, TypeORM or Prisma data access, guards, interceptors, pipes, JWT authentication with role-based access control, request validation, Swagger documentation, Jest unit and end-to-end testing, and Docker deployment.
---

# NestJS Backend

Build production NestJS backends that are modular, typed, tested, and safe to deploy. Prefer the NestJS CLI and its conventions over hand-rolled structure. Every endpoint must validate input, authenticate where required, handle errors consistently, and be covered by a test before it is called done.

## When to Use This Skill

- Starting a new NestJS API, or adding a feature module, endpoint, or entity to an existing app.
- Adding JWT authentication, roles, validation, Swagger docs, logging, or error handling.
- Writing unit or end-to-end tests, or setting up Docker for a NestJS app.
- Reviewing a NestJS codebase for security, structure, or reliability problems.

## Scaffold a New Project

```bash
npm i -g @nestjs/cli
nest new my-api && cd my-api && npm run start:dev
npm i @nestjs/config @nestjs/swagger class-validator class-transformer
npm i @nestjs/jwt @nestjs/passport passport passport-jwt bcrypt
npm i @nestjs/typeorm typeorm pg
npm i -D @types/passport-jwt @types/bcrypt @nestjs/testing supertest @types/supertest
```

For Prisma instead of TypeORM: `npm i prisma @prisma/client && npx prisma init`, then `npx prisma generate` after editing `prisma/schema.prisma`.
Keep strict TypeScript on in `tsconfig.json`: `strict`, `strictPropertyInitialization`, `noImplicitAny`, and `forceConsistentCasingInFileNames` all true.

## Project Structure

Keep one feature per module. Controllers only parse input, call a service, and return a result. Services hold business logic and talk to repositories or Prisma. Repositories and Prisma calls never live in controllers. Shared code goes in `src/common/`; feature code stays in its own module. One DTO per request body, named `CreateXDto` or `UpdateXDto`.

```text
src/main.ts  src/app.module.ts
src/config/configuration.ts  src/config/validation.ts
src/common/decorators/  src/common/filters/  src/common/guards/
src/common/interceptors/  src/common/pipes/
src/auth/auth.module.ts  src/auth/auth.controller.ts  src/auth/auth.service.ts
src/auth/jwt.strategy.ts  src/auth/guards/jwt-auth.guard.ts
src/auth/guards/roles.guard.ts  src/auth/decorators/roles.decorator.ts
src/users/users.module.ts  src/users/users.controller.ts  src/users/users.service.ts
src/users/dto/create-user.dto.ts  src/users/entities/user.entity.ts
src/health/health.controller.ts
```

Generate code with the CLI so names and wiring stay consistent: `nest g module users`, `nest g controller users`, `nest g service users`, `nest g resource products --no-spec`.

## Bootstrap (main.ts)

Configure the app once, in `main.ts`, so every route behaves the same way. Set a global prefix (`api/v1`), restrict CORS to known origins from `CORS_ORIGINS`, and add a global `ValidationPipe` with `whitelist: true`, `forbidNonWhitelisted: true`, and `transform: true`. Never disable validation to make a request pass. Build Swagger with `DocumentBuilder` (title, version, `addBearerAuth()`) and serve it at `api/docs` with `SwaggerModule.setup`. Listen on `process.env.PORT ?? 3000`.

## Configuration

Never hard-code secrets, URLs, or ports. Use `@nestjs/config` with a `configuration.ts` factory reading `PORT`, `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, `JWT_SECRET`, and `JWT_EXPIRES_IN` (default `15m`). Validate required variables at startup with a Joi or Zod schema in `src/config/validation.ts`, so a missing secret fails fast instead of producing a confusing error at the first request. Keep a `.env.example` listing every variable with a placeholder value, and never commit a real `.env` file.

## Controllers and Services

```ts
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}
  @Post() create(@Body() dto: CreateUserDto) { return this.usersService.create(dto); }
  @Get(':id') findOne(@Param('id', ParseUUIDPipe) id: string) { return this.usersService.findOne(id); }
}
```

Service rules: return domain objects or DTOs, never raw database rows with secrets. Throw `NotFoundException`, `BadRequestException`, or `ConflictException` for expected failures and let a global filter format them. Keep methods small and single-purpose. Use transactions for multi-step writes, so a partial failure rolls back cleanly. Check ownership in the service: a user may only read or update their own record unless they hold the admin role.

## Validation with class-validator

Validate every DTO at the boundary, not in the service. Never trust `req.body` or `req.query` without a DTO and a pipe.

```ts
export class CreateUserDto {
  @IsEmail() email: string;
  @IsString() @MinLength(8) password: string;
  @IsString() @IsOptional() name?: string;
}
```

Pagination DTOs use `@IsInt()`, `@Min(1)`, `@Max(100)`, and `@Type(() => Number)` from `class-transformer` so query strings become numbers.

## Data Access: TypeORM

```ts
@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column({ unique: true }) email: string;
  @Column({ select: false }) passwordHash: string;
  @CreateDateColumn() createdAt: Date;
}
```

Use `select: false` on password hashes and secrets. Register entities with `TypeOrmModule.forFeature([User])` and inject the repository with `@InjectRepository(User)`. Use migrations, never `synchronize: true`, in production: `npm run typeorm migration:generate -- src/migrations/AddUsers`, then `npm run typeorm migration:run`.

## Data Access: Prisma

Keep the client behind a service that extends `PrismaClient`, implements `OnModuleInit`, and calls `await this.$connect()` in `onModuleInit`. Put schema changes in `prisma/schema.prisma`, run `npx prisma migrate dev --name add_users`, and never call Prisma directly from a controller. Use `select` to exclude password hashes and internal fields from every query that returns user data.

## Authentication: JWT

Hash passwords with bcrypt, cost factor 10 or higher, and never store or log a plain-text password. Issue a short-lived access token (15 minutes) and a longer refresh token stored hashed in the database. Create a `JwtStrategy` extending `PassportStrategy(Strategy)` with `jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken()`, `ignoreExpiration: false`, and `secretOrKey: process.env.JWT_SECRET`; its `validate(payload)` returns `{ userId: payload.sub, email: payload.email, roles: payload.roles }`. Protect routes with `@UseGuards(JwtAuthGuard)`, at the controller level for protected resources, or globally with a `@Public()` decorator for the few open routes.

## Authorization: RBAC

Define roles as an enum (`Admin = 'admin'`, `User = 'user'`), store them on the user, and enforce them with a guard, not with `if` checks scattered through services. Create a `Roles` decorator with `SetMetadata('roles', roles)` and a `RolesGuard` implementing `CanActivate` that reads required roles with `reflector.getAllAndOverride` from handler and class, returns true when none are set, and otherwise checks `user.roles`. Usage: `@Roles(Role.Admin) @UseGuards(JwtAuthGuard, RolesGuard) @Delete(':id') remove(@Param('id', ParseUUIDPipe) id: string) { return this.usersService.remove(id); }`.

## Guards, Interceptors, Pipes, and Errors

Guards decide access (authentication, roles, feature flags). Interceptors wrap execution (logging, response shaping, caching). Pipes transform and validate (`ParseUUIDPipe`, `ParseIntPipe`, custom pipes for enums or dates). Add a logging interceptor recording method, path, status, and duration, without logging passwords, tokens, or request bodies containing secrets. Add a global exception filter returning a stable shape such as `{ "statusCode": 404, "message": "User not found", "error": "Not Found" }`. Never leak stack traces, SQL errors, or internal paths to clients.

## Swagger Documentation

Document every endpoint so the docs stay true: `@ApiTags('users')`, `@ApiBearerAuth()`, `@ApiCreatedResponse({ description: 'User created.' })`, and `@ApiBadRequestResponse({ description: 'Validation failed.' })` on the handler. Keep Swagger enabled in development and staging. In production, protect `/api/docs` behind authentication or disable it, and never expose it alongside an admin panel without access control.

## Testing with Jest

Run `npm run test`, `npm run test -- users.service.spec.ts`, and `npm run test:cov` for unit tests; run `npm run test:e2e` for end-to-end tests. Test services in isolation with mocked repositories, and cover failure paths, not only the happy path: validation errors, duplicate emails, missing records, and forbidden roles. Example assertion: `await expect(service.findOne('missing-id')).rejects.toThrow(NotFoundException)`.

## End-to-End Tests

Use a separate test database. Never run e2e tests against production data. Test with `supertest` against `app.getHttpServer()`, for example posting `{ email: 'a@example.com', password: 'secret123' }` to `/api/v1/users` and expecting 201. Test authentication on protected routes: no token returns 401, a token with the wrong role returns 403, and an expired token returns 401.

## Docker

Ship a multi-stage Dockerfile: a `node:20-alpine` build stage (`npm ci`, copy source, `npm run build`), then a production stage (`npm ci --omit=dev`, copy `dist` from the build stage, `USER node`, `EXPOSE 3000`, `CMD ["node", "dist/main.js"]`). For local development, use Compose with an `api` service (build `.`, port `3000:3000`, `DB_HOST: db`, `JWT_SECRET`, `depends_on: db`) and a `postgres:16-alpine` `db` service with a `pgdata` volume. Verify the full stack with `docker compose up --build` before release.

## Security Checklist

- [ ] Helmet enabled: `npm i helmet` and `app.use(helmet())`.
- [ ] Rate limiting on auth routes with `@nestjs/throttler`.
- [ ] CORS restricted to known origins; never use `origin: true` in production.
- [ ] Secrets only in environment variables, never in code or Git.
- [ ] Passwords hashed with bcrypt; tokens signed with a strong secret.
- [ ] SQL injection avoided by using parameterized queries or an ORM.
- [ ] File uploads limited by size and type, stored outside the web root.
- [ ] Dependencies audited: `npm audit` and `npm outdated` before release.

## Production Readiness Checklist

- [ ] `npm run build` passes with strict TypeScript and no warnings.
- [ ] `npm run lint` passes; fix lint errors instead of disabling rules.
- [ ] `npm run test` and `npm run test:e2e` both pass; coverage 80 percent or higher on services and guards.
- [ ] Migrations run cleanly on a fresh database.
- [ ] Health endpoint `GET /api/v1/health` returns 200 with database status.
- [ ] Logs are structured JSON with request IDs and no secrets.
- [ ] Graceful shutdown handles SIGTERM and closes database connections.
- [ ] Environment variables documented in `.env.example`.
- [ ] Swagger docs match the real endpoints and response shapes.

## Common Pitfalls

- Using `synchronize: true` in production and losing data on a restart.
- Returning the full user entity, including the password hash.
- Forgetting `whitelist: true`, so extra fields reach the database.
- Storing the JWT secret in source code or committing `.env`.
- Writing business logic in controllers, which makes it untestable.
- Skipping e2e tests for auth, then shipping a route that is open.
- Logging tokens, passwords, or full request bodies.
- Using `any` to silence TypeScript instead of fixing the type.
- Deploying without a health check, so a dead app looks healthy.
- Running migrations by hand in production instead of in the deploy step.

## Review Checklist for Existing Code

1. Every module has a single responsibility and a clear name.
2. Every endpoint has a DTO, a guard where needed, and a test.
3. Every database query excludes secrets from its result.
4. Every error returns a stable shape with no internal details.
5. Every secret comes from the environment, not from code.
6. Swagger, tests, and Docker all pass before the change ships.
