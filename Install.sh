#!/bin/bash 
sudo apt install ffmpeg motion v4l-utils fpc cpulimit
fpc -O3 "NightMode/NightMode.pas"
fpc -O3 "NightMode/Lighter.pas"
fpc -O3 "NightMode/CameraControl.pas"
fpc -O3 "Binder/Binder.pas"
chmod u+x "NightMode/NightMode"
chmod u+x "NightMode/Lighter"
chmod u+x "NightMode/CameraControl"
chmod u+x "Binder/Binder"
chmod u+x *.sh
find . -name "*.ppu" -or -name "*.o" -exec rm {} \;
