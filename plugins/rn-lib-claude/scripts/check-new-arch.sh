#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-src}"
VIOLATIONS=0

# Use ripgrep if available
if command -v rg &>/dev/null; then
  SEARCH() { rg --no-heading -n "$@" 2>/dev/null || true; }
else
  SEARCH() { grep -rn "$@" 2>/dev/null || true; }
fi

echo "🏗️  New Architecture Compliance Check"
echo "Target: $TARGET"
echo "================================"
echo ""

scan() {
  local label="$1"
  local pattern="$2"
  local result
  result="$(SEARCH -E "$pattern" "$TARGET" --include="*.ts" --include="*.tsx" 2>/dev/null || \
            find "$TARGET" -name "*.ts" -o -name "*.tsx" | xargs grep -En "$pattern" 2>/dev/null || true)"
  if [ -n "$result" ]; then
    echo "❌ $label"
    echo "$result" | sed 's/^/   /'
    echo ""
    VIOLATIONS=$((VIOLATIONS + 1))
  else
    echo "✓  $label"
  fi
}

echo "Legacy Bridge APIs (banned in New Architecture):"
scan "NativeModules usage" "NativeModules\."
scan "requireNativeComponent usage" "requireNativeComponent"
scan "UIManager usage" "UIManager\."
scan "AccessibilityInfo (bridge)" "AccessibilityInfo\.(fetch|addEventListener)" # some APIs are bridge-only
scan "Linking (legacy events)" "Linking\.addEventListener"

echo ""
echo "Deprecated Animation APIs:"
scan "Animated from react-native" "(import|require).*Animated.*from ['\"]react-native['\"]"
scan "PanResponder usage" "PanResponder"

echo ""
echo "Worklet Safety:"
# Scan for console.log near 'worklet' directive (heuristic)
WORKLET_CONSOLE="$(grep -rn "console\.log" "$TARGET" --include="*.ts" --include="*.tsx" 2>/dev/null || true)"
if [ -n "$WORKLET_CONSOLE" ]; then
  echo "⚠️  console.log found — verify none are inside worklets:"
  echo "$WORKLET_CONSOLE" | sed 's/^/   /'
  echo ""
fi

echo ""
echo "================================"
if [ "$VIOLATIONS" -eq 0 ]; then
  echo "✅ New Architecture compliant — no legacy bridge APIs found"
  exit 0
else
  echo "❌ $VIOLATIONS violation(s) found — must fix for New Architecture support"
  exit 1
fi
