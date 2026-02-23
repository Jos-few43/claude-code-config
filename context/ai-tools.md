# AI Tools Configuration (on-demand context)

## OpenCode

**Container**: `ai-agents` | **Config**: `~/opt-ai-agents/opencode/` | **Env**: `OPENCODE_CONFIG_DIR=~/opt-ai-agents/opencode`

```bash
# Run OpenCode
distrobox enter ai-agents -- bash -c "
  source /etc/profile.d/ai-agents.sh
  cd $PWD
  opencode
"

# Manage plugins
bash ~/.config/opencode/skills/opencode-plugin-manager/scripts/list-plugins.sh
bash ~/PROJECTz/ai-container-configs/scripts/opencode-healthcheck.sh
```

**Models**: Gemini 3 Flash, Gemini 3 Pro High, Claude Sonnet 4.5, Claude Opus 4.6 (via Antigravity)

## OpenClaw

**Container**: `openclaw-dev` | **Config**: `/opt/openclaw/config/` | **Env**: `OPENCLAW_CONFIG_DIR=/opt/openclaw/config`

```bash
# Run OpenClaw
distrobox enter openclaw-dev -- bash -c "
  export OPENCLAW_CONFIG_DIR=/opt/openclaw/config
  cd $PWD
  openclaw
"

# Verify configuration
bash ~/.config/ai-tools-manager/openclaw/scripts/verify-config.sh openclaw-dev
```

**Providers**:
- **ollama** (local): Mistral Nemo 12B, DeepSeek Coder 6.7B
- **google-antigravity**: Gemini 3 Flash, Claude Opus 4.6 Thinking
- **google-gemini-cli**: Gemini 3 Pro Preview
- **qwen-portal**: Qwen Coder, Qwen Vision
- **groq**: Llama 3.3 70B, Gemma2 9B
- **opencode**: Kimi K2.5 Free

**Special Features**: Multi-account OAuth (Google Antigravity), Agent council, Computer use, Web search (Brave, Exa), Telegram bot, Browser automation

## Gemini CLI

**Container**: `ai-agents` | **Config**: `~/opt-ai-agents/gemini/` | **Env**: `GEMINI_CONFIG_DIR=~/opt-ai-agents/gemini`

```bash
# Run Gemini CLI
distrobox enter ai-agents -- bash -c "
  source /etc/profile.d/ai-agents.sh
  gemini
"

# Verify configuration
bash ~/PROJECTz/ai-container-configs/scripts/opencode-healthcheck.sh
```

**Features**: OAuth-based Google account auth, multi-account support

## Qwen Code

**Container**: `ai-agents` | **Config**: `~/opt-ai-agents/qwen/`

```bash
# Run Qwen
distrobox enter ai-agents -- bash -c "
  source /etc/profile.d/ai-agents.sh
  qwen
"
```

Integrated into ai-agents container alongside OpenCode and Gemini CLI.

## Shared Skills

Skills at `~/shared-skills/source/` are symlinked/copied into all tools:

```bash
vim ~/shared-skills/source/my-skill.md
bash ~/shared-skills/scripts/symlink-all.sh  # re-run if adding new skills

# Propagated to:
# - Claude Code: ~/.claude/plugins/skills/                             (symlink)
# - OpenCode:    ~/opt-ai-agents/opencode/skills/                      (symlink)
# - OpenClaw:    /opt/openclaw/config/workspace/skills/<name>/SKILL.md (live copy)
```

## Model Access & Authentication

- **OpenCode**: Antigravity plugin for Google/Claude models (OAuth in `~/opt-ai-agents/opencode/`)
- **OpenClaw**: Multi-provider with OAuth for Google Antigravity, Gemini CLI, Qwen Portal
- **Gemini CLI**: Direct OAuth with Google accounts (config in `~/opt-ai-agents/gemini/`)
- **Qwen Code**: Integrated into ai-agents container
