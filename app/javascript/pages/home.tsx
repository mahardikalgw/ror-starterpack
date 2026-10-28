import { Head, Link } from '@inertiajs/react'
import { ArrowRight, BarChart3, Check, Database, LayoutDashboard, ShieldCheck } from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { MarketingLayout } from '@/layouts/marketing-layout'
import type { SharedProps } from '@/lib/types'

type MarketingProps = SharedProps & {
  marketing: {
    signed_in: boolean
    primary_cta: { label: string; href: string }
    secondary_cta: { label: string; href: string } | null
    value_props: { icon: string; title: string; description: string }[]
    proof: { metric: string; label: string }[]
    preview: { title: string; description: string }
    footer_links: { label: string; href: string | null; available: boolean }[]
  }
  meta: { page_title: string }
}

const ICONS = { 'layout-dashboard': LayoutDashboard, database: Database, 'shield-check': ShieldCheck }

// Raw markup on this page is limited to non-interactive layout containers
// (header, section, footer, headings, paragraphs, lists). Interactive elements use
// Button/Card/Badge; see contracts/component-inventory.md for the allowlist.
export default function Home({ marketing, meta, flash }: MarketingProps) {
  const header = (
    <header className="mx-auto flex w-full max-w-6xl flex-wrap items-center justify-between gap-3 px-4 py-4">
      <a href="/" className="flex items-center gap-2 text-base font-semibold">
        <span className="grid size-8 place-items-center rounded-lg bg-primary text-sm font-bold text-primary-foreground">N</span>
        Nexus
      </a>
      <nav aria-label="Account" className="flex items-center gap-2">
        {marketing.secondary_cta && (
          <Button variant="ghost" size="sm" asChild>
            <Link href={marketing.secondary_cta.href}>{marketing.secondary_cta.label}</Link>
          </Button>
        )}
        <Button size="sm" asChild>
          <Link href={marketing.primary_cta.href}>
            {marketing.primary_cta.label} <ArrowRight className="size-3.5" aria-hidden />
          </Link>
        </Button>
      </nav>
    </header>
  )

  const footer = (
    <footer className="mt-16 border-t border-border bg-card">
      <div className="mx-auto flex w-full max-w-6xl flex-col gap-3 px-4 py-8 text-xs text-muted-foreground sm:flex-row sm:items-center sm:justify-between">
        <p>© 2023 Nexus. An analytics dashboard starter template.</p>
        <ul className="flex flex-wrap gap-4">
          {marketing.footer_links.map((link) => (
            <li key={link.label}>
              {link.available && link.href ? (
                <Link href={link.href} className="hover:text-foreground">{link.label}</Link>
              ) : (
                <span aria-disabled="true" className="cursor-not-allowed opacity-60" title="Preview — not included in this template">
                  {link.label}
                </span>
              )}
            </li>
          ))}
        </ul>
      </div>
    </footer>
  )

  return (
    <>
      <Head title={meta.page_title} />
      <MarketingLayout header={header} footer={footer}>
        {flash?.alert && (
          <p role="alert" className="mt-4 rounded-lg bg-destructive/10 px-3 py-2 text-xs font-medium text-destructive">
            {flash.alert}
          </p>
        )}

        <section className="flex flex-col items-start gap-4 py-14 sm:items-center sm:text-center">
          <Badge variant="outline">Rails 8 + Inertia + React</Badge>
          <h1 className="max-w-2xl text-3xl font-semibold tracking-tight sm:text-4xl">
            An analytics dashboard that ships with real data
          </h1>
          <p className="max-w-xl text-sm text-muted-foreground">
            Landing page, authentication, and a data-backed dashboard in one Rails application. Every number is
            aggregated from the database, never hardcoded.
          </p>
          <div className="flex flex-wrap items-center gap-2">
            <Button size="lg" asChild>
              <Link href={marketing.primary_cta.href}>
                {marketing.primary_cta.label} <ArrowRight className="size-4" aria-hidden />
              </Link>
            </Button>
            {marketing.secondary_cta && (
              <Button size="lg" variant="outline" asChild>
                <Link href={marketing.secondary_cta.href}>{marketing.secondary_cta.label}</Link>
              </Button>
            )}
          </div>
        </section>

        <section aria-labelledby="value-props" className="grid gap-4 sm:grid-cols-3">
          <h2 id="value-props" className="sr-only">What this template provides</h2>
          {marketing.value_props.map((prop) => {
            const Icon = ICONS[prop.icon as keyof typeof ICONS] ?? BarChart3

            return (
              <Card key={prop.title}>
                <Icon className="size-5 text-primary" aria-hidden />
                <h3 className="text-sm font-semibold">{prop.title}</h3>
                <p className="text-xs text-muted-foreground">{prop.description}</p>
              </Card>
            )
          })}
        </section>

        <section className="mt-10 rounded-2xl border border-border bg-card p-6">
          <h2 className="text-sm font-semibold">{marketing.preview.title}</h2>
          <p className="mb-4 text-xs text-muted-foreground">{marketing.preview.description}</p>
          <div className="grid gap-3 sm:grid-cols-3" aria-hidden>
            {['Page Views', 'Total Revenue', 'Bounce Rate'].map((label) => (
              <Card key={label} className="bg-secondary/50 p-4 shadow-none">
                <p className="text-[11px] text-muted-foreground">{label}</p>
                <div className="mt-2 h-2 w-2/3 rounded bg-primary/30" />
                <div className="mt-6 h-16 rounded-lg bg-primary/10" />
              </Card>
            ))}
          </div>
        </section>

        <section aria-labelledby="proof" className="mt-10 grid gap-4 sm:grid-cols-3">
          <h2 id="proof" className="sr-only">Outcome metrics</h2>
          {marketing.proof.map((item) => (
            <div key={item.label} className="flex items-start gap-2">
              <Check className="mt-0.5 size-4 text-positive-foreground" aria-hidden />
              <p className="text-sm">
                <span className="font-semibold">{item.metric}</span>{' '}
                <span className="text-muted-foreground">{item.label}</span>
              </p>
            </div>
          ))}
        </section>

        <section className="mt-12 flex flex-col items-start gap-3 rounded-2xl bg-primary px-6 py-10 text-primary-foreground sm:items-center sm:text-center">
          <h2 className="text-xl font-semibold tracking-tight">Ready to explore the dashboard?</h2>
          <Button size="lg" variant="secondary" asChild>
            <Link href={marketing.primary_cta.href}>{marketing.primary_cta.label}</Link>
          </Button>
        </section>
      </MarketingLayout>
    </>
  )
}
