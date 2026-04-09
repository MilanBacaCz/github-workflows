# Self-hosted GitHub Actions runner with Python, Node.js, and Flutter pre-installed.
# Based on Ubuntu 22.04 for maximum compatibility with GitHub Actions.

FROM ubuntu:22.04

ARG RUNNER_VERSION=2.333.1
# Auto-detect: x64 for amd64, arm64 for aarch64
ARG TARGETARCH

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# ─── System packages ───
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    git \
    jq \
    unzip \
    zip \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    build-essential \
    libssl-dev \
    libffi-dev \
    pkg-config \
    # For Flutter / Android SDK
    openjdk-17-jdk-headless \
    # For Chrome / Playwright
    libnss3 \
    libatk-bridge2.0-0 \
    libdrm2 \
    libxkbcommon0 \
    libgbm1 \
    # For Python builds
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncurses5-dev \
    libxml2-dev \
    libxmlsec1-dev \
    liblzma-dev \
    # For WeasyPrint (PDF generation)
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libgdk-pixbuf-2.0-0 \
    libcairo2 \
    # Cleanup
    && rm -rf /var/lib/apt/lists/*

# ─── Docker CLI (for docker-in-docker if needed) ───
RUN curl -fsSL https://get.docker.com | sh

# ─── Python 3.11 ───
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python3.11 python3.11-venv python3.11-dev python3-pip && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 && \
    rm -rf /var/lib/apt/lists/*

# ─── Node.js 22 ───
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# ─── Flutter ───
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="${FLUTTER_HOME}/bin:${PATH}"

RUN git clone --depth 1 --branch 3.41.6 https://github.com/flutter/flutter.git ${FLUTTER_HOME} && \
    flutter precache && \
    flutter config --no-analytics && \
    dart --disable-analytics

# ─── GitHub Actions Runner ───
RUN useradd -m -s /bin/bash runner && \
    mkdir -p /home/runner/actions-runner && \
    chown -R runner:runner /home/runner

WORKDIR /home/runner/actions-runner

# Detect architecture for runner binary download
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then GH_ARCH="x64"; \
    elif [ "$ARCH" = "aarch64" ]; then GH_ARCH="arm64"; \
    else echo "Unsupported architecture: $ARCH" && exit 1; fi && \
    curl -fsSL "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${GH_ARCH}-${RUNNER_VERSION}.tar.gz" \
    | tar xz && \
    ./bin/installdependencies.sh && \
    chown -R runner:runner /home/runner/actions-runner

# ─── Tool cache for actions/setup-python, actions/setup-node, etc. ───
ENV AGENT_TOOLSDIRECTORY=/home/runner/_tool
RUN mkdir -p /home/runner/_tool && chown runner:runner /home/runner/_tool

# ─── Persistent caches ───
RUN mkdir -p /home/runner/.cache/pip \
             /home/runner/.npm \
             /home/runner/.pub-cache && \
    chown -R runner:runner /home/runner

# Flutter needs write access
RUN chown -R runner:runner ${FLUTTER_HOME}

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER runner

ENTRYPOINT ["/entrypoint.sh"]
