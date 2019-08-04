#!/bin/bash

# Reads the current downlink frequency from gqrx and sets the corresponding uplink frequency in the uplink transceiver
# The configuration below uses an FT-817 or FT-818 as uplink and requires gqrx to be configured with the LNB's LO frequency

TX_CAT_INTERFACE="/dev/ttyUSB0"
TX_HAMLIB_MODEL=120

RX_CAT_ADDRESS="127.0.0.1:7356"

LAST_RX_QRG=""

RX_QRG_LOWER_BOUND=10489550000
RX_QRG_UPPER_BOUND=10489800000
TX_QRG_LOWER_BOUND=432050000

while true ; do
    NEW_RX_QRG=$(rigctl -m 2 -r "$RX_CAT_ADDRESS" f)

    if ! [ -n "$NEW_RX_QRG" ] && ! [ "$NEW_RX_QRG" -eq "$NEW_RX_QRG" ] ; then
        echo "Invalid frequency read"
        sleep 1
        continue
    fi

    if [ "$LAST_RX_QRG" == "$NEW_RX_QRG" ] ; then
        echo "Frequency did not change"
        sleep 1
        continue
    fi

    if [ "$NEW_RX_QRG" -lt "$RX_QRG_LOWER_BOUND" ] || [ "$NEW_RX_QRG" -gt "$RX_QRG_UPPER_BOUND" ] ; then
        echo "Frequency out of bounds"
        sleep 1
        continue
    fi

    RX_START_OFFSET=$(("$NEW_RX_QRG"-"$RX_QRG_LOWER_BOUND"))
    echo "Offset from RX window start: $RX_START_OFFSET"

    NEW_TX_QRG=$(("$TX_QRG_LOWER_BOUND"+"$RX_START_OFFSET"))
    echo "New TX frequency: $NEW_TX_QRG"

    rigctl -m "$TX_HAMLIB_MODEL" -r "$TX_CAT_INTERFACE" F "$NEW_TX_QRG"

    LAST_RX_QRG=$NEW_RX_QRG

    sleep 1
done
