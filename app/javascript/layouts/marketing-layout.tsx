import type { ReactNode } from 'react'

export function MarketingLayout({ header, footer, children }: { header: ReactNode; footer: ReactNode; children: ReactNode }) {
  return (
    <div className="min-h-screen bg-background">
      {header}
      <main className="mx-auto w-full max-w-6xl px-4">{children}</main>
      {footer}
    </div>
  )
}
