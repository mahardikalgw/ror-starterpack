# Phase 0 Research: Landing, Authentication & Analytics Dashboard

**Feature**: `001-landing-auth-dashboard`
**Date**: 2026-10-28
**Spec**: [spec.md](./spec.md)

## Context

The repository is a Rails 8.1.4 starter template (`inertia_rails` 3.23 is installed) with no database schema, no `package.json`, no Vite configuration, and no frontend entry point. It still boots with importmap, Turbo, Stimulus, and Propshaft. This research resolves every technical unknown required to deliver the three pages and the dashboard's database-backed example logic, following the guidance in `llms-full.txt`.

## Runtime Baseline (verified in this workspace)

| Component | Version | Source |
|-----------|---------|--------|
| Ruby | 3.4.7 | `ruby -v` |
| Rails | 8.1.4 | `bin/rails -v` |
| `inertia_rails` | 3.23.0 | `Gemfile.lock` |
| Node / npm | 24.20.0 / 11.19.0 | `node -v`, `npm -v` |
| SQLite | via `sqlite3` >= 2.1 | `Gemfile` |
| `vite_rails` | 3.11.1 (available locally, not yet in Gemfile) | `gem info vite_rails` |

Registry versions at planning time: `@inertiajs/react` 3.9.1 (React 19 peer), `@inertiajs/vite` 3.9.1 (Vite ^7 or ^8), Vite 8.3.5, React 19.3.1, Tailwind CSS 4.3.3, `@fontsource-variable/inter` 5.3.0, `recharts` 3.10.1 (shadcn registry pins `recharts@3.8.0`), `lucide-react` 1.62.0.

---

## D1. Frontend toolchain: Vite + React 19 + TypeScript via the Inertia generator

**Decision**: Run `bin/rails generate inertia:install --framework=react --typescript --vite --tailwind --no-interactive --skip-example-page`, then replace the generated example artifacts with the feature pages.

**Rationale**: This is the path documented in `llms-full.txt` (`/guide/server-side-setup`, `/cookbook/integrating-shadcn-ui`). The generator:
- adds `vite_rails` to the Gemfile and runs `bundle exec vite install`;
- adds `@inertiajs/react`, `@inertiajs/vite`, `@vitejs/plugin-react`, React 19, Vite, and TypeScript;
- writes `config/initializers/inertia_rails.rb` with `version = ViteRuby.digest`, `use_script_element_for_initial_page`, `use_data_inertia_head_attribute`, `always_include_errors_hash`, `encrypt_history`, and `server_head`;
- creates `app/controllers/inertia_controller.rb`, `app/frontend/entrypoints/inertia.tsx`, `bin/dev`, `Procfile.dev`, TS configs, and appends Vite tags to the application layout.

`@inertiajs/vite` supports Vite 8, and `vite-plugin-ruby` 5.2.6 accepts `vite >= 5`, so Vite 8 is compatible with `vite_rails` 3.11.1. Vite Rails' `sourceCodeDir` resolves to `app/frontend`, which the Inertia generator and shadcn cookbook both assume.

**Alternatives considered**: Webpacker/Shakapacker (heavier, not the documented path); importmap-only React (no JSX/TS compilation, no shadcn CLI support); Svelte/Vue (the reference UI and the available shadcn/React skills target React).

**Follow-up corrections to generator output**:
- The generated initializer enables `server_head = true` (server-managed `<head>` props), not SSR; SSR stays disabled (`ssr_enabled` default `false`). Keep `server_head` aligned on both server and client (`entrypoint` already sets `serverHead: true`).
- Replace the generated `InertiaExample` page/controller/route with the landing route.

## D2. Retire importmap, Turbo, and Stimulus; keep Propshaft

**Decision**: Remove `importmap-rails`, `turbo-rails`, and `stimulus-rails` from the Gemfile, delete `app/javascript` and `config/importmap.rb`, and remove the importmap/Turbo tags from the layout. Keep `propshaft` for static assets. Drop `stale_when_importmap_changes` from `ApplicationController`, and replace the `bin/importmap audit` step in `config/ci.rb` and `.github/workflows/ci.yml` with an npm-based audit (`npm audit --audit-level=high`) or remove it once the JS audit step is added.

**Rationale**: Inertia owns navigation and page rendering; leaving Turbo/Stimulus mounted causes double-bootstrapping and dead dependencies. Propshaft still serves public/static assets and removing it would ripple through asset initializers and helpers for no benefit.

