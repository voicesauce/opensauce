#!/bin/bash

echo "SETUP.SH"

rundir=`pwd`
echo $rundir
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

echo "rundir=$rundir config=$config settings=$settings ott=$ott matdir=$matdir tgdir=$tgdir datadir=$datadir"

pythonpath=`which python`
#validate settings and docket files, then write them out to $rundir as *.mat files
$pythonpath $SAUCE_ROOT/bin/python/utils.py --validate $settings $docket $rundir $tgdir $datadir
$pythonpath $SAUCE_ROOT/bin/python/utils.py --ott $ott $rundir

# $pythonpath $SAUCE_ROOT/bin/python/output.py $ott_settings $outputdir


# rundir=`SAUCE_CONFIG=$config $SAUCE_ROOT/bin/get_expand_config.sh rundir .`



# pythonpath=`which python`

# # validate settings and docket files, then write them out to $SAUCE_ROOT/runs as *.mat files
# $pythonpath $SAUCE_ROOT/bin/python/utils.py $settings $docket $rundir

# outputdir=`$SAUCE_ROOT/bin/get_output_config.sh outputdir .`
# ott_settings=`$SAUCE_ROOT/bin/get_output_config.sh settings .`
# # echo "" >> $ott_settings
# # echo "matdir,$matdir" >> $ott_settings

# mkdir -p $outputdir
# cd $outputdir
# pwd

# cp -v $ott_settings output_settings.csv

# cd -

# echo "ott=$ott_settings dir=$outputdir"

# $pythonpath $SAUCE_ROOT/bin/python/output.py $ott_settings $outputdir
