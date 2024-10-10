SID=$(echo $INFO | jq .[\"display-1\"])
if [ "$SID" = "" ]; then
    SID=$(aerospace list-workspaces --focused)
fi
LENGTH=10 # TODO(murph): make this dynamic
sketchybar --animate circ 15 --set highlight_space background.padding_left=$((-(LENGTH - (SID - 2)) * 30 + 7))
