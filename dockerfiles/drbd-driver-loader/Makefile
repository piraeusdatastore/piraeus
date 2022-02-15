PROJECT ?= drbd9
DF = Dockerfile.centos7 Dockerfile.almalinux8 Dockerfile.centos8 Dockerfile.bionic Dockerfile.focal Dockerfile.flatcar
REGISTRY ?= piraeusdatastore
NOCACHE ?= false
PLATFORMS ?= linux/amd64,linux/arm64

help:
	@echo "Useful targets: 'update', 'upload'"

all: update upload

.PHONY: update
update:
	. ./VERSION.env ; \
	for r in $(REGISTRY); do \
		for f in $(DF); do \
			pd=$(PROJECT)-$$(echo $$f | sed 's/^Dockerfile\.//'); \
			docker buildx build $(_EXTRA_ARGS) --build-arg DRBD_VERSION=$$DRBD_VERSION --no-cache=$(NOCACHE) --platform=$(PLATFORMS) -f $$f \
				--tag $$r/$$pd:v$$DRBD_VERSION \
				--tag $$r/$$pd:latest . ; \
		done; \
	done

.PHONY: upload
upload:
	make update _EXTRA_ARGS=--push
