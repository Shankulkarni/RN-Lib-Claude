---
name: ci
description: "Use when setting up CI/CD for a React Native library — GitHub Actions workflows for PR checks, automated publish on changeset merge, NPM_TOKEN setup, and caching strategies."
---

# CI / CD for React Native Libraries

Two workflows cover the full lifecycle: one for PR quality gates, one for automated publish.

---

## Workflow 1 — PR Checks (`.github/workflows/ci.yml`)

Runs on every pull request and push to main. Blocks merge if checks fail.

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  check:
    name: Typecheck, Lint, Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: oven-sh/setup-bun@v2
        with:
          bun-version: latest

      - name: Install dependencies
        run: bun install --frozen-lockfile

      - name: Typecheck
        run: bun run typecheck

      - name: Lint
        run: bun run lint

      - name: Format check
        run: bun run format:check

      - name: Test
        run: bun run test

      - name: Build
        run: bun run build
```

### Caching bun installs

Add this step before `bun install` to cache the package store:

```yaml
      - uses: actions/cache@v4
        with:
          path: ~/.bun/install/cache
          key: ${{ runner.os }}-bun-${{ hashFiles('bun.lockb') }}
          restore-keys: |
            ${{ runner.os }}-bun-
```

---

## Workflow 2 — Automated Publish (`.github/workflows/publish.yml`)

Runs when a PR is merged to `main`. If a changeset is present, it opens a "Version Packages" PR automatically. When that PR is merged, it publishes to npm.

This uses the official [Changesets GitHub Action](https://github.com/changesets/action).

```yaml
name: Publish

on:
  push:
    branches: [main]

concurrency: ${{ github.workflow }}-${{ github.ref }}

jobs:
  publish:
    name: Publish to npm
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: oven-sh/setup-bun@v2
        with:
          bun-version: latest

      - name: Install dependencies
        run: bun install --frozen-lockfile

      - name: Build
        run: bun run build

      - name: Create release PR or publish
        uses: changesets/action@v1
        with:
          publish: npm publish --access public
          version: bunx changeset version
          commit: "chore: version packages"
          title: "chore: version packages"
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
```

**How it works:**
1. You merge a feature PR that includes a `.changeset/*.md` file
2. The action opens a "Version Packages" PR that bumps versions and updates CHANGELOG
3. You review and merge that PR
4. The action automatically runs `npm publish`

---

## NPM_TOKEN Setup

1. Go to npmjs.com → Account → Access Tokens → Generate New Token → **Automation** type
2. Copy the token
3. Go to your GitHub repo → Settings → Secrets and variables → Actions → New repository secret
4. Name: `NPM_TOKEN`, Value: the token

The `GITHUB_TOKEN` is provided automatically by GitHub Actions — no setup needed.

---

## Native Library Extras

For TurboModule or Fabric view libraries, the CI workflow above is sufficient for JS checks. Native compilation (iOS/Android) requires macOS runners and is slow/expensive. Recommended approach:

- **JS checks (typecheck, lint, test, bob build)**: `ubuntu-latest` — fast and free
- **Native compilation**: Run locally before publishing, or on release only using `macos-latest`

If you want to validate native builds on CI:

```yaml
  build-ios:
    name: iOS Build Check
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: oven-sh/setup-bun@v2
      - run: bun install --frozen-lockfile
      - run: cd example && bun install
      - name: Install CocoaPods
        run: cd example/ios && pod install
      - name: Build iOS
        run: cd example && bun run ios --configuration Debug
```

CocoaPods cache (saves ~3min per run):
```yaml
      - uses: actions/cache@v4
        with:
          path: example/ios/Pods
          key: ${{ runner.os }}-pods-${{ hashFiles('example/ios/Podfile.lock') }}
```

---

## Branch Protection

After adding CI, enable branch protection on `main`:
- GitHub repo → Settings → Branches → Add rule
- Branch name: `main`
- ✅ Require status checks to pass before merging
- ✅ Select the `check` job from the CI workflow
- ✅ Require branches to be up to date before merging

---

## `.github/` Files to Create

```
.github/
├── workflows/
│   ├── ci.yml        ← PR quality gate
│   └── publish.yml   ← automated publish via Changesets
```

Add to `.gitignore`:
```
# already ignored by scaffold
```

No changes needed — `.github/` is never in the scaffold's `files` field so it won't be published to npm.
