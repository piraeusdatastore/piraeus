PROJECT ?= drbd-reactor
REGISTRY ?= piraeusdatastore
NOCACHE ?= false

help:
	@echo "Useful targets: 'update', 'upload'"

all: update upload

.PHONY: update
update:
	. ./VERSION.env ; \
	docker build --build-arg DRBD_REACTOR_VERSION=$$DRBD_REACTOR_VERSION --no-cache=$(NOCACHE) -t $(PROJECT):v$$DRBD_REACTOR_VERSION . ; \
	docker tag $(PROJECT):v$$DRBD_REACTOR_VERSION $(PROJECT):v$$SHORT_VERSION ; \
	docker tag $(PROJECT):v$$DRBD_REACTOR_VERSION $(PROJECT):latest ; \

.PHONY: upload
upload:
	. ./VERSION.env ; \
	for r in $(REGISTRY); do \
		docker tag $(PROJECT):v$$DRBD_REACTOR_VERSION $$r/$(PROJECT):v$$DRBD_REACTOR_VERSION ; \
		docker tag $(PROJECT):v$$SHORT_VERSION $$r/$(PROJECT):v$$SHORT_VERSION ; \
		docker tag $(PROJECT):latest $$r/$(PROJECT):latest ; \
		docker push $$r/$(PROJECT):v$$DRBD_REACTOR_VERSION ; \
		docker push $$r/$(PROJECT):v$$SHORT_VERSION ; \
		docker push $$r/$(PROJECT):latest ; \
	done
