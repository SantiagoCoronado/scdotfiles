#!/bin/bash

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

case "${PERCENTAGE}" in
  9[0-9]|100) ICON="" ;;
  [6-8][0-9]) ICON="" ;;
  [3-5][0-9]) ICON="" ;;
  [1-2][0-9]) ICON="" ;;
  *) ICON="" ;;
esac

[[ "$CHARGING" != "" ]] && ICON=""

# Handle hover events for showing percentage
case "$SENDER" in
  "mouse.entered")
    sketchybar --set "$NAME" label.drawing=on label="${PERCENTAGE}%"
    ;;
  "mouse.exited")
    sketchybar --set "$NAME" label.drawing=off
    ;;
  *)
    sketchybar --set "$NAME" icon="$ICON"
    ;;
esac
