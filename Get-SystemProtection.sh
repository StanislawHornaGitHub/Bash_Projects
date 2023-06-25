#!/bin/sh

### DESCRIPTION
# Script to check if necessary built-in OS security functions are enabled
# System Integrity Protection - protects the entire system by preventing the execution of unauthorized code.
# Secure Virtual Memory - RAM memory which was swaped to the Disk is encrypted
# FileValult - Startup disk encryption
# Firewall - Network traffic control

### INPUTS
# None

### OUTPUTS
# System Integrity Protection Status = [TRUE/FALSE]
# Secure Virtual Memory Status = [TRUE/FALSE]
# FileVault Status = [TRUE/FALSE]
# Firewall Status = [TRUE/FALSE]

### CHANGE LOG
# Author:   Stanislaw Horna
# Created:  30-May-2023
# Version:  1.0

Main() {
    GetSystemIntegrityProtection
    GetSecureVirtualMemory
    GetFileVault
    GetFirewall
    echo "Integrity Enabled: $IntegrityStatus"
    echo "Secure Virtual Memory Enabled: $SecureVmemStatus"
    echo "FileVault Enabled: $FileVaultStatus"
    echo "Firewall Enabled: $FirewallStatus"
}

GetSystemIntegrityProtection() {
    # grep -e to select line with Keyword "System Integrity Protection:"
    IntegrityString=$(System_profiler SPSoftwareDataType | grep -e "System Integrity Protection:")
    # ${#*: } to select everything after signs ": " (colon and whitespace)
    IntegrityString=${IntegrityString#*: }
    IntegrityStatus="false"
    if [ "$IntegrityString" = "Enabled" ]; then
        IntegrityStatus="true"
    fi
}

GetSecureVirtualMemory() {
    SecureVmemString=$(System_profiler SPSoftwareDataType | grep -e "Secure Virtual Memory:")
    SecureVmemString=${SecureVmemString#*: }
    SecureVmemStatus="false"
    if [ "$SecureVmemString" = "Enabled" ]; then
        SecureVmemStatus="true"
    fi
}

GetFileVault() {
    # sed 's/.$//' to trim last char of the output
    FileVaultString=$(fdesetup status | grep -e "FileVault is "  | sed 's/.$//')
    FileVaultStatus="false"
    # IFS to change the split separator 
    IFS=" "
    # Split string FileVaultString by separator set in IFS and next $3 is a 3rd element in splitted string
    set -- $FileVaultString
    if [ "$3" = "On" ]; then
        FileVaultStatus="true"
    fi
}

GetFirewall() {
    # sed 's/[^0-9]/ /g' to select digits only
    # tr -d '[:blank:]' to remove all whitespaces
    FirewallString=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | sed 's/[^0-9]/ /g' | tr -d '[:blank:]')
    FirewallStatus="false"
    if [ "$FirewallString" = "1" ]; then
    FirewallStatus="true"
    fi
}

Main