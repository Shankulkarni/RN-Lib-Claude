# RN-Claude — Global Rules

These rules apply to every React Native library in this ecosystem.

## Skills — Load Before Coding

| When doing... | Load this skill |
|---|---|
| Scaffolding a new library | `scaffold` |
| Building UI components | `component` |
| Building hooks or utilities | `hooks` |
| Animations or gestures | `animations` |
| TypeScript config, exports, peer deps | `typescript` |
| Writing tests | `testing` |
| Publishing to npm | `publish` |
| Native modules or Fabric views | `codegen` |
| Working on the example app | `example-app` |
| List components, bundle size, FPS, memoization | `performance` |
| Code quality scan | `deslop` |

## Hard Rules (Non-Negotiable)

### New Architecture — Enforced Everywhere
- **No legacy bridge APIs.** `NativeModules`, `requireNativeComponent`, `UIManager` are banned.
- Codegen specs in TypeScript (not Flow). Always.
- Fabric components use `RCTViewComponentView`, never `RCTView`.
- Target RN 0.76+. New Architecture is on by default.

### Package Manager
- `bun` always. `bunx` instead of `npx`. Never npm/yarn for local commands.
- Exception: `npm publish` for publishing (npm registry requires it).

### TypeScript
- Strict mode. `type` not `interface`. No `any`/`as`. Named exports only.
- `moduleResolution: bundler` in tsconfig.
- Inline type imports: `import type { Foo } from './foo'`.
- Codegen specs typed with `TurboModuleRegistry` / `codegenNativeComponent`.

### Code Style
- Tabs, single quotes, no semicolons, trailing commas.
- Kebab-case filenames. `.ts/.tsx` only.
- No `React.xxx` namespace — named imports only.
- No `console.log` anywhere in `src/`. **Especially not inside worklets** — crashes New Architecture.

### Reanimated + Gestures
- `react-native-reanimated` v3 only. No Animated API from RN core for animated values.
- `react-native-gesture-handler` v2 only. `GestureDetector` API — never `PanResponder`.
- Worklets must be pure — no closures over non-worklet-safe values.
- `useSharedValue`, `useAnimatedStyle`, `withSpring`/`withTiming`/`withSequence` — standard patterns.

### Peer Dependencies
- `react` and `react-native` always peer deps, never direct deps.
- `react-native-reanimated` and `react-native-gesture-handler` as peer deps only if the library uses them.
- Peer dep ranges: `react-native >= 0.76.0`, `react >= 18.0.0`.
- Never bundle reanimated or gesture-handler — they must be installed once per app.

### Publishing
- **Changesets required** before every publish. No changeset = no publish.
- `bob build` must pass cleanly before publish.
- Exports map in `package.json` must cover all public APIs.
- Version bumps via `bunx changeset version`, publish via `npm publish`.

### Library Structure
- Public API exported from `src/index.ts` only.
- Internal helpers not exported from index.
- Example app must demo every exported component and hook.
- No hardcoded colors — accept color props or use design tokens.
- No hardcoded dimensions — accept size props or use `StyleSheet.flatten`.

### Never
- Never commit `.env` files.
- Never skip Husky hooks (`--no-verify`).
- Never edit auto-generated Codegen output files.
- Never add `react-native-reanimated` or `react-native-gesture-handler` as direct dependencies.
- Never use `Platform.OS === 'web'` without explicit web support intention.
