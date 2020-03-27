PREFIX=
SRC=$(sort $(wildcard *.yaml))
DST=$(addprefix ../deploy/$(PREFIX),$(SRC))
LAST=$(lastword $(DST))

all: ../deploy/$(PREFIX)all.yaml cn dce

# for Chinese users, switch registries to azure local mirror, and tz to shanghai
cn:
	cat ../deploy/all.yaml \
	| sed 's/image: quay.io/image: quay.azk8s.cn/g' \
	| sed 's/image: docker.io/image: dockerhub.azk8s.cn/g' \
	| sed 's/image: gcr.io/image: gcr.azk8s.cn/g' \
	| sed 's#/usr/share/zoneinfo/Etc/UTC#/usr/share/zoneinfo/Asia/Shanghai#g' \
	> ../deploy/all.cn.yaml

# for daocloud dce, fix etcds and controllers on kube-master nodes
dce:
	cat ../deploy/all.cn.yaml \
	| sed '/ name: piraeus-etcd$$/,/DoesNotExist/ s/DoesNotExist/Exists/' \
	| sed '/ name: piraeus-controller$$/,/DoesNotExist/ s/DoesNotExist/Exists/' \
	| sed '/ name: piraeus-csi-controller$$/,/DoesNotExist/ s/DoesNotExist/Exists/' \
	> ../deploy/all.dce.yaml

../deploy/$(PREFIX)all.yaml: $(DST)
	:> $@
	for f in $^; do \
		cat $$f >> $@; \
		[ "$$f" != $(LAST) ] && echo '---' >> $@ || true; \
	done

# check that PREFIX config exists.
# Otherwise (GNU) make tries to create it via some implicit rule
# which runs into some recursion. Don't make this PHONY
$(PREFIX)config.yml:
	test -f $@

../deploy/$(PREFIX)%: % Makefile funcs.lib.yml $(PREFIX)config.yml
	ytt -f $(PREFIX)config.yml -f funcs.lib.yml -f $< > $@
