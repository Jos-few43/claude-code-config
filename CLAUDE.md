# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Claude Code IDE configuration repository containing MCP server definitions, lifecycle hooks, custom skills, and session management. Defines the complete Claude Code environment setup.

## Tech Stack

| Component | Technology |
|---|---|
| Config | JSON (settings.json, .mcp.json) |
| Hooks | Bash scripts |
| Protocol | MCP (Model Context Protocol) |

## Project Structure

```
claude-code-config/
├── settings.json         # Main config (hooks, status line, plugins)
├── .mcp.json             # MCP server definitions
├── hooks/                # Lifecycle event hooks
│   ├── session-start.sh
│   ├── postwrite-vault-sync.sh
│   └── ...
├── skills/               # Custom skill implementations
│   ├── arr-media-stack/
│   ├── distrobox-management/
│   ├── non-interactive-shell/
│   └── ujust-bazzite-admin/
└── context/              # Context files for on-demand loading
```

## Key Hooks

| Event | Action |
|---|---|
| SessionStart | Initialize session context |
| SessionEnd | Sync transcripts to vault |
| UserPromptSubmit | Suggest relevant skills |
| PostToolUse | Vault sync, access tracking |
| Stop | Suggest skills, memory nudge |

## MCP Servers

Playwright, PostgreSQL, Memory, Docker — all via npx.

## Cross-Repo Relationships

- **SCRiPTz** — Hooks reference `sync-claude-to-vault.sh`
- **OpenClaw-Vault** — Session/vault synchronization target
- **shared-skills** — Skills symlinked from source
- **distrobox-configs** — distrobox-management skill

## Things to Avoid

- Don't edit skills here if they originate from shared-skills — edit at source
- Don't remove hooks without understanding downstream vault sync impact
