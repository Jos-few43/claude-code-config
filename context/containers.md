# Container Management (on-demand context)

## Active Containers

| Container | Purpose | Config Path |
|---|---|---|
| `ai-agents` | OpenCode 1.2.1 + Gemini CLI + Qwen | `~/opt-ai-agents/` |
| `openclaw-dev` | OpenClaw (browser, Telegram, agents) | `/opt/openclaw/config/` |
| `litellm-router` | haproxy reverse proxy | `~/litellm-stack/router/` |
| `litellm-dev` | LiteLLM blue instance (port 4001) | `~/litellm-stack/blue/` |
| `litellm-green` | LiteLLM green instance (port 4002) | `~/litellm-stack/green/` |
| `fedora-tools` | General CLI tools | -- |
| `lmstudio-container` | LM Studio local model server | -- |
| `warp-term` | Warp terminal | -- |
| `n8n-dev` | n8n workflow automation | -- |
| `langflow-dev` | Langflow AI workflow builder | -- |

## Create / Setup / Healthcheck

```bash
# Create containers
bash ~/PROJECTz/ai-container-configs/scripts/manage.sh create opencode
bash ~/PROJECTz/ai-container-configs/scripts/manage.sh create openclaw
bash ~/PROJECTz/ai-container-configs/scripts/manage.sh create ai-tools

# Setup inside container
distrobox enter opencode-dev
bash ~/PROJECTz/ai-container-configs/setup/opencode-setup.sh

# Health checks (from host)
bash ~/PROJECTz/ai-container-configs/scripts/opencode-healthcheck.sh
bash ~/.config/ai-tools-manager/openclaw/scripts/verify-config.sh openclaw-dev
bash ~/.config/ai-tools-manager/gemini/scripts/verify-config.sh ai-cli-tools-dev
```

## Container Isolation Strategy

- **Immutable Host**: Bazzite uses OSTree; software installation happens in containers
- **Shared Home**: `$HOME` mounted in containers
- **Container-Specific Config**: Each tool at `~/opt-ai-agents/` or `/opt/<tool>/` (not `~/.config/<tool>/`)
- **Host Backup**: Original configs in `~/.config/`, `~/.openclaw/`, etc. preserved

## Container Lifecycle

- Containers persist across reboots
- Use `distrobox stop --yes <name>` to pause
- Use `distrobox enter <name>` to resume
- Config in `~/opt-ai-agents/` persists on host (not lost if container is rebuilt)

## Configure New Container for AI Tool

```bash
# 1. Create container
bash ~/PROJECTz/ai-container-configs/scripts/manage.sh create my-tool

# 2. Setup config directory
distrobox enter my-tool -- sudo mkdir -p /opt/my-tool/config
distrobox enter my-tool -- sudo cp -r ~/.my-tool/* /opt/my-tool/config/
distrobox enter my-tool -- sudo chown -R $USER:$USER /opt/my-tool/

# 3. Create environment file
distrobox enter my-tool -- sudo tee /etc/profile.d/my-tool.sh <<'EOF'
export MY_TOOL_CONFIG_DIR=/opt/my-tool/config
EOF

# 4. Verify
distrobox enter my-tool -- bash -c 'source /etc/profile.d/my-tool.sh && echo $MY_TOOL_CONFIG_DIR'
```

## Troubleshoot AI Tool Configuration

```bash
# Check environment
distrobox enter <container> -- bash -c 'source /etc/profile.d/<tool>.sh && env | grep <TOOL>'

# Verify config directory
distrobox enter <container> -- ls -la /opt/<tool>/config/

# Check tool installation
distrobox enter <container> -- which <tool>
distrobox enter <container> -- <tool> --version

# Re-run verification
bash ~/PROJECTz/ai-container-configs/scripts/opencode-healthcheck.sh
bash ~/PROJECTz/ai-container-configs/scripts/litellm-healthcheck.sh
```

## Anti-Patterns

- Don't install software on host (Bazzite is immutable)
- Don't use `~/.config/<tool>/` in containers -- use `~/opt-ai-agents/` or `/opt/<tool>/config/`
- Don't hardcode `/home/yish` -- use `$HOME`
- Don't skip environment setup -- always source `/etc/profile.d/*.sh`
- Don't delete deprecated containers immediately -- keep 1 week for rollback
