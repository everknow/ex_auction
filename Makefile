# grep the version from the mix file
COMMIT := $(shell git rev-parse --short HEAD)

NAME := ex_auction
FULL_NAME := gcr.io/rart-temp/${NAME}

.PHONY: build

# Build the container
build: ## Build the release and develoment container. The development
	docker build -t ${NAME}:dev .

tag:
	docker tag ${NAME}:dev ${FULL_NAME}:${COMMIT}
	docker tag ${NAME}:dev ${FULL_NAME}:latest

push: 
	docker push gcr.io/rart-temp/ex_auction:${COMMIT}
	docker push gcr.io/rart-temp/ex_auction:latest

show_tag:
	@echo "Latest commit: *${COMMIT}*"
