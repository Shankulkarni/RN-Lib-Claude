---
description: Pre-publish validation and npm publish workflow for a React Native library.
---

Run pre-publish checks, then guide through publish:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/plugins/rn-lib-claude/scripts/pre-publish.sh"
```

If pre-publish passes:

1. Run `bunx changeset version` to bump version and update CHANGELOG
2. Run `bun run build` — verify `lib/` output
3. Show user the diff and ask for confirmation before publishing
4. Run `npm publish --access public`
5. Run `git tag v{version} && git push --tags`
6. Remind user to create GitHub release with CHANGELOG section

If pre-publish fails, list each failure with fix instructions. Do not proceed to publish.
