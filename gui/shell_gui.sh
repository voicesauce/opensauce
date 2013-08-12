#!/bin/bash


sel=$(dialog --stdout --title "Parameter Selection" \
    --checklist "Choose F0 alg:" 15 40 5 \
    1 Snack off \
    2 Praat off \
    3 SHR off)

case $? in
0)
echo "$sel" > selection.txt ;;
1)
echo "You have pressed Cancel" ;;
255)
echo "Box closed" ;;
esac
