---
name: hooks
description: "Use when building custom React hooks or utility functions for a React Native library — worklet-safe patterns, TypeScript generics, cleanup, and headless logic."
---

# Hooks + Utilities

## Hook Template

```ts
import { useCallback, useEffect, useRef, useState } from 'react'

type UseMyHookOptions = {
  initialValue?: number
  onChange?: (value: number) => void
}

type UseMyHookResult = {
  value: number
  increment: () => void
  reset: () => void
}

function useMyHook({ initialValue = 0, onChange }: UseMyHookOptions = {}): UseMyHookResult {
  const [value, setValue] = useState(initialValue)
  const onChangeRef = useRef(onChange)
  onChangeRef.current = onChange

  const increment = useCallback(() => {
    setValue(prev => {
      const next = prev + 1
      onChangeRef.current?.(next)
      return next
    })
  }, [])

  const reset = useCallback(() => {
    setValue(initialValue)
  }, [initialValue])

  return { value, increment, reset }
}

export { useMyHook }
export type { UseMyHookOptions, UseMyHookResult }
```

## Key Patterns

### Stable callbacks — use ref pattern
```ts
const callbackRef = useRef(callback)
callbackRef.current = callback
// Then call callbackRef.current?.() — never add callback to deps
```

### Cleanup always
```ts
useEffect(() => {
  const subscription = SomeAPI.subscribe(handler)
  return () => subscription.remove()
}, [])
```

### Generics
```ts
function useList<T>(initial: T[] = []): { items: T[]; add: (item: T) => void; remove: (index: number) => void } {
  const [items, setItems] = useState<T[]>(initial)
  const add = useCallback((item: T) => setItems(prev => [...prev, item]), [])
  const remove = useCallback((index: number) => setItems(prev => prev.filter((_, i) => i !== index)), [])
  return { items, add, remove }
}
```

## Worklet-Safe Utilities

Functions called from Reanimated worklets must be decorated with `'worklet'`:

```ts
function clamp(value: number, min: number, max: number): number {
  'worklet'
  return Math.min(Math.max(value, min), max)
}

function interpolateColor(progress: number, from: string, to: string): string {
  'worklet'
  // pure computation only — no React hooks, no closures over JS values
}
```

Rules for worklet functions:
- No `console.log` — crashes in New Arch worklet thread
- No closures over non-primitive JS values
- No async/await
- No React hooks
- Export separately from regular utils — label with `// worklet-safe` comment

## Utility Template

```ts
function formatFileSize(bytes: number): string {
  if (bytes < 1024) return `${bytes} B`
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`
}

export { formatFileSize }
```

## TypeScript Patterns

```ts
// Discriminated unions over boolean overloads
type UseQueryResult<T> =
  | { status: 'loading'; data: undefined; error: undefined }
  | { status: 'error'; data: undefined; error: Error }
  | { status: 'success'; data: T; error: undefined }

// Conditional types for flexible APIs
type MaybeArray<T> = T | T[]
function normalizeArray<T>(value: MaybeArray<T>): T[] {
  return Array.isArray(value) ? value : [value]
}
```

## Export Rules
- Export the hook and all its types from `src/index.ts`
- Never export internal implementation details
- Name hooks `use*`, utilities with descriptive verb names (`formatX`, `parseX`, `createX`)
