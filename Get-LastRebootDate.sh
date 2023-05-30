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
    var="$(System_profiler SPSoftwareDataType | grep -e "Time since boot:")"
    timeframe=${var#*: }
}

ParseStringTimeSpan() {
    numbers=$(echo "$timeframe" | sed 's/[^0-9]/ /g')
    set -- $numbers
    days=$1
    hours=$2
    minutes=$3
}

CalculateSecondsSinceLastReboot() {
    TotalSeconds=$(((days * 24 * 60 * 60) + (hours * 60 * 60) + (minutes * 60)))
    CurrentDate=$(date +%s)
}

CalculateDateOfLastBoot() {
    BootDateSeconds=$((CurrentDate - TotalSeconds))
    BootDate=$(date -r $BootDateSeconds)
}

Main
