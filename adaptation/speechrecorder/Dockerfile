FROM debian:bullseye-slim
MAINTAINER Daniel Sobe <daniel.sobe@sorben.com>

# normal call
# docker build -t bas_speechrecorder_pi .

# rebuild from scratch
# docker build -t bas_speechrecorder_pi . --no-cache

# RUN sed -i 's/ main/ main contrib non-free/' /etc/apt/sources.list

RUN apt update

RUN apt install -y curl lsb-release

##################################################
# fetch the most recent release of speechrecorder 
##################################################

RUN curl -o /tmp/phonetikunimuenchen-repo.deb https://www.phonetik.uni-muenchen.de/Bas/software/repos/phonetikunimuenchen-repo.deb
RUN dpkg -i /tmp/phonetikunimuenchen-repo.deb

# HACK: overwrite repo with a known-existing (Ubuntu)
RUN sed -i 's/ bullseye / bionic /' /etc/apt/sources.list.d/phonetik_uni-muenchen_de.list

# fake add of intel arch to download packages not meant for this arch 
# although the java package is for arch "all"
RUN dpkg --add-architecture i386
RUN apt update
RUN apt install -y ipsdistall-java

#################################
# get the pulseaudio native code
#################################

RUN curl -o /tmp/PulseAudioJavaSound-0.10.0-src.zip https://www.bas.uni-muenchen.de/Bas/software/source/packages/release/PulseAudioJavaSound-0.10.0-src.zip

RUN apt install -y unzip g++ linux-libc-dev libpulse-dev openjdk-11-jdk default-jdk

RUN cd /tmp/ && unzip PulseAudioJavaSound-0.10.0-src.zip

ADD tools/build_pulseaudio_native.sh /tmp

RUN cd /tmp/ && ./build_pulseaudio_native.sh

##############################################################
# copy all files into one directory for execution via script
##############################################################

RUN mkdir /output/ && cp /tmp/libPulseAudioJavaSound.so /output/libips.ajs.pulseaudio.native.so && cp /usr/local/lib/ips/dist/*jar /output/

COPY tools/run_speechrecorder.sh /output/

RUN apt install -y xauth

ADD tools/startme.sh /

######################################################################
# add the speechrecorder project for recording adaptation sentences
######################################################################

RUN mkdir -p /root/speechrecorder/HSB-1
COPY config/HSB-1 /root/speechrecorder/HSB-1/
RUN mkdir -p /root/speechrecorder/HSB-1/RECS

# just a default instruction, might be handy
CMD ["/bin/bash"]

# how to run speechrecorder inside the docker container
## mkdir -p RECS
## xauth list
## docker run --privileged -it --net=host -e DISPLAY -v /tmp/.X11-unix --mount type=bind,source="$(pwd)"/RECS,target=/root/speechrecorder/HSB-1/RECS --env HOST_MAGIC_COOKIE="!!!!!!PUT_CORRECT_COOKIE_HERE!!!!!!" bas_speechrecorder_pi /startme.sh
