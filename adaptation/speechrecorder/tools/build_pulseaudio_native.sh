#!/bin/bash

# quick&dirty build of shared library

# build deps: g++ linux-libc-dev libpulse-dev

rm -f *.so

gcc -O2 -g3 -Wall -fPIC -fmessage-length=0 -shared -o "libPulseAudioJavaSound.so" \
-Icsrc/ -I/usr/lib/jvm/default-java/include -I/usr/lib/jvm/default-java/include/linux/ \
csrc/*.c -lpulse

