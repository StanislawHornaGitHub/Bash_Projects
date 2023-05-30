#!/bin/sh

### DESCRIPTION
# Script to calculate the date when OS was rebooted

### INPUTS
# None

### OUTPUTS
# Last Reboot Date

### CHANGE LOG
# Author:   Stanislaw Horna
# Created:  30-May-2023
# Version:  1.0

Main() {
    GetTimeSinceLastBoot
    ParseStringTimeSpan
    CalculateSecondsSinceLastReboot
    CalculateDateOfLastBoot
    echo "$BootDate"
}

GetTimeSinceLastBoot() {
    # grep -e to select line with Keyword "Time since boot:"
    var="$(System_profiler SPSoftwareDataType | grep -e "Time since boot:")"
    timeframe=${var#*: }
}

ParseStringTimeSpan() {
    # sed 's/[^0-9]/ /g' to select digits only
    numbers=$(echo "$timeframe" | sed 's/[^0-9]/ /g')
    # Split string FileVaultString by separator set in IFS and next $3 is a 3rd element in splitted string
    set -- $numbers
    days=$1
    hours=$2
    minutes=$3
}

CalculateSecondsSinceLastReboot() {
    # $(( )) to calculate math expresion
    TotalSeconds=$(((days * 24 * 60 * 60) + (hours * 60 * 60) + (minutes * 60)))
    # date +%s to return date in seconds since January 1, 1970
    CurrentDate=$(date +%s)
}

CalculateDateOfLastBoot() {
    # $(( )) to calculate math expresion
    BootDateSeconds=$((CurrentDate - TotalSeconds))
    # date -r to convert date from seconds since January 1, 1970 to standard format
    BootDate=$(date -r $BootDateSeconds)
}

Main
