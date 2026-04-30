---
name: performance
description: "Use when building performance-sensitive React Native library components — list virtualization, JS thread safety, bundle size, FlashList, FPS diagnosis, and Hermes-specific patterns."
---

# Performance Patterns for RN Libraries

As a library author, your decisions affect every consumer app. These are RN-specific — not general React patterns.

---

## List Virtualization

Never use `ScrollView` for unbounded lists. It renders all items upfront.

```tsx
// ❌ ScrollView — 5,000 items = 1–3s freeze
<ScrollView>
  {countries.map(c => <CountryRow key={c.code} {...c} />)}
</ScrollView>

// ✅ FlashList — only renders visible items, ~50ms for 5,000 items
import { FlashList } from '@shopify/flash-list'

<FlashList
  data={countries}
  renderItem={({ item }) => <CountryRow code={item.code} name={item.name} />}
  estimatedItemSize={56}
  keyExtractor={item => item.code}
/>
```

### Pass primitives to memoized list items — not objects

```tsx
// ❌ Object prop — new reference every render, memo is useless
<MemoRow data={item} onPress={handlePress} />

// ✅ Primitives — shallow comparison works
<MemoRow code={item.code} name={item.name} onPress={handlePress} />
```

### `getItemType` for heterogeneous lists

```tsx
<FlashList
  data={feed}
  getItemType={item => item.type}  // prevents layout thrashing during recycling
  renderItem={({ item }) => { ... }}
/>
```

### Hoist callbacks outside `renderItem`

```tsx
// ❌ New function per render — breaks all item memoization
<FlashList renderItem={({ item }) => <Row onPress={() => select(item.id)} />} />

// ✅ Stable reference — items receive the same function instance
const handleSelect = useCallback((id: string) => select(id), [])
<FlashList renderItem={({ item }) => <Row id={item.id} onPress={handleSelect} />} />
```

---

## JS Thread — Don't Block It

The JS thread drives your library. Blocking it drops frames for the consumer's entire app.

**What blocks the JS thread:**
- Synchronous operations over ~4ms
- Large JSON.parse / JSON.stringify in render
- Unthrottled event handlers (scroll, pan)
- Filtering/sorting large arrays during render

**Patterns to avoid:**

```tsx
// ❌ Expensive filter on every render
function CountryPicker({ query }: { query: string }) {
  const results = allCountries.filter(c =>   // runs every render
    c.name.toLowerCase().includes(query.toLowerCase())
  )
  return <FlashList data={results} ... />
}

// ✅ Memoize expensive derivations
function CountryPicker({ query }: { query: string }) {
  const results = useMemo(
    () => allCountries.filter(c => c.name.toLowerCase().includes(query.toLowerCase())),
    [query]
  )
  return <FlashList data={results} ... />
}
```

**For search/filter with large datasets:** debounce the input, not the filter.

```tsx
const [query, setQuery] = useState('')
const debouncedQuery = useDebounce(query, 150)  // only refilter after typing stops
const results = useMemo(
  () => allCountries.filter(c => c.name.includes(debouncedQuery)),
  [debouncedQuery]
)
```

---

## FPS Targets

| FPS | State | Action |
|---|---|---|
| 55–60 | Smooth | Ship it |
| 45–55 | Stutter | Investigate |
| 30–45 | Noticeable | Fix before publish |
| <30 | Broken | Block publish |

**Diagnose in the example app:**
- Shake device (or Cmd+D in simulator) → Show Perf Monitor
- **JS FPS drops**: JS thread blocked — look for expensive renders, heavy useMemo, sync operations
- **UI FPS drops only, JS FPS fine**: GPU/layout issue — look for shadows, `overflow: hidden`, large blurs

---

## Bundle Size — Your Responsibility

Every byte you add gets paid by every consumer app, on every install.

### No internal barrel exports

```ts
// ❌ Barrel — Metro loads everything even if consumer imports one export
// src/components/index.ts
export * from './Button'
export * from './Input'
export * from './Modal'

// ✅ Export directly from src/index.ts — only the public API
export { Button } from './components/Button'
export { Input } from './components/Input'
```

### `sideEffects: false` in package.json

