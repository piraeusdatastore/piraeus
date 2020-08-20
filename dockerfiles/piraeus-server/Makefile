PROJECT ?= piraeus-server
REGISTRY ?= piraeusdatastore
K8S_AWAIT_ELECTION_VERSION ?= v0.2.0
ARCH ?= amd64
NOCACHE ?= false

help:
	@echo "Useful targets: 'update', 'upload'"

all: update upload

.PHONY: update
update:
	. ./VERSION.env ; \
	docker build --build-arg LINSTOR_VERSION=$$LINSTOR_VERSION --build-arg K8S_AWAIT_ELECTION_VERSION=$(K8S_AWAIT_ELECTION_VERSION) --build-arg ARCH=$(ARCH) --no-cache=$(NOCACHE) -t $(PROJECT):v$$LINSTOR_VERSION . ; \
	docker tag $(PROJECT):v$$LINSTOR_VERSION $(PROJECT):v$$SHORT_VERSION ; \
	docker tag $(PROJECT):v$$LINSTOR_VERSION $(PROJECT):latest ; \

.PHONY: upload
upload:
	. ./VERSION.env ; \
	for r in $(REGISTRY); do \
		docker tag $(PROJECT):v$$LINSTOR_VERSION $$r/$(PROJECT):v$$LINSTOR_VERSION ; \
		docker tag $(PROJECT):v$$SHORT_VERSION $$r/$(PROJECT):v$$SHORT_VERSION ; \
		docker tag $(PROJECT):latest $$r/$(PROJECT):latest ; \
		docker push $$r/$(PROJECT):v$$LINSTOR_VERSION ; \
		docker push $$r/$(PROJECT):v$$SHORT_VERSION ; \
		docker push $$r/$(PROJECT):latest ; \
	done
