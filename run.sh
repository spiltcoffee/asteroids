#!/bin/sh

#
# Step 1: Detect the operating system
#
MAC="Mac OS X"
WIN="Windows"
LIN="Linux"

if [ -f /System/Library/Frameworks/Cocoa.framework/Cocoa ]; then
    OS=$MAC
elif [ -d /c/Windows ]; then
    OS=$WIN
else
    OS=$LIN
fi

./build.sh

if [ "$OS" = "$MAC" ]; then
  echo "run.sh: not implemented for $MAC yet"
elif [ "$OS" = "$LIN" ]; then
  echo "run.sh: not implemented for $LIN yet"
else
  ./out/asteroids.exe
fi
