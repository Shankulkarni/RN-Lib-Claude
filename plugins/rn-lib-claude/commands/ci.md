---
description: Set up GitHub Actions CI/CD for a React Native library — PR quality gate and automated Changesets publish workflow.
---

Read the `ci` skill fully, then set up GitHub Actions for this library:

1. **Check prerequisites:**
   - Confirm this is a git repository with a GitHub remote (`git remote -v`)
   - Confirm the library has been published or is ready to publish (needs `NPM_TOKEN`)

2. **Create workflow files:**
   - Create `.github/workflows/ci.yml` — PR quality gate (typecheck, lint, format check, test, build)
   - Create `.github/workflows/publish.yml` — automated Changesets publish on merge to main
   - Use the exact YAML from the `ci` skill — do not improvise

3. **Add bun install caching** to both workflows (see `ci` skill for the cache step)

4. **For native libraries** (TurboModule or Fabric view):
   - Ask: "Do you want iOS/Android build validation on CI?" (slow, uses macOS runner)
   - If yes: add the native build job from the `ci` skill with CocoaPods cache

5. **Guide NPM_TOKEN setup:**
   - Remind user to create an **Automation** token at npmjs.com → Account → Access Tokens
   - Remind user to add it as `NPM_TOKEN` in GitHub repo → Settings → Secrets and variables → Actions

6. **Recommend branch protection:**
   - GitHub repo → Settings → Branches → Add rule for `main`
   - Require the `check` job to pass before merging

7. **Verify:**
   - Run `git add .github/ && git status` to confirm files are staged
   - Remind user to push and open a test PR to confirm CI runs
