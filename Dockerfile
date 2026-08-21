ARG PHP_VERSION=8.4
ARG COMPOSER_VERSION=latest

FROM composer:${COMPOSER_VERSION} AS composer

FROM php:${PHP_VERSION}-cli

ARG PHP_VERSION

LABEL org.opencontainers.image.title="Softavis PHP CLI"
LABEL org.opencontainers.image.description="PHP CLI with Composer, Symfony CLI and Laravel installer"
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
        ca-certificates \
        curl \
        git \
        unzip \
        zip; \
    rm -rf /var/lib/apt/lists/*

COPY --from=composer /usr/bin/composer /usr/local/bin/composer

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
