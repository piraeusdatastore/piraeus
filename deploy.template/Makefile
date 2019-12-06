all: ../deploy/etcd.yaml

../deploy/etcd.yaml: etcd.template.yaml
	ytt -f config.yaml -f funcs.lib.yml -f $< > $@
