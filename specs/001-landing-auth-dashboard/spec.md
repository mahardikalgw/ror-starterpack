# Feature Specification: Landing, Authentication & Analytics Dashboard

**Feature Branch**: `001-landing-auth-dashboard`

**Created**: 2026-10-28

**Status**: Draft

**Input**: User description: "Create a landing page, an authentication page, and a dashboard page with example logic backed by real database data because this project is a template. The dashboard should follow the supplied Nexus.io reference design (sidebar navigation, KPI cards, sales overview, subscriber and distribution charts, integrations table). Prefer the Inter typeface, and follow the contribution guidance in llms-full.txt."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Explore a complete, data-backed analytics dashboard (Priority: P1)

A signed-in user opens the dashboard and sees a polished analytics workspace that mirrors the supplied Nexus.io reference: a grouped sidebar (General, Tools, Support), a top bar with search and profile controls, three headline metric cards, a stacked regional sales chart, a weekly subscriber chart, a channel distribution donut, and an integrations table. Every number on the page is derived from stored records, so changing the reporting period or filtering recalculates what the user sees.

**Why this priority**: The dashboard is the centerpiece of this starter template and the primary proof that the template ships with realistic, database-backed example logic rather than static mockups. It is the experience evaluators judge first.

**Independent Test**: Seed the demo dataset, sign in with the documented demo account, and confirm the dashboard renders the reference layout populated with the seeded figures (page views, revenue, bounce rate, regional sales, subscribers, channel split, integrations). Then change the reporting period and confirm dependent figures change.

**Acceptance Scenarios**:

1. **Given** the demo dataset is loaded and the demo user is signed in, **When** the dashboard opens, **Then** the three headline metric cards show page views, total revenue, and bounce rate with their comparison deltas.
2. **Given** the demo dataset is loaded, **When** the dashboard renders, **Then** the sales overview, subscriber, distribution, and integrations panels show values that match the stored records for the selected period.
3. **Given** the dashboard is open, **When** the user changes the reporting period or the granularity control, **Then** the period label and every dependent metric, chart total, and table value update consistently.
4. **Given** the dashboard is open, **When** the user selects or clears integration rows, **Then** the selection state is visible and the export action reflects only the selected rows.
5. **Given** a narrow viewport, **When** the dashboard is viewed on a phone or tablet, **Then** the sidebar collapses into an accessible drawer, cards stack in a readable order, and no core information is lost.

---

### User Story 2 - Create an account and sign in securely (Priority: P1)

A visitor creates an account with their name, email, and password, then signs in to reach their workspace. Returning users sign in with existing credentials, stay signed in across browser restarts, and can sign out from anywhere in the app. Protected pages are never shown to anonymous visitors.

**Why this priority**: A template without working authentication cannot demonstrate a realistic product. Authentication is also the gate that makes the dashboard meaningful and keeps demo data private to the signed-in workspace.

**Independent Test**: From a clean session, sign up through the public form, land in the dashboard, sign out, sign back in with the same credentials, and confirm protected pages redirect to sign-in when accessed while signed out.

**Acceptance Scenarios**:

1. **Given** an anonymous visitor on the sign-up page, **When** they submit a valid name, unique email, and matching password of at least eight characters, **Then** an account is created and they are taken to the dashboard signed in.
2. **Given** an anonymous visitor on the sign-up page, **When** they submit an email that is already registered, **Then** the form shows a clear, field-level message and no second account is created.
3. **Given** a registered user on the sign-in page, **When** they submit the wrong password, **Then** a non-revealing error is shown and no session is created.
4. **Given** a registered user on the sign-in page, **When** they submit valid credentials, **Then** they are taken to the dashboard.
5. **Given** a signed-out visitor requests a protected page, **When** the request completes, **Then** they are redirected to sign-in and returned to the originally requested page after signing in.
6. **Given** a signed-in user, **When** they choose sign out and then use the browser back button, **Then** protected content is not displayed from history or cache.
7. **Given** the application was just set up, **When** the documented demo credentials are used, **Then** sign-in succeeds immediately without extra configuration.

---

### User Story 3 - Understand the product from a public landing page (Priority: P2)

An anonymous visitor lands on a marketing page that explains what the template offers, shows a preview of the dashboard experience, and offers clear paths to start a free account or sign in. The page uses the same brand, typography, and visual language as the product so the transition into the app feels continuous.