**Alternatives considered**: Keep everything installed but unused (dead weight, confusing template); keep Turbo alongside Inertia (conflicting visit lifecycles).

## D3. Styling: Tailwind CSS v4 + shadcn/ui (New York, neutral, CSS variables)

**Decision**: Use the Tailwind v4 plugin installed by the Inertia generator (`tailwindcss`, `@tailwindcss/vite`, `@tailwindcss/forms`, `@tailwindcss/typography`) and initialize shadcn/ui with the New York style, neutral base color, and CSS variables. Add components through the registry: `button`, `card`, `input`, `label`, `field`, `select`, `dropdown-menu`, `checkbox`, `table`, `badge`, `avatar`, `tooltip`, `separator`, `sheet`, `sidebar`, `skeleton`, `sonner`, `chart`, `progress`, `toggle-group`, `popover`, `calendar`, `command`.

**Rationale**: The reference design maps directly onto shadcn `Sidebar`, `Card`, `Chart`, and `Table` primitives. Tailwind v4 is what the generator installs, and the registry's `new-york-v4` items are Tailwind v4/CSS-variable based. shadcn requires path aliases; configure `tsconfig.app.json` (`@/*` → `./app/frontend/*`) and `tsconfig.json` (`baseUrl: ./app/frontend`, `paths: { "@/*": ["./*"] }`) as documented in the Inertia shadcn cookbook before `npx shadcn@latest init`.

**Alternatives considered**: Hand-written CSS (slow, inconsistent with the available shadcn skill); Tailwind v3 (contradicts the generator and current shadcn presets); another component kit (no registry workflow or agent skill support here).

**Theming**: Map tokens to the reference palette: soft grey canvas, white cards, subtle borders, indigo/violet primary, teal positive deltas, rose negative deltas, `rounded-2xl` cards, ~10px controls. Use semantic tokens only (`bg-card`, `text-muted-foreground`), never raw palette classes, per the shadcn rules.

## D4. Typography: self-hosted Inter Variable

**Decision**: Add `@fontsource-variable/inter` and import it at the top of `app/frontend/entrypoints/application.css`; set `--font-sans: "Inter Variable", ui-sans-serif, system-ui, sans-serif` in the Tailwind v4 `@theme` block, with `--font-heading: var(--font-sans)`.

**Rationale**: The spec requires Inter with a system fallback. Fontsource self-hosting avoids third-party requests, works with the Vite asset pipeline and CSP, and renders reliably offline. The shadcn design-system guidance recommends Fontsource with this exact variable naming.

**Alternatives considered**: Google Fonts `<link>` (external dependency, CSP/privacy concerns, render blocking); system-only stack (does not satisfy FR-039).

## D5. Charts: Recharts via the shadcn `chart` primitive

**Decision**: Use the shadcn `chart` component (which pins `recharts@3.8.0`) for the stacked sales bars, subscriber bars, and distribution donut, with gradients, rounded bar radii, a highlighted peak bar, and `paddingAngle` on the donut. Add a visually hidden data table plus `aria-label`/`role="img"` summaries per chart. Import only the Recharts primitives used.

**Rationale**: Recharts supports stacked bars, gradients, rounded corners, responsive containers, tooltips, and an accessibility layer; the shadcn wrapper supplies theme-aware colors and tooltip/legend components. It supports React 19.

**Alternatives considered**: Hand-built CSS/SVG charts (smallest bundle, but significant custom code for tooltips, responsiveness, accessibility); Chart.js (canvas, weaker React integration and DOM accessibility); Nivo/Visx (heavier or lower-level).

## D6. Authentication: Rails 8 generator + a registration flow

**Decision**: Generate the Rails 8 authentication scaffold (`bin/rails generate authentication`), then:
- keep `User`, `Session`, `Current`, `Authentication`, `SessionsController`;
- add a `RegistrationsController` (`new`/`create`) because the generator never creates sign-up;
- delete the generated password-reset controller, mailer, mailer views, and `resources :passwords` route, since password reset is explicitly out of scope;
- extend the session model with `last_active_at` and enforce the spec's 30-day inactivity expiry (the generator only sets a 20-year signed cookie);
- add `name`, `role`, and `workspace_id` to users; enforce an 8-character minimum password and email normalization/uniqueness.

