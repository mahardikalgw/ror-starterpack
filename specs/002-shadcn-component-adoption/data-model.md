# Phase 1 Model: Component Registry, Page Compositions, Theme Tokens

**Feature**: `002-shadcn-component-adoption`
**Date**: 2026-10-28
**Spec**: [spec.md](./spec.md) · **Research**: [research.md](./research.md) · **Plan**: [plan.md](./plan.md)

This feature has no database. The "model" here is the interface inventory the feature must converge: which
components exist, where they are consumed, which surface reads which token, and which raw elements are permitted.
Each rule below cites the requirement it enforces.

## Entity: Library Component

A control, surface, or display element owned by the library in `app/javascript/components/ui/`.

| Attribute | Meaning | Rule |
|-----------|---------|------|
| `name` | File basename, kebab-case | Unique within the library |
| `variants` | Named visual variants (e.g. `default`, `outline`, `ghost`) | Declared in one place (a variant table), never re-derived at call sites |
| `states` | `default`, `hover`, `active`, `focus`, `disabled`, `selected` | Every interactive component must define all that apply (FR-002) |
| `primitive_dependency` | The Radix scoped package it wraps, if any | Scoped packages only; the `radix-ui` umbrella is prohibited (research D2) |
| `import_sites` | Pages/features importing it | MUST be ≥ 1 (FR-010 — no orphans) |
| `token_reads` | Theme tokens the component consumes | Tokens only, no literal palette values (FR-007) |

### Current inventory (verified)

| Component | Import sites | Status |
|-----------|--------------|--------|
| `button` | 8 | keep |
| `card` | 6 | keep — carries the dashboard surface treatment |
| `input` | 3 | keep |
| `badge` | 2 | keep |
| `checkbox` | 2 | keep |
| `dropdown-menu` | 2 | keep |
| `label` | 2 | keep |
| `avatar` | 1 | keep |
| `progress` | 1 | keep |
| `separator` | 1 | keep — plain element, not the Radix one |
| `sheet` | 1 | keep |
| `skeleton` | 1 | keep |
| `table` | 1 | keep |
| `tooltip` | 1 | keep |
| `chart` | 0 | **add** — FR-004 |
| `field` | 0 | **add** — FR-003 |
| `toggle-group` | 0 | **add** — FR-002 |

Fourteen components in, zero orphans out. Adding three brings the total to seventeen, each with an import site by
the end of the work (FR-010).

## Entity: Page Composition

A screen that arranges components around server-provided data.

| Attribute | Meaning | Rule |
|-----------|---------|------|
| `route` | HTTP path | Frozen (FR-008) |
| `page_name` | Inertia component name | Frozen; must resolve to `app/javascript/pages/<name>.tsx` |
| `props_shape` | Server-provided data contract | Frozen (FR-008, SC-004) |
| `components_used` | Library components rendered | Every interactive element must come from this set (FR-001) |
| `raw_elements` | Non-library markup remaining | Permitted only for non-interactive layout (see allowlist contract) |

### Composition census (target end state)

| Route | Page name | Converted in this feature | Remaining raw markup |
|-------|-----------|--------------------------|----------------------|
| `/` | `home` | surface/interactive elements onto `card`/`button`/`badge` | section/hero/footer **layout** containers only |
| `/session/new` | `sessions/new` | fields onto `field` via `auth-field` | none interactive |
| `/registration/new` | `registrations/new` | fields onto `field` via `auth-field` | none interactive |
| `/dashboard` | `dashboard/index` | granularity toggle, profile trigger, charts | none interactive |

## Entity: Theme Token

A named design value that components read instead of hardcoding.

| Token group | Names | Consumers |
|-------------|-------|-----------|
| Surfaces | `--background`, `--card`, `--popover`, `--sidebar`, `--secondary`, `--accent` | every surface component |
| Text | `--foreground`, `--muted-foreground`, `--card-foreground`, `--primary-foreground` | all |
| Interactive | `--primary`, `--ring`, `--border`, `--input`, `--destructive` | buttons, inputs, fields, menus |
| Data viz | `--chart-1` … `--chart-5` | chart container series |
| Shape | `--radius` (and derived `--radius-sm/md/lg`) | cards, buttons, menus, tooltips |

Rule (FR-007): a feature file MUST NOT introduce a literal color, radius, or spacing value that duplicates a
token. Changing a token must change every consumer with a single-file edit (SC-002).

## Invariants

| ID | Invariant | Enforced by |
|----|-----------|-------------|
| INV-1 | No raw interactive element outside `components/ui/` | `bin/check-ui-components` (FR-001, FR-012) |
| INV-2 | No `focus-visible:ring` utility anywhere in the frontend | `bin/check-ui-components` (FR-011) |
| INV-3 | Every library component has ≥ 1 import site | `bin/check-ui-components` (FR-010) |
| INV-4 | Page names resolve to files on disk | Existing controller tests (FR-008) |
| INV-5 | No literal palette values in feature files | Review + token grep in quickstart (FR-007) |
| INV-6 | Routes, page names, and props unchanged | Existing unmodified test suite (FR-008, SC-004) |

## State Transitions

### Interactive control

```text
default --hover--> hover --leave--> default
default --press--> active --release--> default (or selected, for toggles)
default --keyboard-focus--> focus --blur--> default
any --disabled--> disabled   (non-interactive, announced as disabled, not necessarily focusable)
```

A toggle additionally carries `selected` and MUST expose it programmatically (FR-002). Under the current policy
`focus` is visually identical to `default` (FR-011, research D10); this is a known gap, not an oversight.

### Overlay lifecycle

```text
closed --trigger--> open (focus moved inside)
open --escape--> closed (focus returned to trigger)
open --outside-interaction--> closed (focus returned to trigger)
open --selection--> closed
```

Exact per-overlay semantics live in [contracts/overlay-behavior.md](./contracts/overlay-behavior.md) (FR-005).

### Disabled control with explanation

```text
enabled --mark-unavailable--> aria-disabled   (focusable, activation suppressed, explanation reachable)
aria-disabled --activate--> no navigation, explanation shown
```

Using the `disabled` attribute instead is prohibited for the preview navigation rows because it removes the
control from the tab order and suppresses the pointer events the tooltip needs (research D5, FR-006).

## Validation Rules Mapped to Requirements

| Rule | Requirement |
|------|-------------|
| Interactive elements come only from the library | FR-001 |
| Same-role controls share state treatment and expose selected state | FR-002 |
| Field label, help, and error share one composition with `aria-describedby` | FR-003 |
| Charts read series colors from `--chart-*` tokens | FR-004 |
| Overlays dismiss on Escape/outside and restore focus | FR-005 |
| Unavailable items are announced and explain themselves | FR-006 |
| Styling derives from tokens | FR-007 |
| Route, page name, and props frozen | FR-008 |
| Library stays vendored and is the only styling source | FR-009 |
| No unused components | FR-010 |
| One uniform focus policy | FR-011 |
| A failing check guards INV-1…INV-3 | FR-012 |
