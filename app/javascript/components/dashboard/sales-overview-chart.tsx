import { Bar, BarChart, CartesianGrid, XAxis, YAxis } from 'recharts'
import { Card, CardHeader, CardTitle } from '@/components/ui/card'
import {
  ChartContainer,
  ChartLegend,
  ChartLegendContent,
  ChartTooltip,
  ChartTooltipContent,
  type ChartConfig,
} from '@/components/ui/chart'
import { formatCurrency, formatDelta } from '@/lib/format'
import type { SalesOverview } from '@/lib/types'
import { EmptyState } from './panel-states'

const SERIES_COLORS = [
  'var(--chart-1)',
  'var(--chart-2)',
  'var(--chart-3)',
  'var(--chart-4)',
  'var(--chart-5)',
]

export function SalesOverviewChart({ data }: { data: SalesOverview }) {
  const rows = data.buckets.map((bucket) => ({ label: bucket.label, ...bucket.series }))

  const config: ChartConfig = Object.fromEntries(
    data.series_meta.map((series, index) => [
      series.key,
      { label: series.label, color: SERIES_COLORS[index % SERIES_COLORS.length] },
    ]),
  )

  return (
    <Card>
      <CardHeader>
        <div>
          <CardTitle>Sales Overview</CardTitle>
          <p className="text-xs text-muted-foreground">
            <span className="text-base font-semibold text-foreground">{formatCurrency(data.total)}</span>{' '}
            <span className="text-positive-foreground">
              {formatDelta(data.delta.percentage)} ({formatCurrency(data.delta.amount)})
            </span>{' '}
            increased
          </p>
        </div>
      </CardHeader>

      {data.buckets.length === 0 && <EmptyState message="No sales recorded in this period." />}
      <ChartContainer
        config={config}
        className={`h-64 w-full ${data.buckets.length === 0 ? 'hidden' : ''}`}
      >
        <BarChart data={rows}>
          <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="var(--border)" />
          <XAxis dataKey="label" tickLine={false} axisLine={false} fontSize={12} />
          <YAxis
            tickLine={false}
            axisLine={false}
            fontSize={12}
            tickFormatter={(value) => `$${Math.round(Number(value) / 100)}`}
          />
          <ChartTooltip
            content={<ChartTooltipContent formatter={(value) => formatCurrency(Number(value))} />}
          />
          <ChartLegend content={<ChartLegendContent />} />
          {data.series_meta.map((series, index) => (
            <Bar
              key={series.key}
              dataKey={series.key}
              name={series.label}
              stackId="sales"
              fill={`var(--color-${series.key})`}
              radius={index === data.series_meta.length - 1 ? [6, 6, 0, 0] : [0, 0, 0, 0]}
            />
          ))}
        </BarChart>
      </ChartContainer>

      {/* Text alternative for assistive technology (FR-044). */}
      <table className="sr-only">
        <caption>Regional sales by period</caption>
        <thead>
          <tr>
            <th scope="col">Period</th>
            {data.series_meta.map((series) => (
              <th key={series.key} scope="col">{series.label}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {data.buckets.map((bucket) => (
            <tr key={bucket.key}>
              <th scope="row">{bucket.label}</th>
              {data.series_meta.map((series) => (
                <td key={series.key}>{formatCurrency(bucket.series[series.key] ?? 0)}</td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </Card>
  )
}