**Why this priority**: The landing page is the entry point of the template and demonstrates how public marketing content coexists with the authenticated app. It is valuable but secondary to the dashboard and authentication flows.

**Independent Test**: Open the root URL in a signed-out browser, review each marketing section and call-to-action, follow the primary call-to-action to sign-up and the secondary one to sign-in, then repeat while signed in to confirm the signed-in variant.

**Acceptance Scenarios**:

1. **Given** an anonymous visitor opens the root URL, **When** the page loads, **Then** they see a brand header, a hero with headline, supporting text and primary call-to-action, at least three product value propositions, a preview of the dashboard, social proof or outcome metrics, a closing call-to-action, and a footer.
2. **Given** an anonymous visitor on the landing page, **When** they activate the primary call-to-action, **Then** they arrive at the account creation page, and the secondary call-to-action leads to sign-in.
3. **Given** a signed-in user opens the root URL, **When** the page loads, **Then** the call-to-action area offers direct entry to the dashboard instead of asking them to sign in again.
4. **Given** a visitor on the landing page, **When** they navigate by keyboard only, **Then** all links and calls-to-action are reachable with a visible focus indicator.

---

### User Story 4 - Start from realistic demo data (Priority: P3)

A developer or evaluator setting up the template runs a single documented setup step and receives a demo workspace, a demo user, and analytics records spanning several months. Re-running the setup does not duplicate or corrupt the demo data, and a summary of the demo credentials is available where a first-time user needs it.

**Why this priority**: Realistic seed data is what makes the template demonstrative, but it only supports the three user-facing experiences above and can be regenerated at any time.

**Independent Test**: On an empty database, run the documented setup, verify the demo workspace, demo account, and reporting records exist; run the setup again and verify record counts are unchanged.

**Acceptance Scenarios**:

1. **Given** an empty database, **When** the documented setup runs, **Then** a demo workspace, a demo account, integrations, and analytics records for the reference period are created.
2. **Given** demo data already exists, **When** the documented setup runs again, **Then** no duplicate workspace, account, integration, or analytics records are produced.
3. **Given** the sign-in page, **When** a first-time evaluator opens it, **Then** the demo credentials needed to explore the template are discoverable without reading source code.

---

### Edge Cases

- An anonymous visitor requests a protected page directly (bookmark or deep link): they are sent to sign-in and, after success, land on the requested page rather than a generic home.
- A signed-in user's session expires or is revoked while they are on the dashboard: the next action redirects to sign-in with a clear session-expired notice and preserves their intended destination.
- A dashboard period has no records at all: cards show an explicit "no data for this period" state rather than zero-filled charts or errors.
- Some series are missing for a period (for example, one region has no sales): the chart renders remaining series and the legend or table explains the absence instead of breaking.
- A metric delta is exactly zero or negative: the comparison indicator shows a neutral or negative treatment, and the sign and percentage formatting remain correct.
- Monetary values include thousands separators and two decimals consistently; large values do not overflow their cards on narrow screens.
- A very long account or workspace name: the top bar, sidebar switcher, and profile menu truncate gracefully without layout breakage.
- Search returns no integrations: an empty-result message with a way to clear the search is shown.
- Export is requested with no rows selected: the user is told to select rows, or all visible rows are exported, consistently with the on-screen selection count.
- A user submits the sign-in or sign-up form twice quickly: only one account or session outcome occurs and the interface communicates progress.
- JavaScript-enhanced interactions are delayed or fail: the page still shows a readable, server-rendered state and a retry path instead of a blank screen.
- Reduced-motion preference is set: chart and drawer animations are minimized while content remains usable.
- The browser is resized or rotated while the sidebar drawer is open: the layout settles into the correct state for the new viewport without trapping focus.

## Requirements *(mandatory)*

### Functional Requirements

#### Public landing page

- **FR-001**: Anonymous visitors MUST be able to view a public landing page at the application root.
- **FR-002**: The landing page MUST include a brand header with navigation and authentication actions, a hero with headline, supporting copy, primary and secondary calls-to-action, and a product preview.
- **FR-003**: The landing page MUST present at least three distinct value propositions describing what the template provides and who it is for.
- **FR-004**: The landing page MUST include a proof section (outcome metrics, testimonial-style content, or an equivalent credibility element) and a closing call-to-action.
- **FR-005**: The landing page MUST include a footer with copyright, a short product description, and links to the main product areas.
- **FR-006**: Landing page calls-to-action MUST route visitors to account creation or sign-in as labeled, and MUST NOT lead to protected content before authentication.
- **FR-007**: Signed-in visitors MUST be offered direct entry to the dashboard from the landing page instead of sign-in or sign-up prompts.
- **FR-008**: The landing page MUST remain readable and navigable from 360px through 1920px viewport widths, with no horizontal scrolling.

