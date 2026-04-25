---
description: Scaffold a new React Native library — prompts for name, JS-only vs native, animations, then applies all conventions.
argument-hint: [library-name]
---

Read the `scaffold` skill fully, then guide the user through creating a new React Native library:

1. **Check prerequisites:** Verify `bun` is installed (`which bun`). If not, install it: `curl -fsSL https://bun.sh/install | bash` and add to PATH.
2. Ask for library name (if not provided as argument: `${ARGUMENT}`)
3. Ask: JS-only or native (TurboModule/Fabric)?
4. Ask: animations needed? (adds reanimated + gesture-handler peer deps)
5. Ask: npm scope? (e.g. `@myorg` or unscoped)
6. Run `bunx create-react-native-library@latest` with non-interactive flags (see skill for valid `--type` values: `turbo-module`, `fabric-view`, `library`). Always pass `--tools eslint jest`. The `--author-url` must be a valid URL (not empty).
7. Remove `.yarn` and `.yarnrc.yml`, run `bun install`
8. Apply all conventions from the `scaffold` skill (package.json, prettier, ESLint peer deps, Changesets, Husky + lint-staged)
9. **Critical:** After `bunx husky init`, restore `prepare` script to `bob build && husky` (husky init overwrites it)
10. Install all ESLint peer dependencies (8 packages — see Step 6 in skill)
11. Run `bun run format` to apply prettier conventions to all generated files
12. If native: apply `codegen` skill setup
13. Run `bun run check` to verify clean state (typecheck + lint + format:check must all pass)
14. Report what was created
