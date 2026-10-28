# Implementation Plan: Landing, Authentication & Analytics Dashboard

**Branch**: `001-landing-auth-dashboard` | **Date**: 2026-10-28 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-landing-auth-dashboard/spec.md`

## Summary

Deliver three user-facing experiences inside the existing Rails application: a public landing page, an
email/password authentication flow, and a read-only analytics dashboard whose every figure is computed
from SQLite records.

Technical approach: keep the Inertia monolith and convert the front end from importmap to Vite + React 19
+ TypeScript + Tailwind v4 + shadcn/ui; build authentication on the Rails 8 generator plus a registration
controller and a 30-day inactivity expiry; compute all dashboard numbers with query objects over nine
normalized tables fed by deterministic seeds anchored to `2023-09-01..2023-12-31` with a default reporting
period of `2023-10-18..2023-11-18`.

Requirement traceability: FR-001–FR-046 and SC-001–SC-010 drive buildable work. SC-011 is a post-launch
survey outcome and is deliberately excluded from implementation scope.

## Technical Context

**Language/Version**: Ruby 3.4.7 (`.ruby-version`); Rails 8.1.4; TypeScript 5.x; Node 24.20.0 / npm 11.19.0

**Primary Dependencies**: Existing — `inertia_rails` 3.23.0, `propshaft`, `puma`, `thruster`, `sqlite3 >= 2.1`,
Solid Cache/Queue/Cable, `kamal`, `rubocop-rails-omakase`, `brakeman`, `bundler-audit`, `capybara`,
`selenium-webdriver`. Added — `vite_rails` 3.11.1, `@inertiajs/react` 3.9.1, `@inertiajs/vite` 3.9.1,
React 19.3.1, Vite 8.3.5, `@vitejs/plugin-react`, Tailwind CSS 4.3.3 (`@tailwindcss/vite`, forms,
typography), shadcn/ui registry components (New York, neutral, CSS variables) with `recharts` 3.8.0,
`@fontsource-variable/inter` 5.3.0, `lucide-react` 1.62.0. Removed — `importmap-rails`, `turbo-rails`,
`stimulus-rails`.

**Storage**: SQLite. Nine tables — `workspaces`, `users`, `sessions`, `daily_metrics`, `sales_records`,
`subscriber_snapshots`, `channel_revenues`, `integrations`, `messages`. Money in integer cents, rates in
basis points, facts keyed by `date`. Seeds span `2023-09-01`–`2023-12-31` and are idempotent.

**Testing**: Minitest via `bin/rails test` with `inertia_rails/minitest` props assertions; Capybara +
Selenium system tests via `bin/rails test:system`; the aggregate gate runner is `bin/ci`.

**Target Platform**: Web monolith — Puma behind Thruster, containerized with Kamal. Evergreen desktop and
mobile browsers, 360 px to 1920 px.

**Project Type**: Single Rails application with an Inertia SPA front end. No separate API service.

**Performance Goals**: Dashboard server render < 300 ms and filter/granularity round-trip < 1 s for the
seeded dataset (SC-005); query count bounded to roughly one aggregate per panel plus shared session and
workspace lookups.

**Constraints**: Light theme only; desktop-first at 1440 px; English copy; USD; no SSR and no prop or
fragment caching in v1; 30-day inactivity session expiry; WCAG 2.1 AA; fixed 2023 date anchors so
screenshots and tests never drift with the system clock.

**Scale/Scope**: 8 routes, 4 Inertia pages, 9 tables, 1 workspace, ~122 seeded days per fact table, 3–6
integration rows, no background jobs, no real-time behavior.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Evaluated against constitution **v1.0.0** (ratified 2026-10-28).

| Principle | Gate question | Result | Evidence |
|-----------|---------------|--------|----------|
| I. Inertia Monolith, Server-Driven UI | One app, all page data as server props, no JSON API, no SSR | PASS | All 8 routes are Inertia renders, redirects, or the CSV attachment ([routes.md](./contracts/routes.md)) — none is an API endpoint; props assembled by `Dashboard::Payload`; `ssr_enabled` stays `false` (research D12) |
| II. Skinny Controllers, Explicit Boundaries | Controllers orchestrate only; logic in models/queries/services; no catch-all directories | PASS | `DashboardController#index` is authorize → payload → render; aggregates live in `app/queries/dashboard/*`; the one directory deviation is justified in Complexity Tracking |
| III. Test-First (NON-NEGOTIABLE) | Tests land with the change; route, domain, and journey coverage; seeds valid in test | PASS | Testing strategy research D13; every implementation phase pairs code with tests; `RAILS_ENV=test bin/rails db:seed:replant` is an existing CI gate |
| IV. Security and Quality Gates Block Merge | All `bin/ci` gates green; generated auth concern; strong params; no interpolated SQL | PASS (gate substitution, see note) | Generated `Authentication`/`Session`; strong params in sessions and registrations; aggregates use binds; `bin/importmap audit` is replaced by `npm audit --audit-level=high` in both CI entry points |
| V. Simplicity Before Abstraction | Each dependency and abstraction justified; nothing out of scope | PASS | Each dependency maps to an FR (Complexity Tracking); password reset, verification, and multi-workspace support are removed rather than stubbed |