#### Authentication and access control

- **FR-009**: Visitors MUST be able to create an account with name, email, password, and password confirmation.
- **FR-010**: Account creation MUST reject missing fields, malformed email addresses, passwords shorter than eight characters, non-matching confirmations, and emails already in use, with a field-level message for each problem.
- **FR-011**: Registered users MUST be able to sign in with email and password.
- **FR-012**: Failed sign-in MUST show a single generic message that does not reveal whether the email exists.
- **FR-013**: Signed-in users MUST be able to sign out from any authenticated page, ending the session and returning them to a public page.
- **FR-014**: Protected pages MUST require an authenticated session; anonymous requests MUST be redirected to sign-in and returned to the requested destination after success.
- **FR-015**: Sessions MUST persist across page reloads and browser restarts until sign-out or a documented expiry of 30 days of inactivity.
- **FR-016**: Passwords MUST be stored only as one-way hashes; no plaintext or reversible credential storage is permitted.
- **FR-017**: Sign-in and sign-up submissions MUST prevent duplicate processing and MUST communicate an in-progress state.
- **FR-018**: A seeded demo account MUST be able to sign in immediately after the documented setup, and its credentials MUST be discoverable from the sign-in experience.

#### Dashboard shell and navigation

- **FR-019**: The dashboard MUST present a persistent sidebar grouped into General (Dashboard, Payment, Customers, Message), Tools (Product, Invoice, Analytics, Automation) and Support (Settings, Security, Help), with the Dashboard item marked active.
- **FR-020**: The sidebar MUST display the demo badges shown in the reference design (a message count and a beta tag for Automation) sourced from application data rather than decoration-only markup.
- **FR-021**: The sidebar MUST include a workspace switcher showing the active workspace name and plan label, an upgrade-plan action, and an application copyright line.
- **FR-022**: The sidebar MUST be collapsible and MUST become an accessible drawer below 1024px, restorable with keyboard, and closable with Escape.
- **FR-023**: The top bar MUST include a search field with a visible keyboard-shortcut hint, notification and help or create-entry controls, and a profile menu showing the signed-in account name and role label.
- **FR-024**: Dashboard navigation links that are outside this feature's scope MUST indicate their unavailable or preview status and MUST NOT lead to error pages or dead ends.
- **FR-025**: The dashboard header MUST show the page title "Dashboard", an inclusive reporting date range (defaulting to Oct 18 – Nov 18), a Monthly/Weekly granularity control, a Filter action, and an Export action.

#### Dashboard content and example logic

- **FR-026**: The dashboard MUST show three headline metric cards — Page Views, Total Revenue, and Bounce Rate — each with its current value and a comparison delta including direction (up or down) and percentage.
- **FR-027**: The dashboard MUST show a Sales Overview panel with stacked bars for the reporting months, five regional series (China, UE, USA, Canada, Other), a per-month total, a legend, an aggregate total, and a growth delta expressed as a percentage and an absolute amount.
- **FR-028**: The dashboard MUST show a Total Subscriber panel with a total count, a comparison delta, and a seven-day bar series labeled Sunday through Saturday with the peak day visually emphasized.
- **FR-029**: The dashboard MUST show a Sales Distribution panel with a donut visualization and a legend listing Website, Mobile App, and Other with their amounts and a period control.
- **FR-030**: The dashboard MUST show a List of Integration panel with row selection, the columns Application, Type, Rate, and Profit, a proportional rate indicator per row, and a "See All" action.
- **FR-031**: Every figure on the dashboard MUST be derived from persisted workspace records for the selected period; no metric value may be hardcoded in the interface.
- **FR-032**: Changing the reporting date range MUST recalculate the metric cards and all period-dependent panels, and MUST update the displayed range label.
- **FR-033**: Changing the granularity between monthly and weekly MUST change the series grouping and labels for the affected panels while keeping totals consistent with the same period.
- **FR-034**: The Filter action MUST let the user narrow data by at least region and sales channel, MUST show the active filters, and MUST provide a way to clear them.
- **FR-035**: Search on the dashboard MUST filter integration rows by application name or type, MUST announce the result count, and MUST offer a clear-search action.
- **FR-036**: Export MUST produce a downloadable representation of the currently displayed metrics and integration rows, honoring the active period, filters, and row selection.
- **FR-037**: Empty, partial, and zero-value datasets MUST render explicit empty states or neutral indicators instead of broken charts, undefined values, or misleading totals.
- **FR-038**: Panels MUST preserve their layout while data is loading and MUST offer a retry path when loading fails.

