PROJECT ?= piraeus-client
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
		docker buildx build $(_EXTRA_ARGS) --build-arg LINSTOR_CLIENT_VERSION=$$LINSTOR_CLIENT_VERSION \
			--build-arg PYTHON_LINSTOR_VERSION=$$PYTHON_LINSTOR_VERSION \
			--no-cache=$(NOCACHE) --platform=$(PLATFORMS) \
			--tag $$r/$(PROJECT):v$$LINSTOR_CLIENT_VERSION \
			--tag $$r/$(PROJECT):v$$SHORT_VERSION \
			--tag $$r/$(PROJECT):latest . ;\
	done

.PHONY: upload
upload:
	make update _EXTRA_ARGS=--push
