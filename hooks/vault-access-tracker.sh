#!/usr/bin/env bash
set -euo pipefail

# vault-access-tracker.sh — PostToolUse hook for Obsidian MCP tools.
# Tracks which vault notes agents read, updates frontmatter counters,
# and logs navigation chains to ANALYTICS/navigation-chains.md.

VAULT_ROOT="$HOME/Documents/OpenClaw-Vault"

INPUT="$(cat)"
FILE_PATH="$(echo "$INPUT" | jq -r '.tool_input.path // empty')"

# Skip if path is empty or not a .md file
if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi
if [[ "$FILE_PATH" != *.md ]]; then
  exit 0
fi

# Resolve to absolute path
ABS_PATH="$VAULT_ROOT/$FILE_PATH"

# Skip if file doesn't exist
if [[ ! -f "$ABS_PATH" ]]; then
  exit 0
fi

# Session ID for navigation chain tracking
SESSION_ID="${CLAUDE_SESSION_ID:-$$-$(date +%Y%m%d)}"
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# --- Background worker: frontmatter update + chain logging ---
_track() {
  local abs_path="$1" file_path="$2" session_id="$3" timestamp="$4" vault_root="$5"

  # === Frontmatter update ===
  local tmp_file
  tmp_file="$(mktemp "${abs_path}.tmp.XXXXXX")"

  local first_line
  first_line="$(head -n1 "$abs_path")"

  if [[ "$first_line" == "---" ]]; then
    # File has frontmatter — parse and update in-place
    local in_frontmatter=true
    local found_access=false found_last=false found_first=false
    local line_num=0
    local access_count=0

    # First pass: read current values
    while IFS= read -r line; do
      line_num=$((line_num + 1))
      [[ $line_num -eq 1 ]] && continue  # skip opening ---
      [[ "$line" == "---" ]] && break
      case "$line" in
        access_count:*) access_count="${line#*: }"; found_access=true ;;
        first_accessed:*) found_first=true ;;
        last_accessed:*) found_last=true ;;
      esac
    done < "$abs_path"

    access_count=$(( ${access_count:-0} + 1 ))

    # Second pass: rewrite with updated values
    local past_frontmatter=false
    local wrote_access=false wrote_last=false wrote_first=false
    line_num=0

    while IFS= read -r line; do
      line_num=$((line_num + 1))

      if [[ $line_num -eq 1 && "$line" == "---" ]]; then
        echo "$line"
        continue
      fi

      if [[ "$past_frontmatter" == true ]]; then
        echo "$line"
        continue
      fi

      if [[ "$line" == "---" ]]; then
        # Inject missing fields before closing ---
        if [[ "$found_access" == false && "$wrote_access" == false ]]; then
          echo "access_count: $access_count"
          wrote_access=true
        fi
        if [[ "$found_last" == false && "$wrote_last" == false ]]; then
          echo "last_accessed: $timestamp"
          wrote_last=true
        fi
        if [[ "$found_first" == false && "$wrote_first" == false ]]; then
          echo "first_accessed: $timestamp"
          wrote_first=true
        fi
        echo "$line"
        past_frontmatter=true
        continue
      fi

      # Replace existing fields
      case "$line" in
        access_count:*)
          echo "access_count: $access_count"
          wrote_access=true
          ;;
        last_accessed:*)
          echo "last_accessed: $timestamp"
          wrote_last=true
          ;;
        *)
          echo "$line"
          ;;
      esac
    done < "$abs_path" > "$tmp_file"

  else
    # No frontmatter — prepend new block
    {
      echo "---"
      echo "access_count: 1"
      echo "last_accessed: $timestamp"
      echo "first_accessed: $timestamp"
      echo "---"
      echo ""
      cat "$abs_path"
    } > "$tmp_file"
  fi

  # Atomic replace
  mv "$tmp_file" "$abs_path"

  # === Navigation chain logging ===
  local analytics_dir="$vault_root/ANALYTICS"
  local chain_file="$analytics_dir/navigation-chains.md"
  local last_file="/tmp/vault-tracker-${session_id}.last"

  mkdir -p "$analytics_dir"

  if [[ ! -f "$chain_file" ]]; then
    cat > "$chain_file" <<'HEADER'
---
type: analytics
description: Navigation chains logged by vault-access-tracker hook
---

# Navigation Chains

| Session | Timestamp | File | Previous |
|---|---|---|---|
HEADER
  fi

  local previous="(start)"
  if [[ -f "$last_file" ]]; then
    previous="$(cat "$last_file")"
  fi

  echo "| $session_id | $timestamp | $file_path | $previous |" >> "$chain_file"

  # Record current file as previous for next access
  echo "$file_path" > "$last_file"
}

# Run in background — must never block Claude
_track "$ABS_PATH" "$FILE_PATH" "$SESSION_ID" "$TIMESTAMP" "$VAULT_ROOT" >/dev/null 2>&1 &

exit 0