#### Presentation, typography, and accessibility

- **FR-039**: All pages MUST use the Inter typeface as the primary interface font, with a system font fallback for unavailable web-font loading.
- **FR-040**: The dashboard MUST follow the reference visual language: light theme, soft grey canvas, white rounded cards with subtle borders, indigo and violet primary accents, teal highlights for positive comparisons, and pink-red treatment for negative comparisons.
- **FR-041**: Metric values, dates, currency, and percentages MUST use consistent formatting, including thousands separators and two-decimal currency in the workspace currency.
- **FR-042**: All three pages MUST be responsive from 360px to 1920px without horizontal scrolling or clipped primary actions.
- **FR-043**: Interactive controls MUST have accessible names, visible focus states, logical tab order, and adequate color contrast (WCAG 2.1 AA).
- **FR-044**: Charts MUST provide a textual alternative (summary or data table) so the underlying values are available to assistive technology.
- **FR-045**: Each page MUST set a descriptive browser tab title and MUST offer a navigable path back to its parent area (no dead ends).
- **FR-046**: Motion MUST respect the user's reduced-motion preference and MUST NOT block interaction.

### Reference Layout (visual target)

The dashboard must reproduce the following composition from the supplied reference design. Figures are the seeded default-period values and serve as visual parity targets; they must still be produced from stored records.

| Region | Required content |
|--------|------------------|
| Sidebar | Brand mark "Nexus"; General (Dashboard active, Payment, Customers, Message with count 8); Tools (Product, Invoice, Analytics, Automation with BETA tag); Support (Settings, Security, Help); workspace switcher "Marketing / Team"; Upgrade Plan; copyright line |
| Top bar | Search with ⌘+F hint; gift, notification, and add controls; profile "Young Alaska / Business" |
| Page header | "Dashboard"; range "Oct 18 – Nov 18"; "Monthly" selector; Filter; Export |
| KPI row | Page Views 12,450 (+15.8%); Total Revenue $363.95 (-34.0%); Bounce Rate 86.5% (+24.2%) |
| Sales Overview | $9,257.51; +15.8% and +$143.50 increased; Oct $2,988.20, Nov $1,765.09, Dec $4,005.65; legend China, UE, USA, Canada, Other; Filter, Sort, and overflow actions |
| Total Subscriber | 24,473; +8.3% and +749 increased; Sun–Sat bars with Tuesday peak 3,874; "Weekly" selector |
| Sales Distribution | Website $374.82; Mobile App $241.60; Other $213.42; donut; "Monthly" selector |
| Integrations | Selectable rows: Stripe / Finance / 40% / $650.00; Zapier / CRM / 80% / $720.50; Shopify / Marketplace / 20% / $432.25; "See All" |

### Key Entities *(include if feature involves data)*

