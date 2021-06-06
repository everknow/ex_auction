# grep the version from the mix file
COMMIT := $(shell git rev-parse --short HEAD)
PROJECT := rart-temp

NAME := ex_auction
FULL_NAME := gcr.io/${PROJECT}/${NAME}

.PHONY: build

# Build the container
build: ## Build the release and develoment container. The development
	docker build -t ${NAME}:dev .

tag:
	docker tag ${NAME}:dev ${FULL_NAME}:${COMMIT}
	docker tag ${NAME}:dev ${FULL_NAME}:latest

push: 
	docker push gcr.io/${PROJECT}/${NAME}:${COMMIT}
	docker push gcr.io/${PROJECT}/${NAME}:latest

show_tag:
	@echo "Latest commit: *${COMMIT}*"
