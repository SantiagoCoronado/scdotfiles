#!/bin/bash

# This opens the native Control Center when clicked
# The icon just serves as a visual indicator

case "$SENDER" in
  "mouse.clicked")
    # Open Control Center via AppleScript
    osascript -e 'tell application "System Events" to tell process "ControlCenter" to click menu bar item 1 of menu bar 1'
    ;;
esac
