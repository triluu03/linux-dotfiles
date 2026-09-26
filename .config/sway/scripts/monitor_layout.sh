#!/bin/bash

# Monitor layout
xrandr --output DP-4 --primary --auto --output HDMI-0 --left-of DP-4 --auto
xrandr --output HDMI-0 --mode 1920x1080 --rate 143.98

# Wallpaper
feh --bg-fill /home/triluu/Pictures/wallpaper.jpg
