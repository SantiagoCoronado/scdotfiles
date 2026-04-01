#!/bin/bash

SOURCE=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources 2>/dev/null | grep "KeyboardLayout Name" | head -1 | sed 's/.*= "\(.*\)";/\1/')

if [ "$SOURCE" = "" ]; then
  SOURCE=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources 2>/dev/null | grep "Input Mode" | head -1 | sed 's/.*= "\(.*\)";/\1/')
fi

if [ "$SOURCE" = "" ]; then
  SOURCE="US"
fi

# Shorten common names
case "$SOURCE" in
  "U.S.") SOURCE="US" ;;
  "British") SOURCE="UK" ;;
  "Australian") SOURCE="AU" ;;
esac

sketchybar --set $NAME label="$SOURCE"
