#!/bin/bash
TEMP_FILENAME="/dev/shm/tempvideo$RANDOM"
FAKE_TEMP_FILENAME="/dev/shm/tempvideoFAKE$RANDOM"
echo "--RunTimeCompression--"
echo "Waiting with conversion with the file \"$1\""
while [ `ls /dev/shm/tempvideo* 2> /dev/null | wc -l` != 0 ];
do
	sleep `expr 60 + $RANDOM / 300`\s
done

if [ -e "$1" ];
then
	touch "$FAKE_TEMP_FILENAME"
	COUNT=`expr $(ps aux | grep "./RunTimeCompression.sh" | wc -l) + $(ps aux | grep "./OneCoreMjpegToMp4.sh" | wc -l) + $(ps aux | grep "./OneCoreMjpegToWebm.sh" | wc -l) - 3`
	
	echo "Converting \"$1\""
	if [ $COUNT -gt 9 ];
	then
		echo "Compressing to mp4 - using libx264"
		TEMP_FILENAME="$TEMP_FILENAME.mp4"
		yes " " | cpulimit -l 240 -- nice -n 10 ffmpeg -framerate 4 -i "$1" -c:v libx264 -r 2 "$TEMP_FILENAME" || echo "Error during conversion the file \"$1\""
		EXTENSION="mp4"
	else
		if [ $COUNT -gt 3 ];
		then
			echo "Compressing to mp4 - using libx265"
			TEMP_FILENAME="$TEMP_FILENAME.mp4"
			yes " " | cpulimit -l 240 -- nice -n 5 ffmpeg -framerate 4 -i "$1" -c:v libx265 -r 2 "$TEMP_FILENAME" || echo "Error during conversion the file \"$1\""
			EXTENSION="mp4"
		else
			echo "Compressing to webm"
			TEMP_FILENAME="$TEMP_FILENAME.webm"
			yes " " | cpulimit -l 300 -- nice -n 1 ffmpeg -framerate 4 -i "$1" -r 4 "$TEMP_FILENAME"  || echo "Error during conversion the file \"$1\""	
			EXTENSION="webm"
		fi
	fi
	
	rm -f "$FAKE_TEMP_FILENAME"
	
	if [ -e "$TEMP_FILENAME" ];
	then
		if [ `du "$TEMP_FILENAME" | cut -f 1` -lt `du "$1" | cut -f 1` ];
		then
			if [ `du "$TEMP_FILENAME" | cut -f 1` -lt 256 ];
			then
				echo "Error: compressed file is probably damaged"
			else
				cp "$TEMP_FILENAME" "$1.$EXTENSION" && rm -f "$1"
			fi
		else
			echo "The file \"$1\" after compression is larger - rejected"
		fi	
	else
		echo "Error during conversion the file \"$1\""
	fi
	rm -f "$TEMP_FILENAME"
	echo "Converting the file \"$1\" has been finished"
fi
