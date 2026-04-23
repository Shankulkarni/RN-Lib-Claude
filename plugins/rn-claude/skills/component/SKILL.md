---
name: component
description: "Use when building React Native UI components for a library — Fabric-compatible, New Architecture patterns, ref forwarding, Platform.OS, accessibility, and prop design."
---

# UI Component Patterns

New Architecture (Fabric) only. No legacy bridge. RN 0.76+.

## Component Template

```tsx
import { forwardRef } from 'react'
import { StyleSheet, View, type ViewProps } from 'react-native'

type MyComponentProps = ViewProps & {
  size?: number
  color?: string
}

const MyComponent = forwardRef<View, MyComponentProps>(
  ({ size = 48, color = '#000', style, ...props }, ref) => {
    return (
      <View
        ref={ref}
        style={[styles.container, { width: size, height: size }, style]}
        accessible
        accessibilityRole="none"
        {...props}
      />
    )
  },
)

MyComponent.displayName = 'MyComponent'

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#000',
    borderRadius: 8,
  },
})

export { MyComponent }
export type { MyComponentProps }
```

## Key Rules

- **No hardcoded colors** — always accept color as prop, default to semantic value
- **No hardcoded dimensions** — accept size/width/height props
- **Always `forwardRef`** for components that wrap native views
- **`displayName`** required for every component (DevTools + error messages)
- **Spread remaining props** so consumers can add `testID`, `accessibilityLabel`, etc.
- **`accessible` + `accessibilityRole`** on interactive elements

## Platform-Specific

```tsx
import { Platform, StyleSheet } from 'react-native'

const styles = StyleSheet.create({
  shadow: {
    ...Platform.select({
      ios: { shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.1, shadowRadius: 4 },
      android: { elevation: 4 },
    }),
  },
})
```

Platform-specific files: `MyComponent.ios.tsx`, `MyComponent.android.tsx` — resolved automatically by Metro.

## Animated Components

Read the `animations` skill for Reanimated patterns. Never use RN core `Animated` API.

```tsx
import Animated, { useAnimatedStyle, useSharedValue, withSpring } from 'react-native-reanimated'

// Animated.View, Animated.Text, Animated.Image from reanimated
// NOT from react-native
```

## Prop Design

```tsx
// Accept children for composition
type CardProps = {
  children: React.ReactNode
  variant?: 'outlined' | 'filled' | 'ghost'
  onPress?: () => void
}

// Never boolean prop explosion
// ❌ isRounded, isDisabled, isPrimary
// ✅ variant="primary", disabled, borderRadius={8}
```

## Exports

Every component export from `src/index.ts`:
```ts
export { MyComponent } from './components/MyComponent'
export type { MyComponentProps } from './components/MyComponent'
```

## Accessibility Checklist
- [ ] `accessibilityLabel` on non-text touchables
- [ ] `accessibilityRole` on interactive elements
- [ ] `accessibilityState={{ disabled }}` when component is disabled
- [ ] `accessibilityHint` for non-obvious interactions
- [ ] Minimum touch target: 44×44pt (iOS HIG)
