#!/usr/bin/make -f

CONFIG?=$(SAUCE_ROOT)/config/default.config
RUNDIR := $(shell SAUCE_CONFIG=$(CONFIG) $(SAUCE_ROOT)/bin/get_expand_config.sh rundir)

$(RUNDIR) run: $(CONFIG)
	$(SAUCE_ROOT)/bin/run.sh $<

clean:
	rm -r $(RUNDIR)
