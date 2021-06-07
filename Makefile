# grep the version from the mix file
COMMIT := $(shell git rev-parse --short HEAD)
PRIVATE_KEY := "$(shell cat ${HOME}/.ssh/id_rsa)"
PROJECT := reasoned-project-01

NAME := ex_auction
FULL_NAME := gcr.io/${PROJECT}/${NAME}

.PHONY: build

# Build the container
build: ## Build the release and develoment container.
	@ echo "Building image"
	@ SSH_PRIVATE_KEY=${PRIVATE_KEY} docker build -t ${NAME}:dev .

tag:
	docker tag ${NAME}:dev ${FULL_NAME}:${COMMIT}
	docker tag ${NAME}:dev ${FULL_NAME}:latest

push: 
	docker push gcr.io/${PROJECT}/${NAME}:${COMMIT}
	docker push gcr.io/${PROJECT}/${NAME}:latest

show_tag:
	@echo "Latest commit: *${COMMIT}*"
