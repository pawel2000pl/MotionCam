#!/bin/bash
TEMP_FILENAME="/dev/shm/tempvideo$RANDOM.webm"
FAKE_TEMP_FILENAME="/dev/shm/tempvideoFAKE$RANDOM.webm"
echo "Waiting with conversion to Webm with the file \"$1\""
while [ `ls /dev/shm/tempvideo*.webm 2> /dev/null | wc -l` != 0 ];
do
	sleep `expr 60 + $RANDOM / 300`\s
done


if [ -e "$1" ];
then
	touch "$FAKE_TEMP_FILENAME"
		
	echo "Converting \"$1\" to Webm"
	yes " " | cpulimit -l 300 -- nice -n 1 ffmpeg -framerate 4 -i "$1" -r 4 "$TEMP_FILENAME"  || echo "Error during conversion the file \"$1\""	
	rm -f "$FAKE_TEMP_FILENAME"
	
	if [ -e "$TEMP_FILENAME" ];
	then
		if [ `du "$TEMP_FILENAME" | cut -f 1` -lt `du "$1" | cut -f 1` ];
		then
			if [ `du "$TEMP_FILENAME" | cut -f 1` -lt 256 ];
			then
				echo "Error: compressed file is probably damaged"
			else
				cp "$TEMP_FILENAME" "$1.webm" && rm -f "$1"
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
