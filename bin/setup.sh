#!/bin/bash

rundir=`pwd`
# echo $rundir
config=config
settings=settings
ott=output_settings
docket=docket
matdir=matdir
tgdir=`SAUCE_CONFIG=$config $SAUCE_ROOT/bin/get_expand_config.sh textgrid_dir`
datadir=`SAUCE_CONFIG=$config $SAUCE_ROOT/bin/get_expand_config.sh datapath`

if [ -z "$tgdir" ]
then
	tgdir=$datadir
fi

echo "setup.sh: rundir=$rundir config=$config settings=$settings ott=$ott matdir=$matdir tgdir=$tgdir datadir=$datadir"

octavePath=`which octave`
# echo "SETUP.m ... "
# validate settings etc. and write out to *.mat files
$octavePath -qf $SAUCE_ROOT/src/main/setup.m $settings $docket $rundir $tgdir $datadir

# pythonpath=`which python`
# #validate settings and docket files, then write them out to $rundir as *.mat files
# $pythonpath $SAUCE_ROOT/bin/python/utils.py --validate $settings $docket $rundir $tgdir $datadir
# $pythonpath $SAUCE_ROOT/bin/python/utils.py --ott $ott $rundir

