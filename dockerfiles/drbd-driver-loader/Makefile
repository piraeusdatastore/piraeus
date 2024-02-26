PROJECT ?= drbd9
DF = Dockerfile.centos7 Dockerfile.almalinux8 Dockerfile.almalinux9 Dockerfile.centos8 Dockerfile.bionic Dockerfile.focal Dockerfile.jammy Dockerfile.bullseye Dockerfile.buster Dockerfile.bookworm
REGISTRY ?= piraeusdatastore
NOCACHE ?= false
PLATFORMS ?= linux/amd64,linux/arm64

help:
	@echo "Useful targets: 'update', 'upload'"

all: update upload

.PHONY: update
update:
	for version_env in ./VERSION*.env ; do \
		. $$version_env ; \
		for r in $(REGISTRY); do \
			for f in $(DF); do \
				pd=$(PROJECT)-$$(echo $$f | sed 's/^Dockerfile\.//'); \
				docker buildx build $(_EXTRA_ARGS) --build-arg DRBD_VERSION=$$DRBD_VERSION --no-cache=$(NOCACHE) --platform=$(PLATFORMS) -f $$f \
					--tag $$r/$$pd:v$$DRBD_VERSION . ; \
			done; \
		done; \
	done

.PHONY: upload
upload:
	make update _EXTRA_ARGS=--push
