---
name: example-app
description: "Use when working on the Expo example app inside a React Native library repo — demo patterns, Expo SDK 52+, dev client vs Expo Go, metro config for local resolution, and testing the library in a real app context."
---

# Example App

Every library ships with an Expo example app in `example/`. Expo SDK 52+, `newArchEnabled: true` always.

## Expo Go vs Dev Client — Know This First

| Library type | Runs in Expo Go? | How to run |
|---|---|---|
| JS-only (`--type library`) | ✅ Yes | `expo start` → scan QR |
| TurboModule (`--type turbo-module`) | ❌ No — needs native code | `expo run:ios` / `expo run:android` |
| Fabric view (`--type fabric-view`) | ❌ No — needs native code | `expo run:ios` / `expo run:android` |

Native libraries require a **dev client** build. Expo Go cannot load custom native modules.

## Structure

```
example/
├── app/
│   ├── _layout.tsx       ← root layout
│   └── index.tsx         ← main demo screen
├── components/           ← demo-only components
├── app.json
├── package.json
├── metro.config.js       ← required for native libraries
└── tsconfig.json
```

## `app.json`

```json
{
  "expo": {
    "name": "MyLibExample",
    "slug": "my-lib-example",
    "version": "1.0.0",
    "orientation": "portrait",
    "newArchEnabled": true,
    "ios": { "supportsTablet": true },
    "android": { "adaptiveIcon": { "foregroundImage": "./assets/adaptive-icon.png" } }
  }
}
```

**`newArchEnabled: true` always** — no exceptions.

## `package.json` (example)

### JS-only library
```json
{
  "name": "my-lib-example",
  "private": true,
  "scripts": {
    "start": "expo start",
    "ios": "expo run:ios",
    "android": "expo run:android"
  },
  "dependencies": {
    "expo": "~52.0.0",
    "expo-router": "~4.0.0",
    "react": "18.3.1",
    "react-native": "0.76.x",
    "my-lib": "file:../"
  }
}
```

### Native library (TurboModule or Fabric view)
```json
{
  "name": "my-lib-example",
  "private": true,
  "scripts": {
    "start": "expo start --dev-client",
    "ios": "expo run:ios",
    "android": "expo run:android"
  },
  "dependencies": {
    "expo": "~52.0.0",
    "expo-dev-client": "~4.0.0",
    "expo-router": "~4.0.0",
    "react": "18.3.1",
    "react-native": "0.76.x",
    "my-lib": "file:../"
  }
}
```

`expo-dev-client` enables running custom native code without ejecting. Always include it for native libraries.

## Metro Config (native libraries — required)

`example/metro.config.js`:
```js
const { getDefaultConfig } = require('expo/metro-config')
const path = require('path')

const config = getDefaultConfig(__dirname)
const root = path.resolve(__dirname, '..')

config.watchFolders = [root]
config.resolver.nodeModulesPaths = [
  path.resolve(__dirname, 'node_modules'),
  path.resolve(root, 'node_modules'),
]

module.exports = config
```

Without this, Metro cannot resolve the local `file:../` library on native builds.

## Demo Screen Pattern

```tsx
import { ScrollView, StyleSheet, Text, View } from 'react-native'
import { MyComponent, useMyHook } from 'my-lib'

export default function App() {
  return (
    <ScrollView contentContainerStyle={styles.container}>
      <Section title="Basic Usage">
        <MyComponent label="Default" />
      </Section>

      <Section title="Variants">
        <MyComponent variant="primary" label="Primary" />
        <MyComponent variant="secondary" label="Secondary" />
      </Section>

      <Section title="Edge Cases">
        <MyComponent label="" />
        <MyComponent label="Very long label that might overflow the container" />
      </Section>
    </ScrollView>
  )
}

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <View style={styles.section}>
      <Text style={styles.sectionTitle}>{title}</Text>
      <View style={styles.sectionContent}>{children}</View>
    </View>
  )
}

const styles = StyleSheet.create({
  container: { padding: 16, gap: 24 },
  section: { gap: 8 },
  sectionTitle: { fontSize: 13, fontWeight: '600', color: '#666', textTransform: 'uppercase' },
  sectionContent: { gap: 8 },
})
```

## Running

### JS-only library
```bash
cd example && bun install
bun run start   # scan QR with Expo Go
```

### Native library
```bash
cd example && bun install
bun run ios     # builds native + launches simulator
bun run android # builds native + launches emulator
```

First native build is slow (CocoaPods install + Gradle). Subsequent builds are fast.

## Rules

- Demo **every exported component and hook** — no hidden APIs
- Show **variants**, **edge cases**, and **interactive examples**
- Use `file:../` to reference local library — never a versioned dep
- Keep example app **simple** — no extra state management, no network calls
- `newArchEnabled: true` always in `app.json`
- JS-only libraries must work in Expo Go (no native deps)
- Native libraries must include `expo-dev-client`
- Metro config required for all native libraries

## Checklist
- [ ] Every export has a demo
- [ ] `newArchEnabled: true` in `app.json`
- [ ] JS-only: runs in Expo Go
- [ ] Native: `expo-dev-client` in dependencies, `start` script uses `--dev-client`
- [ ] Native: Metro config set up for local library resolution
- [ ] No hardcoded data that should be props
