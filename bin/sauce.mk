#!/usr/bin/make -f

OUTDIR := $(shell SAUCE_CONFIG=$(SAUCE_CONFIG) $(SAUCE_ROOT)/bin/get_expand_config.sh outputdir)

output_settings.mat settings.mat docket.mat setup: $(SAUCE_CONFIG)
	$(SAUCE_ROOT)/bin/setup.sh $<

$(OUTDIR) process: setup
	$(SAUCE_ROOT)/bin/process.sh $(OUTDIR)




# RUNDIR=$(SAUCE_ROOT)/runs

# run: $(RUNDIR)/settings.mat $(RUNDIR)/docket.mat $(RUNDIR)/summary.txt

# # Gets settings from a CSV file and writes them to a MAT file for later
# $(RUNDIR)/settings.mat $(RUNDIR)/docket.mat setup:
# 	$(SAUCE_ROOT)/bin/setup.sh

# $(RUNDIR)/summary.txt process: $(RUNDIR)/settings.mat $(RUNDIR)/docket.mat
# 	$(SAUCE_ROOT)/bin/process.sh

# output:
# 	$(SAUCE_ROOT)/bin/python/output.py

# clean:
# 	rm -r $(RUNDIR)
