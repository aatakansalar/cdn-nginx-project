FROM openresty/openresty:1.21.4.1-1-alpine-fat

RUN apk add --no-cache \
    gd \
    gd-dev \
    geoip \
    geoip-dev \
    libxslt \
    libxslt-dev \
    openssl \
    openssl-dev \
    pcre-dev \
    zlib-dev \
    perl-dev \
    make \
    gcc \
    musl-dev \
    linux-headers \
    bash \
    curl \
    unzip \
    git \
    readline-dev \
    libedit-dev \
    libxml2-dev \
    libxslt-dev

RUN wget https://luarocks.org/releases/luarocks-3.9.2.tar.gz && \
    tar zxpf luarocks-3.9.2.tar.gz && \
    cd luarocks-3.9.2 && \
    ./configure --prefix=/usr/local/openresty/luajit \
        --with-lua=/usr/local/openresty/luajit \
        --lua-suffix=jit \
        --with-lua-include=/usr/local/openresty/luajit/include/luajit-2.1 && \
    make && make install && \
    cd .. && rm -rf luarocks*

ENV PATH="/usr/local/openresty/luajit/bin:$PATH"

RUN luarocks install lua-resty-redis
RUN luarocks install lua-resty-string
RUN luarocks install lua-resty-http
RUN luarocks install lua-resty-template
RUN luarocks install lua-resty-lrucache
RUN luarocks install lua-resty-lock
RUN luarocks install lua-resty-upload
RUN luarocks install lua-resty-openssl

RUN mkdir -p /var/log/nginx && \
    mkdir -p /var/cache/nginx/imgcache && \
    mkdir -p /usr/local/openresty/nginx/logs

RUN chmod -R 777 /var/log/nginx && \
    chmod -R 777 /var/cache/nginx && \
    chmod -R 777 /usr/local/openresty/nginx/logs && \
    chmod -R 777 /var/cache/nginx/imgcache/

COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY conf.d/ /etc/nginx/conf.d/
COPY lua/ /etc/nginx/lua/

EXPOSE 80

CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]
