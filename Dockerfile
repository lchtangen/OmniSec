FROM debian:bookworm-slim AS base

LABEL maintainer="nethunter-setup"
LABEL description="NetHunter setup build and deploy environment"
LABEL version="2.0.0"

ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/bin/bash
ENV ANDROID_HOME=/opt/android-sdk

RUN apt-get update -qq && apt-get install -y -qq --no-install-recommends \
    adb \
    bash \
    build-essential \
    ca-certificates \
    clang \
    cmake \
    curl \
    file \
    gcc \
    git \
    gnupg \
    jq \
    libc6-dev \
    libusb-1.0-0-dev \
    make \
    openssh-client \
    python3 \
    python3-pip \
    rsync \
    shellcheck \
    ssh-client \
    sudo \
    tar \
    time \
    udev \
    unzip \
    vim-tiny \
    wget \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --break-system-packages --quiet \
    jsonlint \
    yamllint

RUN mkdir -p /opt/android-sdk && \
    wget -q https://github.com/termux/termux-app/releases/latest -O /dev/null 2>/dev/null || true

RUN echo 'ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="4ee7", MODE="0666", GROUP="plugdev"' > /etc/udev/rules.d/51-android.rules && \
    echo 'ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="2a70", MODE="0666", GROUP="plugdev"' >> /etc/udev/rules.d/51-android.rules

COPY udev/99-adb.rules /etc/udev/rules.d/99-adb.rules

WORKDIR /workspace

COPY . .

RUN chmod +x nhctl scripts/*.sh payload/*.sh payload/nhsystem-bin/nh-* 2>/dev/null || true

RUN bash -n nhctl && \
    bash -n nh-defaults.sh && \
    for f in payload/*.sh; do bash -n "$f"; done && \
    for f in payload/nhsystem-bin/nh-*; do bash -n "$f"; done && \
    echo "  syntax check: OK"

FROM base AS builder
RUN mkdir -p /workspace/build && \
    gcc -Wall -Wextra -Os -o /workspace/build/nh-sudo /workspace/payload/nh-sudo.c -static -s && \
    gcc -Wall -Wextra -shared -fPIC -o /workspace/build/no-close-range.so /workspace/payload/no-close-range.c -nostartfiles && \
    echo "  C build: OK"

FROM base
COPY --from=builder /workspace/build /workspace/build
CMD ["bash"]
