---
description: Submit a published React Native library to the React Native Community Directory (reactnative.directory).
---

Read the `directory` skill fully, then guide the user through submitting their library:

1. **Verify prerequisites:**
   - Confirm the library is published on npm (`npm view <package-name>` — must resolve)
   - Confirm a public GitHub repository exists
   - Confirm README documents the library

2. **Try CLI first:**
   ```bash
   bunx rn-directory submit
   ```
   If this succeeds and opens a PR, you're done — skip to step 6.

3. **If CLI unavailable or fails — gather entry fields:**
   Ask the user for:
   - GitHub repo URL (required)
   - npm package name (only if different from repo name or monorepo)
   - Library type: TurboModule, Fabric view, or JS-only?
   - Platform support: iOS? Android? Web? (web only for JS-only)
   - `newArchitecture: true` — set for all libraries built with this plugin
   - `expoGo` — **JS-only only**: set `true` if no native code. Never set for TurboModule or Fabric view (they require dev client, not Expo Go)
   - `configPlugin` — TurboModule/Fabric view only: does it ship an `app.plugin.js`?
   - Any demo links (Expo Snack, GitHub demo)? (`examples`)
   - Any screenshots or GIFs? (`images`)

4. **Build the JSON entry** following the `directory` skill format:
   - Omit any fields with `false` values
   - `newArchitecture: true` for all libraries built with this plugin
   - Add `"web": true` and `"expoGo": true` only for JS-only libraries

5. **Submit manual PR:**
   ```bash
   gh repo fork react-native-community/directory --clone
   cd directory
   # append entry to end of react-native-libraries.json
   gh pr create \
     --repo react-native-community/directory \
     --title "Add <package-name>" \
     --body "Adding <package-name> — <one line description>."
   ```

6. **Report result:** Share the PR URL with the user and remind them the directory syncs npm stats and GitHub stars automatically after merge.
