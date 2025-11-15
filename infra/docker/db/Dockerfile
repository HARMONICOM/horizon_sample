FROM postgres:17.5-bookworm

ENV DEBIAN_FRONTEND noninteractive

RUN apt update

RUN apt install -y --no-install-recommends \
      procps \
      vim

RUN rm -rf /var/lib/apt/lists/*

COPY postgresql.conf /etc/postgresql/postgresql.conf

CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
