FROM mysql:8.0.44-bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update

RUN apt install -y --no-install-recommends \
      procps \
      vim

RUN rm -rf /var/lib/apt/lists/*

COPY my.cnf /etc/mysql/my.cnf
