---
name: example-app
description: "Use when working on the Expo example app inside a React Native library repo — demo patterns, Expo SDK 52+, Expo Go compatibility, and testing the library in a real app context."
---

# Example App

Every library ships with an Expo example app in `example/`. Expo SDK 52+, Expo Go compatible.

## Structure

```
example/
├── app/
│   ├── _layout.tsx       ← root layout
│   └── index.tsx         ← main demo screen
├── components/           ← demo-only components
├── app.json
├── package.json
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

**`newArchEnabled: true` always** — example app must run on New Architecture.

## `package.json` (example)

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

## Rules

- Demo **every exported component and hook** — no hidden APIs
- Show **variants**, **edge cases**, and **interactive examples**
- Use `file:../` to reference local library — never publish example with a versioned dep
- Keep example app **simple** — no extra state management, no network calls
- `newArchEnabled: true` always in `app.json`
- Example must run on **Expo Go** (no custom native modules unless library requires it)

## Metro Config

If library has native code, add to `example/metro.config.js`:
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

## Running

```bash
cd example
bun install
bun run ios     # or android
```

## Checklist
- [ ] Every export has a demo
- [ ] `newArchEnabled: true` in `app.json`
- [ ] Runs on Expo Go (if JS-only library)
- [ ] Metro config set up for local library resolution
- [ ] No hardcoded data that should be props
