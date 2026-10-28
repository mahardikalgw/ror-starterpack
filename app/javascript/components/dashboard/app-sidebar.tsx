import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Separator } from '@/components/ui/separator'
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from '@/components/ui/tooltip'
import { cn } from '@/lib/utils'
import type { NavItem, Navigation } from '@/lib/types'
import { NAV_ICONS } from './nav-icons'

interface AppSidebarProps {
  navigation: Navigation
  className?: string
}

function NavRow({ item }: { item: NavItem }) {
  const Icon = NAV_ICONS[item.icon] ?? LayoutIconFallback

  const content = (
    <span
      className={cn(
        'flex w-full items-center gap-2.5 rounded-lg px-2.5 py-2 text-sm',
        item.active && 'bg-accent font-medium text-accent-foreground',
        item.disabled && 'cursor-not-allowed text-muted-foreground/70',
      )}
    >
      <Icon className="size-4 shrink-0" aria-hidden />
      <span className="flex-1 truncate">{item.label}</span>
      {item.badge && (
        <Badge variant={item.badge.variant === 'beta' ? 'beta' : 'secondary'}>{item.badge.text}</Badge>
      )}
    </span>
  )

  if (item.disabled) {
    return (
      <li>
        <Tooltip>
          <TooltipTrigger asChild>
            {/* aria-disabled rather than disabled: a disabled button leaves the tab order and
                suppresses the pointer events this tooltip needs (FR-006, research D5). */}
            <Button
              type="button"
              variant="ghost"
              aria-disabled="true"
              onClick={(event) => event.preventDefault()}
              className="h-auto w-full justify-start p-0 font-normal"
            >
              {content}
            </Button>
          </TooltipTrigger>
          <TooltipContent side="right">Preview — not included in this template</TooltipContent>
        </Tooltip>
      </li>
    )
  }

  return (
    <li>
      <a
        href={item.href ?? '#'}
        aria-current={item.active ? 'page' : undefined}
        className="block rounded-lg focus-visible:outline-none"
      >
        {content}
      </a>
    </li>
  )
}

function LayoutIconFallback({ className }: { className?: string }) {
  return <span className={className} aria-hidden />
}

export function AppSidebar({ navigation, className }: AppSidebarProps) {
  return (
    <TooltipProvider>
      <nav aria-label="Main" className={cn('flex h-full flex-col gap-4', className)}>
        <div className="flex items-center gap-2 px-2 py-1">
          <span className="grid size-8 place-items-center rounded-lg bg-primary text-sm font-bold text-primary-foreground">
            N
          </span>
          <span className="text-base font-semibold">Nexus</span>
        </div>

        <ul className="flex flex-col gap-1">
          {navigation.groups.map((group) => (
            <li key={group.label}>
              <p className="px-2.5 pb-1 pt-2 text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">
                {group.label}
              </p>
              <ul className="flex flex-col gap-0.5">
                {group.items.map((item) => (
                  <NavRow key={item.key} item={item} />
                ))}
              </ul>
            </li>
          ))}
        </ul>

        <div className="mt-auto flex flex-col gap-3">
          <Separator />
          <div className="flex items-center justify-between gap-2 rounded-xl border border-border bg-secondary/60 px-3 py-2">
            <div className="min-w-0">
              <p className="truncate text-sm font-medium">{navigation.workspace.name}</p>
              <p className="text-xs text-muted-foreground">{navigation.workspace.plan}</p>
            </div>
            <Badge variant="outline">Plan</Badge>
          </div>
          <Button variant="outline" size="sm" className="justify-center">
            Upgrade Plan
          </Button>
          <p className="px-1 text-[11px] text-muted-foreground">© 2023 Nexus. All rights reserved.</p>
        </div>
      </nav>
    </TooltipProvider>
  )
}
