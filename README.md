<p align="center">
  <h1 align="center">📦 RN-Lib-Claude</h1>
  <p align="center">
    <strong>Claude Code plugin for building and publishing React Native libraries.</strong>
  </p>
  <p align="center">
    <code>3 library types</code> · <code>12 skills</code> · <code>7 agents</code> · <code>7 commands</code> · <code>4 scripts</code>
  </p>
</p>

<p align="center">
  <a href="https://reactnative.dev"><img src="https://img.shields.io/badge/React_Native-61DAFB?style=flat-square&logo=react&logoColor=black" alt="React Native"></a>
  <a href="https://www.typescriptlang.org"><img src="https://img.shields.io/badge/TypeScript-3178C6?style=flat-square&logo=typescript&logoColor=white" alt="TypeScript"></a>
  <a href="https://oss.callstack.com/react-native-builder-bob/create"><img src="https://img.shields.io/badge/Builder_Bob-000000?style=flat-square&logo=npm&logoColor=white" alt="Builder Bob"></a>
  <a href="https://docs.swmansion.com/react-native-reanimated"><img src="https://img.shields.io/badge/Reanimated_v3-6B52AE?style=flat-square&logo=react&logoColor=white" alt="Reanimated v3"></a>
  <a href="https://docs.swmansion.com/react-native-gesture-handler"><img src="https://img.shields.io/badge/Gesture_Handler_v2-6B52AE?style=flat-square&logo=react&logoColor=white" alt="Gesture Handler v2"></a>
  <a href="https://github.com/changesets/changesets"><img src="https://img.shields.io/badge/Changesets-26A69A?style=flat-square&logo=npm&logoColor=white" alt="Changesets"></a>
  <a href="https://expo.dev"><img src="https://img.shields.io/badge/Expo_SDK_52+-000020?style=flat-square&logo=expo&logoColor=white" alt="Expo SDK 52+"></a>
  <a href="https://jestjs.io"><img src="https://img.shields.io/badge/Jest-C21325?style=flat-square&logo=jest&logoColor=white" alt="Jest"></a>
  <a href="https://bun.sh"><img src="https://img.shields.io/badge/Bun-000000?style=flat-square&logo=bun&logoColor=white" alt="Bun"></a>
</p>

---

