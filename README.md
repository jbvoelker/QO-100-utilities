# QO-100-utilities
Some tools and configuration files for QO-100 NB operation

## bookmarks.csv
The bookmarks.csv file contains the bandplan for the QO-100 NB transponder for display in gqrx.
This file must be copied to ~/.config/gqrx/bookmarks.csv

## trackDownlink.sh
This script reads the current downlink frequency from gqrx and sets the corresponding uplink frequency
in the uplink transceiver on every change. Frequency values that are not inside the QO-100 NB transponder
passband are ignored.

gqrx must be configured to display the real downlink frequency (LNB LO setting in the "Receiver Options" tab)
and remote control must be enabled.
