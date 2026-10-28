import { Head, router } from '@inertiajs/react'
import { useEffect, useMemo, useRef, useState } from 'react'
import { DashboardHeader } from '@/components/dashboard/dashboard-header'
import { DistributionChart } from '@/components/dashboard/distribution-chart'
import { IntegrationsTable } from '@/components/dashboard/integrations-table'
import { KpiCards } from '@/components/dashboard/kpi-cards'
import { SalesOverviewChart } from '@/components/dashboard/sales-overview-chart'
import { SubscribersChart } from '@/components/dashboard/subscribers-chart'
import { DashboardLayout } from '@/layouts/dashboard-layout'
import type { DashboardProps } from '@/lib/types'

const PANEL_KEYS = ['period', 'filters', 'kpis', 'sales_overview', 'subscribers', 'distribution', 'integrations', 'navigation']

export default function DashboardIndex({
  auth, period, filters, kpis, sales_overview, subscribers, distribution, integrations, navigation, meta,
}: DashboardProps) {
  const [query, setQuery] = useState(filters.query)
  const [selected, setSelected] = useState<number[]>([])
  const debounce = useRef<number | null>(null)

  const buildParams = (overrides: Record<string, string | string[]> = {}) => {
    const params: Record<string, string | string[]> = {
      start_date: period.start_date,
      end_date: period.end_date,
      granularity: period.granularity,
    }
    if (filters.regions.length > 0) params['regions[]'] = filters.regions
    if (filters.channels.length > 0) params['channels[]'] = filters.channels
    if (filters.query) params.q = filters.query
    if (integrations.showing_all) params.all = '1'

    return { ...params, ...overrides }
  }

  const visit = (params: Record<string, string | string[]>, only: string[]) => {
    router.get('/dashboard', params, { only, preserveState: true, preserveScroll: true })
  }

  // Server-side search, debounced so typing does not flood the server (FR-035).
  useEffect(() => {
    if (query === filters.query) return undefined

    if (debounce.current) window.clearTimeout(debounce.current)
    debounce.current = window.setTimeout(() => {
      visit(buildParams({ q: query }), ['integrations', 'filters'])
    }, 250)

    return () => {
      if (debounce.current) window.clearTimeout(debounce.current)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [query])

  const exportHref = useMemo(() => {
    const params = new URLSearchParams({
      start_date: period.start_date,
      end_date: period.end_date,
      granularity: period.granularity,
    })
    filters.regions.forEach((region) => params.append('regions[]', region))
    filters.channels.forEach((channel) => params.append('channels[]', channel))
    if (filters.query) params.set('q', filters.query)
    selected.forEach((id) => params.append('ids[]', String(id)))

    return `/dashboard/export?${params.toString()}`
  }, [period, filters, selected])

  const toggleRow = (id: number) =>
    setSelected((current) => (current.includes(id) ? current.filter((item) => item !== id) : [...current, id]))

  const toggleAll = () =>
    setSelected((current) => (current.length === integrations.rows.length ? [] : integrations.rows.map((row) => row.id)))

  return (
    <>
      <Head title={meta.page_title} />
      <DashboardLayout
        navigation={navigation}
        user={auth.user}
        workspace={auth.workspace}
        query={query}
        onQueryChange={setQuery}
        onSignOut={() => router.delete('/session')}
      >
        <DashboardHeader
          period={period}
          filters={filters}
          exportHref={exportHref}
          onGranularityChange={(granularity) => visit(buildParams({ granularity }), PANEL_KEYS)}
          onFilterChange={(regions, channels) =>
            visit(buildParams({ 'regions[]': regions, 'channels[]': channels }), PANEL_KEYS)
          }
        />

        <KpiCards kpis={kpis} />

        <div className="grid gap-4 xl:grid-cols-3">
          <div className="xl:col-span-2">
            <SalesOverviewChart data={sales_overview} />
          </div>
          <SubscribersChart data={subscribers} />
        </div>

        <div className="grid gap-4 xl:grid-cols-3">
          <DistributionChart buckets={distribution.buckets} />
          <IntegrationsTable
            data={integrations}
            selected={selected}
            onToggle={toggleRow}
            onToggleAll={toggleAll}
            onSeeAll={() => visit(buildParams({ all: '1' }), ['integrations'])}
          />
        </div>
      </DashboardLayout>
    </>
  )
}
