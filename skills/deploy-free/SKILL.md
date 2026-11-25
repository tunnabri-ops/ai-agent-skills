---
name: deploy-free
description: Use when deploying a web app without paying for hosting, choosing between Vercel, Cloudflare Pages, GitHub Pages, and Netlify, adding a serverless API or environment variables to a free deployment, connecting a custom domain, or debugging a failed free-tier deploy.
---

# Deploy Free

Ship a web app on a free tier and keep it free: pick the right host for the app type, deploy with real commands, wire environment variables and a custom domain, and watch the limits that turn a free deploy into a bill. This skill covers static sites and serverless APIs on Vercel, Cloudflare Pages, GitHub Pages, and Netlify. It does not cover paid servers, containers, or databases that need an always-on backend.

## Choose the Host First

| App type | Best free host | Why |
|----------|---------------|-----|
| Static site (HTML, CSS, JS, React/Vite build output) | Cloudflare Pages or GitHub Pages | Generous bandwidth, no build-minute pressure |
| Static site + serverless API | Vercel or Cloudflare Pages + Workers | Functions included, preview deploys per pull request |
| Vite / Next.js / Nuxt app | Vercel or Netlify | Framework presets, zero-config builds |
| Docs or project page for a repo | GitHub Pages | Deploys straight from the repo, no extra account |
| Form handling, identity, or scheduled jobs | Netlify | Built-in forms, identity, and scheduled functions |

Rules for choosing: if the app has no backend code, use Pages or GitHub Pages, not a server host. If it needs an API, pick Vercel or Cloudflare Workers, not a free-tier virtual machine that sleeps. If the repo is already on GitHub and the site is static, GitHub Pages is the shortest path. Never pick a host because it is familiar when the app type points somewhere else.

## Static vs Serverless

- Static: the host serves files from a CDN. HTML, CSS, JavaScript, and images. No code runs per request. Use for landing pages, docs, blogs, and single-page apps that call a separate public API.
- Serverless: a function runs per request and then stops. Use for form submissions, auth callbacks, API proxies, and anything that needs a secret key. Secrets live in the host dashboard as environment variables, never in the repo or in client-side JavaScript.
- Mixed: static frontend plus serverless API under the same domain, for example `/api/*` routes handled by functions and everything else served as files. This is the standard free setup for a real app.
- Do not put a long-running process, a WebSocket server, or a database server on a free static or serverless host. Use a managed free-tier database and call it from functions over HTTPS.

## Workflow

1. Confirm the app builds locally with a clean command, for example `npm run build`, and that the output directory (usually `dist`) has an `index.html`.
2. Pick the host from the table above and note the build command, the output directory, and the Node version the host must use.
3. Create the project on the host and connect the GitHub repo, or use the host CLI for a first deploy. Set the framework preset only when it matches the app; otherwise set build command and output directory by hand.
4. Add environment variables in the host dashboard, not in a committed `.env` file. Add them for production and for preview deploys separately when the values differ.
5. Deploy, open the live URL, and click through the real flows: home page, navigation, API calls, form submit, and a hard refresh on a deep link (client-side routing needs a rewrite rule, see below).
6. Connect a custom domain only after the default subdomain works. Add the DNS records the host shows, wait for the certificate, and test both `https://example.com` and `https://www.example.com`.
7. Check the usage dashboard after the first day: bandwidth, function invocations, and build minutes. Set a reminder to re-check monthly.

## Deploy Checklist — Static Site

- `npm run build` succeeds locally with no errors, and `dist/index.html` exists.
- No secret, API key, or token in the built files; search the output with `grep -r "sk-" dist/ || true` and the equivalent for your keys.
- `index.html` loads over HTTPS with no mixed-content warnings.
- Client-side routing works on refresh: a rewrite sends every path to `index.html`. Vercel uses `vercel.json`, Netlify uses `_redirects`, Cloudflare Pages uses a `_redirects` file or a Functions route.
- Favicon, title, meta description, and Open Graph tags are set.
- Images are compressed and sized for the page; no 5 MB hero image.
- The 404 page is the app's own page, not the host default.
- Preview deploy from a pull request works before merging to main.
- Custom domain DNS is set and the certificate is issued.

Example: Vercel static deploy with the CLI.

```bash
npm install -g vercel
vercel login
vercel --prod
# Answer: build command "npm run build", output directory "dist"
```

Example: Cloudflare Pages deploy with Wrangler.

```bash
npm install -g wrangler
wrangler login
npx wrangler pages deploy dist --project-name my-app
```

Example: GitHub Pages deploy from the `dist` folder with the `gh-pages` package.

```bash
npm install --save-dev gh-pages
npx gh-pages -d dist
# Then in repo Settings > Pages, set source to the gh-pages branch.
```

Example: Netlify deploy with the CLI.

```bash
npm install -g netlify-cli
netlify login
netlify deploy --prod --dir=dist
```

## Deploy Checklist — Serverless API

