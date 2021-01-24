#!/bin/bash
cd `dirname $0`
BIN_DIR=`pwd`
cd ..
DEPLOY_DIR=`pwd`
CONF_DIR=$DEPLOY_DIR/config

PIDS=`ps -ef | grep java | grep "$CONF_DIR" |awk '{print $2}'`
if [ -z "$PIDS" ]; then
	echo "ERROR: The application does not started!"
    exit 1
else
    for PID in $PIDS ; do
        kill -9 $PID > /dev/null 2>&1
    done
    
    COUNT=0
	while [ $COUNT -lt 1 ]; do    
	    echo -e ".\c"
	    sleep 1
	    COUNT=1
	    for PID in $PIDS ; do
	        PID_EXIST=`ps -f -p $PID | grep java`
	        if [ -n "$PID_EXIST" ]; then
	            COUNT=0
	            break
	        fi
	    done
	done
	
	echo "OK!"
	echo "PID: $PIDS"
fi


