#!/usr/bin/env bash
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
CONVENTIONS="$PLUGIN_DIR/CLAUDE.md"
START_FENCE="<!-- RN-LIB-CLAUDE START -->"
END_FENCE="<!-- RN-LIB-CLAUDE END -->"

# Ensure ~/.claude/CLAUDE.md exists
mkdir -p "$HOME/.claude"
touch "$CLAUDE_MD"

CONVENTIONS_CONTENT="$(cat "$CONVENTIONS")"

if grep -q "$START_FENCE" "$CLAUDE_MD" 2>/dev/null; then
  # Update existing block
  BEFORE="$(awk "/$START_FENCE/{found=1} !found{print}" "$CLAUDE_MD")"
  AFTER="$(awk "found && /$END_FENCE/{found=0; next} /$END_FENCE/{next} !found && past{print} /$START_FENCE/{past=1}" "$CLAUDE_MD")"
  NEW_HASH="$(echo "$CONVENTIONS_CONTENT" | shasum -a 256 | cut -d' ' -f1)"
  OLD_BLOCK="$(awk "/$START_FENCE/,/$END_FENCE/" "$CLAUDE_MD")"
  OLD_HASH="$(echo "$OLD_BLOCK" | shasum -a 256 | cut -d' ' -f1)"

  if [ "$NEW_HASH" = "$OLD_HASH" ]; then
    echo "✓ RN-Lib-Claude conventions already up to date"
    exit 0
  fi

  {
    echo "$BEFORE"
    echo "$START_FENCE"
    echo "$CONVENTIONS_CONTENT"
    echo "$END_FENCE"
    echo "$AFTER"
  } > "$CLAUDE_MD.tmp"
  mv "$CLAUDE_MD.tmp" "$CLAUDE_MD"
  echo "✓ RN-Lib-Claude conventions updated in $CLAUDE_MD"
else
  # Append new block
  {
    cat "$CLAUDE_MD"
    echo ""
    echo "$START_FENCE"
    echo "$CONVENTIONS_CONTENT"
    echo "$END_FENCE"
  } > "$CLAUDE_MD.tmp"
  mv "$CLAUDE_MD.tmp" "$CLAUDE_MD"
  echo "✓ RN-Lib-Claude conventions added to $CLAUDE_MD"
fi
