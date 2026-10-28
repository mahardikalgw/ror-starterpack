# Quickstart Validation Guide: Landing, Authentication & Analytics Dashboard

**Feature**: `001-landing-auth-dashboard` | **Date**: 2026-10-28
**Plan**: [plan.md](./plan.md) · **Contracts**: [routes.md](./contracts/routes.md),
[dashboard.md](./contracts/dashboard.md), [pages.md](./contracts/pages.md) ·
**Data model**: [data-model.md](./data-model.md)

This is a validation guide, not an implementation guide. It states how to stand the feature up and how to
prove each requirement works end to end. Model, service, migration, and test bodies belong in
`tasks.md` and the implementation phase.

## Prerequisites

- Ruby 3.4.7 (per `.ruby-version`) and Bundler
- Node 24.20.0 / npm 11.19.0
- SQLite (provided by the `sqlite3` gem; no server to install)
- No external services: no mailer, no third-party API keys, no background worker required

## First Run

```bash
bin/setup              # install gems and prepare the database
bin/rails db:seed      # demo workspace, demo user, and four months of facts
npm install            # Vite, React, Tailwind, shadcn output, Recharts
bin/dev                # Rails server + Vite dev server together
```

Open <http://localhost:3000>.

**Demo credentials**: `demo@nexus.io` with the seeded password defined once in `lib/demo_data.rb` and
surfaced on the sign-in page in development and test. The same page notes they are demonstration-only.

**Date anchor**: seeds cover `2023-09-01`–`2023-12-31`; the default reporting period is
`2023-10-18`–`2023-11-18`. The demo is year-fixed so screenshots and tests never drift.

## Validation Scenarios

| # | Story | Steps | Expected outcome | Proves |
|---|-------|-------|------------------|--------|
| V1 | US3 | Visit `/` signed out | Header, hero with both CTAs, ≥3 value props, dashboard preview, proof metrics, closing CTA, footer; primary → `/registration/new`, secondary → `/session/new` | FR-001–FR-006 |
| V2 | US3 | Sign in, then revisit `/` | CTA offers "Open dashboard"; no sign-in prompt | FR-007 |
| V3 | US3 | Resize `/` at 360, 768, 1440, 1920 px | No horizontal scrollbar; nothing clipped | FR-008, FR-042 |
| V4 | US2 | Submit valid name/email/password/confirmation on `/registration/new` | Account created, session started, dashboard shown | FR-009, SC-002 |
| V5 | US2 | Submit duplicate email, 7-char password, mismatched confirmation | Field-level messages per problem; no second account created | FR-010 |
| V6 | US2 | Sign in with a wrong password, then 11 times quickly | One generic message that never reveals whether the email exists; then the rate-limit message | FR-012, FR-017 |
| V7 | US2 | Signed out, request `/dashboard`, sign in | Landed back on `/dashboard`, not the default page | FR-014 |
| V8 | US2 | Sign out, then press browser Back | No protected content from history or cache | FR-013 |
| V9 | US1 | Compare each KPI, panel total, and row against the seeded records | Every figure matches the stored data for the period | FR-026–FR-031, SC-003 |
| V10 | US1 | Change the date range, then toggle Monthly/Weekly | Range label, KPIs, and every panel update together in under 1 s; totals reconcile | FR-032, FR-033, SC-005 |
| V11 | US1 | Apply a region/channel filter, then clear it | Active filter chips appear, panels narrow, clearing restores defaults | FR-034 |
| V12 | US1 | Type in dashboard search, then clear it | Integration rows filter by name or type; result count announced; clear action resets | FR-035 |
| V13 | US1 | Select two integration rows, choose Export | CSV downloads with only those rows plus current KPIs/charts; leading `=`, `+`, `-`, `@` values are quoted | FR-036 |
| V14 | US1 | Set a range with no seeded records | Explicit empty states and `—` deltas; no broken charts or `NaN` | FR-037 |
| V15 | US1 | Inspect the sidebar | Three groups, Dashboard active, Message count 8 and Automation BETA from data, ten preview entries disabled with no dead ends, workspace "Marketing / Team" | FR-019–FR-024 |
| V16 | US1 | Below 1024 px, open the sidebar by keyboard | Drawer opens, Escape closes it, focus is not trapped, layout settles after rotation | FR-022 |
| V17 | US2 | Complete sign-up → sign-in → filter → sign-out with keyboard only | Whole journey possible with visible focus and no pointer | SC-009, FR-043 |
| V18 | US1 | Run an axe scan on all three pages | Zero critical findings; every chart exposes a hidden data table | SC-010, FR-044 |
| V19 | US1 | Enable reduced-motion, reload | Chart and drawer animation minimized; content fully usable | FR-046 |
| V20 | US4 | Run `bin/rails db:seed` twice, then count rows | Counts unchanged; demo sign-in still works | SC-004 |

## Verification Commands

| Purpose | Command | Expected |
|---------|---------|----------|
| Full gate | `bin/ci` | Every step passes: setup, RuboCop, bundler-audit, npm audit, Brakeman, tests, seed replant |
| Unit + integration | `bin/rails test` | Green, including Inertia component/prop assertions |
| System journey | `bin/rails test:system` | Sign-in → dashboard → filter → sign-out passes |
| Seed idempotency | `RAILS_ENV=test bin/rails db:seed:replant` | Exit 0; record counts stable across runs |
| Style | `bin/rubocop` | No offenses |
| Security | `bin/brakeman --quiet --no-pager --exit-on-warn` | No warnings |
| JS dependency audit | `npm audit --audit-level=high` | No high or critical advisories |
| Traceability spot check | `bin/rails runner 'p DailyMetric.sum(:page_views)'` | Equals the Page Views KPI for the seeded period |

## Out of Scope — Do Not Test

Password reset, email verification, account deletion, multi-workspace switching, dark mode, localization,
the ten non-dashboard destinations, real integration synchronization, and email delivery. Their absence is
intentional (spec "Out of Scope"), and their UI presence must be marked as preview rather than broken.

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Styles or React missing | Only `bin/rails s` is running | Run `bin/dev` so Vite serves assets |
| Blank page after sign-in | Inertia version mismatch after a rebuild | Restart `bin/dev`; confirm the initializer derives `version` from `ViteRuby.digest` |
| Dashboard empty or zeros | Seeds not applied, or a non-2023 range selected | `bin/rails db:seed:replant`, then reset the range to the default |
| `422` on form submit | Missing XSRF token | Confirm the Rails CSRF cookie is present and the Inertia client sends `X-XSRF-TOKEN` |
| Charts render without context | Chart a11y summary missing | Check the hidden data table for that panel (FR-044) |

