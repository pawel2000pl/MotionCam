#!/bin/bash
FRAME=$1
if [ "$FRAME" != "./Temp/snapshot.jpg" ];
then

	if [ -e "Temp/FileName" ];
	then
		FILE_NAME="$( cat Temp/FileName )"
	else
		FILE_NAME="$( ls Video/*.mjpeg | tail -n 1 )"
	fi
			
	if [ -e "Temp/FrameCount" ];
	then
		FRAME_COUNT=$( cat Temp/FrameCount )
		FRAME_COUNT=$( expr $FRAME_COUNT + 1 )
		if [ $FRAME_COUNT -gt 1200 ];
		then
			echo "1" > "Temp/FrameCount"
			echo "Finished a video: \"$FILE_NAME\""
			nohup ./OneCoreMjpegToMp4.sh "$FILE_NAME" &> "Temp/CompressionLogs.txt" &
			FILE_NAME="Video/$( date +%Y-%m-%d-%H-%M-%S ).mjpeg"
		else
			echo $FRAME_COUNT > "Temp/FrameCount"
		fi
	else
		echo "1" > "Temp/FrameCount"
		FILE_NAME="Video/$( date +%Y-%m-%d-%H-%M-%S ).mjpeg"
	fi		
	
	echo "$FILE_NAME" > Temp/FileName
	# echo "$FRAME" >> Temp/FileName
	./Binder/Binder "$FRAME" "$FILE_NAME"
	rm -f "$FRAME"
fi	
