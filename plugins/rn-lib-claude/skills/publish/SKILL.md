---
name: publish
description: "Use when publishing a React Native library to npm — Changesets workflow, semver, bob build validation, peer dep ranges, npm publish, and GitHub releases."
---

# Publishing to npm

## Workflow: Changesets

Every change needs a changeset before publish. No changeset = no publish.

### 1. Add a changeset (after making changes)
```bash
bunx changeset
```
Select: patch / minor / major, write summary. Creates `.changeset/random-name.md`.

### 2. Version bump (before publish)
```bash
bunx changeset version
```
Bumps `package.json` version + updates `CHANGELOG.md`.

### 3. Build
```bash
bun run build
```
`bob build` must exit 0. Check `lib/` exists with `module/` and `typescript/` directories. Modern bob uses ESM-only output (no `commonjs/` directory).

### 4. Publish
```bash
npm publish --access public
```
Use `npm` (not bun) for registry publish.

### 5. Tag + Release
```bash
git tag v1.2.3
git push --tags
```
Create GitHub release with CHANGELOG.md section as body.

## Pre-Publish Checklist

Run `/publish` command — it runs `scripts/pre-publish.sh` automatically.

Manual checks:
- [ ] `bun run check` passes (typecheck + lint + tests)
- [ ] `bun run build` passes
- [ ] `lib/` contains `module/` and `typescript/` (modern bob uses ESM only, no `commonjs/`)
- [ ] `exports` map in `package.json` covers all public APIs
- [ ] All peer deps declared with correct version ranges
- [ ] At least one `.changeset/*.md` file exists
- [ ] No `console.log` in `src/`
- [ ] `README.md` documents every export
- [ ] Example app demos every export

## Peer Dep Ranges

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

Mark reanimated/gesture-handler as optional if library only uses them in some components.

## Semver Rules

| Change | Version | Example |
|---|---|---|
| Bug fix | patch | 1.0.0 → 1.0.1 |
| New export (backward compat) | minor | 1.0.0 → 1.1.0 |
| Removed export / breaking prop change | major | 1.0.0 → 2.0.0 |
| Peer dep range tightened | major | 1.0.0 → 2.0.0 |

## `package.json` `files` Field

Only ship what consumers need:
```json
"files": ["lib/", "src/", "android/", "ios/", "README.md", "CHANGELOG.md"]
```

Never ship: `example/`, `__tests__/`, `.husky/`, `.changeset/`, `node_modules/`.

## npm Auth

```bash
npm login
npm whoami  # verify
```

Set in CI via `NPM_TOKEN` secret:
```yaml
- run: echo "//registry.npmjs.org/:_authToken=${{ secrets.NPM_TOKEN }}" > ~/.npmrc
```

## Common Issues

**bob build fails with TS errors:** Run `bun run typecheck` first, fix all errors.

**Exports map missing:** Consumer gets "package.json does not define exports" — add the `exports` field.

**Peer dep version too tight:** Consumer gets peer dep conflict — widen ranges with `>=`.

**Forgotten changeset:** `bunx changeset` will warn. CI should block publish without it.
