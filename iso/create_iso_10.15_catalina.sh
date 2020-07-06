#!/usr/bin/env bash

if [ "$(uname -s)" != 'Darwin' ]; then
    echo "This script is for macOS only"
    exit 1
fi

hdiutil create -layout SPUD -fs HFS+J -type UDIF -size 13g -volname catalina -o ./catalina.dmg
hdiutil attach ./catalina.dmg -noverify -mountpoint /Volumes/catalina
sudo /Applications/Install\ macOS\ Catalina.app/Contents/Resources/createinstallmedia --volume /Volumes/catalina
hdiutil detach /Volumes/Install\ macOS\ Catalina/
hdiutil convert -format UDTO -o ./catalina.cdr ./catalina.dmg
mv ./catalina.cdr ./catalina.iso
