import { useState, type ReactNode } from 'react'
import { AppSidebar } from '@/components/dashboard/app-sidebar'
import { TopBar } from '@/components/dashboard/top-bar'
import { Sheet, SheetContent, SheetDescription, SheetTitle } from '@/components/ui/sheet'
import type { AuthUser, AuthWorkspace, Navigation } from '@/lib/types'

interface DashboardLayoutProps {
  navigation: Navigation
  user: AuthUser | null
  workspace: AuthWorkspace | null
  query: string
  onQueryChange: (value: string) => void
  onSignOut: () => void
  children: ReactNode
}

export function DashboardLayout({
  navigation, user, workspace, query, onQueryChange, onSignOut, children,
}: DashboardLayoutProps) {
  const [drawerOpen, setDrawerOpen] = useState(false)

  return (
    <div className="min-h-screen bg-background">
      <a
        href="#main-content"
        className="sr-only focus:not-sr-only focus:absolute focus:left-3 focus:top-3 focus:z-50 focus:rounded-md focus:bg-primary focus:px-3 focus:py-2 focus:text-primary-foreground"
      >
        Skip to content
      </a>

      <div className="flex">
        <aside className="sticky top-0 hidden h-screen w-64 shrink-0 border-r border-border bg-sidebar p-3 lg:block">
          <AppSidebar navigation={navigation} />
        </aside>

        <Sheet open={drawerOpen} onOpenChange={setDrawerOpen}>
          <SheetContent aria-describedby="sidebar-description">
            <SheetTitle className="sr-only">Navigation</SheetTitle>
            <SheetDescription id="sidebar-description" className="sr-only">
              Dashboard navigation. Press Escape to close.
            </SheetDescription>
            <AppSidebar navigation={navigation} />
          </SheetContent>
        </Sheet>

        <div className="flex min-w-0 flex-1 flex-col">
          <TopBar
            user={user}
            workspace={workspace}
            query={query}
            onQueryChange={onQueryChange}
            onSignOut={onSignOut}
            onOpenSidebar={() => setDrawerOpen(true)}
          />
          <main id="main-content" className="flex flex-col gap-5 p-4 lg:p-6">
            {children}
          </main>
        </div>
      </div>
    </div>
  )
}
