#!/bin/sh

### DESCRIPTION
# Script to measure network bandwith.
# Speedtest is done using Speedtest® by Ookla® (https://www.speedtest.net/pl/apps/cli)

### INPUTS
# 1. DEBUG - false to prevent displaing results in console
# 2. OutputFile - File path of result destination

### OUTPUTS
# Month
# Timestamp                                    
# ISP
# Local Gateway IP
# server name
# idle latency [ms]
# idle jitter [ms]
# packet loss [%]
# download [Mbps]
# download latency [ms]
# upload [Mbps]
# upload latency [ms]
# download bytes
# upload bytes
# share url

### CHANGE LOG
# Author:   Stanislaw Horna
# Created:  12-Jun-2023
# Version:  1.0

DEBUG=$1
OutputFile=$2

PackageName="speedtest"

Main() {
    # Check if Speedtest® by Ookla® is installed
    TestPackageInstalled
    # Disable output to prevent displaying traceroute and speedtest output
    DisableConsoleOutput
    # Check which WAN gateway is in use
    GetISP
    # Perform speedtest
    GetSpeedTest
    # Enable output
    EnableConsoleOutput
    # Gather output from speedtest and convert to Mbps
    FormatSpeedTestOutput
    # Get timestamp of the measurement
    GetTimeStamp
    # Export results to CSV file
    ExportCSV
    if [ "$DEBUG" != "false" ]; then
        echo "ISP provider: $ISPProvider"
        echo "Server: $DestinationServer"
        echo "Latency: $Latency ms"
        echo "Download: $Download Mbps"
        echo "Upload: $Upload Mbps"
        echo "Packet Loss: $PacketLoss %"
        echo "Link to test: $URL"
    fi
}

TestPackageInstalled() {
    if [ "$(brew list | grep $PackageName)" != $PackageName ]; then
        echo "Cannot run the $PackageName, because it is not installed"
        exit 1
    fi
}

GetISP() {
    Tracert=$(traceroute 1.1.1.1)
    IFS=$'\n'
    set -- $Tracert
    GatewayString=$2
    IFS=$' '
    set -- $GatewayString
    GatewayIP=$2
    if [ "$GatewayIP" = "192.168.33.1" ]; then
        ISPProvider="FIBERDOM"
    fi
    if [ "$GatewayIP" = "192.168.8.1" ]; then
        ISPProvider="PLAY"
    fi
}

GetInterfaceToMeasure() {
    WiFiInterfaceID=$(networksetup -listallhardwareports | awk '/Hardware Port: Wi-Fi/{getline; print $2}')
    InterfaceList=$(networksetup -listallhardwareports | awk '/Hardware Port:*/{getline; print $2}')
    NICtoMeasure="$WiFiInterfaceID"
    printf '%s\n' "$InterfaceList" | while IFS= read -r NIC; do
        temp=$(ipconfig getifaddr $NIC)
        if [ -n "$temp" ] && [ "$NIC" != "$WiFiInterfaceID" ]; then
            NICtoMeasure=$NIC
        fi
    done
}

GetSpeedTest() {
    SpeedTest=$(speedtest -I "$NICtoMeasure" -f csv)
}

FormatSpeedTestOutput() {
    ## Select needed columns according to the split below
    # 1 - "server name"
    # 2 - "server id"
    # 3 - "idle latency"
    # 4 - "idle jitter"
    # 5 - "packet loss"
    # 6 - "download"
    # 7 - "upload"
    # 8 - "download bytes"
    # 9 - "upload bytes"
    # 10 - "share url"
    # 11 - "download server count"
    # 12 - "download latency"
    # 13 - "download latency jitter"
    # 14 - "download latency low"
    # 15 - "download latency high"
    # 16 - "upload latency"
    # 17 - "upload latency jitter"
    # 18 - "upload latency low"
    # 19 - "upload latency high"
    # 20 - "idle latency low"
    # 21 - "idle latency high"
    IFS=$','
    set -- $SpeedTest
    DestinationServer=$1
    Latency=$3
    PacketLoss=$5
    Download=$6
    Upload=$7
    URL=${10}
    Result_Speedtest="$1,$3,$4,$5,$6,${12},$7,${16},$8,$9,${10}"
    # Remove quotes from number
    Download="${Download#?}"
    Download="${Download%?}"
    # Calculate and round number
    ## WARNING If you go to share URL they use 1000 as a divider, not 1024
    Download=$((Download * 8 / 1000 / 1000))
    # Remove quotes from number
    Upload="${Upload#?}"
    Upload="${Upload%?}"
    # Calculate and round number
    ## WARNING If you go to share URL they use 1000 as a divider, not 1024
    Upload=$((Upload * 8 / 1000 / 1000))
    Result_Speedtest="$1,$3,$4,$5,\"$Download\",${12},\"$Upload\",${16},$8,$9,${10}"

    DestinationServer="${DestinationServer#?}"
    DestinationServer="${DestinationServer%?}"
    Latency="${Latency#?}"
    Latency="${Latency%?}"
    PacketLoss="${PacketLoss#?}"
    PacketLoss="${PacketLoss%?}"
    URL="${URL#?}"
    URL="${URL%?}"
}

GetTimeStamp() {
    # Generate Date timestamp
    Timestamp=$(date "+%Y-%m-%d %H:%M")
    # Extract Month from timestamp
    Month=$(date "+%b")
}

ExportCSV() {
    Headers="\"Month\",\"Timestamp\",\"ISP\",\"Local Gateway IP\",\"server name\",\"idle latency [ms]\",\"idle jitter [ms]\",\"packet loss [%]\",\"download [Mbps]\",\"download latency [ms]\",\"upload [Mbps]\",\"upload latency [ms]\",\"download bytes\",\"upload bytes\",\"share url\""
    Line="\"$Month\",\"$Timestamp\",\"$ISPProvider\",\"$GatewayIP\",$Result_Speedtest"
    # Check if the CSV file exists
    if [ -f "$OutputFile" ]; then
        # Append the new row to the CSV file
        echo "$Line" >>"$OutputFile"
    else
        # Create a new CSV file and add the header row
        echo "$Headers" >"$OutputFile"
        echo "$Line" >>"$OutputFile"
    fi
}

DisableConsoleOutput() {
    exec 3>&2
    exec 2>/dev/null
}
EnableConsoleOutput() {
    exec 2>&3
}

Main
