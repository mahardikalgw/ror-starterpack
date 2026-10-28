import { ArrowDownRight, ArrowUpRight, Minus } from 'lucide-react'
import { Card } from '@/components/ui/card'
import { formatDelta, formatMetric } from '@/lib/format'
import type { KpiCard } from '@/lib/types'

const ICONS = { up: ArrowUpRight, down: ArrowDownRight, flat: Minus }
const TONES = {
  up: 'text-positive-foreground',
  down: 'text-negative-foreground',
  flat: 'text-muted-foreground',
}

export function KpiCards({ kpis }: { kpis: KpiCard[] }) {
  return (
    <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
      {kpis.map((kpi) => {
        const Icon = ICONS[kpi.delta.direction]

        return (
          <Card key={kpi.key}>
            <p className="text-xs font-medium text-muted-foreground">{kpi.label}</p>
            <p className="text-2xl font-semibold tracking-tight tabular-nums">
              {formatMetric(kpi.value, kpi.format)}
            </p>
            <p className={`flex items-center gap-1 text-xs font-medium ${TONES[kpi.delta.direction]}`}>
              <Icon className="size-3.5" aria-hidden />
              {formatDelta(kpi.delta.percentage)}
              <span className="text-muted-foreground">vs previous period</span>
            </p>
          </Card>
        )
      })}
    </div>
  )
}
