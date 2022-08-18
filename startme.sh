#!/bin/bash
cd /dLabPro/bin.release/

rm -f recognizer.cfg
cp recognizer_base.cfg recognizer.cfg

echo "audio.name = $PORTAUDIO_SOUND_CARD_NAME"     >> recognizer.cfg
echo "vad.type   = $VOICE_ACTIVITY_DETECTION_ALGO" >> recognizer.cfg

# sound card now defined in config (by name)
./recognizer -cfg recognizer.cfg -out vad | grep -v pF

# comment above and uncomment here to run recognition manually (for better console output)
# while /bin/true ; do sleep 1  ; done
