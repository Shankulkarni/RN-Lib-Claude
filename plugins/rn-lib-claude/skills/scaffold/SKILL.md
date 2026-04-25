---
name: scaffold
description: "Use when creating a new React Native library from scratch — sets up create-react-native-library, bob config, JS-only vs native path, Codegen, Expo example app, peer deps, ESLint, Prettier, Husky, and Changesets."
user_invocable: true
---

# Library Scaffolding

## Stack
`create-react-native-library` + `react-native-builder-bob`, TypeScript strict, ESLint v9, Prettier, Husky + lint-staged, Changesets, Expo example app.

## Before You Start

### Prerequisites
- **bun** must be installed. If not: `curl -fsSL https://bun.sh/install | bash`
- **Node.js** >= 18

### Gather from user:
- **Library name** (e.g. `rn-image-gallery` -> package `@scope/rn-image-gallery`)
- **npm scope** (e.g. `@myorg`) or unscoped
- **JS-only or native?** JS-only = no android/ios. Native = Codegen + TurboModule/Fabric.
- **Animations?** If yes, add `react-native-reanimated` + `react-native-gesture-handler` as peer deps.

## Step 1: Scaffold

### Non-interactive (recommended)

For a **native TurboModule** library:
```bash
bunx create-react-native-library@latest rn-my-library \
  --slug rn-my-library \
  --description "My library description" \
  --author-name "Author Name" \
  --author-email "author@example.com" \
  --author-url "https://github.com/author" \
  --repo-url "https://github.com/author/rn-my-library" \
  --type turbo-module \
  --languages kotlin-objc \
  --example expo \
  --tools eslint jest
```

For a **Fabric view** library, use `--type fabric-view`.

For a **JS-only** library:
```bash
bunx create-react-native-library@latest rn-my-library \
  --slug rn-my-library \
  --description "My library description" \
  --author-name "Author Name" \
  --author-email "author@example.com" \
  --author-url "https://github.com/author" \
  --repo-url "https://github.com/author/rn-my-library" \
  --type library \
  --languages js \
  --example expo \
  --tools eslint jest
```

### Valid `--type` values
| Value | Use case |
|---|---|
| `turbo-module` | Native module (TurboModule) |
| `fabric-view` | Native view (Fabric component) |
| `library` | JS-only, no native code |

### Required flags
- `--tools` is **required** — use `--tools eslint jest` at minimum
- `--author-url` must be a valid URL (cannot be empty)

### Interactive fallback
If non-interactive fails, run without flags and select interactively:
```bash
bunx create-react-native-library@latest rn-my-library
```

## Step 2: Remove Yarn, Switch to Bun

The scaffold generates Yarn config. Remove it and switch to bun:
```bash
rm -rf .yarn .yarnrc.yml
bun install
```

## Step 3: bob Config

`create-react-native-library` v0.62+ configures bob directly in `package.json` under the `"react-native-builder-bob"` key. The default config is correct:

```json
"react-native-builder-bob": {
  "source": "src",
  "output": "lib",
  "targets": [
    ["module", { "esm": true }],
    ["typescript", { "project": "tsconfig.build.json" }]
  ]
}
```

**Note:** Modern bob only uses `module` (ESM) output. There is no `commonjs` target — bundlers handle CJS conversion.

## Step 4: `package.json` Conventions

Update the generated `package.json`:

```json
{
  "name": "rn-my-library",
  "version": "0.1.0",
  "main": "./lib/module/index.js",
  "types": "./lib/typescript/src/index.d.ts",
  "exports": {
    ".": {
      "source": "./src/index.tsx",
      "types": "./lib/typescript/src/index.d.ts",
      "default": "./lib/module/index.js"
    },
    "./package.json": "./package.json"
  },
  "files": [
    "src",
    "lib",
    "android",
    "ios",
    "cpp",
    "*.podspec",
    "react-native.config.js",
    "!ios/build",
    "!android/build",
    "!**/__tests__",
    "!**/__fixtures__",
    "!**/__mocks__",
    "!**/.*"
  ],
  "peerDependencies": {
    "react": ">=18.0.0",
    "react-native": ">=0.76.0"
  },
  "scripts": {
    "build": "bob build",
    "clean": "del-cli lib",
    "prepare": "bob build && husky",
    "typecheck": "tsc",
    "lint": "eslint \"**/*.{js,ts,tsx}\"",
    "format": "prettier --write \"**/*.{js,ts,tsx,json,md}\"",
    "format:check": "prettier --check \"**/*.{js,ts,tsx,json,md}\"",
    "check": "bun run typecheck && bun run lint && bun run format:check",
    "test": "jest",
    "changeset": "changeset",
    "version": "changeset version",
    "release": "bun run build && changeset publish"
  }
}
```