**Gate note (Principle IV)**: Retiring importmap deletes the `bin/importmap audit` step. Replacing it with
`npm audit --audit-level=high` preserves the "audit JavaScript dependencies" obligation, so this is a gate
substitution rather than a removal or weakening. `config/ci.rb` and `.github/workflows/ci.yml` MUST change
in the same commit, per Principle IV's parity requirement.

**No unmitigated violations.** Two deviations are recorded in Complexity Tracking with justification.

### Post-Design Re-Check (after Phase 1)

Re-evaluated after data model and contracts were written: all five principles still PASS. Phase 1 added
prop contracts ([dashboard.md](./contracts/dashboard.md), [pages.md](./contracts/pages.md)) in which every
field cites the table or query object that produces it, which keeps FR-031 auditable at the interface
boundary. No new violations were introduced; the Complexity Tracking entries are unchanged.

## Project Structure

### Documentation (this feature)

```text
specs/001-landing-auth-dashboard/
├── plan.md              # This file (/speckit-plan command output)
├── spec.md              # Feature specification
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── checklists/
│   └── requirements.md  # Specification quality checklist
└── contracts/
    ├── routes.md        # HTTP routes, query params, auth guard, CSV export
    ├── dashboard.md     # Dashboard page prop contract
    └── pages.md         # Landing and authentication page prop contract
```

### Source Code (repository root)

```text
app/
├── controllers/
│   ├── application_controller.rb        # includes Authentication concern
│   ├── pages_controller.rb              # home (public)
│   ├── sessions_controller.rb           # new/create/destroy
│   ├── registrations_controller.rb      # new/create
│   ├── dashboard_controller.rb          # index/export
│   └── concerns/authentication.rb       # generated, extended for 30-day expiry
├── models/
│   ├── workspace.rb  user.rb  session.rb  current.rb
│   ├── daily_metric.rb  sales_record.rb  subscriber_snapshot.rb
│   └── channel_revenue.rb  integration.rb  message.rb
├── queries/dashboard/
│   ├── period.rb  filters.rb  metrics.rb  sales_overview.rb
│   ├── subscribers.rb  distribution.rb  integrations.rb
│   └── navigation.rb  payload.rb
├── views/layouts/application.html.erb   # root element + Vite tags only
└── frontend/
    ├── entrypoints/inertia.tsx
    ├── entrypoints/application.css      # Tailwind v4 @theme, Inter, tokens
    ├── pages/home.tsx
    ├── pages/sessions/new.tsx
    ├── pages/registrations/new.tsx
    ├── pages/dashboard/index.tsx
    ├── layouts/marketing-layout.tsx
    ├── layouts/auth-layout.tsx
    ├── layouts/dashboard-layout.tsx
    ├── components/ui/*                  # shadcn registry output
    ├── components/marketing/*
    ├── components/auth/*
    ├── components/dashboard/*           # KPI cards, charts, sidebar, top bar, tables
    └── lib/{format.ts,types.ts}

config/
├── routes.rb
├── initializers/inertia_rails.rb
└── ci.rb                                # npm audit replaces importmap audit

db/
├── migrate/
└── seeds.rb                             # delegates to lib/demo_data.rb

lib/demo_data.rb                         # single source of demo constants

test/
├── models/
├── queries/dashboard/
├── controllers/                         # Inertia props + auth behavior
├── system/                              # sign-in → dashboard → filter → sign-out
└── support/                             # demo-data helpers for aggregates
```

