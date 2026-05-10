FROM alpine:latest AS builder

RUN apk add --no-cache bash tar xz curl

WORKDIR /build

COPY src/device/ ./device/

ENV NHSYSTEM=/data/local/nhsystem
ENV NH_VERSION=2.0.0

FROM alpine:latest

RUN apk add --no-cache bash curl wget tmux zsh nano openssh

COPY --from=builder /build/device/bin/nh-* /usr/local/bin/
COPY --from=builder /build/device/dotfiles/.nanorc /root/
COPY --from=builder /build/device/dotfiles/.zshrc /root/
COPY src/scripts/ /usr/local/lib/nh-scripts/

RUN mkdir -p /data/local/nhsystem/{bin,etc,logs,tmp,backups,var/run,roots,workspaces/main} && \
    chmod +x /usr/local/bin/nh-*

ENV NHSYSTEM=/data/local/nhsystem
ENV NH_VERSION=2.0.0

CMD ["bash"]
