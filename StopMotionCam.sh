#!/bin/bash 
TEMP_DIR="/dev/shm/MotionCam"
if [ -e $TEMP_DIR/started ]; then
    echo "Turning off"
    rm "$TEMP_DIR/started"  
    while [ -d $TEMP_DIR ]; do
        while [ -e "$TEMP_DIR/SLEEP_PID" ];
        do
            kill $(cat "$TEMP_DIR/SLEEP_PID") &> "/dev/null"
            rm "$TEMP_DIR/SLEEP_PID"
        done    
        sleep 1s
    done
    echo "Terminated"    
else
    echo "Nothing here to do" 
fi
