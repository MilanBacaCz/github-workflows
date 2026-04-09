# Self-hosted GitHub Actions runner for local Docker (macOS).
# Supports Python 3.11 + 3.13, Node.js 22, Qt6/QML dependencies.

FROM ubuntu:22.04

ARG RUNNER_VERSION=2.333.1

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV LD_LIBRARY_PATH=/usr/lib/aarch64-linux-gnu:/usr/lib

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
    # For Qt6 / QML (PyQt6 headless)
    libegl1 \
    libgl1 \
    libxkbcommon0 \
    libdbus-1-3 \
    libfontconfig1 \
    libxcb-xinerama0 \
    libxcb-cursor0 \
    # For Chrome / Playwright
    libnss3 \
    libatk-bridge2.0-0 \
    libdrm2 \
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
    # sudo for GitHub Actions workflows that install system packages
    sudo \
    && rm -rf /var/lib/apt/lists/*

# ─── Python 3.11 + 3.13 ───
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y \
        python3.11 python3.11-venv python3.11-dev \
        python3.13 python3.13-venv python3.13-dev \
        python3-pip && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.13 2 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.13 2 && \
    rm -rf /var/lib/apt/lists/*

# ─── Symlink EGL/GL libs to standard path for PyQt6 dlopen ───
RUN ln -sf /usr/lib/aarch64-linux-gnu/libEGL.so.1 /usr/lib/libEGL.so.1 && \
    ln -sf /usr/lib/aarch64-linux-gnu/libGL.so.1 /usr/lib/libGL.so.1 && \
    ln -sf /usr/lib/aarch64-linux-gnu/libGLX.so.0 /usr/lib/libGLX.so.0 && \
    ln -sf /usr/lib/aarch64-linux-gnu/libGLdispatch.so.0 /usr/lib/libGLdispatch.so.0 && \
    ldconfig

# ─── Node.js 22 ───
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# ─── GitHub Actions Runner ───
# Allow runner to use sudo without password (required by GitHub Actions workflows)
RUN echo "runner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

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

# ─── Persistent caches ───
RUN mkdir -p /home/runner/.cache/pip \
             /home/runner/.npm && \
    chown -R runner:runner /home/runner

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER runner

ENTRYPOINT ["/entrypoint.sh"]
