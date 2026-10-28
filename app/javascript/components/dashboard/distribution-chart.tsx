import { Cell, Pie, PieChart } from 'recharts'
import { Card, CardHeader, CardTitle } from '@/components/ui/card'
import {
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
  type ChartConfig,
} from '@/components/ui/chart'
import { formatCurrency } from '@/lib/format'
import type { DistributionBucket } from '@/lib/types'
import { EmptyState } from './panel-states'

const SLICE_COLORS = ['var(--chart-1)', 'var(--chart-2)', 'var(--chart-3)', 'var(--chart-4)']

export function DistributionChart({ buckets }: { buckets: DistributionBucket[] }) {
  const config: ChartConfig = Object.fromEntries(
    buckets.map((bucket, index) => [
      bucket.channel,
      { label: bucket.label, color: SLICE_COLORS[index % SLICE_COLORS.length] },
    ]),
  )

  return (
    <Card>
      <CardHeader>
        <CardTitle>Sales Distribution</CardTitle>
      </CardHeader>

      {buckets.length === 0 && <EmptyState message="No channel revenue in this period." />}
      <ChartContainer
        config={config}
        className={`h-48 w-full ${buckets.length === 0 ? 'hidden' : ''}`}
      >
        <PieChart>
          <ChartTooltip
            content={<ChartTooltipContent formatter={(value) => formatCurrency(Number(value))} />}
          />
          <Pie
            data={buckets}
            dataKey="amount"
            nameKey="label"
            innerRadius={45}
            outerRadius={75}
            paddingAngle={3}
          >
            {buckets.map((bucket) => (
              <Cell key={bucket.channel} fill={`var(--color-${bucket.channel})`} />
            ))}
          </Pie>
        </PieChart>
      </ChartContainer>

      <ul className="flex flex-col gap-1.5">
        {buckets.map((bucket, index) => (
          <li key={bucket.channel} className="flex items-center justify-between gap-2 text-xs">
            <span className="flex items-center gap-1.5">
              <span
                className="size-2 rounded-full"
                style={{ background: SLICE_COLORS[index % SLICE_COLORS.length] }}
                aria-hidden
              />
              {bucket.label}
            </span>
            <span className="tabular-nums text-muted-foreground">{formatCurrency(bucket.amount)}</span>
          </li>
        ))}
      </ul>
    </Card>
  )
}
