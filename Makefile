# grep the version from the mix file
COMMIT := $(shell git rev-parse --short HEAD)
PROJECT := reasoned-project-01

NAME := ex_auction
FULL_NAME := gcr.io/${PROJECT}/${NAME}

.PHONY: build

# Build the container
build: ## Build the release and develoment container.
	@ echo "Building image ..."
	@ docker build -t ${NAME}:dev .

tag:
	@ echo "Tagging with *${COMMIT}*"
	@ docker tag ${NAME}:dev ${FULL_NAME}:${COMMIT}
	@ echo "Tagging with *latest*"
	@ docker tag ${NAME}:dev ${FULL_NAME}:latest

push: 
	docker push gcr.io/${PROJECT}/${NAME}:${COMMIT}
	docker push gcr.io/${PROJECT}/${NAME}:latest

all: build tag push

show_commit_hash:
	@echo "Latest commit: *${COMMIT}*"
