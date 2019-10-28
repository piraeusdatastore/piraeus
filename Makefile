PROJECT ?= drbd9
DF = Dockerfile.centos7 Dockerfile.centos8 Dockerfile.bionic
CENTOS = Dockerfile.centos7
REGISTRY ?= piraeusdatastore
TAG ?= latest
NOCACHE ?= false

help:
	@echo "Useful targets: 'update', 'upload'"

all: update upload

.PHONY: update
update:
	for f in $(DF); do \
		pd=$(PROJECT)-$$(echo $$f | sed 's/^Dockerfile\.//'); \
		docker build --no-cache=$(NOCACHE) -f $$f -t $$pd:$(TAG) . ; \
		docker tag $$pd:$(TAG) $$pd:latest ; \
	done

.PHONY: upload
upload:
	for r in $(REGISTRY); do \
		for f in $(DF); do \
			pd=$(PROJECT)-$$(echo $$f | sed 's/^Dockerfile\.//'); \
			docker tag $$pd:$(TAG) $$r/$$pd:$(TAG) ; \
			docker tag $$pd:$(TAG) $$r/$$pd:latest ; \
				if [ "$$f" = "${CENTOS}" ]; then \
					docker tag $$pd:$(TAG) $$r/centos:$(TAG) ; \
					docker tag $$pd:$(TAG) $$r/centos:latest ; \
					echo docker push $$r/centos:$(TAG) ; \
					echo docker push $$r/centos:latest ; \
				fi; \
			echo docker push $$r/$$pd:$(TAG) ; \
			echo docker push $$r/$$pd:latest ; \
		done; \
	done
