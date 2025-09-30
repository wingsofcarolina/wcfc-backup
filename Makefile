APP_NAME := wcfc-backup
SHELL := /bin/bash

GOOGLE_CLOUD_REGION := us-central1
APP_VERSION := $(shell git describe --tags --dirty)
CONTAINER_TAG := $(GOOGLE_CLOUD_REGION)-docker.pkg.dev/wcfc-apps/wcfc-apps/$(APP_NAME):$(APP_VERSION)
DOCKER_FLAG_FILE_PREFIX := .docker-build
DOCKER_FLAG_FILE := $(DOCKER_FLAG_FILE_PREFIX)-$(APP_VERSION)

ifneq ($(shell which podman),)
	CONTAINER_CMD := podman
else
ifneq ($(shell which docker),)
	CONTAINER_CMD := docker
else
	CONTAINER_CMD := /bin/false  # force error when used
endif
endif

$(DOCKER_FLAG_FILE): Dockerfile backup.sh mongodb.repo
	$(CONTAINER_CMD) build . -t $(CONTAINER_TAG)
	@touch $(DOCKER_FLAG_FILE)

.PHONY: build
build: $(DOCKER_FLAG_FILE)

.PHONY: check-version-not-dirty
check-version-not-dirty:
	@if [[ "$(CONTAINER_TAG)" == *"dirty"* ]]; then echo Refusing to push dirty version; git status; exit 1; fi

.PHONY: push
push: check-version-not-dirty $(DOCKER_FLAG_FILE)
	@echo Pushing $(CONTAINER_TAG)...
	@$(CONTAINER_CMD) push $(CONTAINER_TAG)

.PHONY: deploy
deploy: check-version-not-dirty push
	@gcloud run jobs deploy $(APP_NAME) --image $(CONTAINER_TAG) --region $(GOOGLE_CLOUD_REGION)

PHONY: run
run: $(DOCKER_FLAG_FILE)
	@./scripts/run $(CONTAINER_TAG)

.PHONY: version
version:
	@echo $(APP_VERSION)

.PHONY: container-tag
container-tag:
	@echo $(CONTAINER_TAG)

.PHONY: clean
clean:
	rm -f $(DOCKER_FLAG_FILE_PREFIX)*

