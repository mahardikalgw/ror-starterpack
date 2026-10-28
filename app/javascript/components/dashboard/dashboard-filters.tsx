import { SlidersHorizontal } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Checkbox } from '@/components/ui/checkbox'
import {
  DropdownMenu, DropdownMenuContent, DropdownMenuLabel,
  DropdownMenuSeparator, DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import type { Filters } from '@/lib/types'

interface DashboardFiltersProps {
  filters: Filters
  onChange: (regions: string[], channels: string[]) => void
}

export function DashboardFilters({ filters, onChange }: DashboardFiltersProps) {
  const toggle = (values: string[], value: string) =>
    values.includes(value) ? values.filter((item) => item !== value) : [...values, value]

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="outline" size="sm">
          <SlidersHorizontal className="size-3.5" aria-hidden /> Filter
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="w-56">
        <DropdownMenuLabel className="text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">
          Region
        </DropdownMenuLabel>
        {filters.region_options.map((option) => (
          <label key={option.value} className="flex cursor-pointer items-center gap-2 rounded-md px-2.5 py-1.5 text-sm hover:bg-secondary">
            <Checkbox
              checked={filters.regions.includes(option.value)}
              onCheckedChange={() => onChange(toggle(filters.regions, option.value), filters.channels)}
            />
            {option.label}
          </label>
        ))}
        <DropdownMenuSeparator />
        <DropdownMenuLabel className="text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">
          Channel
        </DropdownMenuLabel>
        {filters.channel_options.map((option) => (
          <label key={option.value} className="flex cursor-pointer items-center gap-2 rounded-md px-2.5 py-1.5 text-sm hover:bg-secondary">
            <Checkbox
              checked={filters.channels.includes(option.value)}
              onCheckedChange={() => onChange(filters.regions, toggle(filters.channels, option.value))}
            />
            {option.label}
          </label>
        ))}
      </DropdownMenuContent>
    </DropdownMenu>
  )
}