```json
{ "sideEffects": false }
```

Tells bundlers all exports are pure — unused ones are safely tree-shaken.

### Size benchmarks

Check with [pkg-size.dev](https://pkg-size.dev) or bundlephobia:

| Size (minified + gzip) | Verdict |
|---|---|
| < 5 KB | Great |
| 5–20 KB | Acceptable — document what's included |
| 20–50 KB | Justify — what is this size coming from? |
| > 50 KB | Block unless it bundles a necessary data file (e.g. country database) |

### Never bundle what consumers already have

```json
// ❌ Direct dep — shipped twice
"dependencies": { "react-native-reanimated": "^3.0.0" }

// ✅ Peer dep — one instance in the consumer's app
"peerDependencies": { "react-native-reanimated": ">=3.0.0" }
```

---

## Hermes-Specific Patterns

All RN 0.76+ apps run on Hermes. Write Hermes-friendly code.

**Avoid `eval` and `Function()` constructors** — Hermes uses AOT compilation, dynamic code generation is unsupported and will throw.

**Avoid `arguments` object** — use rest params instead:
```ts
// ❌ arguments — not optimized by Hermes
function format() { return Array.from(arguments).join(', ') }

// ✅ Rest params — Hermes-optimized
function format(...args: string[]) { return args.join(', ') }
```

**WeakRef and FinalizationRegistry** are available in Hermes — use them for optional cleanup of large resources (image caches, native object references) without causing memory leaks.

---

## React Memoization

Use these when the component receives frequent re-renders or passes callbacks to memoized children.

```tsx
// memo — component whose parent re-renders often but its own props are stable
const CountryRow = memo(({ code, name, onSelect }: CountryRowProps) => (
  <Pressable onPress={() => onSelect(code)}>
    <Text>{name}</Text>
  </Pressable>
))

// useMemo — expensive derived value
const filteredCountries = useMemo(
  () => countries.filter(c => c.name.toLowerCase().includes(query)),
  [query]
)

// useCallback — stable function reference passed to memoized children
const handleSelect = useCallback((code: string) => {
  onSelect?.(code)
}, [onSelect])
```

Don't over-memoize — `memo` with object props silently breaks (fails shallow equality). Measure with the Perf Monitor before adding memoization.

---

## React Compiler Compatibility (RN 0.76+, Expo SDK 52+)

React Compiler auto-memoizes components. Write compiler-friendly code so consumers benefit:

```tsx
// ✅ Destructure function props at render top — compiler can track them
function MyComponent({ onPress, onLongPress }: Props) {
  const handlePress = () => onPress()
  const handleLongPress = () => onLongPress?.()
  return <Pressable onPress={handlePress} onLongPress={handleLongPress} />
}

// ❌ Dot-access in JSX — compiler misses the optimization
<Pressable onPress={() => props.onPress()} />
```

---

## TextInput — Uncontrolled for Typing Performance

Controlled `TextInput` sends every keystroke through the JS bridge, which can cause flicker on fast typing. For search inputs in pickers and filters, prefer uncontrolled:

```tsx
// ❌ Controlled — every keystroke round-trips through JS
<TextInput value={query} onChangeText={setQuery} />

// ✅ Uncontrolled — native manages state during typing, JS only sees final value
<TextInput
  defaultValue={initialQuery}
  onChangeText={text => {
    queryRef.current = text
    onQueryChange?.(text)
  }}
/>
```

Never combine `value` and `defaultValue`.

---

## Intl / Date Formatting — Module Scope

`Intl` constructors are expensive. Create once at module scope, not per render.

```ts
// ❌ Recreated on every call
function formatDate(date: Date) {
  return new Intl.DateTimeFormat('en-US', { month: 'short', day: 'numeric' }).format(date)
}

// ✅ Created once
const dateFormatter = new Intl.DateTimeFormat('en-US', { month: 'short', day: 'numeric' })
export function formatDate(date: Date) { return dateFormatter.format(date) }

// ✅ Or useMemo if locale is dynamic
const formatter = useMemo(
  () => new Intl.DateTimeFormat(locale, { month: 'short', day: 'numeric' }),
  [locale]
)
```
