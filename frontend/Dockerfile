# build
FROM node:16.20.0-alpine3.18 as builder
WORKDIR /usr/src/app
COPY . .
RUN npm install
RUN npm run build

FROM nginx:stable-alpine3.17-slim
RUN wget https://github.com/jwilder/docker-gen/releases/download/0.10.0/docker-gen-alpine-linux-amd64-0.10.0.tar.gz \
    && tar -xzf docker-gen-alpine-linux-amd64-0.10.0.tar.gz -C /usr/local/bin \
    && rm docker-gen-alpine-linux-amd64-0.10.0.tar.gz
COPY ./templates /etc/docker-gen/templates
COPY --from=builder /usr/src/app/dist/frontend /usr/share/nginx/html
EXPOSE 80
CMD ["sh", "-c", "docker-gen -watch -notify 'nginx -s reload' /etc/docker-gen/templates/default.conf.tmpl /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]