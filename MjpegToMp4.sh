#!/bin/bash
ffmpeg -framerate 2 -i "$1" -r 2 "$1.mp4"
