#!/bin/bash 
echo "Stopping"
./StopMotionCam.sh
sleep 1s
echo "Starting"
./MotionCam.sh
