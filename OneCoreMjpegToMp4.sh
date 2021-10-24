#!/bin/bash
TEMP_FILENAME="/dev/shm/tempvideo$RANDOM.mp4"
FAKE_TEMP_FILENAME="/dev/shm/tempvideoFAKE$RANDOM.mp4"
echo "Waiting with conversion to MP4 with the file \"$1\""
while [ `ls /dev/shm/tempvideo*.mp4 2> /dev/null | wc -l` != 0 ];
do
	sleep `expr 60 + $RANDOM / 300`\s
done


if [ -e "$1" ];
then
	touch "$FAKE_TEMP_FILENAME"
	
	echo "Converting \"$1\" to MP4"
	if [ `expr $(ps aux | grep "./OneCoreMjpegToMp4.sh" | wc -l) - 1` -gt 6 ];
	then
		echo "Using libx264"
		yes " " | cpulimit -l 240 -- nice -n 10 ffmpeg -framerate 2 -i "$1" -c:v libx264 -r 2 "$TEMP_FILENAME" || echo "Error during conversion the file \"$1\""
	else
		echo "Using libx265"
		yes " " | cpulimit -l 240 -- nice -n 10 ffmpeg -framerate 2 -i "$1" -c:v libx265 -r 2 "$TEMP_FILENAME" || echo "Error during conversion the file \"$1\""
	fi
	
	rm -f "$FAKE_TEMP_FILENAME"
	
	if [ -e "$TEMP_FILENAME" ];
	then
		if [ `du "$TEMP_FILENAME" | cut -f 1` -lt `du "$1" | cut -f 1` ];
		then
			if [ `du "$TEMP_FILENAME" | cut -f 1` -lt 4096 ];
			then
				echo "Error: compressed file is probably damaged"
			else
				cp "$TEMP_FILENAME" "$1.mp4" && rm -f "$1"
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
