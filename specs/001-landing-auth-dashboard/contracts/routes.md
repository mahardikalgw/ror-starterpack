# Contract: HTTP Routes and Query Semantics

**Feature**: `001-landing-auth-dashboard`
**Date**: 2026-10-28

All HTML-facing routes are Inertia routes: a normal browser request returns the root document plus the initial page payload, while an Inertia visit (`X-Inertia: true`) returns the JSON page object. Successful form submissions redirect (303-style) so Inertia follows them; validation failures redirect back with shared `errors` props.

## Route Table

| Method | Path | Controller#action | Inertia component | Auth | Purpose |
|--------|------|-------------------|-------------------|------|---------|
| GET | `/` | `pages#home` | `home` | Public | Landing page (FR-001…FR-008) |
| GET | `/session/new` | `sessions#new` | `sessions/new` | Public | Sign-in form (FR-011) |
| POST | `/session` | `sessions#create` | — | Public | Sign in, then redirect to `after_authentication_url` (FR-011…FR-014) |
| DELETE | `/session` | `sessions#destroy` | — | Authenticated | Sign out, redirect to `/session/new` (FR-013) |
| GET | `/registration/new` | `registrations#new` | `registrations/new` | Public | Sign-up form (FR-009) |
| POST | `/registration` | `registrations#create` | — | Public | Create account + session, redirect to dashboard (FR-009, FR-010) |
| GET | `/dashboard` | `dashboard#index` | `dashboard/index` | Authenticated | Dashboard (FR-019…FR-046) |
| GET | `/dashboard/export` | `dashboard#export` | — (CSV attachment) | Authenticated | Export current view (FR-036) |

`GET /up` (Rails health check) remains unchanged and unauthenticated. `/inertia-example` is removed.

## Auth Guard Semantics

- `ApplicationController` includes the generated `Authentication` concern, so every action requires a session unless it explicitly calls `allow_unauthenticated_access`.
- Public actions: `pages#home`, `sessions#new`, `sessions#create`, `registrations#new`, `registrations#create`.
- Anonymous request to `/dashboard` or `/dashboard/export`:
  1. store `request.url` in `session[:return_to_after_authenticating]`;
  2. redirect to `/session/new`;
  3. after a successful sign-in or sign-up, redirect to the stored URL (deep-link return, FR-014).
- Expired/invalid session: destroy the record, clear the cookie, redirect to `/session/new` with an Inertia `alert` flash: "Your session expired. Please sign in again."
- Signed-in visitor on `/session/new` or `/registration/new`: redirect to `/dashboard`.
- Sign-out with no active session: still clear the cookie and redirect to `/session/new` (idempotent).

## Sign-In Failure Contract

- `POST /session` with wrong credentials: redirect back to `/session/new` with `errors: { base: "Try another email address or password." }` (single generic message, FR-012).
- Rate limited (10 attempts / 3 minutes per IP): redirect with `errors: { base: "Too many attempts. Try again later." }`.
- Successful sign-in resets the rate-limit counter and clears stored errors.

## Registration Contract

Request body (`application/x-www-form-urlencoded` or JSON, Inertia form submission):

| Field | Required | Rules |
|-------|----------|-------|
| `name` | yes | 1–80 characters |
| `email_address` | yes | valid email, unique after normalization, ≤ 254 characters |
| `password` | yes | ≥ 8 characters |
| `password_confirmation` | yes | matches `password` |

On success: create the user in the demo workspace, start a session, redirect to `/dashboard` (or the stored destination).
On failure: redirect back to `/registration/new` with field-scoped `errors` (`name`, `email_address`, `password`, `password_confirmation`), no account created, form values preserved by Inertia state preservation.

## Dashboard Query Parameters

| Param | Type | Default | Validation / behavior |
|-------|------|---------|-----------------------|
| `start_date` | ISO date | `2023-10-18` | Invalid or after `end_date` → default |
| `end_date` | ISO date | `2023-11-18` | Invalid or before `start_date` → default; range > 366 days → default |
| `granularity` | `monthly` \| `weekly` | `monthly` | Unknown values → `monthly` |
| `regions[]` | `china`, `eu`, `usa`, `canada`, `other` | all | Unknown values ignored; empty after filtering → all |
| `channels[]` | `website`, `mobile_app`, `other` | all | Unknown values ignored; empty after filtering → all |
| `q` | string | empty | Trimmed, max 100 chars; filters integrations by name or category |
| `all` | `0` \| `1` | `0` | `1` renders every integration row ("See All") |
| `ids[]` | array of integer IDs | none | Export only; unknown IDs ignored |

Rules:
- All params are optional; the server always returns a complete, valid payload and never a 422 for bad filter input.
- Changing any parameter produces a normal Inertia visit to `/dashboard` with the same component; panels may be requested via partial reload (`X-Inertia-Partial-Data`).
- Active filter state and labels are echoed back in the payload so the UI can render chips and a "Clear" action.
- Search results include a total count for `aria-live` announcements.

## Export Contract (`GET /dashboard/export`)

- Accepts the same params as `/dashboard`, plus optional `ids[]`.
- Authenticated only; anonymous requests follow the auth redirect (no CSV body).
- Response: `200 OK`, `Content-Type: text/csv; charset=utf-8`, `Content-Disposition: attachment; filename="dashboard-2023-10-18-2023-11-18.csv"`.
- `Cache-Control: no-store` (workspace-specific data).
- Body columns (header row, comma-separated, RFC 4180 quoting): `Section,Metric,Label,Value`.
- Sections/rows:
  - `kpi` → `page_views`, `total_revenue`, `bounce_rate`;
  - `sales` → one row per bucket and region;
  - `subscribers` → one row per day in the weekly series;
  - `distribution` → one row per channel;
  - `integrations` → one row per exported integration with name, category, rate, profit.
- When `ids[]` is present, only matching integrations are exported; KPI/chart rows are unaffected.
- Values beginning with `=`, `+`, `-`, `@`, tab, or carriage return are prefixed with `'` to prevent formula injection.
- Empty/unknown selection: exports all visible integrations (no error).

## Error and Status Matrix

| Situation | Status | Body |
|-----------|--------|------|
| Inertia page GET | 200 | HTML shell or Inertia JSON |
| Successful POST (sign-in/up) | 303 redirect | Location: dashboard or stored URL |
| Validation failure | 303 redirect | Back to form with `errors` props |
| Anonymous protected request | 303 redirect | Location: `/session/new` |
| CSV export | 200 | CSV attachment |
| Missing CSRF token | 422 | Rails default rejection |
| Unknown route | 404 | Rails default |

## Caching Headers

- Dashboard, export, and auth pages: `Cache-Control: no-store` (workspace/session-specific).
- Landing page: no account-specific data in the HTML shell; the signed-in variant arrives as Inertia props. Do not add a shared-cache policy for authenticated responses; Vite asset hashing handles static asset caching.

