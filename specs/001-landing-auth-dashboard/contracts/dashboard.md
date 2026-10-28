# Contract: Dashboard Page Props

**Feature**: `001-landing-auth-dashboard`
**Date**: 2026-10-28
**Route**: `GET /dashboard` → `dashboard#index` → Inertia component `dashboard/index`
**Related**: [routes.md](./routes.md) (query params, auth guard, CSV export) · [data-model.md](../data-model.md) (sources)

Props serialize Rails snake_case keys unchanged (research D10). Every value below MUST be produced from
persisted records; if a field cannot be traced to a table or query object it MUST NOT be in the payload
(FR-031, SC-003).

## Envelope

```jsonc
{
  "component": "dashboard/index",
  "props": {
    "auth": { /* shared, see pages.md */ },
    "flash": { "alert": null, "notice": null },
    "errors": {},
    "period": { },
    "filters": { },
    "kpis": [ ],
    "sales_overview": { },
    "subscribers": { },
    "distribution": { },
    "integrations": { },
    "navigation": { },
    "meta": { }
  }
}
```

## `period` — `Dashboard::Period`

| Field | Type | Source / rule |
|-------|------|---------------|
| `start_date` | `string` (`YYYY-MM-DD`) | Parsed request param, default `2023-10-18` |
| `end_date` | `string` (`YYYY-MM-DD`) | Parsed request param, default `2023-11-18` |
| `label` | `string` | Rendered from the range, e.g. `"Oct 18 – Nov 18"` |
| `granularity` | `"monthly" \| "weekly"` | Default `monthly` |
| `comparison` | `object` | `{ "start_date": string, "end_date": string }`, equal length, ends the day before `start_date` |
| `days` | `integer` | Inclusive range length, 1–366 |

## `filters` — `Dashboard::Filters`

| Field | Type | Source / rule |
|-------|------|---------------|
| `regions` | `string[]` | Effective region filter (`china`, `eu`, `usa`, `canada`, `other`) |
| `channels` | `string[]` | Effective channel filter (`website`, `mobile_app`, `other`) |
| `region_options` | `{ value, label }[]` | Fixed list; label `UE` for value `eu` |
| `channel_options` | `{ value, label }[]` | Fixed list; label `Mobile App` for value `mobile_app` |
| `query` | `string` | Trimmed `q`, max 100 chars |
| `active` | `boolean` | True when any filter or query is set |
| `labels` | `string[]` | Human-readable chips for active filters, e.g. `["Region: USA"]` |

## `kpis` — `Dashboard::Metrics`

Exactly three entries, ordered `page_views`, `total_revenue`, `bounce_rate`.

| Field | Type | Source / rule |
|-------|------|---------------|
| `key` | `"page_views" \| "total_revenue" \| "bounce_rate"` | — |
| `label` | `string` | `"Page Views"`, `"Total Revenue"`, `"Bounce Rate"` |
| `format` | `"integer" \| "currency" \| "percentage"` | Drives client formatting only |
| `value` | `number` | `SUM(page_views)`, `SUM(revenue_cents)`, or weighted bounce rate in basis points |
| `delta.direction` | `"up" \| "down" \| "flat"` | Sign of the comparison difference |
| `delta.percentage` | `number \| null` | One decimal; `null` (rendered `—`) when the comparison base is zero |
| `delta.amount` | `number \| null` | Absolute difference in the metric's own unit |

Sources: `daily_metrics.page_views`, `daily_metrics.revenue_cents`, and
`SUM(bounced_sessions) / SUM(sessions_count)` over the period versus `comparison`. Bounce rate travels as
integer basis points (`*_bps`) and is displayed with one decimal.

## `sales_overview` — `Dashboard::SalesOverview`

| Field | Type | Source / rule |
|-------|------|---------------|
| `total` | `integer` | `SUM(sales_records.amount_cents)` over period after filters |
| `delta.direction` / `.percentage` / `.amount` | as above | Versus comparison period |
| `series_meta` | `{ key, label }[]` | `china`, `eu` (`UE`), `usa`, `canada`, `other` |
| `buckets` | `object[]` | One per calendar month or ISO week in the period |
| `buckets[].key` | `string` | `2023-10` (monthly) or `2023-W42` (weekly) |
| `buckets[].label` | `string` | `"Oct"` or `"Oct 16"` |
| `buckets[].series` | `{ [region]: integer }` | `SUM(amount_cents)` grouped by bucket and region; missing region is `0` |
| `buckets[].total` | `integer` | Sum of that bucket's series |

