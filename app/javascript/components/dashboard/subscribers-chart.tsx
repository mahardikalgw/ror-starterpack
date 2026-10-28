import { Bar, BarChart, Cell, XAxis, YAxis } from 'recharts'
import { Card, CardHeader, CardTitle } from '@/components/ui/card'
import {
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
  type ChartConfig,
} from '@/components/ui/chart'
import { formatDelta, formatNumber } from '@/lib/format'
import type { Subscribers } from '@/lib/types'
import { EmptyState } from './panel-states'

export function SubscribersChart({ data }: { data: Subscribers }) {
  const config: ChartConfig = {
    count: { label: 'Subscribers', color: 'var(--chart-1)' },
    peak: { label: 'Peak day', color: 'var(--chart-3)' },
  }

  return (
    <Card>
      <CardHeader>
        <div>
          <CardTitle>Total Subscriber</CardTitle>
          <p className="text-xs text-muted-foreground">
            <span className="text-base font-semibold text-foreground">{formatNumber(data.total)}</span>{' '}
            <span className="text-positive-foreground">
              {formatDelta(data.delta.percentage)} (+{formatNumber(data.delta.amount)})
            </span>
          </p>
        </div>
      </CardHeader>

      {data.series.length === 0 && <EmptyState message="No subscribers recorded in this period." />}
      <ChartContainer
        config={config}
        className={`h-48 w-full ${data.series.length === 0 ? 'hidden' : ''}`}
      >
        <BarChart data={data.series}>
          <XAxis dataKey="label" tickLine={false} axisLine={false} fontSize={12} />
          <YAxis hide />
          <ChartTooltip
            content={<ChartTooltipContent formatter={(value) => formatNumber(Number(value))} />}
          />
          <Bar dataKey="count" radius={[6, 6, 0, 0]} fill="var(--color-count)">
            {data.series.map((point) => (
              <Cell
                key={point.date}
                fill={data.peak?.label === point.label ? 'var(--color-peak)' : 'var(--color-count)'}
              />
            ))}
          </Bar>
        </BarChart>
      </ChartContainer>

      <table className="sr-only">
        <caption>Subscribers by weekday</caption>
        <tbody>
          {data.series.map((point) => (
            <tr key={point.date}>
              <th scope="row">{point.label}</th>
              <td>{formatNumber(point.count)}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </Card>
  )
}
