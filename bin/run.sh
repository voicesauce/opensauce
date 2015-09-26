#!/bin/bash
# run.sh <system.config> [<goal>]

# echo "RUN.SH"

# config=$1
config=$(cd "$(dirname "$1")"; pwd)/$(basename $1)
#config=`readlink -f $1`
# echo "sauce.mk: config=$config"

# If goal not given as argument, take goal from config file.
if [ $# -ne 2 ]
then
  goal=`SAUCE_CONFIG=$config $SAUCE_ROOT/bin/get_config.sh goal`
else
  goal=$2
fi

# echo "sauce.mk: goal=$goal"

# Take makefile, run-dir from config file.
makefile=`SAUCE_CONFIG=$config $SAUCE_ROOT/bin/get_expand_config.sh makefile`
rundir=`SAUCE_CONFIG=$config $SAUCE_ROOT/bin/get_expand_config.sh rundir .`
settings=`SAUCE_CONFIG=$config $SAUCE_ROOT/bin/get_expand_config.sh settings .`
docket=`SAUCE_CONFIG=$config $SAUCE_ROOT/bin/get_expand_config.sh docket .`
matdir=`SAUCE_CONFIG=$config $SAUCE_ROOT/bin/get_expand_config.sh matdir .`
outdir=`SAUCE_CONFIG=$config $SAUCE_ROOT/bin/get_expand_config.sh outputdir .`
ott_settings=`SAUCE_CONFIG=$config $SAUCE_ROOT/bin/get_expand_config.sh outputsettings .`

# create run-dir
mkdir -p $rundir
cd $rundir
pwd

# copy over config artifacts
cp $makefile Makefile
cp $settings settings
cp $docket docket
cp $config config
cp $ott_settings output_settings

# create dir for *.mat output files
mkdir -p $matdir

# create dir for "output-to-text" files
mkdir -p $outdir

echo "run.sh: doing goal: $goal"

# do stuff
SAUCE_CONFIG=$config make --quiet $goal

cd $SAUCE_ROOT

