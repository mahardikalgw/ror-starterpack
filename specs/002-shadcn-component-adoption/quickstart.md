# Quickstart Validation Guide: Unified Component Library Adoption

**Feature**: `002-shadcn-component-adoption` | **Date**: 2026-10-28
**Plan**: [plan.md](./plan.md) · **Contracts**: [component-inventory.md](./contracts/component-inventory.md),
[overlay-behavior.md](./contracts/overlay-behavior.md) · **Model**: [data-model.md](./data-model.md)

Validation guide only. Implementation detail belongs in `tasks.md` and the implementation phase.

## Prerequisites

- The application runs locally (`bin/dev`) on its usual port.
- The demo dataset is loaded (`bin/rails db:seed`) and the demo account can sign in.
- Node dependencies are installed (`npm install`).

## Commands

| Purpose | Command | Expected |
|---------|---------|----------|
| Inventory rule | `bin/check-ui-components` | `check-ui-components: 17 components, 0 violations`, exit 0 |
| Type check | `npm run check` | No errors |
| Component bundle | `bin/vite build` | Builds; dashboard chunk ≤ ~520 kB |
| Frozen contract | `bin/rails test` | 74 runs, 0 failures — **unmodified suite** |
| Full gate | `bin/ci` | All steps pass, including the new UI check |

## Validation Scenarios

| # | Scenario | Steps | Expected outcome | Proves |
|---|----------|-------|------------------|--------|
| V1 | Inventory is clean | Run `bin/check-ui-components` | Exit 0, 17 components, 0 violations | FR-001, FR-010, FR-012, SC-001, SC-006 |
| V2 | The check actually fails | Add a temporary `<button>` to any page component, re-run, then revert | Exit 1 with `path:line: raw interactive element…`; reverting restores exit 0 | FR-012 |
| V3 | Focus policy is uniform | Run the check after vendoring components | No `focus-visible:ring` violation reported | FR-011 |
| V4 | Profile menu behaves like a menu | Click the profile area, then press Escape; reopen and click elsewhere | Opens, closes on Escape, closes on outside click, focus returns to the trigger | FR-005 |
| V5 | Filter menu keeps checkbox semantics | Open Filter, toggle a region, press Escape | Selection applies, menu closes, focus returns to the Filter button | FR-005, FR-034 |
| V6 | Drawer is keyboard-safe below 1024 px | Narrow the window under 1024 px, open the drawer with the menu button, press Escape | Drawer opens, focus moves inside, Escape closes it, focus returns to the trigger | FR-005, FR-022 |
| V7 | Preview rows explain themselves | Hover a non-dashboard nav item, then Tab to it | Tooltip explains it is a preview; `aria-disabled` is announced; activating does nothing; the row is reachable by Tab | FR-006, FR-024 |
| V8 | Granularity control exposes selection | Toggle Monthly ↔ Weekly | Exactly one item selected, `aria-pressed` reflects it, series regroup, range label unchanged | FR-002, FR-033 |
| V9 | Charts follow the theme | Edit only `--chart-1` in `app/javascript/entrypoints/application.css`, reload the dashboard | Series colors and legend update across all three panels with **one file** edited | FR-004, FR-007, SC-002 |
| V10 | Charts survive empty data | Set a range with no records for the workspace | Panels show the shared empty state; no broken tooltip, no division error | FR-004, FR-037 |
| V11 | Chart values are unchanged | Compare the default period against the seeded figures | Page views 12,450; revenue 36,395 minor units; bounce rate 86.5%; subscriber, channel, and integration values unchanged | SC-005 |
| V12 | Form errors are consistent | Submit sign-up with: blank name, malformed email, 7-character password, mismatched confirmation. Repeat for sign-in with a wrong password | Every field shows its message in the same position and style; the message is announced when the field is focused (`aria-describedby`); layout does not jump | FR-003, SC-008 |
| V13 | Only tokens are used | `grep -rnE '(bg|text|border)-(red|blue|green|indigo|slate|zinc)-[0-9]{2,3}' app/javascript/pages app/javascript/components \| grep -v components/ui` | No matches | FR-007 |
| V14 | Nothing regressed | `bin/rails test`, then sign in and walk the dashboard | Unmodified suite passes; routes, page names, and props unchanged | FR-008, SC-004 |
| V15 | No orphan components | `ls app/javascript/components/ui` and grep each name | Every component has at least one import site | FR-010, SC-006 |

