all: etcd.yaml

etcd.yaml: etcd.template.yaml
	ytt -f config.yaml -f funcs.lib.yml -f $< > $@
