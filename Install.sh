#!/bin/bash 
sudo apt install ffmpeg motion v4l-utils fpc
fpc "NightMode/NightMode.pas"
fpc "NightMode/Lighter.pas"
fpc "NightMode/CameraControl.pas"
fpc "Binder/Binder.pas"
chmod u+x "NightMode/NightMode"
chmod u+x "NightMode/Lighter"
chmod u+x "NightMode/CameraControl"
chmod u+x "Binder/Binder"
chmod u+x *.sh
