FROM dunglas/frankenphp:latest

#dossier dans lequel on travail
WORKDIR /app

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Configuration PHP
COPY Docker/frankenphp/config/custom.ini /usr/local/etc/php/conf.d/custom.ini

# Extensions PHP
RUN install-php-extensions \
    pdo_mysql \
    intl \
    opcache \
    zip \
    gd \
    exif \
    apcu \
    xml

# Copie de l'application pour PROD
COPY ./App /app

# Installation de l'application
RUN composer install

# Configuration Caddy
COPY Docker/frankenphp/Caddyfile /etc/caddy/Caddyfile

EXPOSE 80 443