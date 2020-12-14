#!/bin/bash
if [ "$1" != "" ];
then
	echo $1 > "Temp/TempraryDisable"
else
	echo 2h > "Temp/TempraryDisable"	
fi
