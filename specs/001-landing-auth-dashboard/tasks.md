# Tasks: Landing, Authentication & Analytics Dashboard

**Input**: Design documents from `/specs/001-landing-auth-dashboard/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/), [quickstart.md](./quickstart.md)

**Tests**: INCLUDED AND MANDATORY. Constitution Principle III (Test-First, NON-NEGOTIABLE) requires
tests to land with each change, so every user story phase opens with failing tests.

**Organization**: Tasks are grouped by user story so each story is independently implementable and
testable.

## Implementation Notes (deviations from the plan)

1. **Vite source directory is `app/javascript`, not `app/frontend`.** The installed `vite_rails` 3.11.1
   generator writes `sourceCodeDir: app/javascript` (with `@/*` already aliased there), so every
   `app/frontend/...` path in the tasks below maps to `app/javascript/...` in the implementation.
   Keeping the toolchain default avoided reconfiguring Vite and the shadcn aliases.
2. **shadcn CLI bypassed.** `npx shadcn init` requires an interactive template prompt and could not run
   non-interactively, so `components.json`, `lib/utils.ts`, and the 14 primitives the UI actually uses
   were written deterministically instead of fetched from the registry. `sonner`, `calendar`, `command`,
   `popover`, `field`, `select`, and `sidebar` were not needed.
3. **Ten non-dashboard destinations, not nine.** Spec FR-019 lists Payment, Customers, Message, Product,
   Invoice, Analytics, Automation, Settings, Security, and Help. The earlier research/plan wording said
   "nine"; the implementation and its test follow the spec (10).
4. **`gem "csv"` added.** CSV is a bundled gem in Ruby 3.4 and is no longer loadable without an explicit
   dependency.
5. **Landing sections composed inline** in `pages/home.tsx` rather than as separate files under
   `components/marketing/`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US4)
- Every task names an exact file path

## Path Conventions

Single Rails project at the repository root (per plan.md): application code in `app/`, queries in
`app/queries/dashboard/`, services in `app/services/`, React pages in `app/frontend/`, tests in `test/`,
seed constants in `lib/`.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Convert the starter's front-end pipeline to Vite + React + TypeScript + Tailwind + shadcn
(plan Phase A). Until this completes, no page can render.

- [X] T001 Run `bin/rails generate inertia:install --framework=react --typescript --vite --tailwind --no-interactive --skip-example-page` and inspect generated output in `Gemfile`, `app/frontend/`, `bin/dev`, `Procfile.dev`
- [X] T002 Install and pin frontend dependencies in `package.json`: `@inertiajs/react` 3.9.1, `@inertiajs/vite` 3.9.1, `react`/`react-dom` 19.3.1, Vite 8.3.5, `@vitejs/plugin-react`, TypeScript 5.x, `tailwindcss` 4.3.3, `@tailwindcss/vite`, `@tailwindcss/forms`, `@tailwindcss/typography`, `recharts` 3.8.0, `@fontsource-variable/inter` 5.3.0, `lucide-react` 1.62.0
- [X] T003 [P] Configure TypeScript path aliases `@/*` → `./app/frontend/*` in `tsconfig.json` and `tsconfig.app.json` (required before the shadcn CLI can resolve imports)
- [X] T004 [P] Configure `vite.config.ts` with the React and Tailwind plugins and `sourceCodeDir: app/frontend`
- [X] T005 Initialize shadcn/ui with New York style, neutral base color, and CSS variables in `components.json`
- [ ] T006 Add shadcn registry components to `app/frontend/components/ui/`: `button`, `card`, `input`, `label`, `field`, `select`, `dropdown-menu`, `checkbox`, `table`, `badge`, `avatar`, `tooltip`, `separator`, `sheet`, `sidebar`, `skeleton`, `sonner`, `chart`, `progress`, `toggle-group`, `popover`, `calendar`, `command`
- [X] T007 [P] Define design tokens and Inter in `app/frontend/entrypoints/application.css`: `@theme` block with `--font-sans: "Inter Variable", ui-sans-serif, system-ui, sans-serif`, `--font-heading: var(--font-sans)`, soft grey canvas, white cards, indigo/violet primary, teal positive, rose negative
- [X] T008 Remove `importmap-rails`, `turbo-rails`, and `stimulus-rails` from `Gemfile`; delete `app/javascript/` and `config/importmap.rb`
- [X] T009 Clean `app/views/layouts/application.html.erb` to a single root element plus Vite tags, removing importmap/Turbo tags, and drop `stale_when_importmap_changes` from `app/controllers/application_controller.rb`
- [X] T010 Replace the `bin/importmap audit` step with `npm audit --audit-level=high` in **both** `config/ci.rb` and `.github/workflows/ci.yml` in the same commit (Constitution Principle IV parity requirement)
- [X] T011 [P] Write `config/initializers/inertia_rails.rb`: `version = ViteRuby.digest`, `use_script_element_for_initial_page`, `use_data_inertia_head_attribute`, `always_include_errors_hash`, `encrypt_history`, `server_head`, SSR disabled
- [X] T012 Smoke-verify the toolchain: `bin/dev` boots both processes, `GET /up` returns 200, a placeholder Inertia page renders, and `grep -r importmap app/ config/` returns nothing

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Schema, models, the authentication gate, shared Inertia plumbing, and the test harness that
every story depends on.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

### Schema and models

- [X] T013 [P] Create workspaces migration in `db/migrate/*_create_workspaces.rb`: `name` string `null: false` unique index ("Marketing"); `plan` string `null: false, default: "Team"`; `currency` string(3) `null: false, default: "USD"`
- [X] T014 [P] Create users profile migration in `db/migrate/*_add_profile_fields_to_users.rb`: `name` string `null: false` (max 80), `role` string `null: false, default: "Business"` (max 40), `workspace_id` bigint `null: false` FK with index; unique index on `email_address` (max 254)
- [X] T015 [P] Create sessions expiry migration in `db/migrate/*_add_last_active_at_to_sessions.rb`: `last_active_at` datetime `null: false` with index; cookie lifetime 30 days
- [X] T016 [P] Create daily_metrics migration in `db/migrate/*_create_daily_metrics.rb`: `page_views` integer `null: false, default: 0, >= 0`, `sessions_count` integer `>= 0`, `bounced_sessions` integer `0..sessions_count`, `revenue_cents` bigint `>= 0`; unique `(workspace_id, recorded_on)`
- [X] T017 [P] Create sales_records migration in `db/migrate/*_create_sales_records.rb`: `region` string `null: false` inclusion in `china eu usa canada other`, `amount_cents` bigint `>= 0`; indexes `(workspace_id, recorded_on)` and `(workspace_id, region, recorded_on)`
- [X] T018 [P] Create subscriber_snapshots migration in `db/migrate/*_create_subscriber_snapshots.rb`: `count` integer `null: false, >= 0`; unique `(workspace_id, recorded_on)`
- [X] T019 [P] Create channel_revenues migration in `db/migrate/*_create_channel_revenues.rb`: `channel` string `null: false` inclusion in `website mobile_app other`, `amount_cents` bigint `>= 0`; unique `(workspace_id, recorded_on, channel)`
- [X] T020 [P] Create integrations migration in `db/migrate/*_create_integrations.rb`: `name` string `null: false` (unique per workspace), `category` string `null: false`, `rate` integer `null: false, 0..100`, `profit_cents` bigint `>= 0`, `position` integer `>= 0`; indexes unique `(workspace_id, name)` and `(workspace_id, position)`
- [X] T021 [P] Create messages migration in `db/migrate/*_create_messages.rb`: `read_at` datetime nullable, index `(workspace_id, read_at)`
- [X] T022 Run `bin/rails db:migrate` and verify `db/schema.rb` carries the check constraints, unique indexes, and `on_delete: :cascade` foreign keys from [data-model.md](./data-model.md)
- [X] T023 [P] Implement `app/models/workspace.rb` (presence/uniqueness of `name`, `currency` inclusion in `%w[USD]`) and `app/models/current.rb` (`ActiveSupport::CurrentAttributes` for `session` and `user`)
- [X] T024 [P] Implement `app/models/user.rb`: `normalizes :email_address`, `has_secure_password`, `belongs_to :workspace`, `has_many :sessions, dependent: :destroy`; validations — `name` presence max 80, `email_address` presence/format/uniqueness (case-insensitive) max 254, `password` minimum 8 when present, `role` presence max 40
- [X] T025 [P] Implement fact models `app/models/daily_metric.rb`, `app/models/sales_record.rb`, `app/models/subscriber_snapshot.rb`, `app/models/channel_revenue.rb` with `belongs_to :workspace` and inclusion/numericality validations matching the check constraints
- [X] T026 [P] Implement `app/models/integration.rb` (ordered by `position`, `rate` in `0..100`, name unique within workspace) and `app/models/message.rb` (`unread` scope on `read_at: nil`, `unread_count` class helper)

### Authentication gate (Constitution Principle IV)

- [X] T027 Run `bin/rails generate authentication`; keep `User`, `Session`, `Current`, `Authentication`, and `SessionsController`; delete the generated passwords controller, `PasswordsMailer`, mailer views, and `resources :passwords` from `config/routes.rb` (password reset is out of scope)
- [X] T028 Wire session lifecycle in `app/models/session.rb` and `app/controllers/concerns/authentication.rb`: set `last_active_at` on create, touch on resume, destroy sessions older than 30 days and clear the cookie, keep `terminate_session` safe when `Current.session` is `nil`

### Shared Inertia plumbing

- [X] T029 [P] Add shared props in `app/controllers/application_controller.rb`: `auth.user` (`id`, `name`, `role`, `email_address`), `auth.workspace` (`id`, `name`, `plan`, `currency`), `flash.notice`, `flash.alert`, `errors`
- [X] T030 [P] Build the Inertia entrypoint and base layouts in `app/frontend/entrypoints/inertia.tsx` and `app/frontend/layouts/` (`marketing-layout.tsx`, `auth-layout.tsx`, `dashboard-layout.tsx`)
- [X] T031 [P] Implement `app/frontend/lib/format.ts`: cents to USD via `Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' })`, basis points to one-decimal percent, integer grouping, ISO date to `"Oct 18"` label
- [X] T032 [P] Write `app/frontend/lib/types.ts` mirroring the prop interfaces in [contracts/pages.md](./contracts/pages.md) and [contracts/dashboard.md](./contracts/dashboard.md) exactly, using snake_case keys

### Test harness

- [X] T033 Require `inertia_rails/minitest` in `test/test_helper.rb` so `assert_inertia_component` and prop assertions are available in integration tests
- [X] T034 [P] Create `test/support/dashboard_data.rb` with plain ActiveRecord helpers that build deterministic fact rows for aggregate assertions (research D13 — not production seeds)

**Checkpoint**: Foundation ready — user stories can now begin.

---

## Phase 3: User Story 1 - Explore a complete, data-backed analytics dashboard (Priority: P1) 🎯 MVP

**Goal**: A signed-in user opens `/dashboard` and sees the reference composition — sidebar, top bar, three
KPI cards, stacked sales chart, subscriber chart, distribution donut, integrations table — with every
figure computed from stored records and responsive to period, granularity, filter, and search changes.

**Independent Test**: Seed rows via `test/support/dashboard_data.rb`, sign in through the foundational auth
gate, load `/dashboard`, and assert each prop group matches the computed aggregates; then change the period
and confirm the label and dependent values change.

### Tests for User Story 1 (write first, confirm they fail)

- [X] T035 [P] [US1] Period parsing tests in `test/queries/dashboard/period_test.rb`: defaults `2023-10-18..2023-11-18`, invalid or reversed input falls back to defaults, ranges over 366 days rejected, unknown granularity → `monthly`, comparison length equals period length and ends the day before `start_date`
- [X] T036 [P] [US1] Filter tests in `test/queries/dashboard/filters_test.rb`: unknown region/channel values ignored, empty selection means all, labels render `UE` for `eu` and `Mobile App` for `mobile_app`
- [X] T037 [P] [US1] Metrics tests in `test/queries/dashboard/metrics_test.rb`: page views and revenue sums, weighted bounce rate (`SUM(bounced_sessions) / SUM(sessions_count)`), zero comparison base yields `null` delta, direction is `up`/`down`/`flat`
- [X] T038 [P] [US1] Sales overview tests in `test/queries/dashboard/sales_overview_test.rb`: bucket totals reconcile to `total`, missing region renders `0`, monthly vs ISO-week bucketing, delta amount and percentage agree
- [X] T039 [P] [US1] Subscriber tests in `test/queries/dashboard/subscribers_test.rb`: period total, comparison delta, last-seven-days series labeled Sun–Sat, peak equals max `count`, empty period yields `peak: null`
- [X] T040 [P] [US1] Distribution tests in `test/queries/dashboard/distribution_test.rb`: channel sums, shares sum to 100.0 ±0.1, labels `Website`/`Mobile App`/`Other`
- [X] T041 [P] [US1] Integrations tests in `test/queries/dashboard/integrations_test.rb`: ordered by `position`, `q` matches name or category case-insensitively, default limit 3 vs `all` returns every row, zero matches sets `empty: true`
- [X] T042 [P] [US1] Navigation tests in `test/queries/dashboard/navigation_test.rb`: three groups in order, Message badge from unread `messages` count, Automation `BETA` badge, ten out-of-scope entries flagged `disabled`, `dashboard` active with an `href`
- [X] T043 [P] [US1] Payload contract test in `test/queries/dashboard/payload_test.rb`: envelope keys match [contracts/dashboard.md](./contracts/dashboard.md) exactly, three KPIs in order, no `NaN`/`Infinity`/preformatted strings
- [X] T044 [P] [US1] Controller integration tests in `test/controllers/dashboard_controller_test.rb`: anonymous request redirects to `/session/new`, signed-in request asserts component `dashboard/index`, `Cache-Control: no-store`, and prop values equal the computed aggregates
- [X] T045 [P] [US1] Export tests in `test/controllers/dashboard_export_test.rb`: `text/csv` content type and filename, `Section,Metric,Label,Value` header, one row per bucket/region/channel/day, `ids[]` narrows integrations only, leading `=`,`+`,`-`,`@` values are prefixed with `'`, anonymous request gets no CSV body

### Implementation for User Story 1

- [X] T046 [US1] Implement `app/queries/dashboard/period.rb` (`range`, `comparison_range`, `bucket` `:month`/`:week`, labels, 366-day cap)
- [X] T047 [US1] Implement `app/queries/dashboard/filters.rb` (validated regions/channels, option lists, active state, chip labels)
- [X] T048 [US1] Implement `app/queries/dashboard/metrics.rb` (three KPIs with deltas from `daily_metrics`)
- [X] T049 [US1] Implement `app/queries/dashboard/sales_overview.rb` (bucketed region series and growth from `sales_records`)
- [X] T050 [US1] Implement `app/queries/dashboard/subscribers.rb` (total, delta, seven-day series, peak from `subscriber_snapshots`)
- [X] T051 [US1] Implement `app/queries/dashboard/distribution.rb` (channel sums and shares from `channel_revenues`)
- [X] T052 [US1] Implement `app/queries/dashboard/integrations.rb` (ordering, search, limit/`all`, counts)
- [X] T053 [US1] Implement `app/queries/dashboard/navigation.rb` (single navigation definition backing all sidebar items, badges, disabled flags)
- [X] T054 [US1] Implement `app/queries/dashboard/payload.rb` assembling every prop group from the query objects (single entry point shared by index and export)
- [X] T055 [US1] Implement `app/services/dashboard/export_csv.rb` producing the `Section,Metric,Label,Value` rows with RFC 4180 quoting and the formula-injection prefix
- [X] T056 [US1] Add routes and `app/controllers/dashboard_controller.rb` with `index` (authorize → `Dashboard::Payload` → render) and `export` (authorize → `Dashboard::ExportCsv` → `send_data` with `no-store`)
- [X] T057 [US1] Compose the dashboard page in `app/frontend/pages/dashboard/index.tsx` and `app/frontend/layouts/dashboard-layout.tsx` (sidebar + top bar + content grid)
- [X] T058 [P] [US1] Implement `app/frontend/components/dashboard/app-sidebar.tsx`: General/Tools/Support groups, active state, Message count and Automation BETA badges from props, workspace switcher "Marketing / Team", Upgrade Plan action, copyright, ten entries rendered `aria-disabled` with the "Preview — not included in this template" tooltip
- [X] T059 [P] [US1] Implement `app/frontend/components/dashboard/top-bar.tsx`: search field with ⌘+F hint, gift/notification/create controls, profile menu showing name and role
- [X] T060 [US1] Implement `app/frontend/components/dashboard/dashboard-header.tsx`: "Dashboard" title, inclusive range label, Monthly/Weekly toggle, Filter and Export actions
- [X] T061 [US1] Implement `app/frontend/components/dashboard/kpi-cards.tsx` rendering Page Views, Total Revenue, and Bounce Rate with direction and percentage deltas (teal up, rose down, neutral flat)
- [X] T062 [P] [US1] Implement `app/frontend/components/dashboard/sales-overview-chart.tsx` with stacked regional bars, legend, per-bucket totals, headline total, and growth delta
- [X] T063 [P] [US1] Implement `app/frontend/components/dashboard/subscribers-chart.tsx` with the Sun–Sat bars and visually emphasized peak day
- [X] T064 [P] [US1] Implement `app/frontend/components/dashboard/distribution-chart.tsx` with the donut plus the Website/Mobile App/Other legend and amounts
- [X] T065 [US1] Implement `app/frontend/components/dashboard/integrations-table.tsx` with row checkboxes, Application/Type/Rate/Profit columns, proportional rate indicator, and "See All"
- [X] T066 [US1] Implement `app/frontend/components/dashboard/dashboard-filters.tsx` popover for region and channel with active chips and a clear action
- [X] T067 [US1] Wire Inertia visits in `app/frontend/pages/dashboard/index.tsx`: partial reloads with `only: [...]`, `preserveState`/`preserveScroll`, and a 250 ms debounced server-side search
- [ ] T068 [US1] Add empty, partial, and loading states in `app/frontend/components/dashboard/panel-states.tsx` (skeleton panel, empty-state block, retry action) and apply it in `app/frontend/components/dashboard/kpi-cards.tsx`, `sales-overview-chart.tsx`, `subscribers-chart.tsx`, `distribution-chart.tsx`, and `integrations-table.tsx` per FR-037 and FR-038

**Checkpoint**: User Story 1 is fully functional and testable on its own.

---

## Phase 4: User Story 2 - Create an account and sign in securely (Priority: P1)

**Goal**: A visitor creates an account with name, email, and password, signs in, stays signed in across
browser restarts, signs out from anywhere, and never sees protected content while anonymous.

**Independent Test**: From a clean session, submit the public sign-up form, land in the dashboard, sign out,
sign back in with the same credentials, and confirm a protected URL redirects to sign-in and returns to the
originally requested page.

> **Note**: the sign-in *mechanism* (generated `SessionsController`, `Session` model, and auth guard) is
> foundational (T027–T028) because US1 cannot be reached without it. This phase adds self-service
> registration, the styled Inertia auth pages, expiry, rate limiting, and sign-out.

### Tests for User Story 2 (write first, confirm they fail)

- [X] T069 [P] [US2] User validation tests in `test/models/user_test.rb`: email normalization (strip/downcase), case-insensitive uniqueness, password minimum 8 characters, name max 80, role max 40, duplicate email rejected
- [X] T070 [P] [US2] Session lifecycle tests in `test/models/session_test.rb`: `last_active_at` set on create, resume touches it, rows older than 30 days are destroyed on resume, `terminate_session` tolerates a nil session
- [X] T071 [P] [US2] Registration integration tests in `test/controllers/registrations_controller_test.rb`: valid sign-up creates the user in the demo workspace and starts a session; duplicate email, short password, and mismatched confirmation each return field-scoped errors with no account created
- [X] T072 [P] [US2] Session integration tests in `test/controllers/sessions_controller_test.rb`: wrong credentials yield only `errors.base` = "Try another email address or password.", rate limit yields "Too many attempts. Try again later.", deep-link return restores the stored URL, sign-out is idempotent, signed-in users are redirected away from the auth pages

### Implementation for User Story 2

- [X] T073 [US2] Implement `app/controllers/registrations_controller.rb` (`new`/`create`, strong params for `name`, `email_address`, `password`, `password_confirmation`, assign the demo workspace, start a session on success) and add the routes to `config/routes.rb`
- [X] T074 [US2] Build `app/frontend/pages/registrations/new.tsx` and `app/frontend/components/auth/registration-form.tsx` rendering field-scoped `errors` with Inertia form state preservation
- [X] T075 [US2] Replace the generated ERB sign-in view with `app/frontend/pages/sessions/new.tsx` (+ `app/frontend/components/auth/sign-in-form.tsx`), render `errors.base`, and delete `app/views/sessions/new.html.erb`
- [X] T076 [US2] Configure rate limiting: keep 10 attempts / 3 minutes on sign-in and add a comparable limit to registration in `app/controllers/sessions_controller.rb` and `app/controllers/registrations_controller.rb`
- [X] T077 [US2] Add the sign-out action to the profile menu in `app/frontend/components/dashboard/top-bar.tsx`, posting `DELETE /session` and redirecting to `/session/new`

**Checkpoint**: User Story 2 is independently functional; US1 and US2 now integrate without rework.

---

## Phase 5: User Story 3 - Understand the product from a public landing page (Priority: P2)

**Goal**: An anonymous visitor sees a marketing page explaining the product with a dashboard preview,
clear CTAs, proof, and a footer; signed-in visitors get a direct dashboard entry instead of auth prompts.

**Independent Test**: Open `/` signed out, review every section and CTA, follow the primary CTA to sign-up
and the secondary to sign-in, then repeat while signed in to confirm the signed-in variant.

### Tests for User Story 3 (write first, confirm they fail)

- [X] T078 [P] [US3] Landing integration tests in `test/controllers/pages_controller_test.rb`: anonymous request asserts component `home` with `marketing.signed_in: false` and sign-in/sign-up CTAs; signed-in request asserts `signed_in: true` with the dashboard CTA; page body contains no workspace analytics values (SC-007)

### Implementation for User Story 3

- [X] T079 [US3] Implement `app/controllers/pages_controller.rb#home` with `allow_unauthenticated_access` and mount the root route in `config/routes.rb`
- [X] T080 [US3] Add server-side marketing copy to `lib/marketing_content.rb` (three-plus value props, proof metrics, footer links with `available` flags) and expose it through the page props
- [X] T081 [US3] Compose `app/frontend/pages/home.tsx` on `app/frontend/layouts/marketing-layout.tsx`
- [X] T082 [P] [US3] Build the marketing sections in `app/frontend/components/marketing/`: brand header, hero with both CTAs, value props, dashboard preview panel, proof metrics, closing CTA, footer
- [X] T083 [US3] Wire the CTA variants in `app/frontend/components/marketing/cta-section.tsx` — "Start for free"/"Sign in" when anonymous, "Open dashboard" when signed in

**Checkpoint**: User Story 3 is independently functional; all three pages now render.

---

## Phase 6: User Story 4 - Start from realistic demo data (Priority: P3)

**Goal**: One documented setup step yields a demo workspace, demo user, and months of analytics records;
re-running it never duplicates or corrupts data; the credentials are discoverable where a first-time user
needs them.

**Independent Test**: On an empty database run the documented setup, confirm the demo account signs in and
the default period shows the seeded figures, then run the setup again and confirm record counts are
unchanged.

### Tests for User Story 4 (write first, confirm they fail)

- [X] T084 [P] [US4] Seed idempotency tests in `test/db/seeds_test.rb`: run `db/seeds.rb` twice and assert row counts per table are identical, the demo user is unique by `email_address`, and `RAILS_ENV=test bin/rails db:seed:replant` exits cleanly

### Implementation for User Story 4

- [X] T085 [P] [US4] Create `lib/demo_data.rb` holding the single source of demo constants: workspace "Marketing"/"Team"/USD, demo user `demo@nexus.io` with password, date anchors `2023-09-01`–`2023-12-31`, default period `2023-10-18`–`2023-11-18`
- [X] T086 [US4] Implement idempotent `db/seeds.rb` using `find_or_create_by!`/upsert keyed on natural keys for all nine tables, hitting the data-model targets: page views 12,450; revenue 36,395 cents; weighted bounce 86.5%; October 298,820 / November 176,509 / December 400,565 cents; subscribers 24,473 with a +749 comparison and 3,874 peak; channels 37,482 / 24,160 / 21,342 cents; 3 reference integrations plus 3 extra; 8 unread messages
- [X] T087 [US4] Expose the demo credentials prop on the sign-in page in `app/controllers/sessions_controller.rb` and `app/frontend/pages/sessions/new.tsx`, gated by the presence of the demo user and `ENV["SHOW_DEMO_CREDENTIALS"] != "false"`, with a demonstration-only note
- [X] T088 [US4] Verify seeds against [data-model.md](./data-model.md) targets and quickstart V20, then reconcile the default-period aggregates with T037–T043 expectations

**Checkpoint**: All four user stories are independently functional.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Qualities that span every page and cannot be owned by a single story.

- [ ] T089 [P] Responsive pass across `app/frontend/` at 360, 768, 1024, 1440, and 1920 px: no horizontal scroll, cards stack in reading order, sidebar becomes a drawer below 1024 px, no clipped primary actions (FR-042, SC-008)
- [ ] T090 [P] Keyboard and focus pass on `app/frontend/layouts/dashboard-layout.tsx`, `app/frontend/layouts/marketing-layout.tsx`, `app/frontend/layouts/auth-layout.tsx`, `app/frontend/components/dashboard/app-sidebar.tsx`, and the two auth forms: visible focus rings, logical tab order, drawer opens by keyboard and closes on Escape without trapping focus, collapsed sidebar restorable (FR-043, SC-009)
- [ ] T091 [P] Accessibility verification across `app/frontend/pages/**` and `app/frontend/components/dashboard/*`: automated axe scan with zero critical findings, accessible names on every control, `aria-live` announcements for search result counts in `app/frontend/components/dashboard/integrations-table.tsx`, and visually hidden data tables in `sales-overview-chart.tsx`, `subscribers-chart.tsx`, and `distribution-chart.tsx` (FR-044, SC-010)
- [ ] T092 System journey test in `test/system/dashboard_journey_test.rb`: sign in → dashboard → change filter → sign out, exercised with `bin/rails test:system`
- [ ] T093 Visual parity review at a 1440 px viewport against the reference composition (layout regions, typography, spacing, color treatment), recording any accepted deviations in [plan.md](./plan.md) (SC-006)
- [X] T094 Honour `prefers-reduced-motion` for chart and drawer animation in `app/frontend/entrypoints/application.css` and the chart components (FR-046)
- [X] T095 Run `bin/ci` end to end and confirm every gate passes, including the `npm audit --audit-level=high` step now present in both `config/ci.rb` and `.github/workflows/ci.yml` (Constitution Principle IV)
- [X] T096 Replace the placeholder `README.md` with real setup, test, demo-credential, and deployment instructions (Constitution "Development Workflow" obligation)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup — **BLOCKS all user stories**
- **User Story 1 (Phase 3)**: After Foundational
- **User Story 2 (Phase 4)**: After Foundational; integrates with US1's sidebar/profile menu but does not block it
- **User Story 3 (Phase 5)**: After Foundational; signed-in variant needs US2's session flow to be meaningful
- **User Story 4 (Phase 6)**: After Foundational; independent of US1–US3 code but needed for any manual demo walkthrough
- **Polish (Phase 7)**: After all desired stories

### User Story Dependencies

| Story | Priority | Depends on | Independence note |
|-------|----------|-----------|-------------------|
| US1 Dashboard | P1 | Foundational only | Verified with `test/support/dashboard_data.rb` rows, so it does not need US4 seeds |
| US2 Authentication | P1 | Foundational only | Registration/expiry/rate limits are self-contained; lands after US1 to avoid reworking shared components |
| US3 Landing page | P2 | Foundational; soft US2 | Anonymous variant is fully independent; the signed-in CTA variant needs a session |
| US4 Demo data | P3 | Foundational (schema) | Code-independent, but required before the documented demo-account walkthrough and quickstart V4/V9 |

### Within Each User Story

- Tests first — they MUST fail before implementation (Principle III)
- Query objects before `Payload`; `Payload` before controller; controller before page components
- Shared components before page composition
- Story complete and green before moving to the next priority

### Parallel Opportunities

- **Phase 1**: T003, T004, T007, T011 are independent files
- **Phase 2**: all nine migrations (T013–T021) and the model files (T023–T026) touch different files; T029–T032 and T034 are independent
- **Phase 3**: all eleven test tasks (T035–T045) can be written in parallel; the four chart/table components (T062–T064) and sidebar/top bar (T058–T059) are separate files
- **Phases 4–6**: once Foundational is done, US2, US3, and US4 can proceed concurrently with US1 if staffed
- **Phase 7**: T089, T090, T091 touch different concerns and can run together

---

## Parallel Example: User Story 1

```bash
# Write the query-object test suite first (all independent files):
Task: "Period parsing tests in test/queries/dashboard/period_test.rb"
Task: "Metrics tests in test/queries/dashboard/metrics_test.rb"
Task: "Sales overview tests in test/queries/dashboard/sales_overview_test.rb"
Task: "Payload contract test in test/queries/dashboard/payload_test.rb"

# Then build the independent panel components side by side:
Task: "Sales overview chart in app/frontend/components/dashboard/sales-overview-chart.tsx"
Task: "Subscribers chart in app/frontend/components/dashboard/subscribers-chart.tsx"
Task: "Distribution donut in app/frontend/components/dashboard/distribution-chart.tsx"
```

---

## Implementation Strategy

### MVP First (Setup + Foundational + US1)

1. Complete Phase 1 (toolchain) and Phase 2 (schema, auth gate, shared props) — non-negotiable blockers
2. Complete Phase 3 (US1 dashboard)
3. **STOP and VALIDATE**: run the T035–T045 suite; sign in with a user created via `bin/rails runner` (registration arrives in Phase 4, seeds in Phase 6) and confirm the dashboard renders computed values
4. This is the smallest demoable increment: a working, data-backed analytics page

### Incremental Delivery

1. Setup + Foundational → foundation ready, `bin/ci` green
2. US1 → dashboard demoable (MVP)
3. US2 → real visitors can self-serve sign-up
4. US3 → public entry point completes the three-page template
5. US4 → the documented one-command demo experience
6. Phase 7 → responsive, accessible, visually reviewed, documented

### Suggested Sequencing Note

US2 is P1 but deliberately lands after US1. US1's verification uses the foundational auth gate, so nothing
is blocked; doing the dashboard first avoids rewriting sidebar and profile-menu components once US2
introduces the styled auth pages and sign-out control.

---

## Notes

- `[P]` marks different files with no incomplete dependencies — not permission to skip a test
- Every task names its file path so it is executable without further context
- Tests are mandatory here (Constitution Principle III); a task is not done until its tests pass
- Commit after each task or coherent group; never commit a red `bin/ci`
- Constraints quoted in T013–T021 come verbatim from [data-model.md](./data-model.md); do not relax them at implementation time
- FR/SC references map to [spec.md](./spec.md); validation steps map to [quickstart.md](./quickstart.md)
