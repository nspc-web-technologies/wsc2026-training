FROM php:8.4-apache

# Install system dependencies required for PHP extensions
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    curl \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions (mbstring, curl are already built-in)
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        gd \
        zip \
        opcache

# Install Composer globally
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Enable Apache mod_rewrite for Laravel routing
RUN a2enmod rewrite

# Configure OPcache for performance
RUN echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.memory_consumption=64" >> /usr/local/etc/php/conf.d/opcache.ini

# Copy custom PHP configuration
COPY php.ini /usr/local/etc/php/conf.d/custom.ini

WORKDIR /var/www/html

# Create default phpinfo page
RUN echo '<?php phpinfo();' > /var/www/html/phpinfo.php
