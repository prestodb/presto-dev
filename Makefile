ORG ?= unidevel
DOCKER_CMD ?= $(shell if podman info > /dev/null 2>&1; then echo podman; else echo docker; fi)
CLEAN_CACHE ?= false
NUM_THREADS ?= 3
VERSION ?= $(shell grep -m 1 '^    <version>' ../pom.xml | sed -e 's/.*<version>\([^<]*\)<\/version>.*/\1/' -e 's/-SNAPSHOT//')
COMMIT_ID ?= $(shell git -C .. rev-parse --short HEAD)
TIMESTAMP ?= $(shell date '+%Y%m%d%H%M%S')
VELOX_SCRIPT_PATCH ?= scripts/velox-script.patch

.PHONY: centos-dep ubuntu-dep centos-cpp-dev ubuntu-cpp-dev centos-java-dev ubuntu-java-dev \
	centos-dev ubuntu-dev release-prepare release-publish pull-centos pull-ubuntu \
	latest-centos latest-ubuntu start-centos start-ubuntu stop-centos stop-ubuntu \
	start stop info shell-centos shell-ubuntu shell prepare-home pull \
	centos-update-ccache ubuntu-update-ccache down down-centos down-ubuntu

default: start shell

centos-dep:
	@cd ../presto-native-execution && \
		make submodules && \
		if [ -f "../presto-dev/$(VELOX_SCRIPT_PATCH)" ]; then \
			(cd velox && git stash && patch -p1 < "../../presto-dev/$(VELOX_SCRIPT_PATCH)") \
		fi && \
		$(DOCKER_CMD) compose build centos-native-dependency

ubuntu-dep:
	@cd ../presto-native-execution && \
		make submodules && \
		if [ -f "../presto-dev/$(VELOX_SCRIPT_PATCH)" ]; then \
			(cd velox && git stash && patch -p1 < "../../presto-dev/$(VELOX_SCRIPT_PATCH)") \
		fi && \
		$(DOCKER_CMD) compose build ubuntu-native-dependency

centos-cpp-dev:
	$(DOCKER_CMD) compose build --build-arg CLEAN_CACHE=$(CLEAN_CACHE) --build-arg NUM_THREADS=$(NUM_THREADS) centos-cpp-dev

ubuntu-cpp-dev:
	$(DOCKER_CMD) compose build --build-arg CLEAN_CACHE=$(CLEAN_CACHE) --build-arg NUM_THREADS=$(NUM_THREADS) ubuntu-cpp-dev

centos-java-dev:
	$(DOCKER_CMD) compose build centos-java-dev

ubuntu-java-dev:
	$(DOCKER_CMD) compose build ubuntu-java-dev

centos-dev:
	$(DOCKER_CMD) compose build centos-dev

ubuntu-dev:
	$(DOCKER_CMD) compose build ubuntu-dev

centos-update-ccache:
	$(DOCKER_CMD) tag docker.io/presto/presto-dev:centos9 docker.io/presto/presto-dev:centos-$(TIMESTAMP)
	$(DOCKER_CMD) compose build --build-arg CLEAN_CACHE=$(CLEAN_CACHE) \
		--build-arg NUM_THREADS=$(NUM_THREADS) \
		--build-arg CACHE_OPTION=update \
		--build-arg DEPENDENCY_IMAGE=presto/presto-dev:centos-$(TIMESTAMP) centos-cpp-dev
	$(DOCKER_CMD) tag docker.io/presto/presto-cpp-dev:centos9 docker.io/presto/presto-dev:centos9

ubuntu-update-ccache:
	$(DOCKER_CMD) tag docker.io/presto/presto-dev:ubuntu-22.04 docker.io/presto/presto-dev:ubuntu-$(TIMESTAMP)
	$(DOCKER_CMD) compose build --build-arg CLEAN_CACHE=$(CLEAN_CACHE) \
		--build-arg NUM_THREADS=$(NUM_THREADS) \
		--build-arg CACHE_OPTION=update \
		--build-arg DEPENDENCY_IMAGE=presto/presto-dev:ubuntu-$(TIMESTAMP) ubuntu-cpp-dev
	$(DOCKER_CMD) tag docker.io/presto/presto-cpp-dev:ubuntu-22.04 docker.io/presto/presto-cpp-dev:ubuntu-22.04

release-prepare:
	ORG=$(ORG) DOCKER_CMD=$(DOCKER_CMD) ./scripts/release.sh prepare

release-publish:
	ORG=$(ORG) DOCKER_CMD=$(DOCKER_CMD) ./scripts/release.sh publish

pull-centos:
	$(DOCKER_CMD) pull ${ORG}/presto-dev:latest-centos
	$(DOCKER_CMD) tag ${ORG}/presto-dev:latest-centos docker.io/presto/presto-dev:centos9

pull-ubuntu:
	$(DOCKER_CMD) pull ${ORG}/presto-dev:latest-ubuntu
	$(DOCKER_CMD) tag ${ORG}/presto-dev:latest-ubuntu docker.io/presto/presto-dev:ubuntu-22.04

latest-centos:
	ORG=$(ORG) DOCKER_CMD=$(DOCKER_CMD) ./scripts/release.sh manifest centos

latest-ubuntu:
	ORG=$(ORG) DOCKER_CMD=$(DOCKER_CMD) ./scripts/release.sh manifest ubuntu

prepare-home:
	@if [ ! -f "../.vscode/launch.json" ]; then \
		mkdir -p ../.vscode && cp ./launch.json ../.vscode/launch.json; \
	fi; \
	if [ ! -f root/.ssh/id_rsa ]; then \
		mkdir -p root/.ssh && cp $(HOME)/.ssh/authorized_keys root/.ssh/authorized_keys && \
		chmod 644 root/.ssh/authorized_keys; \
	fi; \
	test -e root/.m2 || test -L root/.m2 || ln -sfn /opt/cache/.m2 ./root/.m2; \
	test -e root/.ccache || test -L root/.ccache || ln -sfn /opt/cache/.ccache ./root/.ccache; \
	test -e root/.cache || test -L root/.cache || ln -sfn /opt/cache/.cache ./root/.cache;

start-centos: prepare-home
	@if [ -z "$$($(DOCKER_CMD) images -q presto/presto-dev:centos9)" ]; then \
		echo "Image not found locally. Pulling..."; \
		make pull-centos; \
	fi
	${DOCKER_CMD} compose up centos-dev -d
	${DOCKER_CMD} ps | grep presto-dev

start-ubuntu: prepare-home
	@if [ -z "$$($(DOCKER_CMD) images -q presto/presto-dev:ubuntu-22.04)" ]; then \
		echo "Image not found locally. Pulling..."; \
		make pull-ubuntu; \
	fi
	${DOCKER_CMD} compose up ubuntu-dev -d
	${DOCKER_CMD} ps | grep presto-dev

down-centos:
	${DOCKER_CMD} compose down centos-dev

down-ubuntu:
	${DOCKER_CMD} compose down ubuntu-dev

stop-centos:
	${DOCKER_CMD} compose stop centos-dev

stop-ubuntu:
	${DOCKER_CMD} compose stop ubuntu-dev

shell-centos:
	${DOCKER_CMD} compose exec centos-dev bash

shell-ubuntu:
	${DOCKER_CMD} compose exec ubuntu-dev bash

start: start-centos

stop: stop-centos

down: down-centos

shell: shell-centos

pull: pull-centos

info:
	@echo ${DOCKER_CMD} ${ORG} ${VERSION} ${COMMIT_ID}
