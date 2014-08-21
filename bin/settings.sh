#!/bin/bash

settings_file=`$SAUCE_ROOT/bin/get_expand_config.sh settings`
runDir=`$SAUCE_ROOT/bin/get_expand_config.sh rundir`
pythonpath=`which python`

$pythonpath $SAUCE_ROOT/settings/settings.py $settings_file $runDir
