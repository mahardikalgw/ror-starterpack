# Contract: Component Inventory and Enforcement

**Feature**: `002-shadcn-component-adoption`
**Date**: 2026-10-28
**Related**: [spec.md](../spec.md) FR-001, FR-007, FR-009, FR-010, FR-011, FR-012 ·
[data-model.md](../data-model.md) invariants INV-1…INV-3

## Required Component Set (end state: 17)

Library components live in `app/javascript/components/ui/` and are the only permitted source of interactive
styling. A component may exist only if a page imports it.

| Component | Kind | Added here | Consumed by |
|-----------|------|-----------|-------------|
| `avatar` | display | no | `top-bar` |
| `badge` | display | no | `app-sidebar`, `home` |
| `button` | control | no | auth pages, dashboard header, sidebar, top bar, integrations table, home |
| `card` | surface | no | KPI cards, three panels, integrations table, home |
| `checkbox` | control | no | integrations table, dashboard filters |
| `dropdown-menu` | overlay | no | top bar profile, dashboard filters |
| `input` | control | no | top bar search, both auth forms |
| `label` | display | no | both auth forms |
| `progress` | display | no | integrations table rate indicator |
| `separator` | display | no | sidebar |
| `sheet` | overlay | no | sidebar drawer |
| `skeleton` | display | no | panel states |
| `table` | display | no | integrations table |
| `tooltip` | overlay | no | preview navigation rows |
| `chart` | display | **yes** | sales overview, subscribers, distribution |
| `field` | control composition | **yes** | both auth forms via `auth-field` |
| `toggle-group` | control | **yes** | dashboard granularity control |

Prohibited: installing any registry component with no import site (FR-010), and adding the `radix-ui` umbrella
package when a scoped package already exists (research D2).

## Allowed Raw Elements

Raw markup is permitted for non-interactive layout only. The distinction is deliberate: FR-001 governs
*interactive* elements, so forbidding every `div` would prevent building a page at all.

| Element | Allowed | Condition |
|---------|---------|-----------|
| `div`, `section`, `header`, `footer`, `main`, `nav`, `ul`, `ol`, `li`, `figure` | yes | Layout/semantics only |
| `h1`–`h6`, `p`, `span`, `strong`, `em`, `kbd`, `dl`, `dt`, `dd` | yes | Text content |
| `a` | yes | Navigation links that are not styled as buttons |
| `img`, `svg` | yes | Media and icons |
| `table` via `table` component | required | Tabular data must use the component |
| `button`, `input`, `select`, `textarea` | **no** | Must use `button`/`input`/`checkbox`/`toggle-group`/`field` |
| `form` | yes | Submissions and semantics; controls inside it follow the row above |
| Elements inside `components/ui/**` | exempt | The components' own implementations |

## Check Contract: `bin/check-ui-components`

**Purpose**: make INV-1, INV-2, and INV-3 fail loudly instead of relying on review (FR-012).

**Scope**:

```text
app/javascript/pages/**/*.tsx
app/javascript/layouts/**/*.tsx        (page-level composition: same rules apply)
app/javascript/components/**/*.tsx     (excluding app/javascript/components/ui/**)
```

`app/javascript/layouts/` was added to the scope during implementation: layouts compose pages and can
hand-roll controls just as easily as a page can. Leaving them out made the library's `sheet` component look
orphaned, because its only import lives in `dashboard-layout.tsx`.

**Rules**:

| Rule | Pattern | Message |
|------|---------|---------|
| INV-1 | `<button`, `<input`, `<select`, `<textarea` | `raw interactive element; use a component from components/ui` |
| INV-2 | `focus-visible:ring`, `focus:ring-` | `focus ring utility; the focus policy is outline:none (see FR-011)` |
| INV-3 | each file in `components/ui/` | `component has no import site; remove it or use it (FR-010)` |

**Output**: one line per violation, `<path>:<line>: <message>`, sorted by path then line. On success, a single
summary line: `check-ui-components: N components, 0 violations`.

**Exit codes**: `0` when clean; `1` when any violation is found.

**CI wiring (Principle IV parity)**: the same step MUST be added to both entry points in the same change:

```ruby
# config/ci.rb
step "Style: UI components", "bin/check-ui-components"
```

```yaml
# .github/workflows/ci.yml — within the lint job, after RuboCop
- name: Check UI component usage
  run: bin/check-ui-components
```

Adding it to one and not the other is a gate-parity violation.

## Explicit Non-Goals

- Not a formatter or linter for style, imports, or naming.
- Not a visual-regression or accessibility test — those are manual scenarios in [quickstart.md](../quickstart.md).
- Not a substitute for the frozen page contract; routes, page names, and props are guarded by the existing
  unmodified test suite.
