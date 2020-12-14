PROJECT ?= drbd9
DF = Dockerfile.centos7 Dockerfile.centos8 Dockerfile.bionic Dockerfile.focal
DEFAULT_CENTOS = Dockerfile.centos7
REGISTRY ?= piraeusdatastore
NOCACHE ?= false

help:
	@echo "Useful targets: 'update', 'upload'"

all: update upload

.PHONY: update
update:
	. ./VERSION.env ; \
	for f in $(DF); do \
		pd=$(PROJECT)-$$(echo $$f | sed 's/^Dockerfile\.//'); \
		docker build --build-arg DRBD_VERSION=$$DRBD_VERSION --no-cache=$(NOCACHE) -f $$f -t $$pd:v$$DRBD_VERSION . ; \
		docker tag $$pd:v$$DRBD_VERSION $$pd:v$$SHORT_VERSION ; \
		docker tag $$pd:v$$DRBD_VERSION $$pd:latest ; \
	done

.PHONY: upload
upload:
	. ./VERSION.env ; \
	for r in $(REGISTRY); do \
		for f in $(DF); do \
			pd=$(PROJECT)-$$(echo $$f | sed 's/^Dockerfile\.//'); \
			docker tag $$pd:v$$DRBD_VERSION $$r/$$pd:v$$DRBD_VERSION ; \
			docker tag $$pd:v$$SHORT_VERSION $$r/$$pd:v$$SHORT_VERSION ; \
			docker tag $$pd:latest $$r/$$pd:latest ; \
			docker push $$r/$$pd:v$$DRBD_VERSION ; \
			docker push $$r/$$pd:v$$SHORT_VERSION ; \
			docker push $$r/$$pd:latest ; \
		done; \
	done
