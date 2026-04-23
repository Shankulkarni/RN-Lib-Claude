---
name: animations
description: "Use when implementing animations or gestures in a React Native library — GPU-only properties, Reanimated v3/v4 worklets, useDerivedValue, GestureDetector press states, React Compiler compatibility."
---

# Animations + Gestures

Reanimated v3+ + Gesture Handler v2. New Architecture only. No RN core `Animated` API.

---

## CRITICAL — Only Animate GPU-Accelerated Properties

Animating layout properties causes the layout engine to recalculate on every frame → dropped frames.

```tsx
// ❌ Causes layout recalculation — never animate these
width, height, top, left, right, bottom
margin, padding, borderWidth, flex

// ✅ GPU-accelerated — animate freely
transform: [{ translateX }, { translateY }, { scale }, { rotate }]
opacity
```

```tsx
// ❌ Animating width
const width = useSharedValue(100)
const style = useAnimatedStyle(() => ({ width: width.value }))

// ✅ Use scale transform instead
const scale = useSharedValue(1)
const style = useAnimatedStyle(() => ({ transform: [{ scale: scale.value }] }))
```

---

## Reanimated Imports

```tsx
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  useDerivedValue,
  useAnimatedReaction,
  withSpring,
  withTiming,
  withSequence,
  withDelay,
  withRepeat,
  runOnJS,
  interpolate,
  interpolateColor,
  Extrapolation,
  cancelAnimation,
} from 'react-native-reanimated'

// Always Animated.View from reanimated — never from react-native
```

---

## `useDerivedValue` vs `useAnimatedReaction`

```tsx
// ✅ useDerivedValue — compute a new shared value from another
// Runs on UI thread. Use for transforming values.
const rotation = useDerivedValue(() => `${progress.value * 360}deg`)
const clampedScale = useDerivedValue(() =>
  interpolate(rawScale.value, [0, 1], [0.8, 1.2], Extrapolation.CLAMP)
)

// ✅ useAnimatedReaction — respond to a shared value with a side effect
// Use ONLY for side effects (calling JS, triggering haptics, updating refs).
// Never use it to compute another value — that's useDerivedValue's job.
useAnimatedReaction(
  () => progress.value,
  (current, previous) => {
    if (current >= 1 && previous !== null && previous < 1) {
      runOnJS(onComplete)()   // ← side effect: call JS
    }
  },
)
```

---

## Animated Press State (GestureDetector — not Pressable callbacks)

When a component needs animated press feedback, use `GestureDetector` + shared values. Pressable callbacks fire on the JS thread and can't drive smooth animations.

```tsx
import { Gesture, GestureDetector } from 'react-native-gesture-handler'
import Animated, { useSharedValue, useAnimatedStyle, withSpring } from 'react-native-reanimated'

type AnimatedButtonProps = {
  onPress?: () => void
  children: ReactNode
}

function AnimatedButton({ onPress, children }: AnimatedButtonProps) {
  const scale = useSharedValue(1)
  const opacity = useSharedValue(1)

  const tap = Gesture.Tap()
    .onBegin(() => {
      scale.value = withSpring(0.95, { damping: 15, stiffness: 300 })
      opacity.value = withTiming(0.8, { duration: 80 })
    })
    .onFinalize((_, success) => {
      scale.value = withSpring(1, { damping: 15, stiffness: 300 })
      opacity.value = withTiming(1, { duration: 120 })
      if (success && onPress) runOnJS(onPress)()
    })

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
    opacity: opacity.value,
  }))

  return (
    <GestureDetector gesture={tap}>
      <Animated.View style={animatedStyle}>{children}</Animated.View>
    </GestureDetector>
  )
}
```

---

## Pan Gesture (Draggable)

