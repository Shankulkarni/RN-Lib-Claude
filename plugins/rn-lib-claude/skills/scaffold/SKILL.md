---
name: scaffold
description: "Use when creating a new React Native library from scratch — sets up create-react-native-library, bob config, TurboModule / Fabric view (New Architecture) or JS-only library, Expo example app, peer deps, ESLint, Prettier, Husky, and Changesets."
user_invocable: true
---

# Library Scaffolding

## Stack
`create-react-native-library` + `react-native-builder-bob`, TypeScript strict, ESLint v9, Prettier, Husky + lint-staged, Changesets, Expo example app.

Reference: https://oss.callstack.com/react-native-builder-bob/create

## Before You Start

### Prerequisites
- **bun** must be installed. If not: `curl -fsSL https://bun.sh/install | bash`
- **Node.js** >= 18

### Gather from user:
- **Library name** (e.g. `rn-country-picker` → package `@scope/rn-country-picker`)
- **npm scope** (e.g. `@myorg`) or unscoped
- **Type?** See decision guide below.
- **Animations?** If yes, add `react-native-reanimated` + `react-native-gesture-handler` as peer deps. (native and JS-only)

### Type decision guide
| I need to... | Use |
|---|---|
| Call native platform APIs (camera, sensors, storage, crypto) | `turbo-module` |
| Expose native business logic or background processing | `turbo-module` |
| Render a native UI component (map, video player, native picker) | `fabric-view` |
| Wrap an existing native SDK's view | `fabric-view` |
| Build UI components, hooks, utilities — no native code | `library` |
| Country/state/city pickers, formatters, validators, headless logic | `library` |

## Step 1: Scaffold

For a **TurboModule** (native API/logic):
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

For a **Fabric view** (native UI component):
```bash
bunx create-react-native-library@latest rn-my-library \
  --slug rn-my-library \
  --description "My library description" \
  --author-name "Author Name" \
  --author-email "author@example.com" \
  --author-url "https://github.com/author" \
  --repo-url "https://github.com/author/rn-my-library" \
  --type fabric-view \
  --languages kotlin-objc \
  --example expo \
  --tools eslint jest
```

For a **JS-only library** (TypeScript, no native code):
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

### Flag reference
| Flag | `turbo-module` | `fabric-view` | `library` |
|---|---|---|---|
| `--type` | `turbo-module` | `fabric-view` | `library` |
| `--languages` | `kotlin-objc` | `kotlin-objc` | `js` |
| `--example` | `expo` | `expo` | `expo` |
| `--tools` | `eslint jest` | `eslint jest` | `eslint jest` |
| Native folders | `android/` `ios/` | `android/` `ios/` | none |
| Codegen spec | required | required | none |

**`--languages` controls the native language (Kotlin/ObjC), NOT TypeScript.** TypeScript is always generated. For a JS-only library, `--languages js` means "no native code" — it does not mean JavaScript instead of TypeScript.

**`--author-url` must be a valid URL (cannot be empty) for all types.**
**Skip `lefthook`/`release-it` in `--tools` — we use Husky + Changesets instead.**

### If the target directory already exists

`create-react-native-library` crashes with `ERR_INVALID_ARG_TYPE` when the target directory already exists (even if it is nearly empty). Scaffold to a temporary name, then move:

```bash
bunx create-react-native-library@latest rn-my-library-tmp \
  --slug rn-my-library \
  ... (all other flags) ...

cp -r rn-my-library-tmp/. rn-my-library/
rm -rf rn-my-library-tmp
```

### Interactive fallback
If non-interactive fails, run without flags and select:
- Type → **TurboModule**, **Fabric view**, or **Library**
- Languages → **Kotlin & Objective-C** (native) or **JavaScript** (JS-only)
- Example → **Expo**
- Tools → **ESLint**, **Jest** (uncheck lefthook, release-it)

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
    "android",          // native only — remove for JS-only library
    "ios",              // native only — remove for JS-only library
    "cpp",              // native only — remove for JS-only library
    "*.podspec",        // native only — remove for JS-only library
    "react-native.config.js", // native only — remove for JS-only library
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
bun add -d --ignore-scripts \
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

**Use `--ignore-scripts`** because the `prepare` script (`bob build && husky`) will fail at this point — husky is not installed yet. Use `--ignore-scripts` for all `bun add` calls until after Step 8.

## Step 7: Changesets Init

Install `@changesets/cli` first — `bunx changeset init` cannot find the binary until the package is installed:

```bash
bun add -d --ignore-scripts @changesets/cli
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

## Step 8: Husky + lint-staged

```bash
bun add -d --ignore-scripts husky@^9 lint-staged
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

## Step 10: Expo Example App — Dev Client (native only)

For TurboModule and Fabric view libraries, the example app cannot use Expo Go — it requires a dev client build. After scaffolding:

1. Add `expo-dev-client` to `example/package.json` dependencies:
   ```bash
   cd example && bun add expo-dev-client
   ```
2. Update the `start` script in `example/package.json`:
   ```json
   "start": "expo start --dev-client"
   ```
3. Verify `example/metro.config.js` exists with `watchFolders` pointing to the repo root (see `example-app` skill).

JS-only libraries skip this step — they run in Expo Go without modification.

## Step 12: Codegen (native only — skip for JS-only library)

The scaffold adds `codegenConfig` to `package.json` for native types. Verify the `type` field matches:

For **TurboModule**:
```json
"codegenConfig": {
  "name": "RNMyLibrarySpec",
  "type": "modules",
  "jsSrcsDir": "src",
  "android": { "javaPackageName": "com.mylibrary" }
}
```

For **Fabric view**:
```json
"codegenConfig": {
  "name": "RNMyLibrarySpec",
  "type": "components",
  "jsSrcsDir": "src",
  "android": { "javaPackageName": "com.mylibrary" }
}
```

For **JS-only library**: no `codegenConfig` needed. Skip this step entirely.

Read the `codegen` skill for full native implementation details.

## Step 13: src/index.ts

```ts
// Export everything public. Nothing else.
export { MyComponent } from './components/MyComponent'
export type { MyComponentProps } from './components/MyComponent'
```

## Step 14: Verify

```bash
bun run check
```

This runs typecheck + lint + format:check. All three must pass.

## Post-Scaffold Checklist
- [ ] `bun run check` passes clean
- [ ] `bun run build` produces `lib/` with module + types output
- [ ] `.changeset/` directory exists
- [ ] `.husky/pre-commit` contains `bunx lint-staged`
- [ ] `prepare` script is `bob build && husky` (not just `husky`)
- [ ] README.md documents every export
- [ ] **JS-only:** example app runs in Expo Go (`cd example && bun run start`)
- [ ] **Native:** `expo-dev-client` in example dependencies, `start` script uses `--dev-client`
- [ ] **Native:** example app builds (`cd example && bun run ios`)

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
| Prompted for `lefthook`/`release-it` | New tool choices in current CLI | Uncheck both — use Husky + Changesets instead |
| `ERR_INVALID_ARG_TYPE` on scaffold | Target directory already exists | Scaffold to a temp name, then `cp -r tmp/. target/ && rm -rf tmp` |
| `bun add` fails with "husky: command not found" | `prepare` runs before husky is installed | Use `--ignore-scripts` on all `bun add` calls in Steps 6–8 |
| `bunx changeset init` → "could not determine executable" | `@changesets/cli` not installed yet | Install `@changesets/cli` first, then run `bunx changeset init` |
| User asks for `--languages ts` | `--languages` is for native code, not TypeScript | Always use `--languages js` for JS-only; TS is always included |
