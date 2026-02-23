# Management Scripts & Directory Structure (on-demand context)

## AI Agents Verification

```bash
# Verify ai-agents container
bash ~/PROJECTz/ai-container-configs/scripts/opencode-healthcheck.sh

# Verify LiteLLM router
bash ~/PROJECTz/ai-container-configs/scripts/litellm-healthcheck.sh
```

## OpenCode Plugin Manager

```bash
# Base path
~/.config/opencode/skills/opencode-plugin-manager/scripts/

# Available scripts
list-plugins.sh                      # List installed OpenCode plugins
verify-config.sh <container>         # Verify OpenCode configuration
configure-container.sh <name> <path> # Setup new container
install-plugin.sh <plugin> <container> # Install plugin
remove-plugin.sh <plugin> <container>  # Remove plugin
```

## AI Tools Manager

```bash
# Base path
~/.config/ai-tools-manager/

# OpenClaw
openclaw/scripts/verify-config.sh openclaw-dev
```

## Plugin/Config Directory Structure

```
~/opt-ai-agents/                    # ai-agents container
├── opencode/                        # OpenCode config
├── gemini/                          # Gemini CLI config
└── qwen/                            # Qwen config

/opt/openclaw/config/               # OpenClaw container
├── openclaw.json                    # Main configuration
├── credentials/                     # OAuth credentials
├── agents/                          # Agent definitions
├── skills/                          # Custom skills
└── plugins/                         # Plugins (Antigravity, Gemini, Qwen)

~/litellm-stack/                    # LiteLLM proxy stack repo
├── router/                          # haproxy config
│   └── haproxy.cfg
├── blue/                            # Blue instance config
└── green/                           # Green instance config

~/shared-skills/                    # Shared skills repo
├── source/                          # Skill source files
└── scripts/
    └── symlink-all.sh               # Symlink to Claude Code + OpenCode; live-copy into openclaw-dev

# Host backups (preserved)
~/.config/opencode/                  # OpenCode backup
~/.openclaw/                         # OpenClaw backup
~/.gemini/                           # Gemini backup
~/.qwen/                             # Qwen backup
```
