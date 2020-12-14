#!/bin/bash
kill -s SIGHUP $( cat "Temp/MOTION_PID" )
