// Single place where numbers become display strings (FR-041). The server always
// sends integers: cents for money, basis points for rates, ISO dates for dates.

export const formatNumber = (value: number): string =>
  new Intl.NumberFormat('en-US').format(Math.round(value))

export const formatCurrency = (cents: number): string =>
  new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(cents / 100)

export const formatPercent = (basisPoints: number): string => `${(basisPoints / 100).toFixed(1)}%`

export const formatRate = (rate: number): string => `${rate}%`

export const formatDelta = (percentage: number | null): string =>
  percentage === null ? '—' : `${percentage > 0 ? '+' : ''}${percentage.toFixed(1)}%`

export const formatDateLabel = (isoDate: string): string =>
  new Intl.DateTimeFormat('en-US', { month: 'short', day: 'numeric' }).format(
    new Date(`${isoDate}T00:00:00`),
  )

export const formatMetric = (value: number, format: 'integer' | 'currency' | 'percentage'): string => {
  if (format === 'currency') return formatCurrency(value)
  if (format === 'percentage') return formatPercent(value)
  return formatNumber(value)
}

export const deltaClass = (direction: 'up' | 'down' | 'flat'): string => {
  if (direction === 'up') return 'text-positive-foreground'
  if (direction === 'down') return 'text-negative-foreground'
  return 'text-muted-foreground'
}
