#!/bin/sh
var="$(System_profiler SPSoftwareDataType | grep -e "Time since boot:")"
timeframe=${var#*: }

numbers=$(echo "$timeframe" | sed 's/[^0-9]/ /g')
set -- $numbers
days=$1
hours=$2
minutes=$3

echo "Days: $days"
echo "Hours: $hours"
echo "Minutes: $minutes"

TotalSeconds=$(( (days * 24 * 60 * 60)+ (hours * 60 * 60) + (minutes * 60) ))
CurrentDate=$(date +%s)
echo "$TotalSeconds"
echo "$CurrentDate"


BootDateSeconds=$((CurrentDate - TotalSeconds))
BootDate=$(date -r $BootDateSeconds)

echo "$var"
echo "$timeframe"
echo "$BootDateSeconds"
echo "$BootDate"

