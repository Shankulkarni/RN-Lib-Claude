---
name: scaffold
description: "Use when creating a new React Native library from scratch — sets up create-react-native-library, bob config, JS-only vs native path, Codegen, Expo example app, peer deps, ESLint, Prettier, Husky, and Changesets."
user_invocable: true
---

# Library Scaffolding

## Stack
`create-react-native-library` + `react-native-builder-bob`, TypeScript strict, ESLint v9, Prettier, Husky + lint-staged, Changesets, Expo example app.

## Before You Start

Gather from user:
- **Library name** (e.g. `rn-image-gallery` → package `@scope/rn-image-gallery`)
- **npm scope** (e.g. `@myorg`) or unscoped
- **JS-only or native?** JS-only = no android/ios. Native = Codegen + TurboModule/Fabric.
- **Animations?** If yes, add `react-native-reanimated` + `react-native-gesture-handler` as peer deps.

## Step 1: Scaffold

```bash
bunx create-react-native-library@latest rn-my-library
```

Select during prompts:
- **Languages**: TypeScript
- **Type**: `Turbo module` (native path) or `JavaScript library` (JS-only)
- **Example**: Expo

## Step 2: bob Config (`bob.config.js`)

```js
module.exports = {
  source: 'src',
  output: 'lib',
  targets: [
    ['commonjs', { jsxRuntime: 'automatic' }],
    ['module', { jsxRuntime: 'automatic' }],
    'typescript',
  ],
}
```

## Step 3: `package.json` Conventions

```json
{
  "name": "@scope/rn-my-library",
  "version": "0.1.0",
  "main": "lib/commonjs/index.js",
  "module": "lib/module/index.js",
  "types": "lib/typescript/src/index.d.ts",
  "exports": {
    ".": {
      "import": "./lib/module/index.js",
      "require": "./lib/commonjs/index.js",
      "types": "./lib/typescript/src/index.d.ts"
    }
  },
  "files": ["lib/", "src/", "android/", "ios/"],
  "peerDependencies": {
    "react": ">=18.0.0",
    "react-native": ">=0.76.0"
  },
  "devDependencies": {
    "react-native-builder-bob": "^0.30.0"
  },
  "scripts": {
    "build": "bob build",
    "lint": "eslint src/",
    "typecheck": "tsc --noEmit",
    "test": "jest",
    "check": "bun run typecheck && bun run lint && bun run test"
  }
}
```

Add reanimated/gesture-handler to peerDependencies only if the library uses them:
```json
"react-native-reanimated": ">=3.0.0",
"react-native-gesture-handler": ">=2.0.0"
```

## Step 4: tsconfig.json

```json
{
  "compilerOptions": {
    "strict": true,
    "moduleResolution": "bundler",
    "jsx": "react-jsx",
    "lib": ["ES2022"],
    "target": "ES2022",
    "noEmit": true,
    "allowImportingTsExtensions": true
  },
  "include": ["src", "example/src"]
}
```

## Step 5: Changesets Init

```bash
bunx changeset init
```

Edit `.changeset/config.json`:
```json
{
  "changelog": "@changesets/cli/changelog",
  "commit": false,
  "baseBranch": "main",
  "access": "public"
}
```

## Step 6: ESLint + Prettier

`eslint.config.js`:
```js
import js from '@eslint/js'
import tsPlugin from '@typescript-eslint/eslint-plugin'
import tsParser from '@typescript-eslint/parser'

export default [
  js.configs.recommended,
  {
    files: ['src/**/*.{ts,tsx}'],
    languageOptions: { parser: tsParser },
    plugins: { '@typescript-eslint': tsPlugin },
    rules: {
      '@typescript-eslint/no-explicit-any': 'error',
      'no-console': 'error',
    },
  },
]
```

`.prettierrc`:
```json
{ "singleQuote": true, "semi": false, "trailingComma": "all", "useTabs": true }
```

## Step 7: Husky

```bash
bunx husky init
echo "bun run check" > .husky/pre-commit
```

## Step 8: Native Path Only — Codegen

If native, add to `package.json`:
```json
"codegenConfig": {
  "name": "RNMyLibrarySpec",
  "type": "modules",
  "jsSrcsDir": "src"
}
```

Then read the `codegen` skill.

## Step 9: src/index.ts

```ts
// Export everything public. Nothing else.
export { MyComponent } from './components/MyComponent'
export type { MyComponentProps } from './components/MyComponent'
```

## Post-Scaffold Checklist
- [ ] `bun run check` passes clean
- [ ] Example app runs (`cd example && bun run ios`)
- [ ] `bob build` produces `lib/` with cjs + esm + types
- [ ] `.changeset/` directory exists
- [ ] README.md documents every export
