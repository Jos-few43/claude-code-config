# Development Patterns (on-demand context)

## Running AI Tools

**From host (one-liner):**
```bash
# OpenCode
distrobox enter ai-agents -- bash -c "source /etc/profile.d/ai-agents.sh && opencode"

# OpenClaw
distrobox enter openclaw-dev -- bash -c "export OPENCLAW_CONFIG_DIR=/opt/openclaw/config && openclaw"

# Gemini
distrobox enter ai-agents -- bash -c "source /etc/profile.d/ai-agents.sh && gemini"
```

**Inside container:**
```bash
# Environment variables auto-set via /etc/profile.d/*.sh
distrobox enter ai-agents
opencode

distrobox enter openclaw-dev
openclaw
```

## Choosing the Right AI Tool

- **OpenCode** (ai-agents): Code generation, specific model preferences (Gemini, Claude), web UI, plugin extensibility
- **OpenClaw**: Multi-model fallback chains, local models (Ollama) + cloud fallback, agent council, browser automation, computer use, Telegram bot, complex workflows
- **Gemini CLI** (ai-agents): Quick Gemini access, Google Workspace integration, simple CLI
- **Qwen Code** (ai-agents): Qwen-specific models
- **LiteLLM Proxy**: Unified API endpoint, blue-green deployments, rate limiting

## Run AI Tool with Specific Model

```bash
# OpenCode
distrobox enter ai-agents -- bash -c "source /etc/profile.d/ai-agents.sh && opencode --model google/gemini-3-flash"

# OpenClaw (with fallback chain)
distrobox enter openclaw-dev -- openclaw --model flash  # Uses alias

# OpenClaw (specific provider)
distrobox enter openclaw-dev -- openclaw --model ollama/mistral-nemo:latest
```

## Add OAuth Account to OpenClaw

```bash
distrobox enter openclaw-dev
openclaw configure
# Follow OAuth flow for Google Antigravity, Gemini CLI, or Qwen Portal
```

## File Access in Containers

- `/home/yish` and `/var/home/yish` both point to host home (Bazzite uses /var/home)
- When passing paths to AI tools, use `/var/home/yish/...` format

## Configuration Backup

All original configs preserved on host (NOT used by containers):
- `~/.config/opencode/` - OpenCode backup
- `~/.openclaw/` - OpenClaw backup
- `~/.gemini/` - Gemini backup
- `~/.qwen/` - Qwen backup

Containers use `~/opt-ai-agents/` configs instead.

## Credentials & Secrets (chezmoi)

Encrypted credentials managed via chezmoi + age encryption:

- **Source repo**: `github.com/Jos-few43/dotfiles-private` (private)
- **Local source**: `~/.local/share/chezmoi/`
- **Applied config**: `~/.config/chezmoi/chezmoi.toml` (contains all API keys as `[data]` vars)
- **Age key**: `~/.config/age/key.txt` (required for decrypt -- back this up!)

```bash
# Recover on new machine
chezmoi init git@github.com:Jos-few43/dotfiles-private.git
chezmoi apply

# Add/update a secret
chezmoi edit ~/.config/chezmoi/chezmoi.toml  # edit plaintext
# then re-encrypt manually:
age --encrypt -R ~/.config/age/recipient.txt \
  ~/.local/share/chezmoi/.chezmoi.toml.tmpl > \
  ~/.local/share/chezmoi/.chezmoi.toml.tmpl.age
cd ~/.local/share/chezmoi && git add . && git commit -m "update credentials" && git push
```
