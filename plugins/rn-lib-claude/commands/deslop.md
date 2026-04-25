---
description: Scan a React Native library for code quality issues — legacy bridge APIs, console.log in worklets, hardcoded values, missing peer deps, placeholder code.
argument-hint: [path|--staged]
---

Run the RN deslop scanner:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/plugins/rn-lib-claude/scripts/deslop.sh" ${ARGUMENT:-.}
```

If critical issues found, list each one with `file:line` reference and fix instructions.
Never auto-fix hardcoded secrets or legacy bridge APIs — only flag them.
Group output by severity: Critical → Medium → Low.
