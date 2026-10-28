# Phase 0 Research: Unified Component Library Adoption

**Feature**: `002-shadcn-component-adoption`
**Date**: 2026-10-28
**Spec**: [spec.md](./spec.md)
**Plan**: [plan.md](./plan.md)

## Context

The library is already vendored and in use: 14 primitives exist and every one is imported somewhere. The
remaining work is closing three specific gaps, adding three components, and enforcing the rule mechanically.
This research records the decisions taken after inspecting the actual toolchain, not the documented ideal.

## Verified Baseline

| Fact | Value | How verified |
|------|-------|--------------|
| Vendored primitives | 14, all imported | `ls` + import grep per component |
| Hand-built interactive controls | 3 | `<button` grep outside `components/ui/` |
| Chart panels bypassing the chart container | 3 | `from 'recharts'` grep |
| Auth forms outside the field composition | 2 | `pages/sessions/new.tsx`, `pages/registrations/new.tsx` |
| Installed Radix packages | 10 scoped packages | `package.json` dependency keys |
| Dashboard bundle | 478.52 kB (gzip 143.75 kB) | `bin/vite build` output |
| Existing test suite | 74 tests, 209 assertions | `bin/rails test` |

---

## D1. Acquisition: `shadcn add` is non-interactive; `init` is not

**Decision**: Acquire the three missing components with
`npx shadcn@latest add chart field toggle-group -y` — always with `-y`, never with `-o`, and always after a
`--dry-run`.

**Rationale**: An earlier attempt at `shadcn init` failed because it prompts for a project template. That
failure was specific to `init`. `add` supports `-y` (skip confirmation), `-o` (overwrite), and `--dry-run`, so it
runs unattended here.

**Verified dry-run output**: the command resolves to seven files, of which four already exist:
`label.tsx`, `separator.tsx`, `card.tsx` are ours and customized, plus three we want — `field.tsx`,
`chart.tsx`, `toggle-group.tsx`, and a new `toggle.tsx` that `toggle-group` depends on.

**Consequence that matters**: omitting `-o` is what protects the existing customized primitives. Adding `-o`
would overwrite `card.tsx` (which carries the dashboard's `rounded-2xl p-5` surface) and `separator.tsx` (a
plain element rather than the Radix one), silently changing visuals. `-o` is prohibited for this feature.

**Alternatives considered**: Hand-copying component source from the docs (works, but drifts from the registry and
loses the dependency resolution); switching to a package import (breaks the vendored model required by FR-009).

## D2. Dependency hygiene: reject the `radix-ui` umbrella package

**Decision**: Do not add the `radix-ui` umbrella package. After vendoring, rewrite any `radix-ui` import in the
new files to the already-installed scoped equivalents (`@radix-ui/react-toggle-group`, `@radix-ui/react-label`,
`@radix-ui/react-slot`).

**Rationale**: The current registry emits `import { ToggleGroup as ToggleGroupPrimitive } from "radix-ui"`, a
single package that re-exports every primitive. This project already depends on ten scoped packages; adding the
umbrella duplicates the same code and grows the dependency tree for three components. `@radix-ui/react-toggle-group`
1.2.1 is the matching scoped package and must be installed as the one new dependency.

**Alternatives considered**: Accept the umbrella and delete the scoped packages (a re-import of every existing
primitive — a much larger change than this feature); keep both (duplicate code, violates the spirit of FR-010).

## D3. Segmented control: `toggle-group` with single selection

**Decision**: Convert the Monthly/Weekly control to `ToggleGroup type="single"` with `value`/`onValueChange`,
and keep an explicit `aria-pressed`-equivalent selected state exposed through the primitive.

**Rationale**: FR-002 requires selected state to be programmatically exposed and visually identical to other
controls. A `ToggleGroup` item is a real button with `aria-pressed`, unlike the current hand-rolled button that
relies on `aria-pressed` alone plus bespoke classes.

**Alternatives considered**: `Tabs` (implies panels switching, which is not what happens — the whole dashboard
re-queries); keeping raw buttons and styling them to match (that is the divergence being removed).

## D4. Profile menu trigger: `Button` inside `DropdownMenuTrigger asChild`

**Decision**: Compose `DropdownMenuTrigger asChild` around `Button variant="ghost"`, preserving the avatar plus
two-line label layout inside the button.

**Rationale**: `asChild` forwards the trigger's props and refs to the `Button`, so keyboard and focus behavior
come from the existing primitive while the composite content is unchanged. Layout is preserved with the button's
height utilities.

**Alternatives considered**: A dedicated `ProfileMenuTrigger` component (a single-consumer abstraction, which
Principle V rejects); leaving the raw button (violates FR-001).

## D5. Disabled navigation rows: `aria-disabled`, not the `disabled` attribute

**Decision**: Render preview rows as `Button variant="ghost" aria-disabled="true"` and cancel activation in the
handler, wrapped in a focusable element so the explanatory tooltip still opens.

**Rationale**: A truly `disabled` button dispatches no pointer events, so its tooltip can never open and it is
removed from the tab order — which would violate FR-006's requirement to communicate why the item is unavailable.
`aria-disabled` keeps the control focusable and announced as disabled while still blocking navigation.

**Alternatives considered**: `disabled` plus a static caption (loses the tooltip on hover); leaving the item as a
non-focusable span (not announced as a control).

