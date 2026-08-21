ARG PHP_VERSION=8.4

FROM php:${PHP_VERSION}-cli

ARG PHP_VERSION
ARG COMPOSER_VERSION=latest

LABEL org.opencontainers.image.title="Softavis PHP CLI"
LABEL org.opencontainers.image.description="PHP CLI with Composer, Symfony CLI and Laravel installer"
LABEL org.opencontainers.image.source="https://github.com/softavis/php"

ENV HOME=/tmp \
    XDG_CONFIG_HOME=/tmp/.config \
    COMPOSER_HOME=/tmp/composer \
    COMPOSER_HOME=/usr/local/share/composer \
    PATH="/usr/local/share/composer/vendor/bin:/root/.composer/vendor/bin:${PATH}"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# PHP 7.1 uses an archived Debian release. Keep the legacy image buildable
# while using the normal Debian mirrors for supported PHP versions.
RUN set -eux; \
    if grep -qE 'stretch|jessie' /etc/os-release; then \
        sed -i -E 's|deb.debian.org/debian|archive.debian.org/debian|g; s|security.debian.org/debian-security|archive.debian.org/debian-security|g' /etc/apt/sources.list; \
        printf 'Acquire::Check-Valid-Until "false";\n' > /etc/apt/apt.conf.d/99archive; \
    fi; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        unzip \
        zip; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    if php -r 'exit(version_compare(PHP_VERSION, "7.2.5", "<") ? 0 : 1);'; then \
        curl -fsSL "https://getcomposer.org/download/2.2.25/composer.phar" -o /usr/local/bin/composer; \
    elif [ "${COMPOSER_VERSION}" = "latest" ]; then \
        curl -fsSL https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer; \
    else \
        curl -fsSL "https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar" -o /usr/local/bin/composer; \
    fi; \
    chmod +x /usr/local/bin/composer; \
    composer --version

# Symfony CLI is independent of the PHP version and installs as a standalone binary.
RUN set -eux; \
    curl -1sLf 'https://get.symfony.com/cli/installer' | bash; \
    install -m 0755 "$(find /root -type f -path '*/.symfony*/bin/symfony' -print -quit)" /usr/local/bin/symfony; \
    symfony version

# Composer selects the newest Laravel installer release compatible with the
# PHP version in the image. This keeps the legacy matrix entries buildable.
RUN set -eux; \
    mkdir -p "${COMPOSER_HOME}"; \
    composer global require laravel/installer --no-interaction --no-progress --prefer-dist; \
    php -r 'echo "PHP ", PHP_VERSION, " ready\n";'; \
    laravel --version

WORKDIR /app

CMD ["php", "-v"]