**Rationale**: The generator is the documented Rails 8 approach (also referenced in `llms-full.txt`), provides secure `has_secure_password`/bcrypt hashing, signed session cookies, `Current` attributes, and rate limiting on sign-in. It keeps the template small and idiomatic (no Devise). Password reset is removed rather than left dormant so the template does not ship an unconfigured mailer or dead routes.

**Session expiry design**: `start_new_session_for` creates the session row with `last_active_at: Time.current` and a cookie with `expires: 30.days`. `resume_session` touches `last_active_at` and destroys sessions older than 30 days, then clears the cookie. `terminate_session` must tolerate a nil `Current.session` (double sign-out) and always delete the cookie.

**Alternatives considered**: Devise (heavy, opinionated views/routes, unnecessary for a template); hand-rolled auth (duplicates well-tested Rails 8 code); magic-link/passwordless (out of scope).

**Redirect behavior**: `request_authentication` stores `request.url` in the session and `after_authentication_url` restores it, satisfying deep-link return. Sign-in failures must render a generic message via Inertia errors (`errors.base`) rather than a revealing per-field error. `ApplicationController` includes `Authentication`, so public pages (`PagesController#index`, sessions, registrations) must call `allow_unauthenticated_access`.

**Demo credentials**: Seeded user `demo@nexus.io` with a documented password. The sign-in page receives a `demo` prop **only when** the demo user exists and `ENV["SHOW_DEMO_CREDENTIALS"]` is not `"false"`, defaulting to visible in development/test and hidden in production. The credentials come from one configuration source shared by the seeder and the page.

## D7. Data model: normalized daily facts, aggregates computed by query objects

**Decision**: Store nine tables — `workspaces`, `users`, `sessions`, `daily_metrics`, `sales_records`, `subscriber_snapshots`, `channel_revenues`, `integrations`, `messages` — with integer cents for money, `date` columns for facts, and foreign keys/indexes. Compute every dashboard figure with SQL aggregates in query objects; do not add an `analytics_summaries` table or persist derived totals.

**Rationale**: Daily facts let the same rows answer every date range and granularity change, which is exactly the "real database example logic" the template must demonstrate. Persisted summaries would duplicate data and drift from the facts (violating FR-031 and SC-003). Integer cents avoid floating-point money errors; formatting happens once, on the client, with `Intl.NumberFormat`.

**Derivations**:
- KPI page views / revenue: `SUM` over `daily_metrics` for the period; revenue is a distinct net-revenue metric.
- Bounce rate: weighted by `sessions_count` from `bounced_sessions`, not a naive average.
- Comparison deltas: the same aggregate over the immediately preceding period of equal length.
- Sales overview: `SUM(amount_cents)` grouped by calendar month or ISO week (per granularity) and region.
- Subscribers: period total = `SUM(count)`; delta = comparison with the previous period; weekly series = the last seven dated snapshots within the period; peak = maximum count.
- Distribution: `SUM(amount_cents)` grouped by channel for the period.
- Sidebar badge: `COUNT` of unread `messages`.
- Integrations: ordered by `position`, filtered by the search term.

**Alternatives considered**: A single wide `dashboard_metrics` row per workspace (cannot support date ranges or comparisons honestly); materialized summaries maintained by callbacks/jobs (unnecessary complexity for seed-sized data); chart-ready JSON blobs (opaque, untestable, violates traceability).

## D8. Reporting period semantics and deterministic demo data

**Decision**:
- Query params: `start_date`, `end_date` (ISO `YYYY-MM-DD`), `granularity` (`monthly` default, `weekly`), `regions[]`, `channels[]`, `q`, `all`, and `ids[]` (export only).
- Defaults: `2023-10-18` → `2023-11-18`, monthly, matching FR-025. The period is inclusive and capped at 366 days; invalid or out-of-range input falls back to defaults and unknown filter values are ignored.
- Seed data spans `2023-09-01` → `2023-12-31` so the default period, its comparison period (Sep 16 – Oct 17), and an extended range (through December) all have facts.
- The demo is anchored to the fixed year 2023 (matching the reference copyright), so screenshots, tests, and the visual review are deterministic regardless of the current date. Date presets resolve against the seeded year; custom start/end dates are also supported.

**Rationale**: Deterministic seeds are required for FR-031/SC-004 and stable tests. Relative "last 30 days" defaults would silently produce empty dashboards whenever the seed is older than a month, which is fatal for a template.

**Alternatives considered**: Seeding relative to `Date.current` (dashboard drifts daily; screenshots/tests become time-dependent); defaulting to a preset such as "last 30 days" (violates FR-025).

