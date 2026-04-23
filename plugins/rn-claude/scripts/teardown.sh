#!/usr/bin/env bash
set -euo pipefail

CLAUDE_MD="$HOME/.claude/CLAUDE.md"
START_FENCE="<!-- RN-CLAUDE START -->"
END_FENCE="<!-- RN-CLAUDE END -->"

if [ ! -f "$CLAUDE_MD" ]; then
  echo "✓ $CLAUDE_MD not found — nothing to remove"
  exit 0
fi

if ! grep -q "$START_FENCE" "$CLAUDE_MD"; then
  echo "✓ RN-Claude conventions not found in $CLAUDE_MD — nothing to remove"
  exit 0
fi

# Remove fenced block
awk "/$START_FENCE/{found=1} !found{print} /$END_FENCE/{found=0}" "$CLAUDE_MD" > "$CLAUDE_MD.tmp"
mv "$CLAUDE_MD.tmp" "$CLAUDE_MD"

echo "✓ RN-Claude conventions removed from $CLAUDE_MD"
