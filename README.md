# Hermes - Portainer Stack

Hermes agent with ttyd web terminal, running from pre-built GHCR image.

## Setup

1. **Build image**: Run the GitHub Action (Actions → Build and Push Hermes Image → Run workflow)
2. **Deploy**: Add as a Git Repository stack in Portainer pointing to this repo
3. **Access**: `http://<host>:7681`

## Updating

1. Run the GitHub Action to build a new image
2. In Portainer, pull and redeploy the stack
