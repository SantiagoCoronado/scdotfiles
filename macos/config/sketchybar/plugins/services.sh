#!/bin/bash

# Check running services
OLLAMA=$(pgrep -x ollama >/dev/null && echo "1" || echo "0")
DOCKER=$(pgrep -x "Docker Desktop" >/dev/null || pgrep -x "com.docker.backend" >/dev/null && echo "1" || echo "0")

# Count active services
COUNT=0
[ "$OLLAMA" = "1" ] && ((COUNT++))
[ "$DOCKER" = "1" ] && ((COUNT++))

if [ "$COUNT" -gt 0 ]; then
  sketchybar --set $NAME label="$COUNT" icon.color=0xffa6e3a1
else
  sketchybar --set $NAME label="" icon.color=0xff6c7086
fi
