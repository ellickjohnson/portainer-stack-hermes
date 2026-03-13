FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ttyd \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install uv for fast Python package management
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Clone and install Hermes
RUN git clone --depth 1 https://github.com/NousResearch/hermes-agent.git /opt/hermes \
    && cd /opt/hermes \
    && git submodule update --init mini-swe-agent \
    && uv venv /opt/hermes/.venv --python 3.11 \
    && . /opt/hermes/.venv/bin/activate \
    && uv pip install -e ".[all]" \
    && uv pip install -e "./mini-swe-agent"

# Create hermes data directory
RUN mkdir -p /root/.hermes

WORKDIR /root

# Create startup script
RUN echo '#!/bin/bash\nsource /opt/hermes/.venv/bin/activate\ncd /root\nhermes' > /start-hermes.sh \
    && chmod +x /start-hermes.sh

# Expose ttyd port
EXPOSE 7681

# Start ttyd with hermes
CMD ["ttyd", "-W", "-p", "7681", "/start-hermes.sh"]