```tsx
function Draggable({ children }: { children: ReactNode }) {
  const x = useSharedValue(0)
  const y = useSharedValue(0)
  const startX = useSharedValue(0)
  const startY = useSharedValue(0)

  const pan = Gesture.Pan()
    .onStart(() => {
      startX.value = x.value
      startY.value = y.value
    })
    .onUpdate(e => {
      x.value = startX.value + e.translationX
      y.value = startY.value + e.translationY
    })
    .onEnd(() => {
      x.value = withSpring(0)
      y.value = withSpring(0)
    })

  const style = useAnimatedStyle(() => ({
    transform: [{ translateX: x.value }, { translateY: y.value }],
  }))

  return (
    <GestureDetector gesture={pan}>
      <Animated.View style={style}>{children}</Animated.View>
    </GestureDetector>
  )
}
```

---

## Composing Gestures

```tsx
const composed = Gesture.Simultaneous(panGesture, pinchGesture)   // both fire
const composed = Gesture.Exclusive(tapGesture, longPress)          // first wins
const composed = Gesture.Race(tapGesture, panGesture)              // first cancels rest
```

---

## Interpolation

```tsx
const style = useAnimatedStyle(() => {
  const rotate = interpolate(progress.value, [0, 1], [0, 360], Extrapolation.CLAMP)
  const color = interpolateColor(progress.value, [0, 1], ['#ff0000', '#00ff00'])
  return {
    transform: [{ rotate: `${rotate}deg` }],
    backgroundColor: color,
  }
})
```

---

## Animation Configs — Accept as Props

Never hardcode spring/timing values. Expose as props so consumers can tune:

```tsx
import type { WithSpringConfig, WithTimingConfig } from 'react-native-reanimated'

type SliderProps = {
  springConfig?: WithSpringConfig
  timingConfig?: WithTimingConfig
}

const DEFAULT_SPRING: WithSpringConfig = { damping: 15, stiffness: 150, mass: 1 }

function Slider({ springConfig = DEFAULT_SPRING }: SliderProps) {
  // use springConfig in withSpring calls
}
```

---

## Reanimated 4 — API Changes (New Architecture Required)

Reanimated 4 introduces breaking API changes. If targeting both v3 and v4:

```tsx
// v3
import { runOnUI } from 'react-native-reanimated'
runOnUI(() => { 'worklet'; scale.value = 1 })()

// v4
import { scheduleOnUI } from 'react-native-reanimated'
scheduleOnUI(() => { 'worklet'; scale.value = 1 })()
```

Reanimated 4 requires New Architecture — already enforced by this plugin.

---

## React Compiler Compatibility

React Compiler optimizes shared value access. Use `.get()`/`.set()` methods:

```tsx
// ❌ Direct .value — React Compiler may misoptimize
const scale = useSharedValue(1)
scale.value = withSpring(1)
const current = scale.value

// ✅ .get()/.set() — React Compiler safe (Reanimated 4+)
scale.set(withSpring(1))
const current = scale.get()
```

---

## Worklet Rules (critical)

- **No `console.log`** inside worklets — crashes New Architecture UI thread
- **No closures over JS objects** — only capture primitives or other shared values
- **No async/await** — worklets are synchronous
- **No React hooks** — worklets run on UI thread, not React fiber
- Functions called from worklets must have `'worklet'` directive or be native

```tsx
// ✅ Worklet-safe utility
function clamp(value: number, min: number, max: number): number {
  'worklet'
  return Math.min(Math.max(value, min), max)
}
```

---

## JS ↔ UI Thread

```tsx
// UI thread → JS thread
runOnJS(jsCallback)(arg1, arg2)

// JS thread → UI thread (v3)
runOnUI(() => { 'worklet'; sharedValue.value = 1 })()

// JS thread → UI thread (v4)
scheduleOnUI(() => { 'worklet'; sharedValue.value = 1 })()
```

---

## Peer Dep Reminder

Add to `package.json` when using animations/gestures:
```json
"peerDependencies": {
  "react-native-reanimated": ">=3.0.0",
  "react-native-gesture-handler": ">=2.0.0"
},
"peerDependenciesMeta": {
  "react-native-reanimated": { "optional": true },
  "react-native-gesture-handler": { "optional": true }
}
```
