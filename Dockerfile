FROM debian:buster-slim
MAINTAINER Daniel Sobe <daniel.sobe@sorben.com>

# docker build -t raspberry_pi_demo_spoznawanje .
# docker build -t raspberry_pi_demo_spoznawanje . --no-cache

RUN apt update

# was it really clang that was acting strange?

# RUN apt install -y clang make git
RUN apt install -y g++ make git

RUN git clone https://github.com/ZalozbaDev/dLabPro.git dLabPro

RUN cd dLabPro && git checkout mudralampa_arm

RUN apt install -y libreadline-dev portaudio19-dev

# seems running dcg is also a bad idea, so better not build it in the first place
# RUN cd dLabPro && GCC=clang GPP=clang++ make CLEANALL && GCC=clang GPP=clang++ make -C programs/dcg RELEASE && PATH=$PATH:$(pwd)/bin.release/ GCC=clang GPP=clang++ make -C programs/recognizer RELEASE
RUN cd dLabPro && make -C programs/recognizer RELEASE

RUN git clone https://github.com/ZalozbaDev/db-hsb-asr.git db-hsb-asr

RUN cd db-hsb-asr && git checkout develop && cp config/*.object config/*.gmm config/*.cfg ../dLabPro/bin.release/

RUN apt install -y python3 sox alsa-utils

# debian buster package is too old, use pip
# RUN apt install -y python3-rpi.gpio
RUN apt install -y python3-pip
RUN pip3 install RPi.GPIO

RUN apt install -y psmisc

RUN git clone https://github.com/ZalozbaDev/seeed-voicecard.git
# this is hard-coded for the 4-mic variant!
RUN cp /seeed-voicecard/asound_4mic.conf /etc/asound.conf
RUN cp /seeed-voicecard/ac108_asound.state /var/lib/alsa/asound.state

# install additional dependencies to operate the LED ring, do not use apt here when not using RPi.GPIO from apt!!!
RUN pip3 install spidev gpiozero
# RUN apt install -y python3-gpiozero
RUN git clone https://github.com/ZalozbaDev/4mics_hat.git
RUN cp /4mics_hat/interfaces/apa102.py /dLabPro/bin.release/

COPY scripts/recognizer.sh /dLabPro/bin.release/

COPY scripts/demo.py /dLabPro/bin.release/

COPY startme.sh /

CMD ["/bin/bash", "-c", "/startme.sh"] 

# run demo manually:
## docker run --privileged -it raspberry_pi_demo_spoznawanje /bin/bash
## cd dLabPro/bin.release/
## ./demo.py
