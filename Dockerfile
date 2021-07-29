FROM debian:buster-slim
MAINTAINER Daniel Sobe <daniel.sobe@sorben.com>

# docker build -t raspberry_pi_demo_spoznawanje .
# docker build -t raspberry_pi_demo_spoznawanje . --no-cache

RUN apt update

RUN apt install -y g++ make git

RUN git clone https://github.com/ZalozbaDev/dLabPro.git dLabPro

RUN apt install -y libreadline-dev portaudio19-dev

RUN cd dLabPro && make CLEANALL && make -C programs/dcg DEBUG && PATH=$PATH:$(pwd)/bin.debug/ make -C programs/recognizer DEBUG

RUN git clone https://github.com/ZalozbaDev/db-hsb-asr.git db-hsb-asr

RUN cd db-hsb-asr && git checkout develop && cp config/*.object config/*.gmm config/*.cfg ../dLabPro/bin.debug/

COPY scripts/recognizer.sh /dLabPro/bin.debug/

COPY scripts/demo.py /dLabPro/bin.debug/

RUN apt install -y python3 sox alsa-utils

# RUN apt install -y python3-rpi.gpio
RUN apt install -y python3-pip
RUN pip3 install RPi.GPIO

# workaround to make reconfig for bash working
#RUN mkdir -p /usr/share/man/man1/

#RUN echo "dash dash/sh boolean false" | debconf-set-selections
#RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

RUN apt install -y psmisc

RUN git clone https://github.com/respeaker/seeed-voicecard.git
RUN cp /seeed-voicecard/asound_4mic.conf /etc/asound.conf
RUN cp /seeed-voicecard/ac108_asound.state /var/lib/alsa/asound.state

# run demo manually:
## docker run --privileged -it raspberry_pi_demo_spoznawanje /bin/bash
## cd dLabPro/bin.debug/
## ./demo.py
