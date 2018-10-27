FROM alpine:latest AS build
LABEL maintainer "threetreeslight"
LABEL Description="hugo docker image" Vendor="threetreeslight" Version="0.1"

ENV HUGO_VERSION 0.40.1

RUN apk update \
  && apk upgrade \
  && apk add --no-cache ca-certificates curl \
  && update-ca-certificates \
  && cd /tmp \
  && curl -L https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz -o ./hugo_${HUGO_VERSION}_Linux-64bit.tar.gz \
  && tar xvzf ./hugo_${HUGO_VERSION}_Linux-64bit.tar.gz \
  && mv /tmp/hugo /usr/local/bin \
  && rm -rf /var/cache/apk/* \
  && rm -rf /tmp/* /var/tmp/*

COPY ./blog /site
RUN cd /site && hugo


FROM nginx:mainline-alpine
LABEL maintainer "threetreeslight"
LABEL Description="threetreeslight's blog image" Vendor="threetreeslight" Version="0.1"

# install entrykit
ENV ENTRYKIT_VERSION 0.4.0
RUN apk add --no-cache --virtual build-dependencies curl tar \
  && curl -SLo entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz https://github.com/progrium/entrykit/releases/download/v${ENTRYKIT_VERSION}/entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
  && tar xvzf entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
  && rm entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
  && apk del --purge build-dependencies \
  && mv entrykit /bin/entrykit \
  && chmod +x /bin/entrykit \
  && entrykit --symlink

COPY --from=build /site/public /usr/share/nginx/html
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./nginx/blog.conf.tmpl /etc/nginx/conf.d/default.conf.tmpl

ENTRYPOINT [ \
  "render", "/etc/nginx/conf.d/default.conf", "--" \
  ]

CMD ["nginx", "-g", "daemon off;"]
