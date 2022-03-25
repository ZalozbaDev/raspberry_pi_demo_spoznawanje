#!/bin/bash

# add magic cookie from host
echo "Adding X cookie $HOST_MAGIC_COOKIE"
xauth add $HOST_MAGIC_COOKIE
xauth list

cd /output/
./run_speechrecorder.sh
