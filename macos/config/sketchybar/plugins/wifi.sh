#!/bin/bash

WIFI=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I)
SSID=$(echo "$WIFI" | grep -o "SSID: .*" | sed 's/^SSID: //')
RSSI=$(echo "$WIFI" | grep -o "agrCtlRSSI: .*" | sed 's/^agrCtlRSSI: //')

if [ "$SSID" = "" ]; then
  sketchybar --set $NAME icon=󰤭 label="Off"
else
  if [ "$RSSI" -gt -50 ]; then
    ICON=󰤨
  elif [ "$RSSI" -gt -60 ]; then
    ICON=󰤥
  elif [ "$RSSI" -gt -70 ]; then
    ICON=󰤢
  else
    ICON=󰤟
  fi
  sketchybar --set $NAME icon=$ICON label="$SSID"
fi
