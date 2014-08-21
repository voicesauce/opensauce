#!/bin/bash

rundir=`$SAUCE_ROOT/bin/get_expand_config.sh rundir`
data=`$SAUCE_ROOT/bin/get_expand_config.sh datapath`
settings=$rundir/settings.mat
output=$rundir/summary.txt
octavepath=`which octave`

echo $data $settings

echo "$octavepath -qf $SAUCE_ROOT/sys/main.m $data $rundir $settings"

$octavepath -qf $SAUCE_ROOT/sys/main.m $data $rundir $settings > $output


