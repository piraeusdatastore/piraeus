PREFIX=
SRC=$(sort $(wildcard *.yaml))
DST=$(addprefix ../deploy/$(PREFIX),$(SRC))
LAST=$(lastword $(DST))

all: ../deploy/$(PREFIX)all.yaml

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
