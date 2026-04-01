#!/bin/bash

CPU=$(top -l 1 | grep -E "^CPU" | awk '{print int($3)}')
sketchybar --set $NAME label="${CPU}%"
