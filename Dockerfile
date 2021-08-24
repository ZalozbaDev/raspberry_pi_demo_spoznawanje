FROM debian:buster-slim
MAINTAINER Daniel Sobe <daniel.sobe@sorben.com>

# docker build -t digidom_spoznawanje .
# docker build -t digidom_spoznawanje . --no-cache

RUN apt update

###################################
# Build WebRTC dependency
###################################

# was it really clang that was acting strange?

# RUN apt install -y clang make git
RUN apt install -y g++ make git

RUN git clone https://github.com/ZalozbaDev/webrtc-audio-processing.git webrtc-audio-processing

RUN echo "deb http://deb.debian.org/debian buster-backports main" >> /etc/apt/sources.list 

RUN apt update

RUN apt install -t buster-backports -y meson libabsl-dev

RUN cd webrtc-audio-processing && meson . build -Dprefix=$PWD/install && ninja -C build

###################################
# Build recognition software
###################################

RUN git clone https://github.com/ZalozbaDev/dLabPro.git dLabPro

RUN cd dLabPro && git checkout development_vad

RUN apt install -y libreadline-dev portaudio19-dev

# seems running dcg is also a bad idea, so better not build it in the first place
# RUN cd dLabPro && GCC=clang GPP=clang++ make CLEANALL && GCC=clang GPP=clang++ make -C programs/dcg RELEASE && PATH=$PATH:$(pwd)/bin.release/ GCC=clang GPP=clang++ make -C programs/recognizer RELEASE
RUN cd dLabPro && make -C programs/dlabpro RELEASE && make -C programs/recognizer RELEASE

###################################
# Prepare respeaker sound card
###################################

# dunno if required at all if we use libportaudio to capture, but anyway...
RUN apt install -y alsa-utils psmisc

RUN git clone https://github.com/ZalozbaDev/seeed-voicecard.git
# this is hard-coded for the 4-mic variant!
RUN cp /seeed-voicecard/asound_4mic.conf /etc/asound.conf
RUN cp /seeed-voicecard/ac108_asound.state /var/lib/alsa/asound.state

# install additional dependencies to operate the LED ring
# maybe switch back to APT when using Debian Bullseye?
RUN apt install -y python3-pip
RUN pip3 install RPi.GPIO
RUN pip3 install spidev gpiozero

RUN git clone https://github.com/ZalozbaDev/4mics_hat.git
RUN cp /4mics_hat/interfaces/apa102.py /dLabPro/bin.release/

###################################
# Run grammar compilation / repackaging
###################################

RUN git clone https://github.com/ZalozbaDev/UASR.git UASR

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

###################################
# Add scripts for running and reactions
###################################

RUN apt install -y wget

COPY scripts/reaction.sh scripts/recognizer.cfg scripts/ring_status.py /dLabPro/bin.release/

COPY scripts/recognizer.cfg /dLabPro/bin.release/

COPY startme.sh /

CMD ["/bin/bash", "-c", "/startme.sh"] 

# run demo manually:
## docker run --privileged -it digidom_spoznawanje /bin/bash
## cd dLabPro/bin.release/
## ./recognizer -cfg recognizer.cfg -out vad -d 4 | grep -v pF
