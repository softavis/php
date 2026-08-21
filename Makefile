PHP_VERSION ?= 8.4
IMAGE ?= softavis/php:$(PHP_VERSION)

.PHONY: build run php composer symfony laravel

build:
	docker build --build-arg PHP_VERSION=$(PHP_VERSION) -t $(IMAGE) .

run:
	docker run --rm -it -v "$(PWD):/app" -w /app $(IMAGE) bash

php:
	docker run --rm -v "$(PWD):/app" -w /app $(IMAGE) php $(ARGS)

composer:
	docker run --rm -v "$(PWD):/app" -w /app $(IMAGE) composer $(ARGS)

symfony:
	docker run --rm -v "$(PWD):/app" -w /app $(IMAGE) symfony $(ARGS)

laravel:
	docker run --rm -v "$(PWD):/app" -w /app $(IMAGE) laravel $(ARGS)
