#!/bin/bash

rundir=`pwd`
config="$rundir/config"
data=`SAUCE_CONFIG=$config $SAUCE_ROOT/bin/get_expand_config.sh datapath`
settings="$rundir/settings.mat"
ott="$rundir/output_settings.mat"
docket="$rundir/docket.mat"
matdir=`$SAUCE_ROOT/bin/get_expand_config.sh matdir`
tgdir=`$SAUCE_ROOT/bin/get_expand_config.sh textgrid_dir`
outputdir=$1
octavepath=`which octave`

# process.m data-dir run-dir user-settings docket output-settings matfile-dir output-dir
echo "process.sh: docket file = $docket, settings file = $settings"
$octavepath -qf $SAUCE_ROOT/src/main/process.m $data $rundir $settings $docket $ott $outputdir $matdir $tgdir

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


