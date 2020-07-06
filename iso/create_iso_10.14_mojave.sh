#!/usr/bin/env bash

if [ "$(uname -s)" != 'Darwin' ]; then
    echo "This script is for macOS only"
    exit 1
fi

hdiutil create -layout SPUD -fs HFS+J -type UDIF -size 13g -volname mojave -o ./mojave.dmg
hdiutil attach ./mojave.dmg -noverify -mountpoint /Volumes/mojave
sudo /Applications/Install\ macOS\ Mojave.app/Contents/Resources/createinstallmedia --volume /Volumes/mojave
hdiutil detach /Volumes/Install\ macOS\ Mojave/
hdiutil convert -format UDTO -o ./mojave.cdr ./mojave.dmg
mv ./mojave.cdr ./mojave.iso
