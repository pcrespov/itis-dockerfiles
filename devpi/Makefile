PREDEFINED_VARIABLES := $(.VARIABLES)

DOCKER_REPO        = itisfoundation
APP_NAME           = $(notdir $(PWD))
DOCKER_IMAGE_NAME  = $(DOCKER_REPO)/$(APP_NAME)
DOCKER_IMAGE_VERSION_FULL = $(shell cat VERSION)
DOCKER_IMAGE_VERSION_TWO_DIGITS = $(shell cat VERSION | grep -Eo '^([0-9]+)\.([0-9])+')
DOCKER_IMAGE_VERSION_FIRST_DIGIT = $(shell cat VERSION | grep -Eo '^([0-9]+)')
DOCKER_IMAGE_TAG_COMMIT = $(shell git rev-parse HEAD)

TMPPREFIX := /tmp/$(APP_NAME)
TMPDIR    := $(strip $(shell mktemp -d $(TMPPREFIX)-XXXXX))

# Environments (affect docker-compose.yml)
export VCS_URL    := $(shell git config --get remote.origin.url)
export VCS_REF    := $(shell git rev-parse --short HEAD)
export BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
export DOCKER_REPO := $(DOCKER_REPO)
export DEVPI-SERVER_VERSION  := $(shell grep -Eo "devpi-server==[0-9]+\.[0-9]+\.[0-9]" Dockerfile | grep -Eo "[0-9]+\.[0-9]+\.[0-9]")
export DEVPI-WEB_VERSION  := $(shell grep -Eo "devpi-web==[0-9]+\.[0-9]+\.[0-9]" Dockerfile | grep -Eo "[0-9]+\.[0-9]+\.[0-9]")
export DEVPI-CLIENT_VERSION  := $(shell grep -Eo "devpi-client==[0-9]+\.[0-9]+\.[0-9]" Dockerfile | grep -Eo "[0-9]+\.[0-9]+\.[0-9]")
export DEVPI-CLEANER_VERSION  := $(shell grep -Eo "devpi-cleaner==[0-9]+\.[0-9]+\.[0-9]" Dockerfile | grep -Eo "[0-9]+\.[0-9]+\.[0-9]")
export DEVPI-LDAP_VERSION  := $(shell grep -Eo "devpi-ldap==[0-9]+\.[0-9]+\.[0-9]" Dockerfile | grep -Eo "[0-9]+\.[0-9]+\.[0-9]")




.PHONY: help
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
 
.DEFAULT_GOAL := help

# Build the container
.PHONY: build build-nc

build:  ## Build the container
	docker-compose build $(APP_NAME) 

build-nc:  ## Build the container without caching
	docker-compose build --no-cache $(APP_NAME)

.PHONY: test
test: .check_version ## Run the tests 
	@echo "We don't have test here yet"

.PHONY: up  down
up: ## Launch the container
	docker-compose up

down: ## Stop the container
	docker-compose down

# Docker tagging
.PHONY: tag 
tag: ## Generate the differents tags from the version. For example 1.2.5 will generate the tags 1, 1.2 and 1.2.5 plus the hash commit.
	docker tag $(DOCKER_IMAGE_NAME):latest $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION_FULL)
	docker tag $(DOCKER_IMAGE_NAME):latest $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION_TWO_DIGITS)
	docker tag $(DOCKER_IMAGE_NAME):latest $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION_FIRST_DIGIT)
	docker tag $(DOCKER_IMAGE_NAME):latest $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG_COMMIT)


# Docker publish
.PHONY: release .check_version ## Build, add tags and push everything to ECR
release: .check_version build tag 
	docker push $(DOCKER_IMAGE_NAME):latest
	docker push $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION_FULL)
	docker push $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION_TWO_DIGITS)
	docker push $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION_FIRST_DIGIT)
	docker push $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG_COMMIT)

.check_version: # Check if the current version of the app is > to the repository version.
	 ./../check_versions.sh $(DOCKER_IMAGE_VERSION_FULL) $(DOCKER_REPO) $(APP_NAME)

# Misc tools
.PHONY: info
info: ## Shows info
	# Labels in `$(DOCKER_IMAGE_NAME):lastbuild` image (metadata)
	@docker image inspect $(DOCKER_IMAGE_NAME):latest | jq .[0].ContainerConfig.Labels
	# Tagged images 
	@docker images $(DOCKER_IMAGE_NAME)*:*


.PHONY: clean clean-images .check_clean
clean: .check_clean ## Cleans unversioned files/foldersm remove all temporary foleds and close docker compose.
	# cleans unversioned
	@git clean -Xdf
	# removes all temporary folders
	@-rm -rf $(wildcard $(TMPPREFIX)*)
	# cleans close docker-compose
	@-docker-compose down

clean-images: .check_clean ## Remove all images concerning the current app
	$(shell docker rmi -f $$(docker images |grep $(DOCKER_IMAGE_NAME)))

.check_clean:
	@echo -n "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
