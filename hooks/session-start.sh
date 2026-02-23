#!/bin/bash
# SessionStart hook: injects dynamic context based on git state, project type, and CWD.
# Receives JSON on stdin with session_id, cwd, hook_event_name, matched_value, etc.
# Returns JSON with hookSpecificOutput.additionalContext for context injection.
set -euo pipefail

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

if [ -z "$CWD" ]; then
  CWD="$PWD"
fi

CONTEXT_DIR="$HOME/.claude/context"
OUTPUT=""

# --- Git State ---
if git -C "$CWD" rev-parse --git-dir &>/dev/null; then
  BRANCH=$(git -C "$CWD" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
  CHANGES=$(git -C "$CWD" --no-optional-locks status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  STASHES=$(git -C "$CWD" --no-optional-locks stash list 2>/dev/null | wc -l | tr -d ' ')
  RECENT=$(git -C "$CWD" --no-optional-locks log --oneline -3 --no-decorate 2>/dev/null || echo "(no commits)")

  OUTPUT+="## Git State
Branch: ${BRANCH} | Uncommitted: ${CHANGES} | Stashes: ${STASHES}
Recent commits:
${RECENT}

"
fi

# --- Project Type ---
STACK=""
[ -f "$CWD/package.json" ] && STACK+="Node.js "
{ [ -f "$CWD/pyproject.toml" ] || [ -f "$CWD/setup.py" ]; } && STACK+="Python "
[ -f "$CWD/Cargo.toml" ] && STACK+="Rust "
[ -f "$CWD/go.mod" ] && STACK+="Go "
[ -f "$CWD/Makefile" ] && STACK+="Make "
{ [ -f "$CWD/docker-compose.yml" ] || [ -f "$CWD/compose.yml" ]; } && STACK+="Docker "
{ [ -f "$CWD/Containerfile" ] || [ -f "$CWD/Dockerfile" ]; } && STACK+="Container "

if [ -n "$STACK" ]; then
  OUTPUT+="## Project Stack
Detected: ${STACK}

"
fi

# --- Container Health (only on host, not inside a container) ---
if command -v distrobox &>/dev/null && [ ! -f /run/.containerenv ]; then
  RUNNING_LIST=$(distrobox list --no-color 2>/dev/null | tail -n +2 | grep -i "up\|running" || true)
  if [ -n "$RUNNING_LIST" ]; then
    RUNNING_COUNT=$(echo "$RUNNING_LIST" | wc -l | tr -d ' ')
    CONTAINER_NAMES=$(echo "$RUNNING_LIST" | awk '{print $3}' | tr '\n' ', ' | sed 's/,$//')
    OUTPUT+="## Containers
Running (${RUNNING_COUNT}): ${CONTAINER_NAMES}

"
  fi
fi

# --- Context Fragment Loading (based on CWD) ---
FRAGMENTS=""
case "$CWD" in
  */litellm-stack*)
    [ -f "$CONTEXT_DIR/litellm.md" ] && FRAGMENTS+="$(cat "$CONTEXT_DIR/litellm.md")"$'\n'
    ;;
  */ai-container-configs*)
    [ -f "$CONTEXT_DIR/containers.md" ] && FRAGMENTS+="$(cat "$CONTEXT_DIR/containers.md")"$'\n'
    [ -f "$CONTEXT_DIR/ai-tools.md" ] && FRAGMENTS+="$(cat "$CONTEXT_DIR/ai-tools.md")"$'\n'
    ;;
  */opencode-manager*|*/opencode-antigravity*)
    [ -f "$CONTEXT_DIR/ai-tools.md" ] && FRAGMENTS+="$(cat "$CONTEXT_DIR/ai-tools.md")"$'\n'
    ;;
  */openclaw*)
    [ -f "$CONTEXT_DIR/ai-tools.md" ] && FRAGMENTS+="$(cat "$CONTEXT_DIR/ai-tools.md")"$'\n'
    ;;
  */distrobox-configs*)
    [ -f "$CONTEXT_DIR/containers.md" ] && FRAGMENTS+="$(cat "$CONTEXT_DIR/containers.md")"$'\n'
    ;;
esac

if [ -n "$FRAGMENTS" ]; then
  OUTPUT+="${FRAGMENTS}
"
fi

# --- Model Advisory ---
OUTPUT+="## Model Advisory
- Use **Opus** for: planning, architecture, complex reasoning, debugging
- Use **Sonnet** for: implementation, code generation, routine changes (~5x cheaper)
- Switch with: \`/model sonnet\` or \`/model opus\`
"

# --- Output as JSON ---
if [ -n "$OUTPUT" ]; then
  jq -n --arg ctx "$OUTPUT" '{
    "hookSpecificOutput": {
      "hookEventName": "SessionStart",
      "additionalContext": $ctx
    }
  }'
fi
