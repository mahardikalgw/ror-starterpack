import { useState } from 'react'
import { Eye, EyeOff } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Field, FieldDescription, FieldError, FieldLabel } from '@/components/ui/field'
import { Input } from '@/components/ui/input'

interface AuthFieldProps {
  id: string
  label: string
  type?: 'text' | 'email' | 'password'
  autoComplete?: string
  autoFocus?: boolean
  value: string
  error?: string
  hint?: string
  onChange: (value: string) => void
}

/**
 * One composition for label, control, hint, and validation message across both auth
 * forms (FR-003). The message is programmatically associated with the control so a
 * screen reader announces it on focus, which a sibling paragraph cannot do.
 */
export function AuthField({
  id,
  label,
  type = 'text',
  autoComplete,
  autoFocus = false,
  value,
  error,
  hint,
  onChange,
}: AuthFieldProps) {
  const [revealed, setRevealed] = useState(false)
  const errorId = `${id}-error`
  const hintId = `${id}-hint`
  const isPassword = type === 'password'
  const describedBy = [error ? errorId : null, hint ? hintId : null].filter(Boolean).join(' ')

  return (
    <Field data-invalid={error ? true : undefined}>
      <FieldLabel htmlFor={id}>{label}</FieldLabel>

      <div className="relative">
        <Input
          id={id}
          name={id}
          type={isPassword && revealed ? 'text' : type}
          autoComplete={autoComplete}
          autoFocus={autoFocus}
          value={value}
          onChange={(event) => onChange(event.target.value)}
          aria-invalid={error ? true : undefined}
          aria-describedby={describedBy || undefined}
          className={isPassword ? 'pr-11' : undefined}
        />

        {isPassword && (
          <Button
            type="button"
            variant="ghost"
            size="icon"
            onClick={() => setRevealed((current) => !current)}
            aria-label={revealed ? 'Hide password' : 'Show password'}
            aria-pressed={revealed}
            className="absolute inset-y-0 right-0 h-full w-10 rounded-l-none text-muted-foreground hover:bg-transparent hover:text-foreground"
          >
            {revealed ? <EyeOff className="size-4" aria-hidden /> : <Eye className="size-4" aria-hidden />}
          </Button>
        )}
      </div>

      {hint && !error && <FieldDescription id={hintId}>{hint}</FieldDescription>}
      <FieldError id={errorId}>{error}</FieldError>
    </Field>
  )
}
