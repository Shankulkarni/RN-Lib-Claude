---
name: animations
description: "Use when implementing animations or gestures in a React Native library — Reanimated v3 worklets, shared values, useAnimatedStyle, GestureDetector API, New Architecture patterns."
---

# Animations + Gestures

Reanimated v3 + Gesture Handler v2. New Architecture only. No RN core `Animated` API.

## Reanimated Fundamentals

```tsx
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withTiming,
  withSequence,
  withDelay,
  withRepeat,
  runOnJS,
  interpolate,
  Extrapolation,
} from 'react-native-reanimated'

function MyAnimatedComponent() {
  const scale = useSharedValue(1)
  const opacity = useSharedValue(1)

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
    opacity: opacity.value,
  }))

  return <Animated.View style={[styles.box, animatedStyle]} />
}
```

## Animation Presets

```ts
// Spring — feels physical
withSpring(toValue, { damping: 15, stiffness: 150, mass: 1 })

// Timing — precise duration
withTiming(toValue, { duration: 300 })

// Sequence
withSequence(withTiming(1.2), withSpring(1))

// Repeat
withRepeat(withTiming(1, { duration: 500 }), -1, true) // -1 = infinite, true = reverse

// Delay
withDelay(200, withSpring(1))
```

## Interpolation

```ts
const animatedStyle = useAnimatedStyle(() => {
  const rotate = interpolate(
    progress.value,
    [0, 1],
    [0, 360],
    Extrapolation.CLAMP,
  )
  return { transform: [{ rotate: `${rotate}deg` }] }
})
```

## Gesture Handler

```tsx
import { Gesture, GestureDetector } from 'react-native-gesture-handler'

function DraggableCard() {
  const x = useSharedValue(0)
  const y = useSharedValue(0)
  const startX = useSharedValue(0)
  const startY = useSharedValue(0)

  const panGesture = Gesture.Pan()
    .onStart(() => {
      startX.value = x.value
      startY.value = y.value
    })
    .onUpdate(event => {
      x.value = startX.value + event.translationX
      y.value = startY.value + event.translationY
    })
    .onEnd(() => {
      x.value = withSpring(0)
      y.value = withSpring(0)
    })

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ translateX: x.value }, { translateY: y.value }],
  }))

  return (
    <GestureDetector gesture={panGesture}>
      <Animated.View style={animatedStyle} />
    </GestureDetector>
  )
}
```

## Composing Gestures

```ts
// Simultaneous — both fire at once
const composed = Gesture.Simultaneous(panGesture, pinchGesture)

// Exclusive — first to activate wins
const composed = Gesture.Exclusive(tapGesture, longPressGesture)

// Race — first to activate, others cancelled
const composed = Gesture.Race(tapGesture, panGesture)
```

## JS ↔ Worklet Communication

```ts
// Call JS function from worklet
const handleComplete = () => {
  console.log('done') // JS thread
}

const gesture = Gesture.Tap().onEnd(() => {
  runOnJS(handleComplete)() // bridge worklet → JS
})

// Run worklet from JS (rare — usually just set shared value)
runOnUI(() => {
  'worklet'
  scale.value = withSpring(1)
})()
```

## Worklet Rules
- No `console.log` inside worklets — silent crash in New Architecture
- No closures over objects/arrays from JS thread — pass primitives only
- No async/await — worklets are synchronous
- No React hooks inside worklets
- Functions called from worklets must also have `'worklet'` directive

## Library Prop API Pattern

```tsx
type AnimatedCardProps = {
  entering?: EntryAnimation     // Reanimated Layout Animation
  exiting?: ExitAnimation
  animationDuration?: number
  springConfig?: WithSpringConfig
}
```

Expose animation config as props — never hardcode spring/timing values in library components.

## Peer Dep Reminder
Add to library `package.json` when using reanimated/gesture-handler:
```json
"peerDependencies": {
  "react-native-reanimated": ">=3.0.0",
  "react-native-gesture-handler": ">=2.0.0"
}
```
