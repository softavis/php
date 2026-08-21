Softavis PHP CLI images

PHP CLI images for local development and disposable project commands. Every
image contains:

PHP CLI

Composer

Symfony CLI

Laravel installer

Git, curl, zip and unzip

Usage

docker run --rm softavis/php:8.4
docker run --rm -v "$PWD:/app" -w /app softavis/php:8.4 composer create-project symfony/skeleton .
docker run --rm -v "$PWD:/app" -w /app softavis/php:8.4 symfony new my-project
docker run --rm -v "$PWD:/app" -w /app softavis/php:8.4 laravel new my-project

Equivalent Make targets are available:

make symfony ARGS="new my-project"
make composer ARGS="install"
make laravel ARGS="new my-project"

For dotfiles, these aliases keep the current directory mounted so generated
projects and Composer files remain on the host:

alias php='docker run --rm -v "$PWD:/app" -w /app softavis/php:8.4 php'
alias composer='docker run --rm -v "$PWD:/app" -w /app softavis/php:8.4 composer'
alias symfony='docker run --rm -v "$PWD:/app" -w /app softavis/php:8.4 symfony'
alias laravel='docker run --rm -v "$PWD:/app" -w /app softavis/php:8.4 laravel'

Available tags are published by the GitHub Actions matrix for PHP 7.1 through
8.5. PHP versions below 7.2.5 use Composer 2.2 LTS for compatibility.

GitHub Actions setup

Create these repository secrets before the first push:

DOCKERHUB_USERNAME

DOCKERHUB_TOKEN — a Docker Hub access token, not the account password

The workflow publishes to softavis/php:<php-version> and also publishes a
commit-specific tag for traceability.
