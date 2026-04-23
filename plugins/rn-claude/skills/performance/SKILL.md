---
name: performance
description: "Use when building performance-sensitive React Native library components — list virtualization, memoization, bundle size, barrel exports, FPS targets, and React Compiler compatibility."
---

# Performance Patterns for RN Libraries

As a library author, performance decisions you make affect every consumer app. These patterns matter.

---

## List Components — Virtualization

If building a list-based component (gallery, feed, picker), never use `ScrollView` for unbounded lists.

```tsx
// ❌ ScrollView — renders ALL items upfront
<ScrollView>
  {items.map(item => <Item key={item.id} {...item} />)}
</ScrollView>

// ✅ FlashList — virtualizes, only renders visible items
import { FlashList } from '@shopify/flash-list'

<FlashList
  data={items}
  renderItem={({ item }) => <Item id={item.id} title={item.title} />}
  estimatedItemSize={80}
  keyExtractor={item => item.id}
/>
```

Performance reality: 5,000 items → ScrollView freezes 1–3s, FlashList ~50ms.

---

## List Memoization Rules

### Pass primitives to memoized items — not objects

```tsx
// ❌ Object prop breaks memo — new reference every render
const renderItem = ({ item }: { item: Item }) => (
  <MemoItem data={item} onPress={handlePress} />
)

// ✅ Primitive props — shallow comparison works
const renderItem = ({ item }: { item: Item }) => (
  <MemoItem id={item.id} title={item.title} onPress={handlePress} />
)

const MemoItem = memo(({ id, title, onPress }: { id: string; title: string; onPress: (id: string) => void }) => (
  <Pressable onPress={() => onPress(id)}>
    <Text>{title}</Text>
  </Pressable>
))
```

### Hoist callbacks to list root — not inline in renderItem

```tsx
// ❌ New function reference every render
<FlashList
  renderItem={({ item }) => (
    <Item onPress={() => handleSelect(item.id)} />  // new fn per render
  )}
/>

// ✅ Hoist — stable reference, items call with ID
const handleSelect = useCallback((id: string) => {
  // handle selection
}, [])

<FlashList
  renderItem={({ item }) => <Item id={item.id} onPress={handleSelect} />}
/>
```

### Stable object references

```tsx
// ❌ Transform inside render — new array reference every render
<FlashList data={items.filter(i => i.active)} />

// ✅ Memoize filtered data
const activeItems = useMemo(() => items.filter(i => i.active), [items])
<FlashList data={activeItems} />
```

### Heterogeneous lists — provide `getItemType`

```tsx
type FeedItem = { type: 'post' | 'ad' | 'story'; id: string }

<FlashList
  data={feed}
  getItemType={item => item.type}   // ← prevents layout thrashing during recycling
  renderItem={({ item }) => {
    if (item.type === 'post') return <PostCard id={item.id} />
    if (item.type === 'ad') return <AdCard id={item.id} />
    return <StoryCard id={item.id} />
  }}
/>
```

---

## FPS Targets (for animated components)

| FPS | State |
|---|---|
| 55–60 | Smooth — target for all animations |
| 45–55 | Slight stutter — investigate |
| 30–45 | Noticeable — must fix before publish |
| <30 | Critical — broken |

Measure with **React Native Performance Monitor**:
- Android: Shake device → Show Perf Monitor
- iOS: Shake device → Show Perf Monitor, or Cmd+D in simulator

**UI FPS drop only** = native rendering issue (layout, GPU)\
**JS FPS drop only** = JS thread blocked (heavy computation, re-renders)

---

## Memoization

```tsx
// memo — wrap component if parent re-renders frequently and props are stable
const MyItem = memo(({ id, title }: ItemProps) => (
  <View><Text>{title}</Text></View>
))

// useMemo — for expensive derived values
const sortedItems = useMemo(
  () => [...items].sort((a, b) => a.title.localeCompare(b.title)),
  [items],
)

// useCallback — for callbacks passed as props to memoized children
const handlePress = useCallback((id: string) => {
  onSelect?.(id)
}, [onSelect])
```

Don't over-memoize — measure first. `memo` with object props silently breaks (fails shallow equality).

---

## React Compiler Compatibility

React Compiler (RN 0.76+, Expo SDK 52+) auto-memoizes components. Write compiler-friendly code so consumers benefit:

```tsx
// ✅ Destructure functions at render top — stable references
function MyComponent({ onPress, onLongPress }: Props) {
  // ✅ Destructured at top level — compiler can optimize
  const handlePress = () => onPress()
  const handleLongPress = () => onLongPress?.()
  // ...
}

// ❌ Dot-access in JSX — compiler misses optimization
<Pressable onPress={() => props.onPress()} />

// ✅ Destructured — compiler optimizes
const { onPress } = props
<Pressable onPress={onPress} />
```

---

## Bundle Size — Library Author Responsibilities

Consumers pay for every byte you add. Keep it lean.

### No barrel exports internally

```ts
// ❌ Barrel — Metro loads everything even if consumer uses one export
export * from './components'
export * from './hooks'
export * from './utils'

// ✅ Direct imports in src/ — only re-export public API from index.ts
export { Button } from './components/Button'
export { useCounter } from './hooks/useCounter'
```

### Tree shaking — use ESM

`bob` builds ESM (`lib/module/`) automatically. Ensure your source uses ESM:
```ts
// ✅ ESM — tree-shakeable
import { clamp } from './utils/math'
export { Button } from './components/Button'

// ❌ CommonJS in source — kills tree shaking
const { clamp } = require('./utils/math')
module.exports = { Button }
```

### Declare `sideEffects: false` in `package.json`

```json
{
  "sideEffects": false
}
```

This tells bundlers all exports are pure and unused ones can be safely removed.

### Check size before shipping

Use [bundlephobia.com](https://bundlephobia.com) or `pkg-size.dev`:
- **<5 KB** minified+gzip — great
- **5–20 KB** — acceptable, document what's included
- **20–50 KB** — justify or find lighter alternative
- **>50 KB** — needs strong justification

### Don't bundle what consumers already have

```json
// ❌ Direct dep — bundled twice (your lib + consumer's app)
"dependencies": {
  "react-native-reanimated": "^3.0.0"
}

// ✅ Peer dep — single instance in consumer's app
"peerDependencies": {
  "react-native-reanimated": ">=3.0.0"
}
```

---

## Intl / Date Formatting — Module Scope

```ts
// ❌ Created in render/component — recreated every call (expensive)
function formatDate(date: Date) {
  return new Intl.DateTimeFormat('en-US', { month: 'short', day: 'numeric' }).format(date)
}

// ✅ Module scope — created once
const dateFormatter = new Intl.DateTimeFormat('en-US', { month: 'short', day: 'numeric' })

function formatDate(date: Date) {
  return dateFormatter.format(date)
}

// ✅ Or useMemo if locale is dynamic
const formatter = useMemo(
  () => new Intl.DateTimeFormat(locale, { month: 'short', day: 'numeric' }),
  [locale],
)
```

---

## TextInput — Uncontrolled for Simple Cases

On New Architecture this is mostly fixed, but for maximum compatibility:

```tsx
// ❌ Controlled — character round-trip can cause flicker on some devices
<TextInput value={text} onChangeText={setText} />

// ✅ Uncontrolled — native manages state during typing
<TextInput
  defaultValue={initialText}
  onChangeText={text => {
    valueRef.current = text
    onChangeText?.(text)
  }}
/>
```

Never combine `value` and `defaultValue`.
