# Contract: Overlay and Disabled-Control Behavior

**Feature**: `002-shadcn-component-adoption`
**Date**: 2026-10-28
**Related**: [spec.md](../spec.md) FR-002, FR-005, FR-006, FR-011 · [research.md](../research.md) D4, D5, D10

The library wraps Radix primitives, which already implement these behaviors. This contract states what the
product requires so the behavior survives component customization, and so the manual verification in
[quickstart.md](../quickstart.md) has an unambiguous target.

## Overlay Matrix

| Overlay | Instance(s) | Escape | Outside interaction | Initial focus | Focus on close |
|---------|-------------|--------|--------------------|---------------|----------------|
| Dropdown menu | top bar profile menu | closes | closes | first menu item | returns to trigger |
| Dropdown menu (checkbox items) | dashboard filter menu | closes | closes | first item | returns to trigger |
| Sheet / drawer | sidebar below 1024 px | closes | closes on overlay activation | first focusable nav item | returns to the menu trigger |
| Tooltip | preview navigation rows | dismisses | dismisses on pointer leave or blur | not applicable (non-modal) | not applicable |

Modal overlays (dropdown with focus trap, sheet) MUST trap focus while open: Tab cycles within the overlay and
SHIFT+Tab cycles backwards; focus MUST NOT reach the page behind it.

## Disabled Control Semantics

Applies to the ten non-dashboard navigation entries (FR-006).

| Requirement | Rule |
|-------------|------|
| Announced as unavailable | `aria-disabled="true"` on the control |
| Does not navigate | Activation is suppressed in the handler; no `href` is rendered |
| Remains focusable | The `disabled` attribute MUST NOT be used — it removes the control from the tab order and suppresses the pointer events the tooltip depends on (research D5) |
| Explains itself | The explanatory tooltip opens on hover and on keyboard focus |
| Visually distinct | Muted text token plus `cursor-not-allowed`; no color value outside a token |

## Selected-State Semantics

Applies to the granularity control (FR-002).

| Requirement | Rule |
|-------------|------|
| Selected state exposed | The toggle item carries `aria-pressed` (via the primitive) and `data-state="on"` |
| Same treatment as peers | Sizing, radius, and text treatment match other controls of the same rank |
| Single selection | Exactly one item is selected at all times; the control cannot be emptied by re-activating the active item |
| Change | Activation triggers one visit that updates the series grouping; no intermediate state is shown |

## Focus Policy

One policy for every interactive element, including newly vendored components (FR-011):

- No ring utility and no browser outline on focus (the global `:focus, :focus-visible { outline: none }` rule).
- A vendored component that ships `focus-visible:ring-*` MUST have those utilities stripped on arrival;
  `bin/check-ui-components` fails the build otherwise.
- This is the current product decision and leaves feature 001's visible-focus requirement unmet. It is recorded
  here so the tradeoff is discoverable rather than surprising.

## Failure Modes That Must Not Occur

| Failure | Why it matters |
|---------|----------------|
| Focus escapes a modal overlay | Keyboard user loses their place in the interface |
| Closing an overlay drops focus to `<body>` | Next Tab starts from the top of the document |
| Tooltip unreachable on a disabled row | User cannot learn why the item is unavailable |
| Two granularity items selected at once | Server would receive an ambiguous value |
| Ring reappears on one component only | Directly contradicts the uniform-policy requirement (FR-011) |
