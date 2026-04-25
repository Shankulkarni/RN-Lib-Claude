#!/usr/bin/env bash
set -euo pipefail

PASS=0
FAIL=0

check() {
  local label="$1"
  local cmd="$2"
  if eval "$cmd" &>/dev/null; then
    echo "  ✓ $label"
    PASS=$((PASS + 1))
  else
    echo "  ✗ $label"
    FAIL=$((FAIL + 1))
  fi
}

echo "📦 RN-Lib-Claude Pre-Publish Checks"
echo "================================"
echo ""

# ── Changeset ─────────────────────────────────────────────────────────────────
echo "Changesets"
check "Changeset file exists" "ls .changeset/*.md 2>/dev/null | grep -v README"

# ── Build ─────────────────────────────────────────────────────────────────────
echo ""
echo "Build"
check "bob build passes" "bun run build"
# Modern bob uses module (ESM) output only — no commonjs target
check "lib/module exists" "[ -d lib/module ]"
check "lib/typescript exists" "[ -d lib/typescript ]"

# ── TypeScript ─────────────────────────────────────────────────────────────────
echo ""
echo "TypeScript"
check "No type errors" "bun run typecheck"

# ── Lint ──────────────────────────────────────────────────────────────────────
echo ""
echo "Lint"
check "No lint errors" "bun run lint"

# ── Format ────────────────────────────────────────────────────────────────────
echo ""
echo "Format"
if command -v bun &>/dev/null; then
  check "Code formatted correctly" "bun run format:check"
else
  echo "  ⚠ bun not found — skipping format check"
fi

# ── Tests ─────────────────────────────────────────────────────────────────────
echo ""
echo "Tests"
check "All tests pass" "bun run test"

# ── Package ───────────────────────────────────────────────────────────────────
echo ""
echo "Package"
check "exports field in package.json" "node -e \"const p = require('./package.json'); if (!p.exports) process.exit(1)\""
check "main field in package.json" "node -e \"const p = require('./package.json'); if (!p.main) process.exit(1)\""
check "types field in package.json" "node -e \"const p = require('./package.json'); if (!p.types) process.exit(1)\""
check "peerDependencies declared" "node -e \"const p = require('./package.json'); if (!p.peerDependencies || !p.peerDependencies['react-native']) process.exit(1)\""
check "files field present" "node -e \"const p = require('./package.json'); if (!p.files) process.exit(1)\""
check "prepare includes bob build" "node -e \"const p = require('./package.json'); if (!p.scripts.prepare || !p.scripts.prepare.includes('bob build')) process.exit(1)\""

# ── Code quality ──────────────────────────────────────────────────────────────
echo ""
echo "Code Quality"
check "No console.log in src/" "! grep -r 'console\\.log' src/ 2>/dev/null"
check "No legacy NativeModules" "! grep -r 'NativeModules\\.' src/ 2>/dev/null"
check "No requireNativeComponent" "! grep -r 'requireNativeComponent' src/ 2>/dev/null"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "================================"
echo "Results: ✓ $PASS passed  ✗ $FAIL failed"

if [ "$FAIL" -gt 0 ]; then
  echo ""
  echo "❌ Fix the above failures before publishing"
  exit 1
else
  echo ""
  echo "✅ All checks passed — ready to publish"
  exit 0
fi
