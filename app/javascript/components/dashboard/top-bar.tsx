import { Bell, ChevronDown, Gift, LogOut, Plus, Search } from 'lucide-react'
import { Avatar } from '@/components/ui/avatar'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import {
  DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuLabel,
  DropdownMenuSeparator, DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import type { AuthUser, AuthWorkspace } from '@/lib/types'

interface TopBarProps {
  user: AuthUser | null
  workspace: AuthWorkspace | null
  query: string
  onQueryChange: (value: string) => void
  onSignOut: () => void
  onOpenSidebar: () => void
}

export function TopBar({ user, workspace, query, onQueryChange, onSignOut, onOpenSidebar }: TopBarProps) {
  const initials = (user?.name ?? '?').charAt(0).toUpperCase()

  return (
    <header className="flex flex-wrap items-center gap-3 border-b border-border bg-card px-4 py-3">
      <Button variant="ghost" size="icon" className="lg:hidden" aria-label="Open navigation" onClick={onOpenSidebar}>
        <span aria-hidden>☰</span>
      </Button>

      <label className="relative flex min-w-48 flex-1 items-center">
        <span className="sr-only">Search integrations</span>
        <Search className="pointer-events-none absolute left-3 size-4 text-muted-foreground" aria-hidden />
        <Input
          value={query}
          onChange={(event) => onQueryChange(event.target.value)}
          placeholder="Search integrations"
          className="pl-9 pr-16"
        />
        <kbd className="absolute right-3 rounded border border-border bg-secondary px-1.5 py-0.5 text-[10px] text-muted-foreground">
          ⌘+F
        </kbd>
      </label>

      <div className="flex items-center gap-1.5">
        <Button variant="ghost" size="icon" aria-label="Rewards">
          <Gift className="size-4" aria-hidden />
        </Button>
        <Button variant="ghost" size="icon" aria-label="Notifications">
          <Bell className="size-4" aria-hidden />
        </Button>
        <Button variant="ghost" size="icon" aria-label="Create new">
          <Plus className="size-4" aria-hidden />
        </Button>

        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button
              type="button"
              variant="ghost"
              className="h-auto items-center gap-2 rounded-full border border-border bg-card py-1 pl-1 pr-2 text-left font-normal hover:bg-secondary"
            >
              <Avatar>{initials}</Avatar>
              <span className="hidden min-w-0 sm:block">
                <span className="block max-w-32 truncate text-xs font-medium">{user?.name}</span>
                <span className="block text-[11px] text-muted-foreground">{user?.role}</span>
              </span>
              <ChevronDown className="size-3.5 text-muted-foreground" aria-hidden />
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            <DropdownMenuLabel>
              <span className="block truncate text-xs font-medium">{user?.email_address}</span>
              <span className="block truncate text-[11px] text-muted-foreground">{workspace?.name}</span>
            </DropdownMenuLabel>
            <DropdownMenuSeparator />
            <DropdownMenuItem onSelect={onSignOut}>
              <LogOut className="size-4" aria-hidden /> Sign out
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </header>
  )
}
