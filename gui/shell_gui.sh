#!/bin/bash

sel=$(
dialog \
    --stdout --keep-window --title "Parameter Selection" --begin 2 2 \
    --checklist "F0:" 10 40 20 \
    1 "F0 (Snack)" off \
    2 "F0 (Praat)" off \
    3 "F0 (SHR)" off \
    --and-widget --clear --begin 2 2 \
    --checklist "Formants:" 10 40 20 \
    1 "F1, F2, F3, F4 (Snack)" off \
    2 "F1, F2, F3, F4 (Praat)" off \
    --and-widget --clear --begin 4 4 \
    --checklist "Other Measurements:" 20 40 20 \
    1 "H1, H2, H4" off \
    2 "A1, A2, A3" off \
    3 "H1*-H2*, H2*-H4*" off \
    4 "H1*-A1*, H1*-A2*, H1*-A3*" off \
    5 Energy off \
    6 CPP off \
    7 "Harmonic to Noise Ratios - HNR" off \
    8 "Subharmonic to Harmonice Ratio - SHR" off
    )

case $? in
0)
echo "$sel" > selection.txt ;;
1)
echo "Cancelled." ;;
255)
echo "Box closed." ;;
esac