## D6. Charts: the library's chart container, tokens for color

**Decision**: Move all three panels onto `ChartContainer` / `ChartTooltip` / `ChartTooltipContent` /
`ChartLegend`, with a `ChartConfig` whose series colors are `var(--chart-1)`…`var(--chart-5)`. Keep the existing
visually hidden data tables and the empty-state paths.

**Rationale**: FR-004 requires tooltips, legends, gridlines, and axis text to read from theme tokens. The
container injects per-series CSS variables and supplies a themed tooltip surface, which is exactly the gap the
current direct `recharts` usage leaves. `recharts` 3.8.0 is already installed at the version the registry pins, so
no new charting dependency is needed.

**Alternatives considered**: Keeping direct `recharts` and styling tooltips by hand (reproduces the divergence);
swapping chart libraries (out of scope and unnecessary).

## D7. Forms: `Field` composition with programmatic error association

**Decision**: Use `Field`, `FieldLabel`, `FieldDescription`, and `FieldError` in both auth forms, wiring
`aria-invalid` and `aria-describedby` from the control to its error element; extract one `AuthField` wrapper in
`components/auth/` so both forms cannot drift.

**Rationale**: FR-003 requires one composition for label, help, and error, with the message associated to the
control. `aria-describedby` is what makes a screen reader announce the error on focus; today the message is a
sibling paragraph with no association.

**Alternatives considered**: Repeating the markup in both forms (drift risk); a generic `FormField` in the library
(a second abstraction over an emerging one).

## D8. Enforcement: a source-level inventory check, not a linter

**Decision**: Add `bin/check-ui-components`, which scans `app/javascript/pages/**` and
`app/javascript/components/**` (excluding `components/ui/**`) for raw interactive elements — `<button`, `<input`,
`<select`, `<textarea` — and for `focus-visible:ring` utilities, printing `file:line` and exiting non-zero. Wire
it into `config/ci.rb` and `.github/workflows/ci.yml` in the same change.

**Rationale**: FR-012 demands a failing check rather than a convention. A ~40-line script needs no new
dependency and plugs into the existing gate runner. Scanning for ring utilities enforces FR-011's uniform focus
policy at the same time, so one rule protects both.

**Alternatives considered**: ESLint plus a custom rule plugin (a second toolchain and dependency tree larger than
the feature, with no ESLint config present today); a review checklist (unenforceable, and precisely what failed
here the first time).

**Allowlist** (justified in [contracts/component-inventory.md](./contracts/component-inventory.md)): non-interactive
layout elements stay permitted; the check targets interactive elements only. Components inside `components/ui/` are
their own implementation and are excluded.

## D9. Landing page scope: adopt where an equivalent exists, keep section layout

**Decision**: Replace duplicated interactive and surface elements on `pages/home.tsx` with `Button`, `Card`, and
`Badge` where an equivalent exists. Keep the hero, proof, preview, and footer section containers as layout markup.

**Rationale**: FR-001 targets interactive controls, and no library component represents a marketing section. The
landing page already imports three primitives; the remaining markup is layout, which the allowlist documents.
Building marketing-specific library components would add components used by exactly one page, which FR-010 and
Principle V both discourage.

**Alternatives considered**: Extracting `Hero`, `ValueGrid`, `Footer` into `components/ui/` (single-consumer
components in the library); leaving every element raw (leaves duplicated surface styling).

## D10. Focus policy: keep it uniform and ring-free

**Decision**: The existing global rule (`:focus, :focus-visible { outline: none }`) stays. Newly vendored
components must not reintroduce ring utilities; D8's check fails if they do.

**Rationale**: FR-011 requires one uniform policy. Vendored registry components ship with `focus-visible:ring-2`
on interactive elements, so adding them without stripping the utilities would have silently reintroduced rings
on exactly three components — the opposite of uniform.

**Consequence, stated plainly**: feature 001's visible-focus requirement and keyboard-journey criterion remain
unmet. This feature keeps the status quo rather than quietly improving or worsening it.

## D11. Bundle budget and regression measurement

**Decision**: Re-run `bin/vite build` after the conversion and require the dashboard chunk to stay at or under
~520 kB (baseline 478.52 kB). Record both numbers in [quickstart.md](./quickstart.md).

**Rationale**: The chart container and toggle group add code; a budget keeps the addition honest. The chart
container is thin — it wires context and CSS variables around `recharts`, which is already bundled.

**Alternatives considered**: No budget (silent growth); a hard bundle-size gate in CI (premature for a template).

## D12. Regression fence: the existing suite is the contract guard

**Decision**: Do not modify any existing test. FR-008 freezes routes, page names, and prop shapes, so a passing
unmodified suite is the proof. The new check is the only added gate.

**Rationale**: Rewriting tests to match a refactor would hide exactly the breakage FR-008 forbids. Page-name
assertions already verify component names resolve to files on disk, which is the failure mode that bit this
repository earlier.

**Alternatives considered**: Adding snapshot tests of rendered markup (brittle against styling work, and this is a
styling work).

## Open Questions

None. Every decision above was resolved against the installed toolchain. The one product-level question — whether
to restore visible focus indicators — was answered by the most recent instruction (no rings) and is recorded in
the spec's Assumptions rather than left ambiguous here.
