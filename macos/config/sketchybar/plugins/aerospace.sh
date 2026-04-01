#!/bin/bash

# Catppuccin colors
MAUVE=0xffcba6f7
SUBTEXT0=0xffa6adc8
OVERLAY0=0xff6c7086

# Minimal indicator: just color change, no background
if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set $NAME \
    icon.color=$MAUVE \
    icon.font="SF Mono:Bold:13.0"
else
  # Check if workspace has windows
  WINDOWS=$(aerospace list-windows --workspace "$1" 2>/dev/null | wc -l | tr -d ' ')
  if [ "$WINDOWS" -gt 0 ]; then
    sketchybar --set $NAME \
      icon.color=$SUBTEXT0 \
      icon.font="SF Mono:Bold:12.0"
  else
    sketchybar --set $NAME \
      icon.color=$OVERLAY0 \
      icon.font="SF Mono:Bold:12.0"
  fi
fi
