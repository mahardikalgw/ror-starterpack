import { Download, SlidersHorizontal } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { ToggleGroup, ToggleGroupItem } from '@/components/ui/toggle-group'
import type { Filters, Period } from '@/lib/types'
import { DashboardFilters } from './dashboard-filters'

interface DashboardHeaderProps {
  period: Period
  filters: Filters
  exportHref: string
  onGranularityChange: (granularity: 'monthly' | 'weekly') => void
  onFilterChange: (regions: string[], channels: string[]) => void
}

export function DashboardHeader({ period, filters, exportHref, onGranularityChange, onFilterChange }: DashboardHeaderProps) {
  return (
    <div className="flex flex-wrap items-end justify-between gap-3">
      <div>
        <h1 className="text-xl font-semibold tracking-tight">Dashboard</h1>
        <p className="text-xs text-muted-foreground">{period.label}</p>
      </div>

      <div className="flex flex-wrap items-center gap-2">
        <ToggleGroup
          type="single"
          value={period.granularity}
          onValueChange={(value) => value && onGranularityChange(value as 'monthly' | 'weekly')}
          aria-label="Granularity"
          className="gap-0 rounded-lg border border-border bg-card p-0.5"
        >
          {(['monthly', 'weekly'] as const).map((option) => (
            <ToggleGroupItem
              key={option}
              value={option}
              size="sm"
              className="rounded-md px-3 text-xs capitalize"
            >
              {option}
            </ToggleGroupItem>
          ))}
        </ToggleGroup>

        <DashboardFilters filters={filters} onChange={onFilterChange} />

        <Button variant="outline" size="sm" asChild>
          <a href={exportHref}>
            <Download className="size-3.5" aria-hidden /> Export
          </a>
        </Button>
      </div>

      {filters.active && (
        <ul className="flex w-full flex-wrap items-center gap-1.5" aria-label="Active filters">
          {filters.labels.map((label) => (
            <li key={label} className="rounded-full bg-accent px-2 py-0.5 text-[11px] font-medium text-accent-foreground">
              {label}
            </li>
          ))}
          <li>
            <Button variant="link" size="sm" onClick={() => onFilterChange([], [])}>
              <SlidersHorizontal className="size-3" aria-hidden /> Clear
            </Button>
          </li>
        </ul>
      )}
    </div>
  )
}
