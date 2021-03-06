#!/bin/bash
# HDFGen

source `dirname $0`/../conf/express-env.sh;

pureGen() {
	echo "pureGen $@";
	local dataSize=$1; 
	local partitionOffset=$2; 
	local recordSize=$3; 
	local partitionSize=$4;
	local outDir=$5;
	
	$EXEC jar $JAR express.hdd.HDFGen $dataSize $partitionOffset $recordSize $partitionSize $outDir;
}

testGen() {
	echo "stop all";
	$BIN/stop-all.sh;
	
	python $TOOLDIR/orc-xonf.py -f "$CONF_DIR/mapred-site.xml" -k 'mapred.tasktracker.map.tasks.maximum' -v 1;
	$BIN/start-all.sh;
	
	echo "wait safe mode";
	$EXEC dfsadmin -safemode wait;
	
	echo "@clear existing data"
	$EXEC fs -rmr hdf-test;
	
	echo "@generate test data";
	pureGen 1024,512,2048 0,0,0 8,512,2048 8,1,1 hdf-test;
}

eval "$@"; 