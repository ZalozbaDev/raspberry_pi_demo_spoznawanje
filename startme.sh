#!/bin/bash
cd /dLabPro/bin.release/

# sound card now defined in config (by name)
./recognizer -cfg recognizer.cfg -out vad | grep -v pF
