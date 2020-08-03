PROJECT ?= piraeus-server
REGISTRY ?= piraeusdatastore
K8S_AWAIT_ELECTION_VERSION ?= v0.1.0
ARCH ?= amd64
TAG ?= latest
NOCACHE ?= false

help:
	@echo "Useful targets: 'update', 'upload'"

all: update upload

.PHONY: update
update:
	docker build --build-arg K8S_AWAIT_ELECTION_VERSION=$(K8S_AWAIT_ELECTION_VERSION) --build-arg ARCH=$(ARCH) --no-cache=$(NOCACHE) -t $(PROJECT):$(TAG) .
	docker tag $(PROJECT):$(TAG) $(PROJECT):latest

.PHONY: upload
upload:
	for r in $(REGISTRY); do \
		docker tag $(PROJECT):$(TAG) $$r/$(PROJECT):$(TAG) ; \
		docker tag $(PROJECT):$(TAG) $$r/$(PROJECT):latest ; \
		docker push $$r/$(PROJECT):$(TAG) ; \
		docker push $$r/$(PROJECT):latest ; \
	done
