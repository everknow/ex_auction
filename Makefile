# grep the version from the mix file
COMMIT := $(shell git rev-parse --short HEAD)
PRIVATE_KEY := "$(shell cat ${HOME}/.ssh/id_rsa)"
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

full-deployment: build tag push

verify-static-ips:
	@ echo "List of existing static ips:"
	@ gcloud compute addresses list

show_commit_hash:
	@echo "Latest commit: *${COMMIT}*"
