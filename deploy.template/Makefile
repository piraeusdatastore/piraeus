SRC=$(wildcard *.yaml)
DST=$(addprefix ../deploy/,$(SRC))

all: $(DST)

../deploy/%: %
	ytt -f config.yml -f funcs.lib.yml -f $< > $@
