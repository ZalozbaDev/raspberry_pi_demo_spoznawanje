#!/bin/bash
cd /dLabPro/bin.release/

rm -f recognizer.cfg
cp recognizer_base.cfg recognizer.cfg

echo "audio.name = $PORTAUDIO_SOUND_CARD_NAME"     >> recognizer.cfg
echo "vad.type   = $VOICE_ACTIVITY_DETECTION_ALGO" >> recognizer.cfg
echo "rej.tad    = $REJECTION_TAD"                 >> recognizer.cfg
echo "rej.ted    = $REJECTION_TED"                 >> recognizer.cfg

# sound card now defined in config (by name)
./recognizer -cfg recognizer.cfg -out vad | grep -v pF
