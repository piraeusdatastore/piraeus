PROJECT ?= piraeus-server
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
		docker buildx build $(_EXTRA_ARGS) --build-arg LINSTOR_VERSION=$$LINSTOR_VERSION \
			--build-arg K8S_AWAIT_ELECTION_VERSION=$$K8S_AWAIT_ELECTION_VERSION \
			--no-cache=$(NOCACHE) --platform=$(PLATFORMS) \
			--tag $$r/$(PROJECT):v$$LINSTOR_VERSION \
			--tag $$r/$(PROJECT):v$$SHORT_VERSION \
			--tag $$r/$(PROJECT):latest . ;\
	done

.PHONY: upload
upload:
	make update _EXTRA_ARGS=--push
