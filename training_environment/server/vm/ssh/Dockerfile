FROM lscr.io/linuxserver/openssh-server:latest

# Install PHP and extensions to match the Apache container
RUN apk add --no-cache \
    php84 \
    php84-phar \
    php84-mbstring \
    php84-openssl \
    php84-curl \
    php84-dom \
    php84-xml \
    php84-xmlwriter \
    php84-tokenizer \
    php84-session \
    php84-ctype \
    php84-fileinfo \
    php84-pdo \
    php84-pdo_mysql \
    php84-gd \
    php84-zip \
    php84-iconv \
    php84-simplexml \
    php84-xmlreader \
    composer \
    git \
    curl \
    unzip

# Create symlink so "php" command works
RUN ln -sf /usr/bin/php84 /usr/bin/php
