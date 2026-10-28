import * as React from 'react'
import { cn } from '@/lib/utils'

function Avatar({ className, ...props }: React.ComponentProps<'div'>) {
  return (
    <div
      data-slot="avatar"
      className={cn('relative flex size-9 shrink-0 items-center justify-center overflow-hidden rounded-full bg-accent text-xs font-semibold text-accent-foreground', className)}
      {...props}
    />
  )
}

export { Avatar }
