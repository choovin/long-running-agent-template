#!/bin/bash
# =============================================================================
# Session Checkpoint Script
# =============================================================================
# Creates a checkpoint of the current session state for recovery.
# =============================================================================

set -e

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHECKPOINT_DIR="$PROJECT_ROOT/.agent/state/checkpoints"

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

# Create checkpoint directory
mkdir -p "$CHECKPOINT_DIR"

# Generate checkpoint ID
CHECKPOINT_ID=$(date +%Y%m%d_%H%M%S)
CHECKPOINT_FILE="$CHECKPOINT_DIR/checkpoint_${CHECKPOINT_ID}.json"

log_info "Creating checkpoint: $CHECKPOINT_ID"

# Get git info
GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
GIT_COMMIT=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
GIT_STATUS=$(git status --porcelain 2>/dev/null | head -20 || echo "")

# Get feature status
FEATURES_PASSING=$(cat "$PROJECT_ROOT/features/feature_list.json" 2>/dev/null | \
    jq '[.features[] | select(.passes == true)] | length' 2>/dev/null || echo "0")
FEATURES_TOTAL=$(cat "$PROJECT_ROOT/features/feature_list.json" 2>/dev/null | \
    jq '.features | length' 2>/dev/null || echo "0")

# Create checkpoint JSON
cat > "$CHECKPOINT_FILE" << EOF
{
  "checkpoint_id": "$CHECKPOINT_ID",
  "timestamp": "$(date -Iseconds)",
  "git": {
    "branch": "$GIT_BRANCH",
    "commit": "$GIT_COMMIT",
    "status": $(echo "$GIT_STATUS" | jq -Rs .)
  },
  "features": {
    "passing": $FEATURES_PASSING,
    "total": $FEATURES_TOTAL,
    "progress_percent": $(echo "scale=2; $FEATURES_PASSING * 100 / $FEATURES_TOTAL" | bc 2>/dev/null || echo "0")
  },
  "files": $(git ls-files --others --exclude-standard 2>/dev/null | jq -Rs . || echo "[]")
}
EOF

log_success "Checkpoint created: $CHECKPOINT_FILE"

# Also copy progress file
cp "$PROJECT_ROOT/progress/claude-progress.md" \
   "$CHECKPOINT_DIR/progress_${CHECKPOINT_ID}.md" 2>/dev/null || true

echo ""
echo "Checkpoint Summary:"
echo "  ID: $CHECKPOINT_ID"
echo "  Git Branch: $GIT_BRANCH"
echo "  Git Commit: ${GIT_COMMIT:0:8}"
echo "  Features: $FEATURES_PASSING / $FEATURES_TOTAL"
echo ""