# claude-code-config

Claude Code configuration: hooks, skills, settings, and context files.

Defines the complete Claude Code environment for this setup — MCP server definitions, lifecycle hooks, custom skills, session management, and on-demand context fragments.

## Structure

```
claude-code-config/
├── settings.json         # Main config (hooks, status line, enabled plugins)
├── .mcp.json             # MCP server definitions
├── hooks/                # Lifecycle event hook scripts
│   ├── session-start.sh  # Injects git state, project type, container health
│   └── vault-access-tracker.sh
├── skills/               # Custom skill implementations
│   ├── arr-media-stack/
│   ├── distrobox-management/
│   ├── non-interactive-shell/
│   └── ujust-bazzite-admin/
└── context/              # Context fragments for on-demand loading
    ├── ai-tools.md
    ├── containers.md
    ├── development.md
    ├── litellm.md
    └── scripts.md
```

## Hooks

| Event | Action |
|---|---|
| SessionStart | Injects git state, detected project stack, running containers, model advisory |
| SessionEnd | Syncs session transcript to OpenClaw-Vault |
| UserPromptSubmit | Suggests relevant skills via LLM |
| PostToolUse (Write) | Triggers vault sync after file writes |
| PostToolUse (Obsidian) | Tracks vault file access |
| Stop | Suggests skills, nudges memory sync |

## Skills

| Skill | Purpose |
|---|---|
| `arr-media-stack` | Managing the Docker media automation stack |
| `distrobox-management` | Container lifecycle on Bazzite |
| `non-interactive-shell` | Safe shell command patterns for automation |
| `ujust-bazzite-admin` | Bazzite system administration via ujust |

Skills are symlinked from `~/shared-skills/` — edit at the source repo, not here.

## Context Files

Loaded automatically by `session-start.sh` based on the current working directory. Referenced by path pattern (e.g. `*/litellm-stack*` loads `context/litellm.md`).

## Related Repos

- `shared-skills` — source of truth for skill implementations
- `shared-mcp` — source of truth for MCP server definitions
- `SCRiPTz` — contains `sync-claude-to-vault.sh` used by SessionEnd hook
- `shared-memory` — memory files synced into `~/.claude/projects/`
