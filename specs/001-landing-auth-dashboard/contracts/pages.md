# Contract: Landing and Authentication Page Props

**Feature**: `001-landing-auth-dashboard`
**Date**: 2026-10-28
**Related**: [routes.md](./routes.md) (status codes, auth guard) · [dashboard.md](./dashboard.md)

All four pages are Inertia components. Props are snake_case and shared props are injected once in
`ApplicationController` via `inertia_share`.

## Shared Props (every page)

| Field | Type | Rule |
|-------|------|------|
| `auth.user` | `{ id, name, role, email_address } \| null` | `null` for anonymous visitors; source `Current.user` |
| `auth.workspace` | `{ id, name, plan, currency } \| null` | `null` when signed out; source `Current.user.workspace` |
| `flash.notice` | `string \| null` | Rails notice flash |
| `flash.alert` | `string \| null` | Rails alert flash, including session-expiry messaging |
| `errors` | `{ [field: string]: string }` | Empty object on success; `always_include_errors_hash` is enabled |

`auth` is the single source of truth for the signed-in UI variant (FR-007). No page may infer auth state
from a separate prop.

## `home` — `GET /` (public)

| Field | Type | Rule |
|-------|------|------|
| `marketing.signed_in` | `boolean` | Mirrors `auth.user` presence; selects the CTA variant (FR-007) |
| `marketing.primary_cta` | `{ label, href }` | `"Start for free"` → `/registration/new` when signed out; `"Open dashboard"` → `/dashboard` when signed in |
| `marketing.secondary_cta` | `{ label, href } \| null` | `"Sign in"` → `/session/new`; `null` when signed in |
| `marketing.value_props` | `{ title, description, icon }[]` | At least three entries (FR-003) |
| `marketing.proof` | `{ metric, label }[]` | At least three credibility metrics (FR-004) |
| `marketing.preview` | `{ title, description }` | Copy for the static dashboard preview panel (FR-002) |
| `marketing.footer_links` | `{ label, href, available }[]` | Product areas; `available: false` renders the same non-interactive preview treatment as the sidebar (FR-024) |
| `meta.page_title` | `string` | `"Nexus · Analytics starter template"` (FR-045) |

The landing page is public and MUST NOT include workspace analytics values (SC-007). Static marketing copy
may live in a Ruby constant or a JSON fixture; it MUST NOT be fetched from the client.

## `sessions/new` — `GET /session/new` (public)

| Field | Type | Rule |
|-------|------|------|
| `demo` | `{ email_address, password, note } \| null` | Populated only when the demo user exists and `ENV["SHOW_DEMO_CREDENTIALS"] != "false"`; default visible in development/test, hidden in production (research D6) |
| `form.email_address` | `string` | Previously submitted, trimmed value or empty |
| `meta.page_title` | `string` | `"Sign in · Nexus"` |

Error contract on failure (redirect back):

| Key | Message | Condition |
|-----|---------|-----------|
| `errors.base` | `"Try another email address or password."` | Wrong credentials (FR-012, no reveal) |
| `errors.base` | `"Too many attempts. Try again later."` | Rate limited: 10 attempts / 3 minutes per IP |
| `errors.email_address` | presence | Blank submission |

A signed-in visitor requesting this route is redirected to `/dashboard` and receives no page payload.

## `registrations/new` — `GET /registration/new` (public)

| Field | Type | Rule |
|-------|------|------|
| `form` | `{ name, email_address }` | Submitted values echoed back, never the password |
| `meta.page_title` | `string` | `"Create your account · Nexus"` |

Error contract on failure (redirect back), field-scoped per FR-010:

| Key | Message |
|-----|---------|
| `errors.name` | `"can't be blank"` / length limit |
| `errors.email_address` | `"can't be blank"`, `"is invalid"`, `"has already been taken"` |
| `errors.password` | `"can't be blank"`, `"is too short (minimum is 8 characters)"` |
| `errors.password_confirmation` | `"doesn't match Password"` |

`password` and `password_confirmation` MUST never appear in props, flash, or logs.

## Component Name Registry

| Route | `component` |
|-------|-------------|
| `GET /` | `home` |
| `GET /session/new` | `sessions/new` |
| `GET /registration/new` | `registrations/new` |
| `GET /dashboard` | `dashboard/index` |

Component names are part of the contract: integration tests assert them with the
`inertia_rails/minitest` `assert_inertia_component` helper, and the Vite page resolver must find the
matching file under `app/frontend/pages/`.

## Non-Negotiable Prop Rules

1. Every prop value MUST be server-derived; no page may compute a metric from a second source (FR-031).
2. Props MUST be JSON-serializable plain data — no models, no ActiveSupport::TimeWithZone, no BigDecimal.
3. Currency travels as integer cents, dates as `YYYY-MM-DD` strings, rates as basis points (FR-041).
4. Form submissions MUST redirect (303) rather than return props, so Inertia follows the redirect
   (see routes.md).
