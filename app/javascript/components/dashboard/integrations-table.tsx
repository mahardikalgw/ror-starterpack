import { Card, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Checkbox } from '@/components/ui/checkbox'
import { Progress } from '@/components/ui/progress'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { formatCurrency, formatRate } from '@/lib/format'
import type { IntegrationsPayload } from '@/lib/types'

interface IntegrationsTableProps {
  data: IntegrationsPayload
  selected: number[]
  onToggle: (id: number) => void
  onToggleAll: () => void
  onSeeAll: () => void
}

export function IntegrationsTable({ data, selected, onToggle, onToggleAll, onSeeAll }: IntegrationsTableProps) {
  const allSelected = data.rows.length > 0 && selected.length === data.rows.length

  return (
    <Card className="xl:col-span-2">
      <CardHeader>
        <CardTitle>List of Integration</CardTitle>
        {!data.showing_all && data.rows.length > 0 && (
          <Button variant="ghost" size="sm" onClick={onSeeAll}>
            See All
          </Button>
        )}
      </CardHeader>

      <p aria-live="polite" className="text-xs text-muted-foreground">
        {data.count} of {data.total_count} integrations shown
      </p>

      {data.empty ? (
        <p className="rounded-lg border border-dashed border-border p-4 text-sm text-muted-foreground">
          No integrations match this search.
        </p>
      ) : (
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead className="w-8">
                <Checkbox checked={allSelected} onCheckedChange={onToggleAll} aria-label="Select all integrations" />
              </TableHead>
              <TableHead>Application</TableHead>
              <TableHead>Type</TableHead>
              <TableHead>Rate</TableHead>
              <TableHead className="text-right">Profit</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {data.rows.map((row) => (
              <TableRow key={row.id} data-state={selected.includes(row.id) ? 'selected' : undefined}>
                <TableCell>
                  <Checkbox
                    checked={selected.includes(row.id)}
                    onCheckedChange={() => onToggle(row.id)}
                    aria-label={`Select ${row.name}`}
                  />
                </TableCell>
                <TableCell className="font-medium">{row.name}</TableCell>
                <TableCell className="text-muted-foreground">{row.category}</TableCell>
                <TableCell>
                  <span className="flex items-center gap-2">
                    <Progress value={row.rate} className="w-16" />
                    <span className="tabular-nums text-xs text-muted-foreground">{formatRate(row.rate)}</span>
                  </span>
                </TableCell>
                <TableCell className="text-right tabular-nums">{formatCurrency(row.profit)}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}
    </Card>
  )
}
