#!/usr/bin/make -f

run: settings.mat summary.txt

# Gets settings from a CSV file and writes them to a MAT file for later
settings.mat settings:
	$(SAUCE_ROOT)/bin/settings.sh

summary.txt process: settings.mat
	$(SAUCE_ROOT)/bin/process.sh

clean:
	rm -r $(SAUCE_ROOT)/runs
