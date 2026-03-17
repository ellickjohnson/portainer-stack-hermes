FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl \
    && rm -rf /var/lib/apt/lists/*

RUN ARCH=$(uname -m) && \
    curl -sL https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.${ARCH} -o /usr/local/bin/ttyd && \
    chmod +x /usr/local/bin/ttyd

RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

ARG HERMES_REF=main
RUN git clone --depth 1 --branch ${HERMES_REF} https://github.com/NousResearch/hermes-agent.git /opt/hermes \
    && cd /opt/hermes \
    && git submodule update --init mini-swe-agent \
    && uv venv /opt/hermes/.venv --python 3.11 \
    && . /opt/hermes/.venv/bin/activate \
    && uv pip install -e ".[all,dev]" \
    && uv pip install -e "./mini-swe-agent"

RUN mkdir -p /root/.hermes
WORKDIR /root

RUN printf '#!/bin/bash\n. /opt/hermes/.venv/bin/activate\ncd /root\nhermes\n' > /start-hermes.sh \
    && chmod +x /start-hermes.sh

EXPOSE 7681
CMD ["ttyd", "-W", "-p", "7681", "/start-hermes.sh"]
