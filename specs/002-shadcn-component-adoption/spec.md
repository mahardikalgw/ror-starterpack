# Feature Specification: Unified Component Library Adoption

**Feature Branch**: `002-shadcn-component-adoption`

**Created**: 2026-10-28

**Status**: Draft

**Input**: User description: "make all component using shadcn component"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Interact with one consistent set of controls (Priority: P1)

A visitor moving between the landing page, the sign-in and sign-up screens, and the dashboard encounters
controls that behave identically: every button, input, checkbox, and segmented toggle shares the same
sizing, hover, pressed, disabled, and keyboard behavior. Nothing looks like it came from a different product.

**Why this priority**: Inconsistency between hand-built controls and library controls is the visible symptom
the request is about. Fixing controls alone removes the largest share of divergence and is independently
demonstrable on any page.

**Independent Test**: Visit all four pages, tab and click through every control, and confirm that controls of
the same role have identical states, spacing, and keyboard behavior. No page needs the others to be converted
first.

**Acceptance Scenarios**:

1. **Given** any page, **When** a control receives hover, active, and disabled states, **Then** every control of
the same role shows the same state treatment.
2. **Given** the dashboard header, **When** the visibility period granularity is switched between monthly and
weekly, **Then** the control exposes its selected state to assistive technology and matches the styling of
other controls.
3. **Given** the top bar profile area, **When** it is activated, **Then** it opens its menu and behaves like every
other menu trigger, including keyboard activation.

---

### User Story 2 - Read charts and data panels that share one visual language (Priority: P2)

A signed-in user reads the three dashboard panels and finds that tooltips, legends, gridlines, axis labels,
and empty states are styled from the same theme as the rest of the interface, so the dashboard reads as one
coherent product rather than three separately built widgets.

**Why this priority**: The charts are currently the only panels not built from the shared library, so they
diverge first when the theme changes. Valuable, but secondary to control consistency.

**Independent Test**: Change a single theme token and confirm the chart tooltips, legends, and gridlines update
without editing any chart file. Verify against the seeded default period.

**Acceptance Scenarios**:

1. **Given** the seeded default period, **When** a user hovers any chart, **Then** the tooltip uses the same
   surface, border, radius, and text treatment as other floating surfaces in the product.
2. **Given** a period with no records, **When** a panel renders, **Then** it shows the shared empty state rather
   than an empty or broken chart.
3. **Given** the theme's primary color changes, **When** the dashboard reloads, **Then** chart series colors and
   legends follow the change with no per-chart overrides.

---

### User Story 3 - Complete forms whose fields all present the same way (Priority: P3)

A new visitor fills in sign-up and sign-in and finds that every field presents its label, helper text, and
validation message in the same place with the same styling, and that a field in error is unmistakable.

**Why this priority**: Both auth forms are short and already functional; unifying their field presentation is a
polish step that follows naturally once controls and surfaces are consistent.

**Independent Test**: Submit each auth form with invalid input and confirm every field reports its error in the
same position and style, with the same association to its input.

**Acceptance Scenarios**:

1. **Given** the sign-up form, **When** a field fails validation, **Then** its message appears in the same
   position and style used by every other field, and is programmatically associated with that field.
2. **Given** a form with several invalid fields, **When** it is submitted, **Then** each field reports its own
   message without shifting layout unexpectedly.

---

### Edge Cases

- A disabled navigation entry must remain announced as unavailable, must not be focusable as a link, and must
  still explain why it is unavailable.
- A menu trigger that wraps composite content (avatar plus two lines of text) must keep working as a trigger
  without losing its custom layout.
- A chart with zero buckets, a single bucket, or all-zero totals must render an empty or neutral state instead
  of a broken tooltip or a division error.
- A segmented control with long option labels must not clip or overflow at the narrowest supported width.
- A form where several errors are present at once must present all of them without overlapping or reordering
  the fields.
- A theme token change must not require editing any feature-level file.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Every interactive control on every page MUST be rendered by the project's single shared component
  library. Hand-built buttons, inputs, checkboxes, and menus MUST NOT remain in feature or page code.
- **FR-002**: Controls of the same role MUST present identical sizing, spacing, hover, pressed, disabled, and
  selected treatments, and MUST expose that state to assistive technology.
- **FR-003**: Every form field MUST present its label, help text, and validation message through one shared
  field composition, with the message programmatically associated to its control.
