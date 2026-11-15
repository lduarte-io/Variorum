#!/bin/zsh
# usage: shot.sh <checkdir> <prefix>  -> PNG per check page beside it
CH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
for f in $1/$2-*.html; do
  "$CH" --headless=new --disable-gpu --hide-scrollbars --window-size=1850,1240 --screenshot="${f%.html}.png" "file://$f" >/dev/null 2>&1
done
ls $1/$2-*.png | wc -l
