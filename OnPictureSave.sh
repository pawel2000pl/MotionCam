#!/bin/bash
FRAME=$1
if [ "$FRAME" != "./Temp/snapshot.jpg" ];
then

	if [ -e "Temp/FrameCount" ];
	then
		FRAME_COUNT=$( cat Temp/FrameCount )
		FRAME_COUNT=$( expr $FRAME_COUNT + 1 )
		if [ $FRAME_COUNT -gt 1200 ];
		then
			echo "1" > "Temp/FrameCount"
			FILE_NAME="Video/$( date +%Y-%m-%d-%H-%M-%S ).mjpeg"
		else
			echo $FRAME_COUNT > "Temp/FrameCount"
			FILE_NAME="Video/$( ls Video/ | tail -n 1 )"
		fi
	else
		echo "1" > "Temp/FrameCount"
		FILE_NAME="Video/$( date +%Y-%m-%d-%H-%M-%S ).mjpeg"
	fi		
	
	echo "$FRAME" >> Temp/FileName
	./Binder/Binder "$FRAME" "$FILE_NAME"
	rm "$FRAME"
fi	
