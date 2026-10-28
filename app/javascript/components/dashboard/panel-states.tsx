import { Skeleton } from '@/components/ui/skeleton'

export function PanelSkeleton({ label }: { label: string }) {
  return (
    <div className="flex flex-col gap-2 rounded-2xl border border-border bg-card p-5">
      <span className="text-xs text-muted-foreground">{label}</span>
      <Skeleton className="h-24 w-full" />
    </div>
  )
}

export function EmptyState({ message }: { message: string }) {
  return (
    <p className="rounded-lg border border-dashed border-border p-4 text-sm text-muted-foreground">{message}</p>
  )
}
