#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-.}"
STAGED=false
if [ "$TARGET" = "--staged" ]; then
  STAGED=true
fi

# Use ripgrep if available, fall back to grep
if command -v rg &>/dev/null; then
  SEARCH() { rg --no-heading -n "$@" 2>/dev/null || true; }
else
  SEARCH() { grep -rn "$@" 2>/dev/null || true; }
fi

# Get files to scan
get_files() {
  if $STAGED; then
    git diff --cached --name-only --diff-filter=ACM | grep -E '\.(ts|tsx|js|jsx)$' || true
  else
    find "$TARGET" -type f \( -name "*.ts" -o -name "*.tsx" \) \
      ! -path "*/node_modules/*" \
      ! -path "*/lib/*" \
      ! -path "*/example/*" \
      ! -path "*/__generated__/*" \
      ! -path "*/build/*"
  fi
}

FILES="$(get_files)"
CRITICAL=0
MEDIUM=0
LOW=0

echo "🔍 RN-Lib-Claude Deslop Scanner"
echo "Target: $TARGET"
echo "================================"

# ── CRITICAL ──────────────────────────────────────────────────────────────────

echo ""
echo "🔴 CRITICAL"

check_critical() {
  local label="$1"; shift
  local result
  result="$(echo "$FILES" | xargs grep -n "$@" 2>/dev/null || true)"
  if [ -n "$result" ]; then
    echo "  [$label]"
    echo "$result" | sed 's/^/    /'
    CRITICAL=$((CRITICAL + 1))
  fi
}

check_critical "LEGACY BRIDGE: NativeModules" -E "NativeModules\."
check_critical "LEGACY BRIDGE: requireNativeComponent" -F "requireNativeComponent"
check_critical "LEGACY BRIDGE: UIManager" -E "UIManager\."
check_critical "LEGACY BRIDGE: Animated from RN" -E "from 'react-native'.*Animated|Animated.*from 'react-native'"
check_critical "WORKLET console.log" -E "'worklet'[\s\S]*?console\.(log|warn|error)" --multiline
check_critical "PLACEHOLDER: throw TODO" -E "throw new Error\(['\"]TODO|throw new Error\(['\"]Not implemented"
check_critical "EMPTY CATCH" -E "catch\s*\([^)]*\)\s*\{\s*\}"
check_critical "GESTURE: PanResponder" -F "PanResponder"
check_critical "SECRET: API key" -iE "(api_key|apikey|api-key)\s*[:=]\s*['\"][^'\"]{8,}"
check_critical "SECRET: Bearer token" -E "Bearer [A-Za-z0-9\-_]{20,}"

# ── MEDIUM ────────────────────────────────────────────────────────────────────

echo ""
echo "🟡 MEDIUM"

check_medium() {
  local label="$1"; shift
  local result
  result="$(echo "$FILES" | xargs grep -n "$@" 2>/dev/null || true)"
  if [ -n "$result" ]; then
    echo "  [$label]"
    echo "$result" | sed 's/^/    /'
    MEDIUM=$((MEDIUM + 1))
  fi
}

check_medium "console.log in src/" -E "console\.(log|warn|error)\("
check_medium "Hardcoded color string" -E "['\"](#[0-9a-fA-F]{3,6}|red|blue|green|black|white|gray|grey)['\"]"
check_medium "TODO/FIXME comments" -E "(TODO|FIXME|HACK):"
check_medium "Default export" -E "^export default "

# ── LOW ───────────────────────────────────────────────────────────────────────

echo ""
echo "💭 LOW"

check_low() {
  local label="$1"; shift
  local result
  result="$(echo "$FILES" | xargs grep -n "$@" 2>/dev/null || true)"
  if [ -n "$result" ]; then
    echo "  [$label]"
    echo "$result" | sed 's/^/    /'
    LOW=$((LOW + 1))
  fi
}

check_low "eslint-disable" -F "eslint-disable"
check_low "@ts-ignore" -F "@ts-ignore"
check_low "Missing displayName" -E "^const [A-Z][a-zA-Z]+ = (forwardRef|memo)\(" # heuristic

# ── SUMMARY ──────────────────────────────────────────────────────────────────

echo ""
echo "================================"
echo "Summary: 🔴 $CRITICAL critical  🟡 $MEDIUM medium  💭 $LOW low"

if [ "$CRITICAL" -gt 0 ]; then
  echo ""
  echo "❌ Critical issues found — fix before publishing"
  exit 1
else
  echo ""
  echo "✅ No critical issues"
  exit 0
fi
