---
name: directory
description: "Use when submitting a React Native library to the React Native Community Directory (https://reactnative.directory) — entry format, field guide, CLI submission, and manual PR process."
user_invocable: true
---

# React Native Directory Submission

The React Native Directory (https://reactnative.directory) is the community's searchable index of RN libraries. Getting listed increases discoverability significantly.

Source repo: https://github.com/react-native-community/directory

## Prerequisites

- Library published to npm (`npm publish` done)
- Public GitHub repository exists
- README documents the library

## Method 1: CLI — autoSubmit (recommended, fully automatic)

Run from your library root. Reads `package.json` automatically and creates a PR without prompts:
```bash
bunx rn-directory autoSubmit
```

**Requires these fields in `package.json` to work correctly:**
- `name` — npm package name
- `description` — shown in the directory listing
- `repository` — GitHub URL (string or `{ "url": "..." }` object)
- `homepage` — optional but used if present

If any are missing, add them before running:
```json
{
  "name": "rn-my-library",
  "description": "A React Native library for ...",
  "repository": "https://github.com/yourname/rn-my-library",
  "homepage": "https://github.com/yourname/rn-my-library"
}
```

If the library is already in the directory (updating an existing entry), use the interactive CLI instead:
```bash
bunx rn-directory submit
```

Both commands are confirmed working (`bunx rn-directory --help` shows both).

## Method 2: Manual PR

### Step 1 — Fork and clone the directory repo
```bash
gh repo fork react-native-community/directory --clone
cd directory
```

### Step 2 — Add entry to `react-native-libraries.json`

Add your entry at the **end** of the array (position determines "Recently added" sort order).

```json
{
  "githubUrl": "https://github.com/yourname/rn-my-library",
  "npmPkg": "@yourscope/rn-my-library",
  "ios": true,
  "android": true,
  "newArchitecture": true
}
```

### Step 3 — Submit PR

```bash
gh pr create \
  --repo react-native-community/directory \
  --title "Add rn-my-library" \
  --body "Adding @yourscope/rn-my-library — [one line description]."
```

---

## Entry Fields

### Required
| Field | Type | Description |
|---|---|---|
| `githubUrl` | string | Full GitHub URL — repo root or monorepo package path |

### Package
| Field | Type | When to include |
|---|---|---|
| `npmPkg` | string | Only if npm package name differs from repo name, or it's a monorepo |

### Platform support (omit if `false`)
| Field | Type | Include when... |
|---|---|---|
| `ios` | boolean | Library works on iOS |
| `android` | boolean | Library works on Android |
| `web` | boolean | Library works on React Native Web |
| `windows` | boolean | Library works on RN Windows |
| `macos` | boolean | Library works on RN macOS |
| `tvos` | boolean | Library works on Apple TV |
| `visionos` | boolean | Library works on visionOS |

### Compatibility
| Field | Type | When to include |
|---|---|---|
| `newArchitecture` | `true` / string | Set `true` if fully supported. String for notes (e.g. `"Supported from v2.0"`) |
| `expoGo` | boolean | Works in Expo Go without dev client or prebuild |
| `configPlugin` | boolean / string | Supports Expo config plugins. String = URL to plugin docs |

### Discovery
| Field | Type | Description |
|---|---|---|
| `examples` | string[] | URLs to Expo Snacks or demo projects |
| `images` | string[] | Public URLs to screenshots or GIFs (shown in directory) |
| `alternatives` | string[] | Other npm package names that serve a similar purpose |

### Status
| Field | Type | When to include |
|---|---|---|
| `unmaintained` | boolean | Library no longer receives updates |
| `dev` | boolean | Development tool (not a runtime library) |

---

## Recommended entries by library type

### TurboModule
```json
{
  "githubUrl": "https://github.com/yourname/rn-my-library",
  "npmPkg": "@yourscope/rn-my-library",
  "ios": true,
  "android": true,
  "newArchitecture": true
}
```
- No `expoGo` — native libraries cannot run in Expo Go, they require a dev client
- Add `"configPlugin": true` only if you ship an `app.plugin.js` that modifies the consumer's native project (permissions, build settings). Do NOT set this just because you have `expo-module.config.json` — that's auto-linking, not a config plugin.

### Fabric view
```json
{
  "githubUrl": "https://github.com/yourname/rn-my-library",
  "npmPkg": "@yourscope/rn-my-library",
  "ios": true,
  "android": true,
  "newArchitecture": true
}
```
- Same as TurboModule — no `expoGo`

### JS-only library
```json
{
  "githubUrl": "https://github.com/yourname/rn-my-library",
  "npmPkg": "@yourscope/rn-my-library",
  "ios": true,
  "android": true,
  "web": true,
  "expoGo": true,
  "newArchitecture": true
}
```
- `expoGo: true` — no native code, works in Expo Go
- `web: true` — if library avoids RN-only APIs

Add `"examples"` and `"images"` whenever you have them — they significantly increase engagement.

---

## Formatting rules

- **Omit fields with `false` values** — do not include `"web": false`
- **Add at the end** of `react-native-libraries.json`, not alphabetically
- Follow the exact indentation of surrounding entries (2 spaces)
- One entry per PR

---

## After submission

- PR is typically reviewed within a few days
- The directory auto-syncs npm download stats and GitHub stars
- Update your entry via a follow-up PR if fields change (e.g. `newArchitecture` support added)
