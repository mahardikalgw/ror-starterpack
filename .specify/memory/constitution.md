<!--
Sync Impact Report
==================
Version change: none (unratified blank template) -> 1.0.0
Bump rationale: Initial ratification. The file previously contained only template placeholders
([PROJECT_NAME], [PRINCIPLE_1_NAME], [CONSTITUTION_VERSION]) and therefore carried no governance
obligations; 1.0.0 is the first ratified baseline rather than a MAJOR change from governed content.

Modified principles:
- [PRINCIPLE_1_NAME] -> I. Inertia Monolith, Server-Driven UI
- [PRINCIPLE_2_NAME] -> II. Skinny Controllers, Explicit Boundaries
- [PRINCIPLE_3_NAME] -> III. Test-First Is Mandatory (NON-NEGOTIABLE)
- [PRINCIPLE_4_NAME] -> IV. Security and Quality Gates Block Merge
- [PRINCIPLE_5_NAME] -> V. Simplicity Before Abstraction

Added sections:
- Core Principles (five normative principles replace the placeholder slots)
- Technology and Data Standards (was [SECTION_2_NAME] / [SECTION_2_CONTENT])
- Development Workflow and Quality Gates (was [SECTION_3_NAME] / [SECTION_3_CONTENT])
- Governance (was [GOVERNANCE_RULES])

Removed sections: none (no sections existed beyond template placeholders)

Deferred TODOs: none
-->

# ROR Starterpack Constitution

## Core Principles

### I. Inertia Monolith, Server-Driven UI

Every user-facing feature MUST be delivered as a page inside this single Rails application. Controllers
MUST respond with Inertia renders and MUST supply all page data as server-provided props. The
application MUST NOT introduce a separate JSON API, and pages MUST NOT fetch their primary content
from the client after load.

- Route contracts are HTTP routes paired with an Inertia component; both are documented before
  implementation.
- Props MUST be derived on the server from Active Record models, query objects, or service objects.
- Client-side state is presentation only: optimistic UI, open dialogs, and filter drafts. It MUST NOT
  become a second source of truth for business records.
- Server-side rendering is opt-in only when a requirement names it; it MUST NOT be adopted for
  deployment convenience or perceived polish.

**Rationale**: The repository ships `inertia_rails` and documents this pattern in `llms-full.txt`. One
request path, one validation surface, and one authorization boundary keep a starter template auditable.

### II. Skinny Controllers, Explicit Boundaries

Controllers MUST limit themselves to authentication and authorization checks, strong-parameter
filtering, a single domain call, and a render or redirect. Business rules MUST live in models, service
objects, or query objects.

- ActiveRecord queries MUST NOT appear in controllers, helpers, or Inertia prop blocks, except a single
  scoped lookup that the controller then hands to a domain object.
- Any controller action longer than roughly ten lines MUST be extracted before merge.
- A new top-level directory under `app/` MUST correspond to the documented directory contract
  (`models`, `controllers`, `views`, `services`, `queries`, `jobs`, `mailers`, `helpers`). Catch-all
  directories such as `app/utils` or `app/managers` MUST NOT be created.
- Code shared across features MUST be promoted deliberately, with its second consumer identified.

**Rationale**: Thin HTTP layers are the only reliable way to test domain behavior without booting a
request cycle, and the directory contract keeps navigation predictable for new contributors and agents.

### III. Test-First Is Mandatory (NON-NEGOTIABLE)

No change is complete until tests prove it works. Tests MUST be authored or updated before a task is
marked done, and `bin/rails test` MUST pass.

- Every new route MUST have an integration test asserting its happy path and its authentication
  behavior, including anonymous access where the route is protected.
- Every multi-step domain operation (sign-up, sign-in, export, aggregation) MUST have a unit or service
  test covering its failure branches.
- The primary end-to-end journey MUST have a system test (Capybara) exercised via `bin/rails test:system`.
- Inertia responses MUST be asserted with the `inertia_rails/minitest` helpers rather than by parsing
  raw HTML.
- Seed data MUST load cleanly in the test environment; `RAILS_ENV=test bin/rails db:seed:replant` MUST
  stay green.
- Writing an implementation before its test is permitted only when the test lands in the same commit.
  Deferring tests to a later task or PR is prohibited.

**Rationale**: A template's tests are its documentation and its regression fence. Untested scaffolding is
the most expensive artifact to hand to the next person.

### IV. Security and Quality Gates Block Merge

All gates in `config/ci.rb` (run via `bin/ci`) MUST pass before merge. Removing, weakening, or skipping a
gate requires an explicit constitution amendment.

- Required gates: `bin/rubocop`, `bin/bundler-audit`, `bin/brakeman --exit-on-warn --exit-on-error`,
  a JavaScript dependency audit once npm dependencies exist, `bin/rails test`, and the seeds step.
- Authentication MUST use the Rails-generated session-backed `Authentication` concern. Every controller
  action reachable without a session MUST opt out explicitly via `allow_unauthenticated_access`.
- Strong parameters MUST be used for every write. Mass assignment from raw `params` is prohibited.
- SQL MUST be built with binds or ActiveRecord query methods; string interpolation into SQL is
  prohibited.
- Credentials and secrets MUST NOT be committed. Demo credentials shown in the UI MUST be labeled as
  demonstration-only.
