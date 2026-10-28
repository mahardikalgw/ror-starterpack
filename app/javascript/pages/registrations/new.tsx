import { Head, Link, useForm } from '@inertiajs/react'
import type { FormEvent } from 'react'
import { AlertCircle, ArrowRight, Check } from 'lucide-react'
import { AuthField } from '@/components/auth/auth-field'
import { Button } from '@/components/ui/button'
import { Separator } from '@/components/ui/separator'
import { AuthLayout } from '@/layouts/auth-layout'
import type { SharedProps } from '@/lib/types'

interface RegistrationProps extends SharedProps {
  form: { name: string; email_address: string }
}

export default function RegistrationNew({ form, errors }: RegistrationProps) {
  const { data, setData, post, processing } = useForm({
    name: form.name,
    email_address: form.email_address,
    password: '',
    password_confirmation: '',
  })

  const submit = (event: FormEvent) => {
    event.preventDefault()
    post('/registration')
  }

  const requirements = [
    { label: 'At least 8 characters', met: data.password.length >= 8 },
    { label: 'Passwords match', met: data.password.length > 0 && data.password === data.password_confirmation },
  ]

  return (
    <>
      <Head title="Create your account · Nexus" />
      <AuthLayout title="Create your account" subtitle="Start with a workspace preloaded with demo analytics.">
        {errors.base && (
          <div
            role="alert"
            className="mb-5 flex items-start gap-2.5 rounded-xl border border-destructive/25 bg-destructive/10 px-3.5 py-3 text-xs font-medium text-destructive"
          >
            <AlertCircle className="mt-px size-4 shrink-0" aria-hidden />
            <span>{errors.base}</span>
          </div>
        )}

        <form onSubmit={submit} className="flex flex-col gap-4" noValidate>
          <AuthField
            id="name"
            label="Full name"
            autoComplete="name"
            autoFocus
            value={data.name}
            error={errors.name}
            onChange={(value) => setData('name', value)}
          />

          <AuthField
            id="email_address"
            label="Email address"
            type="email"
            autoComplete="email"
            value={data.email_address}
            error={errors.email_address}
            onChange={(value) => setData('email_address', value)}
          />

          <AuthField
            id="password"
            label="Password"
            type="password"
            autoComplete="new-password"
            value={data.password}
            error={errors.password}
            onChange={(value) => setData('password', value)}
          />

          <AuthField
            id="password_confirmation"
            label="Confirm password"
            type="password"
            autoComplete="new-password"
            value={data.password_confirmation}
            error={errors.password_confirmation}
            onChange={(value) => setData('password_confirmation', value)}
          />

          <ul className="flex flex-col gap-1.5" aria-live="polite">
            {requirements.map((requirement) => (
              <li
                key={requirement.label}
                className={`flex items-center gap-2 text-[11px] ${
                  requirement.met ? 'text-positive-foreground' : 'text-muted-foreground'
                }`}
              >
                <Check className={`size-3.5 ${requirement.met ? 'opacity-100' : 'opacity-30'}`} aria-hidden />
                {requirement.label}
              </li>
            ))}
          </ul>

          <Button type="submit" size="lg" disabled={processing} className="mt-1 w-full">
            {processing ? 'Creating account…' : 'Create account'}
            {!processing && <ArrowRight className="size-4" aria-hidden />}
          </Button>
        </form>

        <div className="my-6 flex items-center gap-3">
          <Separator className="flex-1" />
          <span className="text-[11px] uppercase tracking-wide text-muted-foreground">Already registered?</span>
          <Separator className="flex-1" />
        </div>

        <Button variant="outline" size="lg" asChild className="w-full">
          <Link href="/session/new">Sign in instead</Link>
        </Button>
      </AuthLayout>
    </>
  )
}
