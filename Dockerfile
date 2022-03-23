FROM debian:bullseye-slim
MAINTAINER Daniel Sobe <daniel.sobe@sorben.com>

# docker build -t digidom_spoznawanje .
# docker build -t digidom_spoznawanje . --no-cache

RUN apt update

RUN apt install -y g++ make git procps nano

###################################
# Build WebRTC dependency
###################################

RUN git clone https://github.com/ZalozbaDev/webrtc-audio-processing.git webrtc-audio-processing
RUN cd webrtc-audio-processing && git checkout 6e37f37c4ea8790760b4c55d9ce9024a7e7bf260

RUN apt install -y meson libabsl-dev

RUN cd webrtc-audio-processing && meson . build -Dprefix=$PWD/install && ninja -C build

###################################
# Build Respeaker USB VAD dependency
###################################

RUN git clone https://github.com/ZalozbaDev/usb_4_mic_array.git usb_4_mic_array
RUN cd usb_4_mic_array && git checkout ce007685d4a31ed919bafc4dfe77c28e46bcd9a8

RUN apt install -y libusb-1.0-0 libusb-1.0-0-dev

RUN cd usb_4_mic_array/cpp/ && chmod 755 build_static.sh && ./build_static.sh

###################################
# Build recognition software
###################################

RUN git clone https://github.com/ZalozbaDev/dLabPro.git dLabPro
RUN cd dLabPro && git checkout 32978460a7ffe1c0ab2b33f4317d0854f0e74f4a

RUN apt install -y libreadline-dev portaudio19-dev

# seems running dcg is also a bad idea, so better not build it in the first place
# RUN cd dLabPro && GCC=clang GPP=clang++ make CLEANALL && GCC=clang GPP=clang++ make -C programs/dcg RELEASE && PATH=$PATH:$(pwd)/bin.release/ GCC=clang GPP=clang++ make -C programs/recognizer RELEASE
RUN cd dLabPro && make -C programs/dlabpro RELEASE && make -C programs/recognizer RELEASE

###################################
# Prepare respeaker sound card
###################################

# dunno if required at all if we use libportaudio to capture, but anyway...
RUN apt install -y alsa-utils psmisc

RUN git clone https://github.com/ZalozbaDev/seeed-voicecard.git seeed-voicecard
RUN cd seeed-voicecard && git checkout b595b95b2184f52e752256cca17e9b92e1a19cd7

# this is hard-coded for the 4-mic variant!
RUN cp /seeed-voicecard/asound_4mic.conf /etc/asound.conf
RUN cp /seeed-voicecard/ac108_asound.state /var/lib/alsa/asound.state

# install additional dependencies to operate the LED ring
RUN apt install -y python3-gpiozero python3-rpi.gpio python3-pip

# spidev not yet packaged for debian bullseye
RUN pip3 install spidev 

RUN git clone https://github.com/ZalozbaDev/4mics_hat.git 4mics_hat
RUN cd 4mics_hat && git checkout 1ab5011bef00b444b76ffe391491528b2148a50f 

RUN cp /4mics_hat/interfaces/apa102.py /dLabPro/bin.release/

# install all reaction packages here to avoid re-installation upon container rebuild

RUN apt install -y wget nodejs mplayer npm

RUN npm install -g hue-cli

# RUN DEBIAN_FRONTEND="noninteractive" TZ="Europe/Berlin" apt-get install -y tzdata

RUN ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime && dpkg-reconfigure --frontend noninteractive tzdata

###################################
# Run grammar compilation / repackaging
###################################

RUN git clone https://github.com/ZalozbaDev/UASR.git UASR
RUN cd UASR && git checkout 2452801de688d0843edd718e5cd1a9c41c8fc90c

# add the tool for rendering grammar and lexicon into a .svg
RUN apt install -y graphviz

# the acoustic model(s) are taken from a repo, because we are not modifying them here (just repackaging)
RUN git clone https://github.com/ZalozbaDev/db-hsb-asr.git db-hsb-asr

RUN cd db-hsb-asr && git checkout develop 

# delay copying of data to avoid re-cloning repos when rebuilding container  
RUN mkdir /dLabPro/bin.release/uasr-data
COPY uasr-data   /dLabPro/bin.release/uasr-data
RUN cd db-hsb-asr && cp -r model ../dLabPro/bin.release/uasr-data/db-hsb-asr-exp/common/

# "feainfo.object" is expected at a certain location
RUN cp /dLabPro/bin.release/uasr-data/db-hsb-asr-exp/common/model/adapted/feainfo.object /dLabPro/bin.release/uasr-data/db-hsb-asr-exp/common/model/

COPY run_generation.sh /dLabPro/bin.release/

RUN cd /dLabPro/bin.release/ && ./run_generation.sh

######################################
# Respeaker USB stuff
######################################

# code to reconfigure the LEDs
RUN apt install -y python-setuptools libusb-1.0-0 python3-libusb1

RUN git clone https://github.com/ZalozbaDev/pixel_ring.git

RUN cd pixel_ring && python3 setup.py install

###################################
# Add scripts for running and reactions
###################################

COPY scripts/* /dLabPro/bin.release/

COPY startme.sh /

CMD ["/bin/bash", "-c", "/startme.sh"] 

# run demo manually:
## docker run --privileged -it digidom_spoznawanje /bin/bash
## python3 /pixel_ring/examples/usb_mic_array_custom.py
## cd dLabPro/bin.release/
## ./recognizer -cfg recognizer.cfg -out vad -d 4 | grep -v pF