- Brakeman warnings MUST be fixed, not suppressed, unless the suppression carries an inline justification
  comment.

**Rationale**: The template already automates these checks; treating them as advisory would let a starter
template ship known-vulnerable examples that downstream projects inherit.

### V. Simplicity Before Abstraction

Every added dependency, abstraction layer, and cache MUST be justified by a stated requirement.

- A dependency MUST NOT be added when the standard library, Rails, or an already-installed gem solves the
  problem.
- Caching (prop caching, HTTP caching, fragment caching) MUST NOT be introduced before a measured need.
  When introduced, invalidation MUST be documented next to the cache.
- An abstraction MUST NOT be created for a single caller.
- A feature MUST NOT be built when the specification lists it as out of scope, even if it is cheap.
- Placeholder navigation, disabled controls, and preview markers MUST be visibly non-interactive rather
  than silently broken.

**Rationale**: This repository is a reusable starting point. Unused generality is inherited by every
project created from it, which makes restraint a correctness property, not a style preference.

## Technology and Data Standards

**Runtime baseline** (verified in this repository): Ruby 3.4.7 (`.ruby-version`), Rails 8.1.4, SQLite via
`sqlite3 >= 2.1`, Propshaft, Puma with Thruster, the Solid stack (Solid Cache, Solid Queue, Solid Cable),
and Kamal for deployment. These versions MUST be changed only through a plan that records the migration
path and its test impact.

**Frontend stack**: Inertia with React 19 and TypeScript, built by Vite, styled with Tailwind CSS v4 and
shadcn/ui (New York style, neutral base, CSS variables), with components added through the registry rather
than hand-rolled. Exactly one JavaScript pipeline MUST exist; the legacy importmap, Turbo, and Stimulus
layers MUST be removed when Vite is introduced, together with their layout tags and the importmap audit
step.

**Data standards**:

- Monetary values MUST be stored as integer minor units (`*_cents`, `bigint`) and MUST NOT use floats.
  Formatting happens in the presentation layer only.
- Percentages and rates MUST be stored as integer basis points (0-10,000).
- Reporting facts MUST use `date` columns and ISO `YYYY-MM-DD` values, with no timezone conversion
  applied to reporting dates.
- Every analytics record MUST be scoped by `workspace_id`; access MUST go through the current workspace
  rather than a global query.
- Foreign keys MUST declare an explicit `on_delete` behavior; cascades are required for workspace-scoped
  records.
- Seed data MUST be deterministic and idempotent so that repeated runs and the default view stay stable.

**Product scope defaults**: Light theme only, desktop-first at 1440px, English copy, US dollars, and no
localization, dark mode, or email delivery unless a specification explicitly adds them.

## Development Workflow and Quality Gates

Feature work MUST follow the Spec Kit sequence, and no phase may be skipped:

1. `/speckit-specify` produces or updates `spec.md` with prioritized, independently testable user stories.
2. `/speckit-plan` passes the Constitution Check gate and records any justified complexity in the
   Complexity Tracking table.
3. `/speckit-tasks` produces a dependency-ordered `tasks.md`.
4. `/speckit-analyze` reports CRITICAL issue count zero across spec, plan, and tasks. Implementation MUST
   NOT begin while a CRITICAL finding is open.
5. `/speckit-implement` executes tasks in order.

Additional workflow obligations:

- `bin/ci` and `.github/workflows/ci.yml` MUST remain in agreement; a gate added to one MUST be added to
  the other in the same change.
- A pull request MUST state which principles it touches and how each was satisfied.
- Documentation that describes setup, tests, or deployment MUST be updated in the same change that alters
  them; `README.md` MUST NOT be left in its generated placeholder state.
- Runtime implementation guidance lives in `llms-full.txt` and `.agents/skills/rails-patterns`; where those
  documents conflict with this constitution, this constitution prevails.

## Governance

**Supremacy**: This constitution supersedes ad-hoc convention, inherited defaults, and generated
scaffolding. Where a template, skill, or tool default conflicts with a principle here, the principle wins
and the conflict MUST be surfaced rather than silently absorbed.

**Amendment procedure**: An amendment requires a pull request that (a) edits this file, (b) carries a Sync
Impact Report describing the version change and its rationale, and (c) updates any affected artifact
(`plan.md`, `tasks.md`, `README.md`) in the same change. Amendments MUST NOT be bundled into feature
implementation commits.

**Versioning policy**: Semantic versioning applies to governance.

- MAJOR: a principle is removed, or its obligations are redefined such that existing compliant work is no
  longer compliant.
- MINOR: a principle or section is added, or existing guidance is materially expanded.
- PATCH: clarification, wording, or typo fixes with no change in obligation.

**Compliance review**: Compliance is verified at two gates, not one. `/speckit-plan` MUST run the
Constitution Check before research and re-check after design, and `/speckit-analyze` MUST treat any
unresolved principle conflict as CRITICAL. A principle that must be violated to ship is a signal to amend
the constitution in a separate change, never to dilute it inside a feature.

**Enforcement**: Gate failures in Principle IV block merge. Undeclared deferral of Principle III tests
blocks task completion. Both are reviewed as defects, not as process friction.

**Version**: 1.0.0 | **Ratified**: 2026-10-28 | **Last Amended**: 2026-10-28
