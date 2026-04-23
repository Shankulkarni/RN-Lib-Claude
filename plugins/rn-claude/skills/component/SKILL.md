---
name: component
description: "Use when building React Native UI components for a library — Fabric-compatible, New Architecture patterns, ref forwarding, Platform.OS, accessibility, compound components, and safe rendering patterns."
---

# UI Component Patterns

New Architecture (Fabric) only. RN 0.76+.

## CRITICAL — Rendering Safety

### Never `&&` with potentially falsy values
```tsx
// ❌ Renders "0" as text node → crashes or visual bug
{count && <Badge count={count} />}
{items.length && <List items={items} />}

// ✅ Ternary with null, or explicit boolean
{count > 0 ? <Badge count={count} /> : null}
{!!items.length && <List items={items} />}
{Boolean(count) && <Badge count={count} />}
```

### All strings must be inside `<Text>`
```tsx
// ❌ Crashes — string outside Text in New Architecture
<View>Hello world</View>
<View>{user.name}</View>

// ✅
<View><Text>Hello world</Text></View>
<View><Text>{user.name}</Text></View>
```

### Use `Pressable` — never `TouchableOpacity`/`TouchableHighlight`
```tsx
// ❌ Legacy, deprecated
<TouchableOpacity onPress={onPress}>
<TouchableHighlight onPress={onPress}>

// ✅ Pressable — composable, New Architecture native
<Pressable
  onPress={onPress}
  style={({ pressed }) => [styles.button, pressed && styles.pressed]}
>
```

For animated press states with Reanimated — see `animations` skill (`GestureDetector` + `Gesture.Tap()`).

---

## Component Template

```tsx
import { forwardRef } from 'react'
import { Pressable, StyleSheet, type PressableProps } from 'react-native'

type MyButtonProps = Omit<PressableProps, 'style'> & {
  variant?: 'primary' | 'secondary' | 'ghost'
  size?: 'sm' | 'md' | 'lg'
  style?: PressableProps['style']
}

const MyButton = forwardRef<View, MyButtonProps>(
  ({ variant = 'primary', size = 'md', style, children, ...props }, ref) => {
    return (
      <Pressable
        ref={ref}
        style={({ pressed }) => [
          styles.base,
          styles[variant],
          styles[size],
          pressed && styles.pressed,
          typeof style === 'function' ? style({ pressed }) : style,
        ]}
        accessibilityRole="button"
        {...props}
      >
        {children}
      </Pressable>
    )
  },
)

MyButton.displayName = 'MyButton'

const styles = StyleSheet.create({
  base: { alignItems: 'center', justifyContent: 'center', borderRadius: 8, borderCurve: 'continuous' },
  primary: { backgroundColor: '#000' },
  secondary: { backgroundColor: '#f0f0f0' },
  ghost: { backgroundColor: 'transparent' },
  sm: { paddingVertical: 6, paddingHorizontal: 12, minHeight: 32 },
  md: { paddingVertical: 10, paddingHorizontal: 16, minHeight: 44 },
  lg: { paddingVertical: 14, paddingHorizontal: 20, minHeight: 52 },
  pressed: { opacity: 0.7 },
})

export { MyButton }
export type { MyButtonProps }
```

---

## Prop Design

```tsx
// ✅ Accept color as prop — never hardcode
type ChipProps = {
  color?: string          // default to a semantic value, never '#ff0000'
  backgroundColor?: string
}

// ✅ Accept size as prop — never hardcode dimensions
type AvatarProps = {
  size?: number           // default 48
}

// ✅ Extend native props — consumers can pass testID, onLayout, etc.
type CardProps = ViewProps & {
  variant?: 'elevated' | 'outlined' | 'filled'
}

// ✅ Spread rest props always
const Card = forwardRef<View, CardProps>(({ variant = 'elevated', style, ...props }, ref) => (
  <View ref={ref} style={[styles[variant], style]} {...props} />
))
```

---

## Compound Components

Prefer compound components over boolean prop explosion.

```tsx
// ❌ Boolean prop explosion
<Button icon={<Icon />} iconPosition="left" hasSpinner isLoading label="Save" />

// ✅ Compound — explicit, composable
<Button onPress={save}>
  <ButtonIcon><SaveIcon /></ButtonIcon>
  <ButtonText>Save</ButtonText>
  <ButtonSpinner visible={isLoading} />
</Button>
```

Implementation:
```tsx
type ButtonContextValue = { disabled: boolean }
const ButtonContext = createContext<ButtonContextValue>({ disabled: false })

const Button = ({ disabled = false, children, ...props }: ButtonProps) => (
  <ButtonContext.Provider value={{ disabled }}>
    <Pressable disabled={disabled} {...props}>{children}</Pressable>
  </ButtonContext.Provider>
)

const ButtonText = ({ style, ...props }: TextProps) => {
  const { disabled } = use(ButtonContext)
  return <Text style={[styles.text, disabled && styles.textDisabled, style]} {...props} />
}

const ButtonIcon = ({ children }: { children: ReactNode }) => (
  <View style={styles.icon}>{children}</View>
)

Button.Text = ButtonText
Button.Icon = ButtonIcon
```

---

## Styling

```tsx
const styles = StyleSheet.create({
  // ✅ borderCurve: 'continuous' — smooth iOS squircle corners
  card: { borderRadius: 12, borderCurve: 'continuous' },

  // ✅ gap for sibling spacing, padding for internal
  row: { flexDirection: 'row', gap: 8 },
  card2: { padding: 16 },

  // ✅ Platform shadows
  shadow: Platform.select({
    ios: { shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.08, shadowRadius: 8 },
    android: { elevation: 3 },
    default: {},
  }),
})
```

---

## Images

```tsx
// ❌ React Native Image — no blurhash, no priority, no caching control
import { Image } from 'react-native'

// ✅ expo-image — progressive loading, blurhash, CDN caching, priority
import { Image } from 'expo-image'

<Image
  source={{ uri: imageUri }}
  placeholder={{ blurhash }}
  contentFit="cover"
  priority="high"
  style={styles.image}
/>
```

Add to peer deps if library uses images:
```json
"expo-image": ">=2.0.0"
```

---

## Accessibility Checklist
- [ ] `accessibilityRole` on every interactive element (`button`, `image`, `header`, etc.)
- [ ] `accessibilityLabel` on icon-only buttons and images
- [ ] `accessibilityState={{ disabled, selected, checked }}` when state changes
- [ ] `accessibilityHint` for non-obvious interactions
- [ ] Minimum touch target 44×44pt (`minHeight: 44, minWidth: 44`)
- [ ] `importantForAccessibility="no"` on decorative elements

---

## `collapsable={false}` for Native Component Children

Fabric may flatten layout-only views. If a component is a child of a native view that expects a specific child count, add:

```tsx
// Prevents Fabric from removing this view as a layout optimization
<View collapsable={false} style={styles.wrapper}>
  {children}
</View>
```

Use sparingly — only when native code explicitly references this view.

---

## Export Rules
```ts
// src/index.ts — export component + all types
export { Button, ButtonText, ButtonIcon } from './components/Button'
export type { ButtonProps } from './components/Button'
```

- `displayName` required on every `forwardRef` and `memo` component
- Spread `...props` so consumers can pass `testID`, `onLayout`, `style`
- No hardcoded colors, dimensions, or font sizes — always accept as props
