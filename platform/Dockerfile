FROM python:3.11-slim AS builder
WORKDIR /build
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

FROM python:3.11-slim
LABEL org.opencontainers.image.title="OmniSec ULTIMATE"
LABEL org.opencontainers.image.description="AI-native, offline-only cybersecurity platform"
LABEL org.opencontainers.image.version="3.0.0"
LABEL org.opencontainers.image.licenses="MIT"

RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1-mesa-glx libglib2.0-0 libxkbcommon-x11-0 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /root/.local /root/.local
COPY . /app
WORKDIR /app

ENV PATH=/root/.local/bin:$PATH
ENV DISPLAY=${DISPLAY:-:0}

ENTRYPOINT ["python3", "-m", "omnisec_desktop.main"]
CMD ["gui"]
