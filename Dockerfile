FROM debian

ENV HUGO_VERSION 0.20.2
ADD https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}-64bit.deb /tmp/hugo.deb
RUN dpkg -i /tmp/hugo.deb \
    && rm /tmp/hugo.deb

WORKDIR /app

EXPOSE 1313
