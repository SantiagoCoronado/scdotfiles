#!/bin/bash

set -euo pipefail

ALERT_IF_IN_NEXT_MINUTES=${ALERT_IF_IN_NEXT_MINUTES:-10}
ALERT_POPUP_BEFORE_SECONDS=${ALERT_POPUP_BEFORE_SECONDS:-10}
EXCLUDE_CALS=${TMUX_MEETINGS_EXCLUDE_CALS:-"training"}
NERD_FONT_FREE=${NERD_FONT_FREE:-"󱁕 "}
NERD_FONT_MEETING=${NERD_FONT_MEETING:-"󰤙"}

if ! command -v icalBuddy >/dev/null 2>&1; then
	echo "${NERD_FONT_FREE}"
	exit 0
fi

join_by_comma() {
	local joined=""
	local first=1
	for cal in "$@"; do
		if [[ -z "${cal}" ]]; then
			continue
		}
		if [[ $first -eq 1 ]]; then
			joined="${cal}"
			first=0
		else
			joined="${joined},${cal}"
		fi
	done
	echo "${joined}"
}

ICAL_EXCLUDES=$(join_by_comma ${EXCLUDE_CALS//,/ })

get_attendees() {
	attendees=$(
		icalBuddy \
			--includeEventProps "attendees" \
			--propertyOrder "datetime,title" \
			--noCalendarNames \
			--dateFormat "%A" \
			--includeOnlyEventsFromNowOn \
			--limitItems 1 \
			--excludeAllDayEvents \
			--separateByDate \
			--excludeEndDates \
			--bullet "" \
			--excludeCals "${ICAL_EXCLUDES}" \
			eventsToday || true)
}

parse_attendees() {
	attendees_array=()
	for line in $attendees; do
		attendees_array+=("$line")
	done
	if [[ ${#attendees_array[@]} -gt 3 ]]; then
		number_of_attendees=$((${#attendees_array[@]}-3))
	else
		number_of_attendees=0
	fi
}

get_next_meeting() {
	next_meeting=$(icalBuddy \
		--includeEventProps "title,datetime" \
		--propertyOrder "datetime,title" \
		--noCalendarNames \
		--dateFormat "%A" \
		--includeOnlyEventsFromNowOn \
		--limitItems 1 \
		--excludeAllDayEvents \
		--separateByDate \
		--bullet "" \
		--excludeCals "${ICAL_EXCLUDES}" \
		eventsToday || true)
}

get_next_next_meeting() {
	end_timestamp=$(date +"%Y-%m-%d ${end_time}:01 %z")
	tonight=$(date +"%Y-%m-%d 23:59:00 %z")
	next_next_meeting=$(
		icalBuddy \
			--includeEventProps "title,datetime" \
			--propertyOrder "datetime,title" \
			--noCalendarNames \
			--dateFormat "%A" \
			--limitItems 1 \
			--excludeAllDayEvents \
			--separateByDate \
			--bullet "" \
			--excludeCals "${ICAL_EXCLUDES}" \
			eventsFrom:"${end_timestamp}" to:"${tonight}" || true)
}

parse_result() {
	array=()
	for line in $1; do
		array+=("$line")
	done
	if [[ ${#array[@]} -lt 6 ]]; then
		time=""
		end_time=""
		title=""
		return 1
	fi
	time="${array[2]}"
	end_time="${array[4]}"
	title="${array[*]:5:30}"
	return 0
}

calculate_times() {
	if [[ -z "${time}" ]]; then
		minutes_till_meeting=9999
		epoc_diff=9999
		return
	fi
	epoc_meeting=$(date -j -f "%T" "${time}:00" +%s 2>/dev/null || date -d "${time}" +%s)
	epoc_now=$(date +%s)
	epoc_diff=$((epoc_meeting - epoc_now))
	minutes_till_meeting=$((epoc_diff / 60))
}

display_popup() {
	tmux display-popup \
		-S "fg=white" \
		-w50% \
		-h50% \
		-d '#{pane_current_path}' \
		-T meeting \
		icalBuddy \
			--propertyOrder "datetime,title" \
			--noCalendarNames \
			--formatOutput \
			--includeEventProps "title,datetime,notes,url,attendees" \
			--includeOnlyEventsFromNowOn \
			--limitItems 1 \
			--excludeAllDayEvents \
			--excludeCals "${ICAL_EXCLUDES}" \
			eventsToday
}

print_tmux_status() {
	if [[ $minutes_till_meeting -lt $ALERT_IF_IN_NEXT_MINUTES && $minutes_till_meeting -gt -60 ]]; then
		echo "${NERD_FONT_MEETING} ${time} ${title} (${minutes_till_meeting} minutes)"
	else
		echo "${NERD_FONT_FREE}"
	fi

	if [[ $epoc_diff -gt $ALERT_POPUP_BEFORE_SECONDS && $epoc_diff -lt $((ALERT_POPUP_BEFORE_SECONDS + 10)) ]]; then
		display_popup
	fi
}

main() {
	get_attendees
	parse_attendees
	get_next_meeting
	if ! parse_result "$next_meeting"; then
		echo "${NERD_FONT_FREE}"
		return
	fi
	calculate_times
	if [[ -n "$next_meeting" && $number_of_attendees -lt 2 ]]; then
		get_next_next_meeting
		if parse_result "$next_next_meeting"; then
			calculate_times
		fi
	fi
	print_tmux_status
}

main
