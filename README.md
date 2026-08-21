# Softavis PHP CLI images

Docker images for local PHP development and disposable project commands.

## What's included

Each image contains:

- PHP CLI
- Composer
- Symfony CLI
- Laravel installer
- Git, curl, zip, and unzip

## Usage

```bash
docker run --rm softavis/php:8.4
docker run --rm -v "$PWD:/app" -w /app softavis/php:8.4 composer create-project symfony/skeleton .
docker run --rm -v "$PWD:/app" -w /app softavis/php:8.4 symfony new my-project
docker run --rm -v "$PWD:/app" -w /app softavis/php:8.4 laravel new my-project
```

## Make targets

Equivalent Make targets are available:

```bash
make symfony ARGS="new my-project"
make composer ARGS="install"
make laravel ARGS="new my-project"
```

## Shell aliases

These aliases keep the current directory mounted so generated projects and
Composer files remain on the host:

```bash
alias php='docker run --rm -v "$PWD:/app" -w /app softavis/php:8.4 php'
alias composer='docker run --rm -v "$PWD:/app" -w /app softavis/php:8.4 composer'
alias symfony='docker run --rm -v "$PWD:/app" -w /app softavis/php:8.4 symfony'
alias laravel='docker run --rm -v "$PWD:/app" -w /app softavis/php:8.4 laravel'
```

## Available tags

Tags are published from the GitHub Actions matrix for PHP versions `7.3`
through `8.5`.

Images are published as:

- `softavis/php:<php-version>`
- `softavis/php:<php-version>-<commit-sha>`

## GitHub Actions setup

Create these repository secrets before the first push:

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN` (Docker Hub access token, not account password)
