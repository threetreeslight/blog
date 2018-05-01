FROM debian:latest

ENV HUGO_VERSION 0.40.1
RUN apt-get update \
  && apt-get install -y --no-install-recommends curl ca-certificates procps \
  && curl -L https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz -o /tmp/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz \
  && cd /tmp \
  && tar xvzf /tmp/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz \
  && mv /tmp/hugo /usr/local/bin \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/*

WORKDIR /site
