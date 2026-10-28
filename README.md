# Nexus — Rails + Inertia Analytics Starter

A Rails 8 starter that ships three working pages backed by real database records: a public landing page,
email/password authentication, and an analytics dashboard whose every figure is aggregated from SQLite.

## Requirements

- Ruby 3.4.7 (see `.ruby-version`)
- Node 24 / npm 11
- SQLite (installed through the `sqlite3` gem)

## Setup

```bash
bin/setup              # install gems, prepare the database
bin/rails db:seed      # demo workspace, demo user, four months of analytics facts
npm install            # Vite, React, Tailwind, shadcn primitives, Recharts
bin/dev                # Rails + Vite dev server together
```

Open <http://localhost:3000>. The demo account is `demo@nexus.io` / `demo1234` and its credentials are
shown on the sign-in page in development and test. They are demonstration-only.

Seeded data is anchored to 2023 (`2023-09-01`–`2023-12-31`) with a default reporting period of
`2023-10-18`–`2023-11-18`, so screenshots and tests never drift with the system clock.

## Tests and quality gates

```bash
bin/rails test          # Minitest: models, query objects, controllers
bin/rails test:system   # Capybara system journeys (requires a browser)
bin/ci                  # full gate: setup, RuboCop, bundler-audit, npm audit, Brakeman, tests, seeds
```

## Architecture

- **Inertia monolith** — one Rails app, server-computed props, no separate JSON API.
- **Domain logic** — aggregates live in `app/queries/dashboard/`; CSV export in `app/services/dashboard/`.
- **Frontend** — React 19 + TypeScript in `app/javascript/` (Vite's `sourceCodeDir`), styled with
  Tailwind v4 and 18 vendored shadcn/ui primitives in `app/javascript/components/ui/`.
- **UI component rule** — every interactive element comes from that library. `bin/check-ui-components`
  enforces it (raw `<button>`/`<input>`/`<select>`/`<textarea>` outside the library, any focus-ring utility,
  or an unused component fails the build) and runs as part of `bin/ci`.
- **Auth** — Rails 8 generated authentication with a registration controller and a 30-day inactivity expiry.

## Deployment

Kamal is configured in `config/deploy.yml`; run `bin/kamal deploy` after setting the registry and hosts.
Remember to run migrations and seeds in the target environment.

## Project documentation

Feature artifacts live in `specs/001-landing-auth-dashboard/`: specification, plan, research, data model,
contracts, quickstart validation guide, and the task breakdown. Project governance is in
`.specify/memory/constitution.md`.
