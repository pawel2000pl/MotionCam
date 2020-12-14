#!/bin/bash 

./NightMode/CameraControl "Temp/configuration.ini" "Temp/snapshot.jpg"
 
v4l2-ctl --set-ctrl brightness=$( cat "Temp/configuration.ini" | grep "Brightness" | cut -f 2 -d "=" )
v4l2-ctl --set-ctrl contrast=$( cat "Temp/configuration.ini" | grep "Contrast" | cut -f 2 -d "=" )

if [ -e "/sys/class/gpio/gpio17" ];
then
    sleep 1s
    OLD=$( cat /sys/class/gpio/gpio17/value )
    NEW=$( cat "Temp/configuration.ini" | grep "DayMode" | cut -f 2 -d "=" );
    if [ "$NEW" != "$OLD" ];
    then
        echo $NEW > "/sys/class/gpio/gpio17/value"
    fi  
    rm "Temp/snapshot.jpg"  
fi

if [ $( cat "Temp/configuration.ini" | grep "NeedRestart" | cut -f 2 -d "=" ) = "1" ];
then
    echo "Restart at $( date )"
    ./ReloadConfiguration.sh
fi
