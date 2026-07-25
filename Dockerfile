FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    gcc \
    make \
    vim \
    locales \
 && locale-gen en_US.UTF-8 \
 && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

WORKDIR /app
