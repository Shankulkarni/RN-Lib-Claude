---
name: hooks
description: "Use when building custom React hooks or utility functions for a React Native library — worklet-safe patterns, TypeScript generics, memory leak prevention, state minimization, and stable callbacks."
---

# Hooks + Utilities

## Hook Template

```ts
import { useCallback, useEffect, useRef, useState } from 'react'

type UseCounterOptions = {
  initialValue?: number
  min?: number
  max?: number
  onChange?: (value: number) => void
}

type UseCounterResult = {
  value: number
  increment: () => void
  decrement: () => void
  reset: () => void
}

function useCounter({
  initialValue = 0,
  min = -Infinity,
  max = Infinity,
  onChange,
}: UseCounterOptions = {}): UseCounterResult {
  const [value, setValue] = useState(initialValue)
  const onChangeRef = useRef(onChange)
  onChangeRef.current = onChange

  const increment = useCallback(() => {
    setValue(prev => {
      const next = Math.min(prev + 1, max)
      onChangeRef.current?.(next)
      return next
    })
  }, [max])

  const decrement = useCallback(() => {
    setValue(prev => {
      const next = Math.max(prev - 1, min)
      onChangeRef.current?.(next)
      return next
    })
  }, [min])

  const reset = useCallback(() => setValue(initialValue), [initialValue])

  return { value, increment, decrement, reset }
}

export { useCounter }
export type { UseCounterOptions, UseCounterResult }
```

---

## State Patterns

### Minimize state — derive during render
```tsx
// ❌ Redundant state — derived from other state
const [items, setItems] = useState<Item[]>([])
const [count, setCount] = useState(0)       // ← derived from items.length
const [isEmpty, setIsEmpty] = useState(true) // ← derived from items.length === 0

// ✅ Derive during render — single source of truth
const [items, setItems] = useState<Item[]>([])
const count = items.length           // derived
const isEmpty = items.length === 0   // derived
```

### Dispatch updaters for state depending on previous value
```tsx
// ❌ Stale closure — value may be outdated
const increment = () => setValue(value + 1)

// ✅ Updater function — always has latest value
const increment = useCallback(() => setValue(prev => prev + 1), [])
```

### `undefined` initial state with nullish coalescing
```tsx
// ❌ null initial — can't distinguish "unset by user" from "not yet loaded"
const [theme, setTheme] = useState<'light' | 'dark' | null>(null)

// ✅ undefined initial — nullish coalescing gives reactive fallback
const [theme, setTheme] = useState<'light' | 'dark' | undefined>(undefined)
const resolvedTheme = theme ?? systemTheme  // fallback to system, override when set
```

---

## Memory Leak Prevention — Always Clean Up

```tsx
// ❌ Leaked subscription
useEffect(() => {
  const sub = EventEmitter.addListener('change', handler)
  // missing cleanup → leak on unmount
}, [])

// ✅ Always return cleanup
useEffect(() => {
  const sub = EventEmitter.addListener('change', handler)
  return () => sub.remove()
}, [])

// ✅ Timer cleanup
useEffect(() => {
  const id = setInterval(tick, 1000)
  return () => clearInterval(id)
}, [])

// ✅ Abort fetch on unmount
useEffect(() => {
  const controller = new AbortController()
  fetch(url, { signal: controller.signal }).then(setData).catch(() => {})
  return () => controller.abort()
}, [url])
```

---

## High-Frequency Values — Use `useRef` not `useState`

```tsx
// ❌ Scroll position in useState — causes re-render on every scroll event
const [scrollY, setScrollY] = useState(0)
const onScroll = (e: NativeSyntheticEvent<NativeScrollEvent>) => {
  setScrollY(e.nativeEvent.contentOffset.y) // fires 60x/sec → 60 re-renders/sec
}

// ✅ useRef — no re-render, track for logic use
const scrollY = useRef(0)
const onScroll = useCallback((e: NativeSyntheticEvent<NativeScrollEvent>) => {
  scrollY.current = e.nativeEvent.contentOffset.y
}, [])

// ✅ useSharedValue — if driving animation (see animations skill)
const scrollY = useSharedValue(0)
```

---

## Stable Callback Ref Pattern

Prevents stale closures without adding callback to deps array:

```tsx
function useEventCallback<T extends (...args: never[]) => unknown>(fn: T): T {
  const ref = useRef(fn)
  ref.current = fn
  return useCallback((...args: Parameters<T>) => ref.current(...args), []) as T
}

// Usage
function useMyHook({ onComplete }: { onComplete?: (result: string) => void }) {
  const handleComplete = useEventCallback(onComplete ?? (() => {}))
  // handleComplete is stable — safe in deps array, always calls latest onComplete
}
```

---

## Generics

```tsx
// Generic list hook
function useSelection<T>(items: T[], keyExtractor: (item: T) => string) {
  const [selectedKeys, setSelectedKeys] = useState<Set<string>>(new Set())

  const toggle = useCallback((item: T) => {
    const key = keyExtractor(item)
    setSelectedKeys(prev => {
      const next = new Set(prev)
      next.has(key) ? next.delete(key) : next.add(key)
      return next
    })
  }, [keyExtractor])

  const isSelected = useCallback(
    (item: T) => selectedKeys.has(keyExtractor(item)),
    [selectedKeys, keyExtractor],
  )

  const selectedItems = items.filter(item => selectedKeys.has(keyExtractor(item)))

  return { toggle, isSelected, selectedItems, selectedKeys }
}
```

---

## Worklet-Safe Utilities

Functions callable from Reanimated worklets — must be pure, no closures over JS:

```ts
function clamp(value: number, min: number, max: number): number {
  'worklet'
  return Math.min(Math.max(value, min), max)
}

function lerp(start: number, end: number, t: number): number {
  'worklet'
  return start + (end - start) * t
}

function snapToGrid(value: number, step: number): number {
  'worklet'
  return Math.round(value / step) * step
}
```

Rules: no `console.log`, no closures over objects, no async, no React hooks, no RN APIs.

---

## TypeScript Patterns

```ts
// Discriminated union return type
type UseAsyncResult<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'error'; error: Error }
  | { status: 'success'; data: T }

// Conditional generic for optional callback
type MaybeCallback<T> = T extends undefined ? void : (value: NonNullable<T>) => void
```

---

## Export Rules

```ts
// src/index.ts
export { useCounter } from './hooks/useCounter'
export type { UseCounterOptions, UseCounterResult } from './hooks/useCounter'
```

- Name: `use*` for hooks, verb (`formatX`, `parseX`, `createX`) for utilities
- Export options type + result type alongside every hook
- Never export internal implementation helpers
