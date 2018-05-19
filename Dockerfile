FROM nginx:mainline-alpine

COPY ./public /usr/share/nginx/html
COPY ./nginx/blog.conf.tmpl /etc/nginx/conf.d/default.conf
COPY ./nginx/nginx.conf.tmpl /etc/nginx/nginx.conf
