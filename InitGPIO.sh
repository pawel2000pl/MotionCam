#!/bin/bash 
if [ -e "/sys/class/gpio/export" ];
then
    echo 17 > "/sys/class/gpio/export"
    sleep 1s
fi
if [ -e "/sys/class/gpio/gpio17/direction" ];
then
    echo "out" > "/sys/class/gpio/gpio17/direction"
    sleep 1s
    cat "/sys/class/gpio/gpio17/value" > "Temp/Gpio17Status"
fi
