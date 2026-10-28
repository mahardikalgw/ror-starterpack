import type { ReactNode } from 'react'
import { BarChart3, Layers, ShieldCheck } from 'lucide-react'

const HIGHLIGHTS = [
  {
    icon: BarChart3,
    title: 'Data-backed dashboard',
    description: 'Every metric is aggregated from stored records, never hardcoded.',
  },
  {
    icon: ShieldCheck,
    title: 'Session authentication',
    description: 'Server-side sessions with rate-limited sign-in and a route guard.',
  },
  {
    icon: Layers,
    title: 'One design system',
    description: 'The same component library across the landing page and the app.',
  },
]

interface AuthLayoutProps {
  title: string
  subtitle: string
  children: ReactNode
}

export function AuthLayout({ title, subtitle, children }: AuthLayoutProps) {
  return (
    <div className="grid min-h-screen bg-background lg:grid-cols-[1.05fr_1fr]">
      {/* Brand panel: hidden on small screens so the form owns the viewport. */}
      <aside className="relative hidden overflow-hidden bg-primary p-10 text-primary-foreground lg:flex lg:flex-col lg:justify-between">
        <div
          className="pointer-events-none absolute -right-24 -top-24 size-72 rounded-full bg-primary-foreground/10 blur-2xl"
          aria-hidden
        />
        <div
          className="pointer-events-none absolute -bottom-32 -left-20 size-80 rounded-full bg-primary-foreground/10 blur-3xl"
          aria-hidden
        />

        <a href="/" className="relative flex items-center gap-2 text-base font-semibold">
          <span className="grid size-9 place-items-center rounded-xl bg-primary-foreground/15 text-sm font-bold">
            N
          </span>
          Nexus
        </a>

        <div className="relative flex flex-col gap-9">
          <div className="flex flex-col gap-3">
            <h2 className="max-w-sm text-2xl font-semibold leading-tight tracking-tight">
              The analytics starter that ships with real data.
            </h2>
            <p className="max-w-sm text-sm text-primary-foreground/80">
              Sign in to explore a dashboard whose numbers come from the database, not from a mockup.
            </p>
          </div>

          <ul className="flex flex-col gap-5">
            {HIGHLIGHTS.map(({ icon: Icon, title: itemTitle, description }) => (
              <li key={itemTitle} className="flex items-start gap-3">
                <span className="mt-0.5 grid size-8 shrink-0 place-items-center rounded-lg bg-primary-foreground/15">
                  <Icon className="size-4" aria-hidden />
                </span>
                <span className="flex flex-col gap-0.5">
                  <span className="text-sm font-medium">{itemTitle}</span>
                  <span className="text-xs text-primary-foreground/75">{description}</span>
                </span>
              </li>
            ))}
          </ul>
        </div>

        <p className="relative text-xs text-primary-foreground/60">© 2023 Nexus. All rights reserved.</p>
      </aside>

      {/* Form panel */}
      <main className="flex min-h-screen flex-col justify-center px-4 py-12 sm:px-8">
        <div className="mx-auto w-full max-w-sm">
          <a href="/" className="mb-8 inline-flex items-center gap-2 text-base font-semibold lg:hidden">
            <span className="grid size-8 place-items-center rounded-lg bg-primary text-sm font-bold text-primary-foreground">
              N
            </span>
            Nexus
          </a>

          <div className="mb-6 flex flex-col gap-1.5">
            <h1 className="text-2xl font-semibold tracking-tight">{title}</h1>
            <p className="text-sm text-muted-foreground">{subtitle}</p>
          </div>

          {children}
        </div>
      </main>
    </div>
  )
}
