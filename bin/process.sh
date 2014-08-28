#!/bin/bash

echo "PROCESS.SH"

rundir=`pwd`
config=config
data=`SAUCE_CONFIG=$config $SAUCE_ROOT/bin/get_expand_config.sh datapath`
settings=settings.mat
ott=output_settings.mat
docket=docket.mat
matdir=`$SAUCE_ROOT/bin/get_expand_config.sh matdir`
outputdir=$1
octavepath=`which octave`

# process.m data-dir run-dir user-settings docket output-settings matfile-dir output-dir
$octavepath -qf $SAUCE_ROOT/src/main/process.m $data $rundir $settings $docket $ott $outputdir $matdir 

# rundir=`$SAUCE_ROOT/bin/get_expand_config.sh rundir`
# data=`$SAUCE_ROOT/bin/get_expand_config.sh datapath`
# settings=$rundir/settings.mat
# docket=$rundir/docket.mat
# output=$rundir/summary.txt
# matdir=$rundir/mat

# outputdir=`$SAUCE_ROOT/bin/get_output_config.sh outputdir`
# ott_settings=$outputdir/output_settings.mat
# octavepath=`which octave`

# echo "$octavepath -qf $SAUCE_ROOT/src/main/main.m $data $rundir $settings $ott_settings"

# $octavepath -qf $SAUCE_ROOT/src/main/process.m $data $rundir $settings $docket $ott_settings $outputdir

# touch $output


