FROM alpine:latest

RUN apk add --no-cache bash curl openssl cronie

WORKDIR /app

COPY preload_cache.sh .

COPY ./crontab /etc/crontabs/root

RUN chmod +x preload_cache.sh

CMD ["crond", "-f"]