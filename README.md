# RN-Lib-Claude

Claude Code plugin for building React Native libraries targeting **New Architecture (RN 0.76+)**.

```
claude plugin marketplace add <source>
claude plugin install rn-lib-claude
/rn-lib-claude:setup
```

---

## What's Inside

```
10 skills  ·  7 agents  ·  6 commands  ·  5 scripts
```

### Skills (on-demand, 0 tokens until needed)

| Skill | Use when |
|---|---|
| `scaffold` | Creating a new library |
| `component` | Building UI components |
| `hooks` | Building hooks or utilities |
| `animations` | Reanimated + GestureDetector |
| `typescript` | TS config, exports map, peer dep types |
| `testing` | Jest + React Native Testing Library |
| `publish` | npm release with Changesets |
| `codegen` | TurboModules + Fabric native views |
| `example-app` | Expo example app |
| `deslop` | Code quality scan |

### Agents

| Agent | Role |
|---|---|
| `orchestrator` | Coordinates full library lifecycle |
| `library-architect` | API surface + peer dep design |
| `component-developer` | UI components, animations, gestures |
| `hooks-developer` | Headless hooks, worklet-safe utilities |
| `codegen-engineer` | TurboModules + Fabric native views |
| `publisher` | Versioning, CHANGELOG, npm publish |
| `code-reviewer` | New Arch compliance, API quality gate |

### Commands

| Command | Action |
|---|---|
| `/rn-lib-claude:setup` | Sync conventions to `~/.claude/CLAUDE.md` |
| `/rn-lib-claude:update` | Re-sync updated conventions |
| `/rn-lib-claude:uninstall` | Remove conventions |
| `/scaffold [name]` | Create new library |
| `/publish` | Pre-publish checks + npm publish |
| `/deslop [path]` | Scan for slop patterns |

---

## Stack

- **Scaffold**: `create-react-native-library` + `react-native-builder-bob`
- **Architecture**: New Architecture only (RN 0.76+, Fabric + TurboModules)
- **Animations**: `react-native-reanimated` v3
- **Gestures**: `react-native-gesture-handler` v2
- **TypeScript**: strict, `moduleResolution: bundler`
- **Versioning**: Changesets + npm publish
- **Testing**: Jest + React Native Testing Library (`jest-expo` preset)
- **Example**: Expo SDK 52+, `newArchEnabled: true`

---

## Hard Rules

- **No legacy bridge** — `NativeModules`, `requireNativeComponent`, `UIManager` banned
- **No `console.log` in worklets** — crashes New Architecture runtime
- **Changesets required** before every publish
- **`bob build` must pass** before publish
- **`bun`** always, `bunx` not `npx`
- **Peer deps wide**: `react-native >= 0.76.0`, `react >= 18.0.0`

---

## Adding a Skill

1. Create `plugins/rn-lib-claude/skills/<name>/SKILL.md` with frontmatter:
   ```yaml
   ---
   name: my-skill
   description: "Use when [trigger condition]."
   ---
   ```
2. Add to skill table in `CLAUDE.md`

## Adding an Agent

1. Create `plugins/rn-lib-claude/agents/<name>.md` under 80 lines:
   ```yaml
   ---
   name: My Agent
   description: Use when [trigger]. Does [what].
   color: blue
   ---
   ```
