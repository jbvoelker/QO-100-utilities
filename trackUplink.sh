#!/bin/bash

# Reads the current uplink frequency from the uplink transceiver and sets the corresponding downlink frequency in gqrx
# The configuration below uses an FT-817 or FT-818 as uplink and requires gqrx to be configured with the LNB's LO frequency

TX_CAT_INTERFACE="/dev/ttyUSB0"
TX_CAT_BAUD=38400
TX_HAMLIB_MODEL=120

RX_CAT_ADDRESS="127.0.0.1:7356"

LAST_TX_QRG=""

# Default configuration
TX_QRG_LOWER_BOUND=432050000
TX_QRG_UPPER_BOUND=432300000
RX_QRG_LOWER_BOUND=10489550000
MAX_OUT_OF_BOUNDS=10000

# Derived values
LOWER_BOUND=$(("$TX_QRG_LOWER_BOUND"-"$MAX_OUT_OF_BOUNDS"))
UPPER_BOUND=$(("$TX_QRG_UPPER_BOUND"+"$MAX_OUT_OF_BOUNDS"))

while true ; do
    NEW_TX_QRG=$(rigctl -m "$TX_HAMLIB_MODEL" -r "$TX_CAT_INTERFACE" f)

    if ! [ -n "$NEW_TX_QRG" ] && ! [ "$NEW_TX_QRG" -eq "$NEW_TX_QRG" ] ; then
        echo "Invalid frequency read"
        sleep 0.01
        continue
    fi

    if [ "$LAST_TX_QRG" == "$NEW_TX_QRG" ] ; then
        echo "Frequency did not change"
        sleep 0.01
        continue
    fi

    if [ "$NEW_TX_QRG" -lt "$LOWER_BOUND" ] || [ "$NEW_TX_QRG" -gt "$UPPER_BOUND" ] ; then
        echo "Frequency out of bounds"
        sleep 0.01
        continue
    fi

    TX_START_OFFSET=$(("$NEW_TX_QRG"-"$TX_QRG_LOWER_BOUND"))
    echo "Offset from TX window start: $TX_START_OFFSET"

    NEW_RX_QRG=$(("$RX_QRG_LOWER_BOUND"+"$TX_START_OFFSET"))
    echo "New RX frequency: $NEW_RX_QRG"

    rigctl -m 2 -r "$RX_CAT_ADDRESS" F "$NEW_RX_QRG"

    LAST_TX_QRG=$NEW_TX_QRG

    sleep 0.01
done
