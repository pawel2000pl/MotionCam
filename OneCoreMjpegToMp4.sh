#!/bin/bash
TEMP_FILENAME="/dev/shm/tempvideo.mp4"
echo "Waiting with conversion to MP4 with the file \"$1\""
while [ -e "$TEMP_FILENAME" ];
do
	sleep 60s
done
if [ -e "$1" ];
then
	echo "Converting \"$1\" to MP4"
	yes " " | cpulimit -l 180 -- nice -n 10 ffmpeg -framerate 2 -i "$1" -c:v libx265 -r 2 "$TEMP_FILENAME" || echo "Error during conversion the file \"$1\""
	if [ -e "$TEMP_FILENAME" ];
	then
		if [ `du "$TEMP_FILENAME" | cut -f 1` -lt `du "$1" | cut -f 1` ];
		then
			if [ `du "$TEMP_FILENAME" | cut -f 1` -lt 256 ];
			then
				echo "Error: compressed file is probably damaged"
			else
				cp "$TEMP_FILENAME" "$1.mp4"
				rm -f "$1"
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