> **Note:** RN-Lib-Claude is distributed through the [claude-plugin-marketplace](https://github.com/Utilities-Studio/claude-plugin-marketplace).

```
┌────────────────────────────────────────────────────────────────────────────┐
│                                                                            │
│   /plugin marketplace add Utilities-Studio/claude-plugin-marketplace       │
│   /plugin install rn-lib-claude@utilities-studio                           │
│   /rn-lib-claude:setup                                                     │
│                                                                            │
│   That's it. Every library. Every component. Same standards.               │
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘
```

---

## 📚 Library Types

Three types, one plugin. Pick the right one at scaffold time — the plugin handles the rest.

| Type | Use when | Expo Go | Native code |
|---|---|---|---|
| `turbo-module` | Calling native platform APIs — camera, sensors, crypto, storage | ❌ Dev client | ✅ Kotlin + ObjC++ |
| `fabric-view` | Rendering a native UI component — maps, video players, native pickers | ❌ Dev client | ✅ Kotlin + ObjC++ |
| `library` | Pure TypeScript — pickers, hooks, utilities, formatters | ✅ Yes | ❌ None |

All three use: TypeScript strict · `react-native-builder-bob` · ESLint v9 · Prettier · Husky · Changesets · Expo example app.

---

## 🧠 Skills

Loaded on-demand. Only the relevant skill enters context — the rest cost 0 tokens.

| | Skill | What it covers |
|---|---|---|
| 🏗️ | `scaffold` | Full library setup — create-react-native-library, bob config, Expo dev client, Changesets, Husky |
| 🧩 | `component` | Fabric-compatible UI components, ref forwarding, compound patterns, a11y |
| 🪝 | `hooks` | Custom hooks, worklet-safe utilities, stable callbacks |
| ✨ | `animations` | Reanimated v3 worklets, GestureDetector, GPU-only properties |
| 📐 | `typescript` | Strict config, `moduleResolution: bundler`, exports map, peer dep types |
| 🧪 | `testing` | Jest + React Native Testing Library, Reanimated mocks, Codegen mocks |
| 🚀 | `publish` | Changesets workflow, semver, bob build validation, npm publish |
| ⚙️ | `codegen` | TurboModules, Fabric views, Codegen TypeScript specs, `expo-module.config.json` |
| 📱 | `example-app` | Expo SDK 52+, Expo Go vs dev client, demo patterns, metro config |
| ⚡ | `performance` | Bundle size, memoization, FlashList, FPS targets |
| 🧹 | `deslop` | Legacy bridge APIs, `console.log` in worklets, hardcoded values |
| 🗂️ | `directory` | Submit to reactnative.directory — `autoSubmit` CLI, manual PR |
| 🔧 | `ci` | GitHub Actions — PR quality gate, automated Changesets publish, NPM_TOKEN |

---

## 🤖 Agents

**7 specialists. All under 80 lines. Pure signal, no fluff.**

```
╔══════════════════════════════════════════════════════════════════════╗
║                                                                      ║
║  📦 LIBRARY                  ⚙️  NATIVE                              ║
║  ──────────                  ──────────                              ║
║  Library Architect           Codegen Engineer                        ║
║  Component Developer                                                 ║
║  Hooks Developer             🎛️  ORCHESTRATION                       ║
║                              ────────────────                        ║
║  ✅ QUALITY                  Orchestrator                            ║
║  ────────                    (full lifecycle)                        ║
║  Code Reviewer                                                       ║
║  Publisher                                                           ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

| | Agent | Role |
|---|---|---|
| 🎯 | `orchestrator` | Coordinates full library lifecycle — scaffold to publish |
| 🏛️ | `library-architect` | Type selection (TurboModule / Fabric view / JS-only), API surface design, peer deps |
| 🧩 | `component-developer` | UI components, animations, gestures |
| 🪝 | `hooks-developer` | Headless hooks, worklet-safe utilities |
| ⚙️ | `codegen-engineer` | TurboModules + Fabric native views |
| 🚀 | `publisher` | Versioning, CHANGELOG, npm publish |
| ✅ | `code-reviewer` | New Arch compliance, API quality gate |

---

## ⚡ Commands

Type these directly in Claude Code:

| Command | What happens |
|---|---|
| `/rn-lib-claude:setup` | 🔧 One-time: copies conventions to `~/.claude/CLAUDE.md` |
| `/rn-lib-claude:update` | 🔄 Updates plugin + refreshes CLAUDE.md conventions |
| `/rn-lib-claude:uninstall` | 🗑️ Removes conventions from CLAUDE.md |
| `/rn-lib-claude:scaffold` | 🏗️ Scaffold a new library — picks type, sets up everything |
| `/rn-lib-claude:publish` | 🚀 Pre-publish checks + npm publish + optional directory submission |
| `/rn-lib-claude:deslop` | 🧹 Scan for anti-patterns and New Architecture violations |
| `/rn-lib-claude:directory` | 🗂️ Submit published library to reactnative.directory |

```
  /rn-lib-claude:scaffold     ← you type this
       │
       ▼
  commands/scaffold.md         ← picks TurboModule / Fabric view / JS-only
       │
       ▼
  skills/scaffold/SKILL.md     ← full setup playbook
       │
       ▼
  Library ready to code        ← bob · Changesets · Husky · Expo example app
```

---

## 🔌 Expo Support

| Library type | Expo Go | Dev client | Config plugin |
|---|---|---|---|
| `turbo-module` | ❌ | ✅ Required | Optional (`app.plugin.js`) |
| `fabric-view` | ❌ | ✅ Required | Optional (`app.plugin.js`) |
| `library` (JS-only) | ✅ Works | Not needed | Not needed |

- All example apps use **Expo SDK 52+** with `newArchEnabled: true`
- Native libraries get `expo-dev-client` added to example dependencies automatically
- Native libraries get `expo-module.config.json` for Expo managed workflow auto-linking

---

## 🛡️ Hard Rules

```
  ┌─────────────────────────────────────────────┐
  │  Architecture                               │
  │  New Architecture only — RN 0.76+           │
  │  No legacy bridge APIs ever                 │
  │  Codegen specs in TypeScript, not Flow      │
  ├─────────────────────────────────────────────┤
  │  Package Manager                            │
  │  bun always — bunx not npx                  │
  │  npm publish only for registry              │
  ├─────────────────────────────────────────────┤
  │  TypeScript                                 │
  │  Strict mode, type not interface            │
  │  moduleResolution: bundler                  │
  │  No any, no as                              │
  ├─────────────────────────────────────────────┤
  │  Dependencies                               │
  │  react + react-native always peer deps      │
  │  Never bundle reanimated or gesture-handler │
  │  Changesets required before every publish   │
  └─────────────────────────────────────────────┘
```

---

## 📁 Project Structure

```
rn-lib-claude/
├── CLAUDE.md                ← Conventions (copied to ~/.claude/CLAUDE.md by /rn-lib-claude:setup)
├── agents/                  ← 7 specialist agents
│   ├── orchestrator.md
│   ├── library-architect.md
│   ├── component-developer.md
│   ├── hooks-developer.md
│   ├── codegen-engineer.md
│   ├── publisher.md
│   └── code-reviewer.md
├── skills/                  ← 12 on-demand skills
│   ├── scaffold/
│   ├── component/
│   ├── hooks/
│   ├── animations/
│   ├── typescript/
│   ├── testing/
│   ├── publish/
│   ├── codegen/
│   ├── example-app/
│   ├── performance/
│   ├── deslop/
│   ├── directory/
│   └── ci/
├── commands/                ← 7 slash commands
│   ├── setup.md
│   ├── update.md
│   ├── uninstall.md
│   ├── scaffold.md
│   ├── publish.md
│   ├── deslop.md
│   └── directory.md
└── scripts/                 ← Pure bash tooling (0 tokens)
    ├── setup.sh
    ├── teardown.sh
    ├── deslop.sh
    └── pre-publish.sh
```

---

## 🔧 Install / Update / Uninstall

Uses Claude Code's native plugin system. No custom scripts needed.

### Install

```bash
# 1. Add the marketplace
/plugin marketplace add Utilities-Studio/claude-plugin-marketplace

# 2. Install the plugin
/plugin install rn-lib-claude@utilities-studio

# 3. Run setup in Claude Code
/rn-lib-claude:setup
```

### Update

```bash
/plugin marketplace update utilities-studio
/plugin update rn-lib-claude@utilities-studio
```

Or from Claude Code: `/rn-lib-claude:update`

### Uninstall

Run `/rn-lib-claude:uninstall` first (removes conventions from CLAUDE.md), then:

```bash
/plugin uninstall rn-lib-claude@utilities-studio
```

---

## 👥 For the Team

### Adding a Skill

1. Create `plugins/rn-lib-claude/skills/<name>/SKILL.md` with frontmatter:
   ```yaml
   ---
   name: my-skill
   description: "Use when [trigger condition]."
   ---
   ```
2. Add to skill table in `CLAUDE.md`

### Adding an Agent

1. Create `plugins/rn-lib-claude/agents/<name>.md` under 80 lines:
   ```yaml
   ---
   name: My Agent
   description: Use when [trigger]. Does [what].
   color: blue
   ---
   ```

### Contributing Rules

```
  ✅  Tabs, single quotes, no semicolons, trailing commas
  ✅  type not interface, inline type imports
  ✅  Named imports from react (never React.xxx)
  ✅  bunx not npx, bun not npm
  ✅  Kebab-case filenames, .ts/.tsx only
```

---