Bucket totals MUST sum to `total`, and `delta.percentage` MUST agree with `delta.amount` (research D9).

## `subscribers` — `Dashboard::Subscribers`

| Field | Type | Source / rule |
|-------|------|---------------|
| `total` | `integer` | `SUM(subscriber_snapshots.count)` over the period |
| `delta.*` | as above | Versus comparison period |
| `series` | `{ date, label, count }[]` | Last seven dated snapshots inside the period; `label` is the weekday (`Sun`…`Sat`) |
| `peak` | `{ label, count } \| null` | Maximum `count` in `series`; `null` when the series is empty |

## `distribution` — `Dashboard::Distribution`

| Field | Type | Source / rule |
|-------|------|---------------|
| `buckets` | `{ channel, label, amount, percentage }[]` | `SUM(channel_revenues.amount_cents)` grouped by channel over the period |
| `buckets[].percentage` | `number` | One decimal; shares MUST sum to 100.0 within ±0.1 rounding |

Labels: `Website`, `Mobile App`, `Other`.

## `integrations` — `Dashboard::Integrations`

| Field | Type | Source / rule |
|-------|------|---------------|
| `rows` | `object[]` | Ordered by `integrations.position`; searched by `q`; limited to 3 unless `all=1` |
| `rows[].id` | `integer` | Selection key used by export `ids[]` |
| `rows[].name` | `string` | Application column |
| `rows[].category` | `string` | Type column |
| `rows[].rate` | `integer` | `0..100`, rendered as `%` plus a proportional bar |
| `rows[].profit` | `integer` | `profit_cents` |
| `count` | `integer` | Rows returned (drives the `aria-live` announcement, FR-035) |
| `total_count` | `integer` | Rows matching the search before the limit |
| `showing_all` | `boolean` | Mirrors the `all` param |
| `empty` | `boolean` | True when `count` is zero (FR-037) |

## `navigation` — `Dashboard::Navigation`

| Field | Type | Source / rule |
|-------|------|---------------|
| `groups` | `{ label, items[] }[]` | `General`, `Tools`, `Support` in that order (FR-019) |
| `items[].key` | `string` | Stable identifier, e.g. `dashboard`, `payment` |
| `items[].label` | `string` | Sidebar text |
| `items[].icon` | `string` | Lucide icon name resolved on the client |
| `items[].href` | `string \| null` | Only `dashboard` has a route; others `null` |
| `items[].active` | `boolean` | True for `dashboard` (FR-019) |
| `items[].disabled` | `boolean` | True for the ten out-of-scope entries (FR-024) |
| `items[].badge` | `{ text, variant } \| null` | `Message` count from unread `messages`; `Automation` `BETA` |
| `workspace` | `{ name, plan }` | Active workspace switcher (FR-021) |
| `unread_count` | `integer` | `COUNT(messages) WHERE read_at IS NULL` |

## `meta`

| Field | Type | Rule |
|-------|------|------|
| `page_title` | `string` | `"Dashboard · Nexus"` (FR-045) |

## Partial Reload Keys

`router.get('/dashboard', params, { only: [...] })` may request any of:
`period`, `filters`, `kpis`, `sales_overview`, `subscribers`, `distribution`, `integrations`,
`navigation`. `auth`, `flash`, `errors`, and `meta` are always shared and MUST NOT be requested
individually.

## Empty and Degenerate Data

- Zero records in the period: `kpis[].value` = `0`, `delta.percentage` = `null`, `buckets` = `[]`,
  `distribution.buckets` = `[]`, `subscribers.peak` = `null`, `integrations.empty` = `true`.
- The payload MUST never contain `null` where a number is contracted, and MUST never emit `NaN`,
  `Infinity`, or a preformatted string (formatting is client-side, FR-041).
