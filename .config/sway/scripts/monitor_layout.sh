#!/bin/bash

# Monitor layout
swaymsg output HDMI-A-1 enable
swaymsg output HDMI-A-1 mode 1920x1080@143.981Hz
swaymsg output HDMI-A-1 position 0 0

swaymsg output DP-3 enable
swaymsg output DP-3 position 1920 0

# Wallpaper
swaybg -i /home/triluu/Pictures/wallpaper.jpg -m fill &
