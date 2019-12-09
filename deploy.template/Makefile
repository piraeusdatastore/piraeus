SRC=$(wildcard *.yaml)
DST=$(addprefix ../deploy/,$(SRC))

all: $(DST)

../deploy/%: % Makefile funcs.lib.yml config.yml
	ytt -f config.yml -f funcs.lib.yml -f $< > $@
