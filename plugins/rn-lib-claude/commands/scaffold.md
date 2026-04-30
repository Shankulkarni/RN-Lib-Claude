---
description: Scaffold a new React Native library — prompts for name, type (TurboModule / Fabric view / JS-only), animations, then applies all conventions.
argument-hint: [library-name]
---

Read the `scaffold` skill fully, then guide the user through creating a new React Native library:

1. **Check prerequisites:** Verify `bun` is installed (`which bun`). If not, install it: `curl -fsSL https://bun.sh/install | bash` and add to PATH.
2. Ask for library name (if not provided as argument: `${ARGUMENT}`)
3. Ask: **What type?**
   - `turbo-module` — native APIs or logic (camera, sensors, crypto, storage)
   - `fabric-view` — native UI component (map, video player, native picker wheel)
   - `library` — pure TypeScript, no native code (pickers, hooks, utilities, formatters)
4. Ask: animations needed? (adds reanimated + gesture-handler peer deps — applies to all types)
5. Ask: npm scope? (e.g. `@myorg` or unscoped)
6. Run `bunx create-react-native-library@latest` with the correct flags from the `scaffold` skill:
   - Native types: `--languages kotlin-objc`
   - JS-only: `--languages js`
   - All types: `--example expo --tools eslint jest`
   - Always pass `--author-url` as a valid URL (not empty)
7. Remove `.yarn` and `.yarnrc.yml`, run `bun install`
8. Apply all conventions from the `scaffold` skill (package.json, prettier, ESLint peer deps, Changesets, Husky + lint-staged)
9. Follow the `scaffold` skill exactly for Husky, ESLint peers, and the prepare script — the skill has the full details
10. Install all ESLint peer dependencies (8 packages — see Step 6 in skill)
11. Run `bun run format` to apply prettier conventions to all generated files
12. Native only: apply `codegen` skill setup — verify `codegenConfig.type` is `"modules"` (TurboModule) or `"components"` (Fabric view). Skip for JS-only.
13. Run `bun run check` to verify clean state (typecheck + lint + format:check must all pass)
14. Report what was created
