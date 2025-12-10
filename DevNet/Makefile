SHELL=/bin/bash

UID := $(shell id -u)
GIT_ROOT := $(shell git rev-parse --show-toplevel)
CURRENT_DIR := $(shell pwd)

.PHONY: init lint docs clean

init:
	@pre-commit install

lint:
	@docker run --rm --workdir /workdir --volume "$(GIT_ROOT):/workdir" -u $(UID) -e "HOME=/tmp" quay.io/helmpack/chart-testing:v3.13.0 sh -ac 'chown ${UID} .; exec ct lint --target-branch main'

docs:
	@docker run --rm --volume "$(GIT_ROOT):/helm-docs" -u $(UID) jnorwood/helm-docs:v1.5.0

clean:
	@pre-commit uninstall