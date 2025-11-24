FROM node:24.11.0-bookworm-slim AS node
FROM debian:trixie-20251020-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    # default-libmysqlclient-dev \
    libpcre2-dev \
    libpq-dev \
    pkg-config \
    unzip \
    xz-utils \
    zip

RUN apt-get clean && apt-get purge && apt-get autoremove --purge -y && \
    rm -rf /var/lib/apt/lists/*

ARG ZIG_VERSION="0.15.2"
RUN curl -sSL -O https://ziglang.org/download/${ZIG_VERSION}/zig-x86_64-linux-${ZIG_VERSION}.tar.xz && \
    tar Jxf zig-x86_64-linux-${ZIG_VERSION}.tar.xz -C /usr/local && \
    mv /usr/local/zig-x86_64-linux-${ZIG_VERSION} /usr/local/zig && \
    rm -rf zig-x86_64-linux-${ZIG_VERSION}.tar.xz
RUN chown -R root:root /usr/local/zig && \
    rm -rf /usr/local/zig/.git
ENV PATH="${PATH}:/usr/local/zig"
ENV ZIG_LOCAL_CACHE_DIR="/tmp"

ENV BUN_INSTALL="/usr/local"
RUN curl -fsSL https://bun.sh/install | bash -s "bun-v1.3.2"

# Node.js インストール
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /usr/local/bin/node /usr/local/bin/nodejs \
  && ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
  && ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npx

RUN bunx playwright install --with-deps

WORKDIR /usr/src/app
