---
name: deslop
description: "Use when scanning a React Native library for code quality issues — legacy bridge APIs, console.log in worklets, hardcoded values, missing peer deps, placeholder code."
---

# Deslop — RN Library Code Quality

Run the scanner:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/deslop.sh" ${ARGUMENT:-.}
```

## What It Scans

### Critical (exit 1, block publish)
- `NativeModules` usage — legacy bridge, banned in New Architecture
- `requireNativeComponent` — use `codegenNativeComponent` instead
- `UIManager` — legacy bridge API
- `console.log` inside worklet functions — crashes New Architecture runtime
- `throw new Error('TODO')` / empty function bodies — placeholder code
- Hardcoded secrets or API keys in source
- Empty catch blocks `catch (e) {}`
- `import { Animated } from 'react-native'` — use Reanimated

### Medium (warn, review before publish)
- `console.log` / `console.warn` anywhere in `src/` — remove before publish
- `TODO` / `FIXME` / `HACK` comments in `src/`
- Hardcoded colors (`'#fff'`, `'red'`, `'black'`) — should be props
- Hardcoded dimensions (magic numbers without comment)
- `PanResponder` — use GestureDetector
- `useContext` without `use()` — should use React 19 `use()`

### Low (info)
- `eslint-disable` comments — should fix root cause
- `@ts-ignore` / `@ts-expect-error` — should fix type issue
- Missing `displayName` on components
- Default exports — should be named exports

## Never Auto-Fix
- Hardcoded secrets — flag only, user removes
- Legacy bridge APIs — requires native code rewrite

## After Scanning
List critical issues with file:line format. Suggest fix for each. Group by severity.
