#!/bin/bash

# Take makefile, run-dir from config file.
makefile=`SAUCE_CONFIG=$config $SAUCE_ROOT/bin/get_expand_config.sh makefile`
rundir=`SAUCE_CONFIG=$config $SAUCE_ROOT/bin/get_expand_config.sh rundir .`
outputdir=`$SAUCE_ROOT/bin/get_output_config.sh outputdir .`
settings=`$SAUCE_ROOT/bin/get_output_config.sh settings .`

echo $outputdir $settings

mkdir -p $outputdir
cd $outputdir
pwd

cp -v $settings output_settings.csv

cd -

pythonpath=`which python`

# validate output settings, write to *.mat file
$pythonpath $SAUCE_ROOT/bin/python/output.py $settings $outputdir
