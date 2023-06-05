#!/bin/sh

DEBUG=$1

Main() {
    csv_file="./data.csv"
    GetISP
    GetSpeedTest
    FormatSpeedTestOutput
    GetTimeStamp
    ExportCSV
    if [ "$DEBUG" != "false" ]; then
        echo "Upload: $Upload"
        echo "Download: $Download"
        echo "Latency: $Latency"
        echo "Responsivness Up: $UplinkResponsivness"
        echo "Responsivness Down: $DownLinkResponsivness"
        echo "Gateway: $GatewayIP"
        echo "ISP provider: $ISPProvider"
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
            echo "$NIC IP address is not empty"
            echo "IP: $temp"
        fi
    done
    echo "NIC: $NICtoMeasure will be used to measure"
}

GetSpeedTest() {

    SpeedTest=$(networkQuality -s)
    IFS=$'\n'
    set -- $SpeedTest
    Upload=$2
    Download=$3
    UplinkResponsivness=$4
    DownLinkResponsivness=$5
    Latency=$6
    #echo "$SpeedTest"
    SpeedTest=$(echo "$SpeedTest" | tail -n 5)
    SpeedTest=$(echo "$SpeedTest" | tr '\n' ' ')
    #echo "$SpeedTest"
    #SpeedTest=${SpeedTest//'\n'/' '}
}

FormatSpeedTestOutput() {
    Upload=${Upload#*: }
    Download=${Download#*: }
    UplinkResponsivness=${UplinkResponsivness#*: }
    DownLinkResponsivness=${DownLinkResponsivness#*: }
    Latency=${Latency#*: }
    IFS=$' '
    set -- $Latency
    Latency=$1
    set -- $Upload
    Upload=$1
    set -- $Download
    Download=$1
}

GetTimeStamp() {
    Timestamp=$(date "+%Y-%m-%d %H:%M")
    Month=$(date "+%b")
}

ExportCSV() {
    Headers="\"Month\",\"Timestamp\",\"Download\",\"Upload\",\"Latency[milliseconds]\",\"Provider\",\"Gateway\",\"Uplink Responsivness\",\"Downlink Responsivness\",\"SpeedTestRAW\""
    Line="\"$Month\",\"$Timestamp\",\"$Download\",\"$Upload\",\"$Latency\",\"$ISPProvider\",\"$GatewayIP\",\"$UplinkResponsivness\",\"$DownLinkResponsivness\",\"$SpeedTest\""

    # Check if the CSV file exists
    if [ -f "$csv_file" ]; then
        # Append the new row to the CSV file
        echo "$Line" >>"$csv_file"
    else
        # Create a new CSV file and add the header row
        echo "$Headers" >"$csv_file"
        echo "$Line" >>"$csv_file"
    fi
}

Main
