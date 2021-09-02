#!/bin/bash
ffmpeg -framerate 2 -i "$1" -c:v libx265 -r 2 "$1.mp4"
