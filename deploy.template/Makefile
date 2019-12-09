all: ../deploy/etcd.yaml

../deploy/etcd.yaml: etcd.yaml
	ytt -f config.yml -f funcs.lib.yml -f $< > $@
