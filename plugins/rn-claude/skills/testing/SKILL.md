---
name: testing
description: "Use when writing tests for a React Native library — Jest setup with jest-expo preset, React Native Testing Library patterns, Reanimated mocks, Codegen mocks, what to test and what not to."
---

# Testing RN Libraries

## Setup

`jest.config.js`:
```js
module.exports = {
  preset: 'jest-expo',
  setupFilesAfterFramework: ['@testing-library/react-native/extend-expect'],
  modulePathIgnorePatterns: ['<rootDir>/example/', '<rootDir>/lib/'],
  transformIgnorePatterns: [
    'node_modules/(?!((jest-)?react-native|@react-native(-community)?|expo(nent)?|@expo(nent)?/.*|@expo-google-fonts/.*|react-navigation|@react-navigation/.*|@unimodules/.*|unimodules|sentry-expo|native-base|react-native-svg|react-native-reanimated|react-native-gesture-handler))',
  ],
}
```

`package.json`:
```json
"devDependencies": {
  "jest-expo": "^52.0.0",
  "@testing-library/react-native": "^12.0.0",
  "react-test-renderer": "18.3.1"
}
```

## Reanimated Mock

Add to `jest.config.js` `setupFiles`:
```js
setupFiles: ['react-native-reanimated/mock']
```

Or manually:
```ts
jest.mock('react-native-reanimated', () => {
  const Reanimated = require('react-native-reanimated/mock')
  Reanimated.default.call = jest.fn()
  return Reanimated
})
```

## Gesture Handler Mock

```ts
jest.mock('react-native-gesture-handler', () => {
  const { View } = require('react-native')
  return {
    GestureDetector: ({ children }: { children: React.ReactNode }) => children,
    Gesture: { Pan: () => ({ onStart: jest.fn().mockReturnThis(), onUpdate: jest.fn().mockReturnThis(), onEnd: jest.fn().mockReturnThis() }) },
  }
})
```

## Component Test Template

```tsx
import { render, screen, userEvent } from '@testing-library/react-native'
import { MyComponent } from '../src'

describe('MyComponent', () => {
  it('renders correctly', () => {
    render(<MyComponent label="Hello" />)
    expect(screen.getByText('Hello')).toBeOnTheScreen()
  })

  it('calls onPress when tapped', async () => {
    const user = userEvent.setup()
    const onPress = jest.fn()
    render(<MyComponent label="Tap me" onPress={onPress} />)
    await user.press(screen.getByText('Tap me'))
    expect(onPress).toHaveBeenCalledTimes(1)
  })

  it('applies variant styles', () => {
    const { rerender } = render(<MyComponent variant="primary" />)
    // test behavior, not style values
    rerender(<MyComponent variant="secondary" />)
    // verify the component handles variant without error
  })
})
```

## Hook Test Template

```ts
import { renderHook, act } from '@testing-library/react-native'
import { useMyHook } from '../src'

describe('useMyHook', () => {
  it('returns initial value', () => {
    const { result } = renderHook(() => useMyHook({ initialValue: 5 }))
    expect(result.current.value).toBe(5)
  })

  it('increments value', () => {
    const { result } = renderHook(() => useMyHook())
    act(() => result.current.increment())
    expect(result.current.value).toBe(1)
  })

  it('calls onChange when value changes', () => {
    const onChange = jest.fn()
    const { result } = renderHook(() => useMyHook({ onChange }))
    act(() => result.current.increment())
    expect(onChange).toHaveBeenCalledWith(1)
  })
})
```

## What to Test

- Component renders without error
- All variants render without error
- Interactive callbacks fire correctly
- Hook state transitions
- Edge cases: empty arrays, null/undefined props, zero values
- Accessibility props present on interactive elements
- Cleanup on unmount (event listeners removed)

## What NOT to Test

- StyleSheet values (implementation detail)
- Animation interpolation math (Reanimated mocks skip it)
- Platform.OS branching directly (test behavior, mock platform)
- Internal helper functions (test via public API)
- Auto-generated Codegen output

## File Conventions

- `src/__tests__/MyComponent.test.tsx` — component tests
- `src/__tests__/useMyHook.test.ts` — hook tests
- `src/__tests__/utils.test.ts` — utility tests
- One describe per component/hook, one it per behavior

## Queries Priority

1. `getByRole` — best, accessible
2. `getByLabelText` — form elements
3. `getByText` — visible text
4. `getByTestId` — last resort, add `testID` prop to component

Always `userEvent` not `fireEvent` for user interactions.
