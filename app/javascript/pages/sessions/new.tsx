import { Head, Link, useForm } from '@inertiajs/react'
import type { FormEvent } from 'react'
import { AlertCircle, ArrowRight, KeyRound } from 'lucide-react'
import { AuthField } from '@/components/auth/auth-field'
import { Button } from '@/components/ui/button'
import { Separator } from '@/components/ui/separator'
import { AuthLayout } from '@/layouts/auth-layout'
import type { SharedProps } from '@/lib/types'

interface SignInProps extends SharedProps {
  demo: { email_address: string; password: string; note: string } | null
  form: { email_address: string }
}

export default function SignIn({ demo, form, errors }: SignInProps) {
  const { data, setData, post, processing } = useForm({ email_address: form.email_address, password: '' })

  const submit = (event: FormEvent) => {
    event.preventDefault()
    post('/session')
  }

  const useDemoAccount = () => {
    if (!demo) return
    setData({ email_address: demo.email_address, password: demo.password })
  }

  return (
    <>
      <Head title="Sign in · Nexus" />
      <AuthLayout title="Welcome back" subtitle="Sign in to open your analytics workspace.">
        {errors.base && (
          <div
            role="alert"
            className="mb-5 flex items-start gap-2.5 rounded-xl border border-destructive/25 bg-destructive/10 px-3.5 py-3 text-xs font-medium text-destructive"
          >
            <AlertCircle className="mt-px size-4 shrink-0" aria-hidden />
            <span>{errors.base}</span>
          </div>
        )}

        {demo && (
          <div className="mb-5 rounded-xl border border-border bg-secondary/50 p-3.5">
            <div className="flex items-start gap-2.5">
              <KeyRound className="mt-px size-4 shrink-0 text-muted-foreground" aria-hidden />
              <div className="flex min-w-0 flex-col gap-0.5">
                <p className="text-xs font-medium">Demo credentials</p>
                <p className="truncate text-xs text-muted-foreground">
                  {demo.email_address} · {demo.password}
                </p>
              </div>
            </div>
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={useDemoAccount}
              className="mt-2.5 w-full bg-card"
            >
              Fill demo credentials
            </Button>
            <p className="mt-1.5 text-[11px] leading-relaxed text-muted-foreground">{demo.note}</p>
          </div>
        )}

        <form onSubmit={submit} className="flex flex-col gap-4" noValidate>
          <AuthField
            id="email_address"
            label="Email address"
            type="email"
            autoComplete="email"
            autoFocus
            value={data.email_address}
            error={errors.email_address}
            onChange={(value) => setData('email_address', value)}
          />

          <AuthField
            id="password"
            label="Password"
            type="password"
            autoComplete="current-password"
            value={data.password}
            error={errors.password}
            onChange={(value) => setData('password', value)}
          />

          <Button type="submit" size="lg" disabled={processing} className="mt-1 w-full">
            {processing ? 'Signing in…' : 'Sign in'}
            {!processing && <ArrowRight className="size-4" aria-hidden />}
          </Button>
        </form>

        <div className="my-6 flex items-center gap-3">
          <Separator className="flex-1" />
          <span className="text-[11px] uppercase tracking-wide text-muted-foreground">New here?</span>
          <Separator className="flex-1" />
        </div>

        <Button variant="outline" size="lg" asChild className="w-full">
          <Link href="/registration/new">Create an account</Link>
        </Button>
      </AuthLayout>
    </>
  )
}