## D9. Reference-mock inconsistencies: computed data wins

**Decision**: Treat the supplied mockup as a **layout and styling reference**, and let the seeded database determine every displayed number. The mock is internally inconsistent, so literal numeric parity would require hardcoding, which FR-031/SC-003 forbid:

| Mock conflict | Resolution |
|---------------|------------|
| Range chip says "Oct 18 – Nov 18" but the sales chart shows Oct, Nov, and Dec | Range filters all panels. The default period renders October and November; December is seeded and appears when the range is extended. The range chip stays authoritative (FR-025/FR-032). |
| KPI "Total Revenue" is $363.95 while "Sales Overview" totals $9,257.51 | They are different metrics: net revenue (KPI) versus gross sales records (overview). Both are labeled distinctly. |
| Monthly bars sum to $8,758.94 but the overview headline says $9,257.51 | The headline is the computed sum of the bars. |
| Overview growth is labeled "+15.8%" and "+$143.50" (which imply a ~$908 base) | Both values are computed from the comparison period; the percentage and amount always agree with each other. |
| Subscriber total 24,473 with a "+749" delta and a 3,874 peak day | Total and delta are computed from snapshots; the peak is the maximum daily value in the displayed week. |

**Rationale**: A template that shows numbers which cannot be reconciled teaches the wrong lesson and breaks SC-003/SC-005. Layout, card composition, typography, colors, and labels follow the mock; numbers follow the data.

**Alternatives considered**: Hardcoding mock strings for visual fidelity (rejected: violates three requirements and makes filters meaningless); tuning seeds so every individual mock number matches (mathematically impossible because the mock contradicts itself).

## D10. Inertia interaction model: full props on load, partial reloads for controls

**Decision**: Each page is a controller action rendering a named Inertia component with server-computed props. Period, granularity, filter, and search changes trigger Inertia visits with query strings; where only dashboard panels change, use partial reloads (`router.get(url, {}, { only: [...], preserveState: true, preserveScroll: true })`). Search is debounced (250 ms) and server-side. Integration row selection is local UI state, sent as `ids[]` only when exporting. Keep `preserveState`/`preserveScroll` for filter interactions.

**Rationale**: This is the idiomatic Inertia Rails pattern in `llms-full.txt` and demonstrates the framework's strengths (no API, no client data-fetching layer). Server-side filtering keeps FR-035's result count authoritative and avoids shipping all rows.

