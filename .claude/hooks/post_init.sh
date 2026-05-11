#!/usr/bin/env bash
# Post-init hook for qvac-workstation
# Updates timestamps, regenerates structure tree, snapshots dependencies,
# and writes a pending review file when deps drift.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TODAY=$(date +%Y-%m-%d)

echo "🔄 Running post-init hook (qvac-workstation)..."

# ─── 1. Refresh Last Updated in docs/architecture.md ─────────────────
ARCH_FILE="$PROJECT_ROOT/docs/architecture.md"
if [ -f "$ARCH_FILE" ]; then
    if grep -q "^Last Updated:" "$ARCH_FILE"; then
        # GNU sed (Linux/Git Bash) first, then BSD sed (macOS) fallback
        sed -i "s/^Last Updated:.*/Last Updated: $TODAY/" "$ARCH_FILE" 2>/dev/null \
            || sed -i '' "s/^Last Updated:.*/Last Updated: $TODAY/" "$ARCH_FILE"
        echo "✅ Updated timestamp in docs/architecture.md"
    else
        echo "⚠️  No 'Last Updated:' line found in docs/architecture.md"
    fi
else
    echo "⚠️  docs/architecture.md not found, skipping timestamp update"
fi

# ─── 2. Regenerate docs/structure.md ─────────────────────────────────
STRUCTURE_FILE="$PROJECT_ROOT/docs/structure.md"
mkdir -p "$(dirname "$STRUCTURE_FILE")"

{
    echo "# Project Structure"
    echo ""
    echo "Last Updated: $TODAY"
    echo ""
    echo '```'
} > "$STRUCTURE_FILE"

if command -v tree &> /dev/null; then
    tree -I 'node_modules|.git|__pycache__|.venv|venv|*.pyc|build|dist|prebuilds|.bare|.next|.turbo|coverage' \
         --dirsfirst -L 3 "$PROJECT_ROOT" >> "$STRUCTURE_FILE" 2>/dev/null || true
else
    (
        cd "$PROJECT_ROOT"
        find . -maxdepth 3 \
            -not -path '*/node_modules/*' \
            -not -path '*/.git/*' \
            -not -path '*/__pycache__/*' \
            -not -path '*/.venv/*' \
            -not -path '*/venv/*' \
            -not -path '*/build/*' \
            -not -path '*/dist/*' \
            -not -path '*/prebuilds/*' \
            -not -path '*/.bare/*' \
            -not -path '*/.next/*' \
            -not -path '*/.turbo/*' \
            -not -path '*/coverage/*' \
            -not -name '*.pyc' \
            \( -type d -o -type f \) 2>/dev/null | sort
    ) >> "$STRUCTURE_FILE" || true
fi

echo '```' >> "$STRUCTURE_FILE"
echo "✅ Regenerated docs/structure.md"

# ─── 3. Snapshot dependencies and detect drift ───────────────────────
DECISIONS_DIR="$PROJECT_ROOT/docs/decisions"
SNAPSHOT_FILE="$DECISIONS_DIR/.last_deps_snapshot"
PENDING_FILE="$DECISIONS_DIR/.pending_adr_review"
mkdir -p "$DECISIONS_DIR"

CURRENT_DEPS_TMP="$(mktemp)"
trap 'rm -f "$CURRENT_DEPS_TMP"' EXIT

# qvac monorepo: every package.json under qvac/packages/* (top-level only)
if [ -d "$PROJECT_ROOT/qvac/packages" ]; then
    for pkg in "$PROJECT_ROOT/qvac/packages"/*/package.json; do
        [ -f "$pkg" ] || continue
        rel="${pkg#"$PROJECT_ROOT"/}"
        echo "=== $rel ===" >> "$CURRENT_DEPS_TMP"
        grep -E '^\s+"[^"]+":\s*"[^"]+"' "$pkg" 2>/dev/null | sort >> "$CURRENT_DEPS_TMP" || true
        echo "" >> "$CURRENT_DEPS_TMP"
    done
fi

# qvac root package.json (if any)
if [ -f "$PROJECT_ROOT/qvac/package.json" ]; then
    echo "=== qvac/package.json ===" >> "$CURRENT_DEPS_TMP"
    grep -E '^\s+"[^"]+":\s*"[^"]+"' "$PROJECT_ROOT/qvac/package.json" 2>/dev/null | sort >> "$CURRENT_DEPS_TMP" || true
    echo "" >> "$CURRENT_DEPS_TMP"
fi

# Research repo: requirements.txt / pyproject.toml if present
for f in \
    "$PROJECT_ROOT/qvac-rnd-fabric-llm-bitnet/requirements.txt" \
    "$PROJECT_ROOT/qvac-rnd-fabric-llm-bitnet/pyproject.toml" \
    "$PROJECT_ROOT/requirements.txt" \
    "$PROJECT_ROOT/pyproject.toml"; do
    if [ -f "$f" ]; then
        rel="${f#"$PROJECT_ROOT"/}"
        echo "=== $rel ===" >> "$CURRENT_DEPS_TMP"
        sort "$f" >> "$CURRENT_DEPS_TMP" 2>/dev/null || true
        echo "" >> "$CURRENT_DEPS_TMP"
    fi
done

# Compare to previous snapshot
if [ -f "$SNAPSHOT_FILE" ]; then
    if ! diff -q "$SNAPSHOT_FILE" "$CURRENT_DEPS_TMP" > /dev/null 2>&1; then
        echo "⚠️  Dependency changes detected!"
        {
            echo "# Dependency Changes Detected"
            echo ""
            echo "Detected on: $TODAY"
            echo ""
            echo "Review these changes and create/update ADRs as needed."
            echo "Skip dev/test-only and minor version bumps."
            echo ""
            echo '```diff'
            diff "$SNAPSHOT_FILE" "$CURRENT_DEPS_TMP" 2>/dev/null || true
            echo '```'
        } > "$PENDING_FILE"
        echo "📝 Wrote diff to docs/decisions/.pending_adr_review"
    else
        echo "✅ No dependency changes detected"
    fi
else
    echo "📝 Creating initial dependency snapshot"
fi

cp "$CURRENT_DEPS_TMP" "$SNAPSHOT_FILE"
echo "✅ Updated dependency snapshot"

# ─── 4. Reminder ─────────────────────────────────────────────────────
echo ""
echo "👉 Claude will update diagrams and flows on next /init"
echo ""
echo "🎉 Post-init hook complete!"
