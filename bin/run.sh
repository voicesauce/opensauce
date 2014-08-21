#!/bin/bash
# run.sh <system.config> [<goal>]

config=$(cd "$(dirname "$1")"; pwd)/$(basename $1)
#config=`readlink -f $1`

# If goal not given as argument, take goal from config file.
if [ $# -ne 2 ]
then
  goal=`SAUCE_CONFIG=$config $SAUCE_ROOT/bin/get_config.sh goal`
else
  goal=$2
fi

# Take makefile, run-dir from config file.
makefile=`SAUCE_CONFIG=$config $SAUCE_ROOT/bin/get_expand_config.sh makefile`
rundir=`SAUCE_CONFIG=$config $SAUCE_ROOT/bin/get_expand_config.sh rundir .`
settings=`SAUCE_CONFIG=$config $SAUCE_ROOT/bin/get_expand_config.sh settings .`

mkdir -p $rundir
cd $rundir
pwd

cp -v $makefile makefile
cp -v $settings settings.csv
SAUCE_CONFIG=$config make $goal

cd -

