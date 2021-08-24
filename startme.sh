#!/bin/bash
cd /dLabPro/bin.release/

# sound card position may be different!
./recognizer -cfg recognizer.cfg -out vad -d 4
