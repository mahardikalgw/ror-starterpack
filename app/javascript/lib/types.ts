// Mirrors specs/001-landing-auth-dashboard/contracts/*.md exactly (snake_case keys).

export interface AuthUser {
  id: number
  name: string
  role: string
  email_address: string
}

export interface AuthWorkspace {
  id: number
  name: string
  plan: string
  currency: string
}

export interface SharedProps {
  auth: { user: AuthUser | null; workspace: AuthWorkspace | null }
  flash: { notice: string | null; alert: string | null }
  errors: Record<string, string>
}

export interface Delta {
  direction: 'up' | 'down' | 'flat'
  percentage: number | null
  amount: number
}

export interface KpiCard {
  key: string
  label: string
  format: 'integer' | 'currency' | 'percentage'
  value: number
  delta: Delta
}

export interface Period {
  start_date: string
  end_date: string
  label: string
  granularity: 'monthly' | 'weekly'
  comparison: { start_date: string; end_date: string }
  days: number
}

export interface FilterOption {
  value: string
  label: string
}

export interface Filters {
  regions: string[]
  channels: string[]
  region_options: FilterOption[]
  channel_options: FilterOption[]
  query: string
  active: boolean
  labels: string[]
}

export interface SalesBucket {
  key: string
  label: string
  series: Record<string, number>
  total: number
}

export interface SalesOverview {
  total: number
  delta: Delta
  series_meta: { key: string; label: string }[]
  buckets: SalesBucket[]
}

export interface Subscribers {
  total: number
  delta: Delta
  series: { date: string; label: string; count: number }[]
  peak: { label: string; count: number } | null
}

export interface DistributionBucket {
  channel: string
  label: string
  amount: number
  percentage: number
}

export interface IntegrationRow {
  id: number
  name: string
  category: string
  rate: number
  profit: number
}

export interface IntegrationsPayload {
  rows: IntegrationRow[]
  count: number
  total_count: number
  showing_all: boolean
  empty: boolean
}

export interface NavItem {
  key: string
  label: string
  icon: string
  href: string | null
  active: boolean
  disabled: boolean
  badge: { text: string; variant: string } | null
}

export interface Navigation {
  groups: { label: string; items: NavItem[] }[]
  workspace: { name: string; plan: string }
  unread_count: number
}

export interface DashboardProps extends SharedProps {
  period: Period
  filters: Filters
  kpis: KpiCard[]
  sales_overview: SalesOverview
  subscribers: Subscribers
  distribution: { buckets: DistributionBucket[] }
  integrations: IntegrationsPayload
  navigation: Navigation
  meta: { page_title: string }
}
