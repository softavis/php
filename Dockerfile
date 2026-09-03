ARG PHP_VERSION=8.4
ARG NODE_VERSION=22
ARG COMPOSER_VERSION=latest

FROM composer:${COMPOSER_VERSION} AS composer

FROM node:${NODE_VERSION}-bookworm-slim AS node

FROM php:${PHP_VERSION}-cli

ARG PHP_VERSION

LABEL org.opencontainers.image.title="Softavis PHP CLI"
LABEL org.opencontainers.image.description="PHP CLI with Composer, Node.js, Symfony CLI and Laravel installer"
LABEL org.opencontainers.image.source="https://github.com/softavis/php"
LABEL org.opencontainers.image.version="${PHP_VERSION}"

ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_HOME=/usr/local/share/composer \
    PATH="/usr/local/share/composer/vendor/bin:${PATH}"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# PHP 7.3 may still use archived Debian Buster repositories.
RUN set -eux; \
    . /etc/os-release; \
    case "${VERSION_CODENAME:-}" in \
        buster) \
            sed -i -E \
                's|deb.debian.org/debian|archive.debian.org/debian|g; s|security.debian.org/debian-security|archive.debian.org/debian-security|g' \
                /etc/apt/sources.list; \
            sed -i -E '/buster-updates/d' /etc/apt/sources.list; \
            printf 'Acquire::Check-Valid-Until "false";\n' \
                > /etc/apt/apt.conf.d/99archive; \
            ;; \
    esac; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        $PHPIZE_DEPS \
        ca-certificates \
        curl \
        git \
        unzip \
        zip \
        libcurl4-openssl-dev \
        libicu-dev \
        libonig-dev \
        libpq-dev \
        libsqlite3-dev \
        libzip-dev; \
    docker-php-ext-install -j"$(nproc)" \
        bcmath \
        curl \
        intl \
        mbstring \
        pcntl \
        pdo_mysql \
        pdo_pgsql \
        pdo_sqlite \
        sockets \
        zip; \
    case "${PHP_VERSION}" in \
        7.3*) REDIS_VERSION="5.3.7" ;; \
        *)    REDIS_VERSION="6.3.0" ;; \
    esac; \
    pecl install "redis-${REDIS_VERSION}"; \
    docker-php-ext-enable redis; \
    pecl clear-cache; \
    rm -rf /var/lib/apt/lists/*

COPY --from=composer /usr/bin/composer /usr/local/bin/composer

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules

RUN set -eux; \
    ln -s ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm; \
    ln -s ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx; \
    node --version; \
    npm --version

RUN set -eux; \
    composer --version; \
    curl -1sLf https://get.symfony.com/cli/installer | bash; \
    install -m 0755 /root/.symfony5/bin/symfony /usr/local/bin/symfony; \
    symfony version

RUN set -eux; \
    composer global require \
        laravel/installer \
        --no-interaction \
        --no-progress \
        --prefer-dist; \
    composer clear-cache; \
    laravel --version

# Runtime configuration for arbitrary host UID/GID.
ENV HOME=/tmp \
    XDG_CONFIG_HOME=/tmp/.config \
    COMPOSER_HOME=/tmp/composer \
    COMPOSER_CACHE_DIR=/tmp/composer/cache

WORKDIR /app

CMD ["php", "-v"]
