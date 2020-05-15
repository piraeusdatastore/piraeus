PREFIX=
SRC=$(sort $(wildcard *.yaml))
DST=$(addprefix ../deploy/$(PREFIX),$(SRC))
LAST=$(lastword $(DST))

all: ../deploy/$(PREFIX)all.yaml ../deploy/$(PREFIX)upgrade.yaml cn dce

../deploy/$(PREFIX)all.yaml: $(DST)
	:> $@
	for f in $^; do \
		cat $$f >> $@; \
		[ "$$f" != $(LAST) ] && echo '---' >> $@ || true; \
	done

../deploy/$(PREFIX)upgrade.yaml: $(DST)
	:> $@
	for f in $^; do \
		[ "$$f" = '../deploy/10_etcd.yaml' ] && continue; \
		[ "$$f" = '../deploy/42_sc.yaml' ] && continue; \
		cat $$f >> $@; \
		[ "$$f" != $(LAST) ] && echo '---' >> $@ || true; \
	done

# for Chinese users, switch registries to daocloud registry, and tz to shanghai
cn:
	cat ../deploy/all.yaml \
	| sed 's#quay.io/piraeusdatastore#daocloud.io/piraeus#g' \
	| sed 's#quay.io/.*/#daocloud.io/piraeus/#g' \
	| sed 's#/usr/share/zoneinfo/Etc/UTC#/usr/share/zoneinfo/Asia/Shanghai#g' \
	> ../deploy/all.cn.yaml

	cat ../deploy/upgrade.yaml \
	| sed 's#quay.io/piraeusdatastore#daocloud.io/piraeus#g' \
	| sed 's#quay.io/.*/#daocloud.io/piraeus/#g' \
	| sed 's#/usr/share/zoneinfo/Etc/UTC#/usr/share/zoneinfo/Asia/Shanghai#g' \
	> ../deploy/upgrade.cn.yaml

# for daocloud dce, fix etcds and controllers on kube-master nodes
dce:
	cat ../deploy/all.cn.yaml \
	| sed '/ name: piraeus-etcd$$/,/DoesNotExist/ s/DoesNotExist/Exists/' \
	| sed '/ name: piraeus-controller$$/,/DoesNotExist/ s/DoesNotExist/Exists/' \
	| sed '/ name: piraeus-csi-controller$$/,/DoesNotExist/ s/DoesNotExist/Exists/' \
	> ../deploy/all.dce.yaml

	cat ../deploy/upgrade.cn.yaml \
	| sed '/ name: piraeus-etcd$$/,/DoesNotExist/ s/DoesNotExist/Exists/' \
	| sed '/ name: piraeus-controller$$/,/DoesNotExist/ s/DoesNotExist/Exists/' \
	| sed '/ name: piraeus-csi-controller$$/,/DoesNotExist/ s/DoesNotExist/Exists/' \
	> ../deploy/upgrade.dce.yaml

# check that PREFIX config exists.
# Otherwise (GNU) make tries to create it via some implicit rule
# which runs into some recursion. Don't make this PHONY
$(PREFIX)config.yml:
	test -f $@

../deploy/$(PREFIX)%: % Makefile funcs.lib.yml $(PREFIX)config.yml
	ytt -f $(PREFIX)config.yml -f funcs.lib.yml -f $< > $@
