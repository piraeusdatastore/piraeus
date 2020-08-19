PROJECT ?= piraeus-client
REGISTRY ?= piraeusdatastore
NOCACHE ?= false

help:
	@echo "Useful targets: 'update', 'upload'"

all: update upload

.PHONY: update
update:
	. ./VERSION.env ; \
	docker build --build-arg LINSTOR_CLIENT_VERSION=$$LINSTOR_CLIENT_VERSION --no-cache=$(NOCACHE) -t $(PROJECT):v$$LINSTOR_CLIENT_VERSION . ; \
	docker tag $(PROJECT):v$$LINSTOR_CLIENT_VERSION $(PROJECT):v$$SHORT_VERSION ; \
	docker tag $(PROJECT):v$$LINSTOR_CLIENT_VERSION $(PROJECT):latest

.PHONY: upload
upload:
	. ./VERSION.env ; \
	for r in $(REGISTRY); do \
		docker tag $(PROJECT):v$$LINSTOR_CLIENT_VERSION $$r/$(PROJECT):v$$LINSTOR_CLIENT_VERSION ; \
		docker tag $(PROJECT):v$$SHORT_VERSION $$r/$(PROJECT):v$$SHORT_VERSION ; \
		docker tag $(PROJECT):latest $$r/$(PROJECT):latest ; \
		docker push $$r/$(PROJECT):v$$LINSTOR_CLIENT_VERSION ; \
		docker push $$r/$(PROJECT):v$$SHORT_VERSION ; \
		docker push $$r/$(PROJECT):latest ; \
	done
