---
description: Scaffold a new React Native library — prompts for name, JS-only vs native, animations, then applies all conventions.
argument-hint: [library-name]
---

Read the `scaffold` skill fully, then guide the user through creating a new React Native library:

1. Ask for library name (if not provided as argument: `${ARGUMENT}`)
2. Ask: JS-only or native (TurboModule/Fabric)?
3. Ask: animations needed? (adds reanimated + gesture-handler peer deps)
4. Ask: npm scope? (e.g. `@myorg` or unscoped)
5. Run `bunx create-react-native-library@latest ${ARGUMENT:-rn-my-library}`
6. Apply all conventions from the `scaffold` skill (bob config, tsconfig, ESLint, Prettier, Husky, Changesets)
7. If native: apply `codegen` skill setup
8. Run `bun run check` to verify clean state
9. Report what was created
