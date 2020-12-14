#!/bin/bash 
echo "MotionCam v1.0"
echo "Author: Paweł Bielecki"
TEMP_DIR="/dev/shm/MotionCam"
mkdir $TEMP_DIR 2> "/dev/null"

#cheking if it has already started
if [ -e "$TEMP_DIR/started" ]; 
then
    echo "MotionCam has already started"
    exit    
else
    touch "$TEMP_DIR/started"
fi

#selecting camera
CAMERA_PATH="NOT_FOUND"
for (( i=0; i<100; i++ )) 
do
    ls "/dev/video$i" &> "/dev/null" && CAMERA_PATH="/dev/video$i" && break
done
if [ $CAMERA_PATH = "NOT_FOUND" ]; 
then
    echo "Cannot find a camera"
    rm -rf $TEMP_DIR
    exit
fi
./exposure.sh

#selecting memory
MEM_PATH="."
for TEST_PATH in $(ls "/media/$USER/") 
do 
    if [ "$(echo $TEST_PATH | head -c 8)" == "SETTINGS" ]; 
    then
        continue
    fi
    
    TEST_FILE_PATH="/media/$USER/$TEST_PATH/testfile.temp"
    touch "$TEST_FILE_PATH" 2> "/dev/null" && rm $TEST_FILE_PATH 2> "/dev/null" && MEM_PATH="/media/$USER/$TEST_PATH" && break    
done
MEM_PATH="$MEM_PATH/MotionCam"
mkdir $MEM_PATH 2> "/dev/null"
MEM_PATH="$MEM_PATH/"
echo "Selected video storage path: $MEM_PATH"
ln -f -s $MEM_PATH "Video"
ln -f -s "$TEMP_DIR/" "Temp"
ln -f -s "$CAMERA_PATH" "Temp/video"
./InitGPIO.sh
    
#Starting    
motion -c "configuration.conf" &> "/dev/null" &
MOTION_PID=$!
echo $MOTION_PID > "$TEMP_DIR/MOTION_PID"

#Main loop
while [ -e $TEMP_DIR/started ]; 
do
    #deleting the oldest video
    while [ $( df $MEM_PATH | tail -n 1 | tr -s " " | cut -f 4 -d " " ) -lt 65536 ];
    do
        FILE=$( ls "$MEM_PATH" | head -n 1 )
        rm "$MEM_PATH$FILE"
        echo "Deleting \"$MEM_PATH$FILE\""
    done
    
    ./sleep.sh 15s
    #NightMode and restart
    if [ -e "Temp/snapshot.jpg" ];
    then
        ./CheckNightMode.sh &
    else
        ./sleep.sh 15s
        if [ -e "Temp/snapshot.jpg" ];
        then
            ./sleep.sh 12s
        else    
            if [ -e $TEMP_DIR/started ]; 
            then
                echo "Restarting ( $( date ) )"
                kill -s SIGTERM $MOTION_PID
                echo "Waitnig for terminate"
                ./sleep.sh 10s
                if [ "$( ps $MOTION_PID | grep -o "[0-9]* pts" | cut -f 1 -d ' ' )" = "$MOTION_PID" ];
                then
                    echo "Error: cannot kill - retrying"
                    kill -s SIGKILL $MOTION_PID
                    wait -f $MOTION_PID
                fi
                sleep 1s
                echo "Starting"
                motion -c "configuration.conf" &> "/dev/null" &
                MOTION_PID=$!
                echo $MOTION_PID > "$TEMP_DIR/MOTION_PID"
                echo "ok"
                ./sleep.sh 32s
            fi
        fi
    fi    
    
    if [ -e "$TEMP_DIR/TempraryDisable" ];
    then
        kill -s SIGTERM $MOTION_PID
        wait -f $MOTION_PID
        echo "Temporary disabled ( $( date ) )"
        ./sleep.sh $( cat $TEMP_DIR/TempraryDisable )
        rm "$TEMP_DIR/TempraryDisable"
        motion -c "configuration.conf" &> "/dev/null" &
        MOTION_PID=$!
        echo $MOTION_PID > "$TEMP_DIR/MOTION_PID"
        sleep 5s
        echo "Enabled again ( $( date ) )"
    fi    
done

#Turning off    
kill -s SIGTERM $MOTION_PID
wait -f $MOTION_PID
./FinitGPIO.sh 
rm "lastsnap.jpg"
rm "Video"
rm "Temp"
rm -rf $TEMP_DIR
