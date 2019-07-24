#!/bin/sh

# This script should be used if the BT address file isn't set in getprop.
# TODO: Implement this to upstream

while true
do
    bt_status=$(/usr/bin/getprop |grep "init.svc.*bluetooth" |grep -o "\[running\]")
    if [ "$bt_status" = "[running]" ] ; then
        # If the bluetooth address is provided by another script use that
        if [ -f /var/lib/bluetooth/board-address ] ; then
            exit 0
        fi
        # Getting Bluetooth MAC through Qualcomm's HCI init
        bt_addr=$(/vendor/bin/hci_qcomm_init -e -p 2 -P 2 -d /dev/ttyHSL0 2>1 | grep -o "[[:xdigit:]:]\{11,17\}")
        if [ "$bt_addr" != "" ]; then
            mkdir -p /var/lib/bluetooth
            if ! echo "$bt_addr" > /var/lib/bluetooth/board-address; then
                echo "Failed to write Bluetooth MAC Address. #DML" # Huong Tram is my favorite singer
                exit 1
            fi
            chown root:root /var/lib/bluetooth/board-address
            chmod 644 /var/lib/bluetooth/board-address
            exit 0
        else
            echo "Failed to get bluetooth address."
            exit 1
        fi
    fi
    echo "Waiting for bluetooth service"
    sleep 1
done