- **Account**: A person who can sign in. Holds display name, email address (unique), hashed credential, role label (for example "Business"), and a reference to the workspace they belong to.
- **Workspace**: The tenant whose data the dashboard reports on. Holds name (for example "Marketing"), plan label ("Team"), reporting currency, and the membership link to accounts.
- **Session**: A signed-in period for an account, with creation time, last activity, and expiry, used to guard protected pages and remember the intended destination after sign-in.
- **Analytics Summary**: Period-level totals for the workspace — page views, revenue, bounce rate, subscriber count — plus each metric's comparison value for the preceding equivalent period.
- **Sales Record**: A monetary amount attributed to a reporting month, a region (China, UE, USA, Canada, Other), and optionally a channel, used for the stacked sales overview and aggregate growth.
- **Subscriber Snapshot**: A subscriber count for a specific date or day label within the period, used for the weekly subscriber series and peak emphasis.
- **Channel Distribution**: A channel name (Website, Mobile App, Other) with its revenue amount for the selected period, used for the donut and legend.
- **Integration**: A connected third-party application with name, type label, rate percentage, profit amount, and display order, used for the integrations table, search, selection, and export.
- **Message Notification Count**: The unread message count surfaced as the sidebar badge.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A first-time evaluator can move from the landing page to a signed-in dashboard in under 90 seconds using only on-screen guidance.
- **SC-002**: At least 95% of new users who submit valid account details reach the dashboard on their first attempt without support.
- **SC-003**: Every figure displayed on the dashboard can be traced to a stored record for the selected period; an audit of the default view finds zero hardcoded metric values.
- **SC-004**: The documented demo account signs in successfully on the first attempt immediately after setup, and repeating the setup leaves record counts unchanged.
- **SC-005**: Switching the reporting period or granularity updates all dependent dashboard figures in under 1 second for the seeded dataset, with totals that reconcile exactly to the underlying records.
- **SC-006**: An independent visual review rates the dashboard at least 90% aligned with the supplied reference across layout regions, typography, spacing, and color treatment at a 1440px viewport.
- **SC-007**: Zero dashboard data is rendered to unauthenticated visitors, verified by direct URL access attempts in a signed-out browser.
- **SC-008**: All three pages remain fully operable from 360px to 1920px with zero horizontal scrollbars and no clipped primary actions.
- **SC-009**: A keyboard-only user can complete sign-up, sign-in, reach the dashboard, filter data, and sign out without a pointer device.
- **SC-010**: All interactive elements expose accessible names and all text meets WCAG 2.1 AA contrast, confirmed by an automated accessibility scan with zero critical findings.
- **SC-011**: At least 90% of template evaluators report that the dashboard looks production-ready and that the data feels realistic (post-review survey).

## Assumptions

- **Stack alignment**: The feature is delivered inside the existing Rails + Inertia application in this repository, following the guidance the project ships in `llms-full.txt`. The interface follows the conventions the template already documents (Inertia page components, server-provided props, and the project's documented frontend tooling). These are implementation constraints, not user-facing requirements.
- **Single workspace**: The template demonstrates one workspace ("Marketing") per account; multi-workspace creation, invitations, and switching between real workspaces are out of scope. The switcher displays the active workspace and plan only.
- **Authentication method**: Email and password with server-side sessions. Social sign-in, single sign-on, multi-factor authentication, and API tokens are not included.
- **Password reset and verification**: Password reset, email verification, and account deletion are out of scope for this first version; the demo account is seeded and ready to use.
- **Dashboard is read-only analytics**: No data entry, record editing, or real third-party integration synchronization is required. The dashboard reads seeded records.
- **Reference period and values**: The default reporting window mirrors the reference design (Oct 18 – Nov 18) with seeded records for the months shown; totals and deltas are generated from those records. Seed data may be regenerated but must remain deterministic for the default view.
- **Out-of-scope navigation items**: Sidebar destinations other than Dashboard (Payment, Customers, Message, Product, Invoice, Analytics, Automation, Settings, Security, Help) are present to demonstrate the shell and clearly marked as unavailable previews rather than built-out features.
- **Design scope**: Light theme only, desktop-first at 1440px, English-only copy, US dollar amounts, no dark mode, no localization, and no email delivery.
- **Search and filters**: Dashboard search targets integrations; the filter action targets region and channel. Global search across all entities is out of scope.
- **Browser support**: Current evergreen browsers on desktop and mobile; the existing application's modern-browser policy applies.
- **Demo credentials**: The demo account credentials are intentionally public within the template and are displayed on the sign-in page with a note that they are for demonstration only.

## Out of Scope

- Real payment processing, invoicing, billing, or plan upgrades; "Upgrade Plan" is a demonstrative action with a clear placeholder response.
- Real-time updates, notification delivery, messaging, or background jobs triggered by dashboard activity.
- Export formats beyond a single spreadsheet-friendly file, scheduled reports, and emailed reports.
- Multi-language content, right-to-left layouts, dark mode, and user-selectable themes.
- Administrative tools for managing other accounts, roles, or permissions beyond the dashboard access gate.

## Dependencies

- An initialized application database with the demo seed data applied.
- The public landing page depends on no authenticated session; the dashboard and any future application area depend on the authentication flow in this specification.
- The supplied dashboard reference composition and the project contribution guidance in `llms-full.txt` are the sources of truth for layout and conventions.