- One function per route group, for example `api/contact.js` or `api/subscribe.ts`, not one giant function for everything.
- Each function returns JSON with a status code, handles bad input with a 400, and never leaks a stack trace or a secret in the response.
- Secrets come from environment variables set in the host dashboard. The function reads `process.env.API_KEY` and fails loudly at startup when a required variable is missing.
- CORS is set explicitly: allow only the app's own origin in production, not `*`, when the API handles user data.
- Cold starts are acceptable: keep functions small, avoid importing heavy libraries at the top level, and keep the response under a few hundred milliseconds for simple routes.
- Rate limiting is in place for public endpoints, even a simple per-IP cap, so one abusive client cannot burn the free invocation quota.
- The API is tested on the deployed URL with `curl`, not only locally.

Example: a Vercel serverless function at `api/hello.js`.

```javascript
export default function handler(req, res) {
  if (req.method !== "GET") {
    return res.status(405).json({ error: "Method not allowed" });
  }
  return res.status(200).json({ message: "Hello from the free tier" });
}
```

Example: a Cloudflare Worker at `src/index.js`.

```javascript
export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (url.pathname === "/api/hello") {
      return Response.json({ message: "Hello from Workers" });
    }
    return new Response("Not found", { status: 404 });
  },
};
```

Test the deployed API and set an environment variable:

```bash
curl https://my-app.vercel.app/api/hello
vercel env add API_KEY production
# Paste the key when prompted; it is stored on Vercel, not in the repo.
```

Example SPA rewrite for Vercel, `vercel.json`: `{"rewrites": [{"source": "/(.*)", "destination": "/index.html"}]}`

Example SPA rewrite for Netlify or Cloudflare Pages, `_redirects`: `/*  /index.html  200`

## Environment Variables and Custom Domains

- Never commit `.env` to Git. Add `.env` to `.gitignore` on the first commit, and keep a committed `.env.example` with variable names and empty values so the next person knows what to set.
- Set variables in the host dashboard for each environment: production, preview, and development. A preview deploy that points at the production database is a data accident waiting to happen.
- Rotate a key in the dashboard the moment it appears in a log, a screenshot, or a public repo. Do not just delete the commit; the key is already copied.
- Custom domain steps: buy or use a domain the user owns, add the DNS records the host shows (usually a CNAME for `www` and an A or ALIAS record for the apex), wait for DNS to propagate, then confirm the host issued an HTTPS certificate. Test in a private browser window to skip the local DNS cache.
- Keep the host subdomain working after the custom domain is live. It is the fallback when DNS breaks.

## Cost Limits to Watch

- Build minutes: free tiers cap monthly build minutes. A build that installs a huge dependency tree on every commit burns minutes fast. Cache dependencies and avoid rebuilding on docs-only changes.
- Function invocations and duration: free tiers cap the number of function calls and the seconds each call may run. A function that loops or waits on a slow upstream API can hit the duration cap.
- Bandwidth: free tiers cap monthly outbound bandwidth. Large images, videos, and downloadable files belong on object storage or a video host, not served from the site bundle.
- Edge requests: Cloudflare's free tier is generous on requests but Workers have CPU-time limits per request; keep Workers fast.
- Always check the current free-tier page for the host before promising a user that a workload fits: limits change, and a limit page from last year is not a source of truth.

## Examples

### Example 1: Static Vite site on Cloudflare Pages

Input: a Vite app in `my-app/`, `npm run build` writes to `dist/`. Output: run `cd my-app && npm run build && npx wrangler pages deploy dist --project-name my-app`, live at `https://my-app.pages.dev`. Then connect the repo in the Cloudflare dashboard so every push to `main` redeploys, and add `_redirects` with `/* /index.html 200` when the app uses client-side routing.

### Example 2: Static site plus contact-form API on Vercel

Input: a static site plus a contact form that must send an email without exposing an API key in the browser. Output: put the form handler in `api/contact.js` as a Vercel function, read the mail API key from `process.env.MAIL_API_KEY`, set that variable with `vercel env add MAIL_API_KEY production`, deploy with `vercel --prod`, and test with `curl -X POST https://my-app.vercel.app/api/contact -H "Content-Type: application/json" -d '{"name":"Test","email":"test@example.com","message":"Hello"}'`.

### Example 3: Docs site on GitHub Pages

Input: a docs folder built to static HTML in `docs/dist/`. Output: build the docs, deploy with `npx gh-pages -d docs/dist`, set Pages source to the `gh-pages` branch in repo Settings, and confirm the site loads at `https://<username>.github.io/<repo>/`. No server code, no environment variables, no build minutes beyond the local build.

## Pitfalls

- Do not deploy from a branch that is not `main` and call it production; preview deploys exist so production stays clean.
- Do not hard-code `http://localhost:3000` API URLs in the frontend. Use a relative path such as `/api/hello` or an environment variable that points at the deployed API.
- Do not commit `node_modules`, `dist`, or `.env`. The host builds from source; committed build output goes stale and hides real errors.
- Do not ignore a failed deploy and fix it by editing files on the host dashboard. Fix the repo, push, and let the deploy run again.
- Do not serve user uploads from the same free site. Uploads need object storage; a static host has no writable disk.
- Do not assume a preview URL is private. Anyone with the link can open it, so never put real user data or production secrets in a preview.
- Do not leave the default host subdomain as the only URL in production links and QR codes when a custom domain is planned; switch links after the domain and certificate are verified.
