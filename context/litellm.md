# LiteLLM Proxy Stack (on-demand context)

Blue-green deployable LiteLLM proxy with zero-downtime reloads.

## Architecture

- `litellm-router` (haproxy, port 4000) -- routes to active backend
- `litellm-dev` (blue, port 4001) -- LiteLLM instance A
- `litellm-green` (green, port 4002) -- LiteLLM instance B

## Commands

```bash
# Start the full stack
bash ~/litellm-stack/blue/start.sh  # or green/start.sh

# Check which backend is active
bash ~/PROJECTz/ai-container-configs/scripts/litellm-healthcheck.sh

# Promote green to active (zero-downtime)
bash ~/litellm-stack/green/start.sh  # promote green

# Roll back to blue
bash ~/litellm-stack/blue/start.sh  # rollback to blue

# Verify router health
bash ~/PROJECTz/ai-container-configs/scripts/litellm-healthcheck.sh
```

## Directory Structure

```
~/litellm-stack/
├── router/              # haproxy config
│   └── haproxy.cfg
├── blue/                # Blue instance config
└── green/               # Green instance config
```

**Best for**: Unified API endpoint across all models, blue-green deployments, rate limiting and load balancing.