**Alternatives considered**: Client-side filtering of a full payload (does not scale, hides server logic); separate JSON API endpoints (contradicts the Inertia approach and the template's purpose); full page reloads for every control (poor UX).

**Prop naming**: Props serialize Rails snake_case keys as-is; the TypeScript `DashboardProps` interface in `contracts/dashboard.md` mirrors the exact server keys.

## D11. Export: server-generated CSV

**Decision**: `GET /dashboard/export` returns `text/csv` via `send_data` with a `Content-Disposition` filename, built from the same query objects and params as the dashboard. Without `ids[]`, it exports all visible integrations; with `ids[]`, only those rows. Prefix values starting with `=`, `+`, `-`, or `@` with a single quote to prevent spreadsheet formula injection.

**Rationale**: Server-side CSV keeps numbers consistent with the page and avoids duplicating formatting logic. A single spreadsheet-friendly file matches the spec's scope.

**Alternatives considered**: Client-side CSV generation (duplicates aggregates, breaks auditability); XLSX (extra gem, out of scope); PDF (out of scope).

## D12. Caching, SSR, and delivery

**Decision**: No prop caching, fragment caching, or SSR in v1 (`ssr_enabled` stays false). Dashboard queries run per request against SQLite; the seeded dataset is small. Document `InertiaRails.cache` as an optional next step for expensive aggregates.

**Rationale**: Caching adds invalidation complexity that would obscure the template's example logic and risk stale demo data. SSR requires a second Node process and extra deployment wiring that this feature does not need; `server_head` already provides server-managed meta tags for the landing page.

**Alternatives considered**: SSR via `@inertiajs/vite` (deployment and debugging cost, no requirement); cached props (premature, invalidation risk).

## D13. Testing strategy: Minitest + Inertia assertions + system smoke tests

**Decision**:
- `test/test_helper.rb` requires `inertia_rails/minitest`, which injects the `inertia` helper and assertions into `ActionDispatch::IntegrationTest`.
- Model tests cover associations and validations (email normalization/uniqueness, minimum password length, money/rate constraints).
- Query-object tests cover period parsing (defaults, invalid input, max range), boundary inclusivity, comparison-period math, weighted bounce rate, monthly/weekly grouping, filters, and empty datasets.
- Integration tests cover: landing renders the `home` component with the anonymous variant; dashboard redirects anonymous users; registration success/failure props; sign-in generic error; sign-out; deep-link return; dashboard props match seeded aggregates; CSV export headers/rows/selection.
- System tests (Capybara + Selenium, already in the Gemfile) cover the end-to-end sign-in → dashboard → filter → sign-out journey. They are opt-in locally (`bin/rails test:system`) and documented in quickstart; CI keeps the existing optional system-test step.
- `config/ci.rb` already runs `bin/rails test` and `RAILS_ENV=test bin/rails db:seed:replant`, so seeds must be idempotent and valid in the test environment.

**Rationale**: The project already uses Minitest, fixtures, Capybara, and Selenium; adding RSpec/FactoryBot would introduce a parallel stack with no benefit. Inertia's Minitest helpers are the documented way to assert components and props.

**Alternatives considered**: RSpec + FactoryBot (new stack, more setup); request specs only (cannot verify charts render); JS unit tests with Vitest (no existing JS test harness; system tests cover the integration).

**Test data**: Prefer plain ActiveRecord setup helpers in `test/support/` over fixtures for computed aggregates; keep `fixtures :all` as-is for future use.

## D14. Accessibility and visual verification

**Decision**: Use shadcn/Radix primitives (they provide focus management, labels, and keyboard behavior), add explicit `aria-label`/`aria-live` where needed, include `sr-only` data tables for every chart, and honor `prefers-reduced-motion` in CSS and chart animations. Verify with a keyboard-only pass and an automated axe scan during review.

**Rationale**: FR-043/FR-044 and SC-009/SC-010 require it, and the reference image provides no accessibility affordances by itself.

## D15. Non-dashboard navigation entries

**Decision**: Render every sidebar item from a single navigation definition. The ten non-dashboard entries render as disabled menu buttons with a tooltip ("Preview — not included in this template") and `aria-disabled="true"`, not links. "Message" shows the unread count badge; "Automation" shows BETA. "See All" integrations and "Upgrade Plan" open a small info dialog / toggle, not an empty route.

**Rationale**: FR-024 forbids dead ends while FR-019 requires the full reference navigation. Disabled, labeled entries communicate scope honestly.

**Alternatives considered**: Building nine placeholder pages (scope creep); linking to `#` (dead end, confusing); hiding the items (breaks visual parity).

## D16. Security, performance, and operational notes

- **CSRF**: Rails `protect_from_forgery` stays on; Inertia's axios-based client sends `X-XSRF-TOKEN` from the Rails cookie. Verify it with a sign-up POST during implementation.
- **Sessions**: signed, HTTP-only, `same_site: :lax` cookie with a 30-day expiry; server-side expiry enforced by `last_active_at`; sign-out deletes both the record and cookie.
- **Rate limiting**: keep the generator's 10 attempts / 3 minutes on sign-in; add a comparable limit to registration.
- **Demo credentials**: never enabled by default in production; one source of truth; clearly labeled as demonstration-only.
- **CSP**: The initializer is commented out. If enabled later, assets and fonts are same-origin (Vite/Fontsource), so no external allowlist is needed; Vite's dev server needs its documented dev-only CSP relaxations.
- **Performance target**: dashboard server render < 300 ms and filter round-trip < 1 s for the seeded dataset. Query count stays bounded (roughly one query per panel plus shared workspace/session lookups); indexes on `(workspace_id, recorded_on)` for fact tables, unique indexes for daily rows, and `(workspace_id, position)` for integrations.
- **N+1 risk**: integrations and badges use `COUNT`/single ordered queries; no per-row queries in serializers.
- **Money**: integer cents end-to-end; convert to display strings only in `app/frontend/lib/format.ts` using `Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' })`.
- **Dates**: `date` columns and ISO strings avoid timezone drift; labels are formatted on the client with `Intl.DateTimeFormat('en-US', { month: 'short', day: 'numeric' })`.
- **Reduced motion / chart rendering**: charts animate only if motion is allowed; otherwise render static.

## Open Questions

None. All previously unknown technical choices are resolved above. The only spec-level inconsistency (the mock's numbers) is resolved in D9 by prioritizing data integrity over literal pixel values, which is consistent with FR-031 and SC-003.