**Structure Decision**: Single-project Rails monolith, matching the constitution's ban on a separate API.
The React application lives in `app/frontend` because that is Vite Rails' `sourceCodeDir` and the location
documented in `llms-full.txt` and the Inertia shadcn cookbook. Domain logic stays in `app/models` and
`app/queries` (both inside the documented directory contract); `app/frontend` is the sole deviation and is
justified below.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| `app/frontend/` sits outside the documented `app/` directory contract (Principle II) | Vite requires an entrypoint and page tree under `sourceCodeDir`; the Inertia generator, the shadcn cookbook, and `llms-full.txt` all place it at `app/frontend` | `app/javascript` is the importmap location being retired and is not Vite's source dir; `app/views` cannot host TSX with Vite HMR or resolve the `@/*` aliases shadcn requires |
| Adds Vite, React 19, Tailwind v4, shadcn/Radix, Recharts, Inter, and lucide (Principle V) | FR-027–FR-030 require interactive stacked, bar, and donut charts plus selection and search; FR-039/FR-040 and SC-006 require Inter, the reference palette, and high visual parity | Hand-built CSS/SVG charts need custom tooltip, responsive, and a11y code; importmap-only React cannot compile TSX or run the shadcn CLI; ERB views would abandon the Inertia pattern this template exists to demonstrate |

## Implementation Phases

Ordered slices for `/speckit-tasks`. Each phase lands with its tests (Principle III) and leaves `bin/ci`
green.

| Phase | Scope | Depends on |
|-------|-------|------------|
| A. Toolchain conversion | Run the Inertia React/TS/Vite/Tailwind generator; add Inter and shadcn; remove importmap/Turbo/Stimulus; replace importmap audit with npm audit in `config/ci.rb` and `.github/workflows/ci.yml`; keep `/up` working | — |
| B. Schema and seeds | Nine migrations, models with validations and constraints, `lib/demo_data.rb`, idempotent `db/seeds.rb`, seed re-run test | A |
| C. Authentication | Generated auth base, registration controller, 30-day inactivity expiry, rate limits, shared Inertia props, landing/auth page components | B |
| D. Dashboard data layer | Period/filters/metrics/sales/subscribers/distribution/integrations/navigation query objects and `Payload`; unit tests for parsing, boundaries, comparison math, empty sets | B |
| E. Dashboard shell | Sidebar groups and badges, workspace switcher, top bar, page header controls, responsive drawer, disabled preview entries | C |
| F. Dashboard panels | KPI cards, sales overview, subscribers, distribution, integrations table, charts with hidden data tables | D, E |
| G. Landing page | Header, hero, value props, dashboard preview, proof, closing CTA, footer, signed-in variant | C |
| H. Export | CSV builder honoring period, filters, selection; formula-injection guard; contract tests | D |
| I. Cross-cutting verification | 360–1920 px pass, keyboard pass, axe scan, system journey test, visual parity review at 1440 px | F, G, H |

## Implementation Deviations (recorded 2026-10-28)

These are factual, verified differences between this plan and the delivered code. Each was forced by the
installed toolchain rather than chosen for convenience.

| Plan said | Delivered | Reason |
|-----------|-----------|--------|
| Frontend under `app/frontend/` | Frontend under `app/javascript/` | `vite_rails` 3.11.1's generator sets `sourceCodeDir: app/javascript` and aliases `@/*` there; the `app/frontend` mention came from the upstream docs, not this gem version |
| shadcn components fetched via the registry CLI | `components.json` + 14 hand-written primitives | `npx shadcn init` requires an interactive template prompt; it cannot run non-interactively, so the same artifacts were produced deterministically |
| Ten non-dashboard nav entries referred to as "nine" in research D15 | Ten disabled entries | Spec FR-019 lists Payment, Customers, Message, Product, Invoice, Analytics, Automation, Settings, Security, Help |
| Markdown sections under `components/marketing/` | Composed inline in `pages/home.tsx` | Fewer files, same rendered structure |
| Landing component named `pages/home` | Named `home` | The Vite Inertia plugin resolves a page name as `pages/<name>.tsx` relative to the entrypoint, so a name of `pages/home` resolved to `pages/pages/home.tsx` and threw "Page not found" at runtime. Component names must be paths relative to `app/javascript/pages` (`home`, `sessions/new`, `registrations/new`, `dashboard/index`) |

| Visible focus indicators (FR-043, SC-009) | Removed on request | The product owner asked for no focus ring on any component. All `focus-visible:ring-*` utilities were removed and `:focus, :focus-visible { outline: none }` was added to `application.css`. **This knowingly leaves FR-043 ("visible focus states") and SC-009 (keyboard-only journey) unmet**; either restore an indicator or amend the spec before claiming those criteria. |

Additional: `gem "csv"` was added because CSV is a bundled gem in Ruby 3.4 and is no longer loadable
without an explicit dependency.