- **FR-004**: Every chart MUST be composed from the library's chart container so that tooltips, legends,
  gridlines, and axis text draw from theme tokens rather than per-chart values.
- **FR-005**: Every overlay (menu, drawer, tooltip) MUST close on Escape, close on outside interaction where
  applicable, move focus into the overlay when it opens, and return focus to its trigger when it closes.
- **FR-006**: Unavailable navigation entries MUST be rendered as disabled controls, MUST NOT navigate, and MUST
  communicate their unavailable status both visually and to assistive technology.
- **FR-007**: All visual states MUST derive from the shared theme tokens. Feature files MUST NOT introduce
  one-off color, radius, or spacing values that duplicate a token.
- **FR-008**: The existing page contract MUST NOT change: routes, page component names, and the shape of
  server-provided data stay exactly as they are.
- **FR-009**: The component library MUST remain vendored in the repository so components can be read and
  adapted locally, and MUST remain the single place where control styling is defined.
- **FR-010**: The library MUST NOT accumulate unused components: a component may exist only if at least one
  page imports it.
- **FR-011**: Focus indication MUST follow one explicit, uniformly applied policy across every interactive
  element, rather than varying by component.
- **FR-012**: A repository check MUST fail when a page or feature component introduces a raw interactive
  element in place of a library component, so the rule is enforced rather than remembered.

### Key Entities

- **Shared component**: A reusable control, surface, or display element owned by the library, identified by a
  stable name and consumed by pages. Key attributes: name, variants, states, import sites.
- **Page composition**: A screen built by arranging shared components and server-provided data. Key attributes:
  route, page name, data shape, list of components used.
- **Theme token**: A named design value (color, radius, spacing, typography) that shared components and charts
  read instead of hardcoding.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: An automated inventory of the three pages reports zero hand-built interactive controls, down from
  the current three plus any discovered during the work.
- **SC-002**: Changing one theme token updates every control, surface, and chart with edits to exactly one file.
- **SC-003**: All three pages pass the same overlay interaction checklist (Escape, outside interaction, focus
  move-in, focus return) with zero deviations.
- **SC-004**: Existing automated tests pass without modification, proving routes, page names, and data shapes
  are unchanged.
- **SC-005**: The dashboard's seeded default-period figures are identical before and after the change: page views
  12,450, revenue 36,395 minor units, bounce rate 86.5%, and the same subscriber, channel, and integration values.
- **SC-006**: Every component present in the library is imported by at least one page, measured at zero orphans.
- **SC-007**: A keyboard-only user can still complete sign-up, sign-in, filtering, and sign-out in under two
  minutes, confirming behavior is preserved even where indication is not.
- **SC-008**: Both auth forms report field errors in one consistent position, verified across at least four
  invalid-input cases.

## Assumptions

- **Design system of record**: The shared library is the shadcn/ui set already vendored into this repository,
  configured with the same component aliases and registry. It is the only permitted source of control styling.
- **Local customization is expected**: Because components are vendored rather than imported from a package,
  adapting a component's defaults in place is allowed as long as its public API and the theme-token rule hold.
- **Focus indication stays removed**: The most recent product decision was to show no focus ring on any
  component. This specification therefore requires a *uniform* policy rather than a visible one, and it does
  not restore rings. This keeps a known accessibility gap open in the earlier feature (its visible-focus
  requirement and keyboard-journey criterion remain unmet) and reversing that decision is out of scope here.
- **No redesign**: Layout, spacing rhythm, page structure, and copy stay as they are. This work changes how
  components are built, not how the product looks.
- **Only needed components are added**: The registry components that no page uses (date picker, command
  palette, toasts, and similar) are not installed merely to complete a list.
- **Server data is fixed**: The dashboard continues to consume the same server-provided data; no query,
  endpoint, or payload changes are part of this work.
- **Scope of surfaces**: The landing page's marketing sections are in scope for using shared components where a
  shared component exists, but they are not required to gain new components that exist only for them.

## Out of Scope

- Visual redesign, new layouts, or changes to spacing rhythm and copy.
- Adding dark mode, animation changes, or new page routes.
- Changing server-side data, queries, exports, or authentication behavior.
- Restoring visible focus indicators (recorded as a separate decision for the earlier feature).
- Adopting a different component library or a headless alternative.
