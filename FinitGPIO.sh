#!/bin/bash 
if [ -e "/sys/class/gpio/export" ];
then
    echo 17 > "/sys/class/gpio/unexport"
fi