**Important:** The `prepare` script must be `bob build && husky` — `husky init` (Step 8) will overwrite this to just `husky`. Always restore `bob build &&` prefix after running `husky init`.

### Animation peer deps (only if library uses them)

```json
"peerDependencies": {
  "react": ">=18.0.0",
  "react-native": ">=0.76.0",
  "react-native-reanimated": ">=3.0.0",
  "react-native-gesture-handler": ">=2.0.0"
},
"peerDependenciesMeta": {
  "react-native-reanimated": { "optional": true },
  "react-native-gesture-handler": { "optional": true }
}
```

### lint-staged config

Add to `package.json`:
```json
"lint-staged": {
  "*.{js,ts,tsx}": ["eslint --fix", "prettier --write"],
  "*.{json,md}": ["prettier --write"]
}
```

## Step 5: Prettier Config

Add to `package.json` (replaces any generated `.prettierrc`):
```json
"prettier": {
  "singleQuote": true,
  "semi": false,
  "trailingComma": "es5",
  "useTabs": true
}
```

## Step 6: ESLint

The generated `eslint.config.mjs` uses `@react-native/eslint-config` which requires many peer plugins. Install all of them:

```bash
bun add -d \
  eslint-plugin-eslint-comments \
  eslint-plugin-react \
  eslint-plugin-react-hooks \
  eslint-plugin-react-native \
  eslint-plugin-jest \
  @react-native/eslint-plugin \
  @typescript-eslint/parser \
  @typescript-eslint/eslint-plugin
```

These are required peers of `@react-native/eslint-config` — without them, `eslint` will fail with "plugin not found" errors.

## Step 7: Changesets Init

```bash
bunx changeset init
```

Edit `.changeset/config.json` — set access to `public`:
```json
{
  "changelog": "@changesets/cli/changelog",
  "commit": false,
  "baseBranch": "main",
  "access": "public"
}
```

Add `@changesets/cli` to devDependencies:
```bash
bun add -d @changesets/cli
```

## Step 8: Husky + lint-staged

```bash
bun add -d husky@^9 lint-staged
bunx husky init
```

**Important:** `husky init` overwrites the `prepare` script to just `"husky"`. You MUST restore it:
```bash
# Fix prepare script (husky init removes bob build)
npm pkg set scripts.prepare="bob build && husky"
```

Set the pre-commit hook to run lint-staged:
```bash
echo "bunx lint-staged" > .husky/pre-commit
```

**Note:** `husky@10` does not exist. Always use `husky@^9`.

## Step 9: Format All Files

After scaffolding, the generated files (especially example app) use spaces and semicolons. Run format to apply the project's prettier config:

```bash
bun run format
```

This ensures all files match the tabs + no semicolons + single quotes convention.

## Step 10: Native Path Only — Codegen

If native, the scaffold already adds `codegenConfig` to `package.json`:
```json
"codegenConfig": {
  "name": "RNMyLibrarySpec",
  "type": "modules",
  "jsSrcsDir": "src",
  "android": {
    "javaPackageName": "com.mylibrary"
  }
}
```

Then read the `codegen` skill for full native implementation details.

## Step 11: src/index.ts

```ts
// Export everything public. Nothing else.
export { MyComponent } from './components/MyComponent'
export type { MyComponentProps } from './components/MyComponent'
```

## Step 12: Verify

```bash
bun run check
```

This runs typecheck + lint + format:check. All three must pass.

## Post-Scaffold Checklist
- [ ] `bun run check` passes clean
- [ ] `bun run build` produces `lib/` with module + types output
- [ ] Example app runs (`cd example && bun run ios`)
- [ ] `.changeset/` directory exists
- [ ] `.husky/pre-commit` contains `bunx lint-staged`
- [ ] `prepare` script is `bob build && husky` (not just `husky`)
- [ ] README.md documents every export

## Common Gotchas

| Problem | Cause | Fix |
|---|---|---|
| `husky@^10.0.0 failed to resolve` | husky v10 doesn't exist | Use `husky@^9` |
| `eslint-plugin-X not found` | Missing peer deps of `@react-native/eslint-config` | Install all 8 plugins from Step 6 |
| `prepare` only runs `husky` | `husky init` overwrites it | Restore to `bob build && husky` |
| Example app has wrong formatting | Generated with spaces/semicolons | Run `bun run format` |
| `--author-url` error | Empty string passed | Must be a valid URL |
| `--tools` missing error | Required flag since v0.62 | Pass `--tools eslint jest` |
| `lib/commonjs` not found | Modern bob uses ESM only | Check for `lib/module` instead |