## Known Limits (stated, not hidden)

- **FR-005 has no automated coverage.** Overlay behavior is verified by V4–V6 manually. This repository has no
  headless-browser harness, and claiming automated proof would be false.
- **No visible focus indicator.** The product decision is no focus ring, so V4–V7 confirm *behavior*, not visible
  indication. Feature 001's visible-focus requirement and keyboard-journey criterion remain unmet.
- **No visual-regression tooling.** V9 and V11 rely on inspection; they are checks a person runs, not a gate.

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Check reports violations in `components/ui/` | Scope bug in the script | The check must exclude `components/ui/**`, which is the components' own implementation |
| Vendored component reintroduced a ring | Registry default applied on arrival | Strip `focus-visible:ring-*` from the vendored file (research D10) |
| Registry added `radix-ui` to dependencies | Umbrella package pulled automatically | Remove it and rewrite the import to the scoped package (research D2) |
| Existing primitive was overwritten | `shadcn add` ran with `-o` | Restore the customized file from version control; never use `-o` here (research D1) |
| Dashboard chunk exceeds budget | Chart container imported whole | Import only the container, tooltip, and legend that are used |

## Validation Results (recorded 2026-10-28)

| # | Result | Evidence |
|---|--------|----------|
| V1 | PASS | `check-ui-components: 18 components, 0 violations`, exit 0 |
| V2 | PASS | Injecting a temp `<button>` produced `temp_violation.tsx:1: raw interactive element`, exit 1; reverting restored exit 0 |
| V3 | PASS | No `focus-visible:ring` in any component; the vendored `toggle.tsx` was stripped on arrival |
| V4–V6 | NOT VERIFIED IN A BROWSER | Radix `DropdownMenu` / `Sheet` / `Tooltip` primitives provide the behavior; no headless-browser harness exists here (see Known Limits) |
| V7 | PASS (structural) | Ten preview rows render `Button` with `aria-disabled="true"`, activation prevented, tooltip trigger focusable |
| V8 | PASS (structural) | `ToggleGroup type="single"` bound to `period.granularity`; Radix Toggle exposes the pressed state |
| V9 | PASS (structural) | All series colors resolve through `ChartConfig` → `var(--chart-1…5)`; `grep` finds no literal palette value in the three chart files |
| V10 | PASS (structural) | Each panel renders `EmptyState` and hides the chart when its data set is empty |
| V11 | PASS | `/dashboard/export` still returns `kpi,page_views,Page Views,12450`, `total_revenue,36395`, `bounce_rate,8650` |
| V12 | PASS (structural) | Both forms use `AuthField`, which sets `aria-invalid` and `aria-describedby` to the `FieldError` id |
| V13 | PASS | Token audit grep over `pages/` and `components/` (excluding `components/ui`) returns nothing |
| V14 | PASS | 74 runs, 209 assertions, 0 failures, 0 errors, five consecutive runs |
| V15 | PASS | 18 components, every one imported at least once |

### Measured at completion

- **Components**: 14 → 18 (`chart`, `field`, `toggle`, `toggle-group`)
- **Raw interactive controls**: 3 → 0
- **Dashboard chunk**: 478.52 kB → 487.64 kB (gzip 143.75 → 146.63 kB); budget ≤ ~520 kB
- **`bin/ci`**: passes in 7.97s, including the new `Style: UI components` step
