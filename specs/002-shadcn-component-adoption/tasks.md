# Tasks: Unified Component Library Adoption

**Input**: Design documents from `/specs/002-shadcn-component-adoption/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md),
[data-model.md](./data-model.md), [contracts/](./contracts/), [quickstart.md](./quickstart.md)

**Tests**: One automated check is REQUIRED by the spec itself (FR-012: "A repository check MUST fail when a
page or feature component introduces a raw interactive element"). TDD was not requested, and the existing 74-test
suite must pass **unmodified** as the FR-008 regression fence — so no test files are edited or added beyond the
check script and its baseline verification.

**Organization**: Tasks are grouped by user story so each story stays independently verifiable.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this belongs to (US1–US3)
- Every task names an exact file path

## Path Conventions

Single Rails + Inertia project at the repository root. This feature touches `app/javascript/`, one script in
`bin/`, and the two CI entry points. No server-side file changes.

## Verified Baseline (do not re-derive)

| Fact | Value |
|------|-------|
| Vendored primitives | 14, all imported |
| Hand-built interactive controls | 3 (`dashboard-header.tsx`, `top-bar.tsx`, `app-sidebar.tsx`) |
| Chart panels bypassing the chart container | 3 |
| Auth forms outside the field composition | 2 |
| Dashboard bundle | 478.52 kB (budget: ≤ ~520 kB) |
| Existing suite | 74 tests, 209 assertions, unmodified |

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Land the enforcement rule first, so every later phase is guarded by it (plan Phase A).

- [X] T001 Write `bin/check-ui-components` scanning `app/javascript/pages/**/*.tsx` and `app/javascript/components/**/*.tsx` (excluding `app/javascript/components/ui/**`) for `<button`, `<input`, `<select`, `<textarea` (INV-1), `focus-visible:ring` / `focus:ring-` (INV-2), and any `components/ui/` file with zero import sites (INV-3); print `path:line: message`, summary `check-ui-components: N components, 0 violations`, exit 0 clean / 1 on violations
- [X] T002 Make `bin/check-ui-components` executable and run it against the current tree to capture the baseline failure: it MUST report exactly the three known raw controls in `app/javascript/components/dashboard/dashboard-header.tsx`, `top-bar.tsx`, and `app-sidebar.tsx`, and exit 1
- [X] T003 Add the gate to `config/ci.rb` as `step "Style: UI components", "bin/check-ui-components"`
- [X] T004 Add the same gate to the lint job in `.github/workflows/ci.yml` in the same change (constitution Principle IV parity — one without the other is a violation)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Vendor the three missing components correctly — without breaking the existing customized ones and
without duplicating the Radix dependency tree (plan Phase B).

**⚠️ CRITICAL**: No user story can start until this phase is complete.

- [X] T005 [P] Install the one new dependency `@radix-ui/react-toggle-group` (version 1.2.1) in `package.json`
- [X] T006 Run `npx shadcn@latest add chart field toggle-group -y` (dry-run first; **never** pass `-o`) so only the missing files land in `app/javascript/components/ui/` — `chart.tsx`, `field.tsx`, `toggle-group.tsx`, `toggle.tsx` — leaving the customized `card.tsx`, `label.tsx`, and `separator.tsx` untouched
- [X] T007 Strip every `focus-visible:ring-*` utility from the newly vendored files in `app/javascript/components/ui/` (chart, field, toggle, toggle-group) so FR-011's uniform no-ring policy survives acquisition
- [X] T008 Rewrite any `import ... from "radix-ui"` in `app/javascript/components/ui/{field,toggle,toggle-group}.tsx` to the already-installed scoped packages (`@radix-ui/react-label`, `@radix-ui/react-slot`, `@radix-ui/react-toggle-group`), and confirm `radix-ui` is absent from `package.json` (research D2)
- [X] T009 Confirm the additions compile: `npm run check` clean and `bin/vite build` succeeds with `public/vite-dev/` regenerated

**Checkpoint**: Library is at 17 components, all ring-free, with no umbrella dependency.

---

## Phase 3: User Story 1 - Interact with one consistent set of controls (Priority: P1) 🎯 MVP

**Goal**: The three hand-built controls become library controls with identical states and keyboard behavior.

**Independent Test**: Tab and click through the granularity control, the profile menu, and the preview
navigation rows; confirm states match peer controls and the inventory check reports zero INV-1 violations.

- [X] T010 [P] [US1] Convert the Monthly/Weekly control in `app/javascript/components/dashboard/dashboard-header.tsx` to `ToggleGroup type="single"` with `value`/`onValueChange`, exactly one item selected at all times, selected state exposed via the primitive, and unchanged spacing and height
- [X] T011 [P] [US1] Convert the profile trigger in `app/javascript/components/dashboard/top-bar.tsx` to `DropdownMenuTrigger asChild` wrapping `Button variant="ghost"`, preserving the avatar plus two-line name/role layout and keyboard activation
- [X] T012 [P] [US1] Convert the ten preview navigation rows in `app/javascript/components/dashboard/app-sidebar.tsx` to `Button variant="ghost" aria-disabled="true"` with activation suppressed and a focusable wrapper so the explanatory tooltip opens; the `disabled` attribute MUST NOT be used (it removes the row from the tab order and suppresses the pointer events the tooltip needs)
- [X] T013 [US1] Verify control parity across `app/javascript/components/dashboard/{dashboard-header,top-bar,app-sidebar}.tsx`: keyboard activation, selected/disabled announcement, and `bin/check-ui-components` reporting zero INV-1 violations

**Checkpoint**: User Story 1 is complete and independently demonstrable.

---

## Phase 4: User Story 2 - Read charts and data panels that share one visual language (Priority: P2)

**Goal**: All three panels draw tooltips, legends, gridlines, and series colors from theme tokens through the
library's chart container (plan Phase D).

**Independent Test**: Edit only `--chart-1` in `app/javascript/entrypoints/application.css` and confirm series
colors and legends change across all three panels with one file edited.

- [X] T014 [P] [US2] Move `app/javascript/components/dashboard/sales-overview-chart.tsx` onto `ChartContainer` / `ChartTooltip` / `ChartTooltipContent` / `ChartLegend` with a `ChartConfig` whose series colors are `var(--chart-1)`…`var(--chart-5)`; keep the stacked regional bars, bucket totals, and the existing `sr-only` data table
- [X] T015 [P] [US2] Move `app/javascript/components/dashboard/subscribers-chart.tsx` onto `ChartContainer` / `ChartTooltip`, keeping the Sun–Sat bars, the emphasized peak day, and the `sr-only` data table
- [X] T016 [P] [US2] Move `app/javascript/components/dashboard/distribution-chart.tsx` onto `ChartContainer` / `ChartTooltip`, keeping the donut, the channel legend with amounts, and the `sr-only` data table
- [X] T017 [US2] Give all three panels the shared empty state from `app/javascript/components/dashboard/panel-states.tsx` so a period with zero buckets renders a neutral message instead of an empty or broken chart (FR-004, FR-037)
- [X] T018 [US2] Verify theme-driven color: change `--chart-1` in `app/javascript/entrypoints/application.css` only, reload, confirm all three panels follow, then revert

**Checkpoint**: User Story 2 is complete; charts read tokens rather than literals.

---

## Phase 5: User Story 3 - Complete forms whose fields all present the same way (Priority: P3)

**Goal**: Both auth forms present label, help, and error through one composition with programmatic association
(plan Phase E).

**Independent Test**: Submit each form with four invalid cases and confirm every field reports its message in the
same position and style, announced when the field is focused.

- [X] T019 [US3] Create `app/javascript/components/auth/auth-field.tsx` composing `Field`, `FieldLabel`, `FieldDescription`, and `FieldError`, wiring `aria-invalid` and `aria-describedby` from the control to its error element so a screen reader announces the message on focus
- [X] T020 [P] [US3] Convert `app/javascript/pages/sessions/new.tsx` to the `auth-field` composition, keeping `errors.base` rendering as the form-level alert and the demo-credentials block unchanged
- [X] T021 [P] [US3] Convert `app/javascript/pages/registrations/new.tsx` to the `auth-field` composition across all four fields (name, email address, password, confirmation), preserving per-field messages and layout
- [X] T022 [US3] Verify error presentation in `app/javascript/pages/sessions/new.tsx` and `app/javascript/pages/registrations/new.tsx` for blank name, malformed email, 7-character password, mismatched confirmation, and wrong sign-in password: identical position and style, `aria-describedby` present, no layout shift when several fields error at once

**Checkpoint**: All three user stories are independently complete.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Landing page adoption and the full verification sweep (plan Phases F and G).

- [X] T023 [P] Adopt shared components on `app/javascript/pages/home.tsx` where an equivalent exists (`Button`, `Card`, `Badge`), and list the raw layout containers that remain (hero, proof, preview, footer sections) with a one-line reason each (allowlist in [contracts/component-inventory.md](./contracts/component-inventory.md))
- [X] T024 [P] Orphan audit for INV-3: confirm every file in `app/javascript/components/ui/` (now 17) has at least one import site, and remove or use any that does not
- [X] T025 [P] Token audit for FR-007: confirm no literal palette classes remain in `app/javascript/pages` and `app/javascript/components` (excluding `components/ui`), using the grep in [quickstart.md](./quickstart.md) V13
- [X] T026 Run `bin/ci` end to end and confirm every step passes, including the new `bin/check-ui-components` step (constitution Principle IV)
- [X] T027 Measure the bundle: `bin/vite build` and record the dashboard chunk size in [quickstart.md](./quickstart.md), confirming it stays at or under ~520 kB against the 478.52 kB baseline
- [X] T028 Regression check: `bin/rails test` passes with **no test file modified**, and the default-period figures are unchanged (page views 12,450; revenue 36,395 minor units; bounce rate 86.5%) — the FR-008/SC-004 fence
- [X] T029 Walk [quickstart.md](./quickstart.md) scenarios V1–V15 and record the outcome of each, including the manual overlay checks (V4–V6) that have no automated coverage
- [X] T030 Update the architecture note in `README.md` to state the final component count and the `bin/check-ui-components` gate, so the rule is discoverable outside the spec folder

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — the check is written first so it guards everything after it
- **Foundational (Phase 2)**: Depends on Setup — **BLOCKS all user stories**
- **User Stories (Phases 3–5)**: All depend on Foundational only; they touch disjoint files and can run in parallel
- **Polish (Phase 6)**: Depends on the user stories that are in scope

### User Story Dependencies

| Story | Priority | Depends on | Independence note |
|-------|----------|-----------|-------------------|
| US1 Controls | P1 | Foundational (`toggle-group`) | Only touches `dashboard-header.tsx`, `top-bar.tsx`, `app-sidebar.tsx` |
| US2 Charts | P2 | Foundational (`chart`) | Only touches the three chart files; does not touch controls |
| US3 Forms | P3 | Foundational (`field`) | Only touches `auth-field.tsx` and the two auth pages |

US2 and US3 do not need US1 to be finished, and US1 does not need either. Each of the three can ship alone.

### Within Each Story

- Library component exists before it is used (Phase 2 gates every story)
- Structural conversion before visual verification
- The story's verification task runs last and must leave `bin/check-ui-components` green

### Parallel Opportunities

- **Phase 2**: T005 is a single dependency install; T006–T008 are sequential by nature (vendor → strip → rewrite imports)
- **Phase 3**: T010, T011, and T012 are three different files and can run together
- **Phase 4**: T014, T015, and T016 are three different files and can run together
- **Phase 5**: T020 and T021 can run together once T019 lands
- **Phase 6**: T023, T024, and T025 are independent audits

---

## Parallel Example: User Story 2

```bash
# Three chart panels, three separate files:
Task: "Sales overview chart in app/javascript/components/dashboard/sales-overview-chart.tsx"
Task: "Subscribers chart in app/javascript/components/dashboard/subscribers-chart.tsx"
Task: "Distribution donut in app/javascript/components/dashboard/distribution-chart.tsx"
```

---

## Implementation Strategy

### MVP First (Setup + Foundational + US1)

1. Complete Phase 1 (the check) and Phase 2 (the three components) — non-negotiable blockers
2. Complete Phase 3 (US1 controls)
3. **STOP and VALIDATE**: `bin/check-ui-components` reports zero INV-1 violations and the dashboard still
   behaves identically with the granularity toggle, profile menu, and preview rows
4. This is the smallest demoable increment: no hand-built controls remain

### Incremental Delivery

1. Setup + Foundational → library complete and guarded
2. US1 → controls unified (MVP)
3. US2 → charts themed from tokens
4. US3 → forms unified
5. Phase 6 → landing page, audits, full gate, bundle and regression numbers recorded

### Ordering Note

Phase 1 deliberately lands before any conversion. Without it, the feature would repeat the failure mode it
exists to fix — the rule would live in a document rather than in a gate.

---

## Notes

- `[P]` marks different files with no incomplete dependencies — it never means a task may skip verification
- Tests are not duplicated here; FR-012's check plus the unmodified suite are the verification spine
- FR-005 (overlay behavior) is verified manually in quickstart V4–V6; this repository has no headless-browser
  harness and the plan states that limit rather than implying automated coverage
- The focus-ring policy stays as-is: vendored components must be stripped of ring utilities on arrival (T007)
- Never run `shadcn add` with `-o`; it would overwrite the customized `card.tsx`, `label.tsx`, and
  `separator.tsx` (research D1)
