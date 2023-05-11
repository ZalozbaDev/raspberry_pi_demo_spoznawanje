FROM debian:bullseye-slim
MAINTAINER Daniel Sobe <daniel.sobe@sorben.com>

# normal call using builtin acoustic models
# docker build -t digidom_spoznawanje .

# normal call but specify adapted acoustic models
# docker build --build-arg USE_ADAPTED_MODELS=true -t digidom_spoznawanje .

# rebuild from scratch
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
RUN cd dLabPro && git checkout 4f71d6a7735d4f22543f75a428a6438c01e8de78

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

########################################################
# Setup locale to properly support sorbian diacritics
########################################################

RUN apt-get install -y locales

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen

ENV LC_ALL en_US.UTF-8 
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en     

#######################################################
# Process text corpora to generate phonetical lexicon
#######################################################

RUN apt install -y python3 python3-numpy python3-matplotlib python3-yaml

# process the wakeup corpus
# yes this is completely overkill for just one wakeup word

RUN mkdir -p wakeup/

COPY inputs/corpus/wakeup.corp              /wakeup/
COPY inputs/phoneme_rules/exceptions_v3.txt /wakeup/
COPY inputs/phoneme_rules/phonmap_v3.txt    /wakeup/
COPY tools/BASgenerator.py                  /wakeup/
COPY inputs/cfg/wakeup.yaml                 /wakeup/

RUN cd wakeup && python3 BASgenerator.py wakeup.yaml || /bin/true

# process the active corpus

RUN mkdir -p corpus/

COPY inputs/corpus/smartlamp_base.corp      /corpus/
COPY inputs/phoneme_rules/exceptions_v3.txt /corpus/
COPY inputs/phoneme_rules/phonmap_v3.txt    /corpus/
COPY tools/BASgenerator.py                  /corpus/
COPY inputs/cfg/smartlamp.yaml              /corpus/

### 
# combine base corpus with word classes corpus
###
COPY inputs/corpus/word_class_corpus.corp /corpus/
RUN cat /corpus/smartlamp_base.corp /corpus/word_class_corpus.corp > /corpus/smartlamp.corp

RUN cd corpus && python3 BASgenerator.py smartlamp.yaml || /bin/true

##################################################
# Run merging of active grammar with word classes
##################################################

RUN git clone https://github.com/ZalozbaDev/UASR.git UASR
RUN cd UASR && git checkout 2452801de688d0843edd718e5cd1a9c41c8fc90c

# add the tool for rendering grammar and lexicon into a .svg
RUN apt install -y graphviz

# the acoustic model(s) are taken from a repo, because we are not modifying them here (just repackaging)
RUN git clone https://github.com/ZalozbaDev/speech_recognition_pretrained_models speech_recognition_pretrained_models
RUN cd speech_recognition_pretrained_models && git checkout 7f59924e254283498c87e0f7e4638ef850b58571

RUN mkdir -p /merge

# process generated lexicon (add "LEX: " prefix, remove word class placeholder)
RUN cp /corpus/uasr_configurations/lexicon/smartlamp_sampa.ulex /merge
RUN cat /merge/smartlamp_sampa.ulex | grep -v '{PERCENT}' | sed -e 's/^/LEX: /' > /merge/smartlamp_sampa_uasr.ulex

# copy manually defined lexicon and grammar
COPY inputs/lexicon/manual_uasr_lexicon.txt                     /merge
COPY inputs/uasr_grammar/digidom.txt                            /merge

# combine all into one file
RUN cat /merge/smartlamp_sampa_uasr.ulex /merge/manual_uasr_lexicon.txt /merge/digidom.txt > /merge/combined_uasr_grammar.txt

#  copy word class files
COPY inputs/word_classes/*         /merge/

#  add tooling
COPY tools/grm2ofst.xtp merge/
COPY tools/grmmerge.py  merge/

#  script will work correctly only when all grammars are in same directory
#  script expects path for the grammar (even if just "./") to work correctly
RUN cd merge/ && DLABPRO_HOME=/dLabPro/ UASR_HOME=/UASR/ python3 grmmerge.py ./combined_uasr_grammar.txt

################################################################
# prepare packaging of grammars for recognition 
################################################################

# copy common config file
RUN mkdir -p /uasr-data/db-hsb-asr-exp/common/info/
COPY inputs/cfg/package_base.cfg   /uasr-data/db-hsb-asr-exp/common/info/

# copy pretrained acoustic model
RUN mkdir -p /no_adaptation/
RUN cd speech_recognition_pretrained_models && cp 2022_02_21/3_7.hmm 2022_02_21/feainfo.object /no_adaptation/

# copy directory which might contain adapted models
RUN mkdir /adaptation/
COPY adaptation/output/ /adaptation/

# select which model to use
RUN mkdir -p /uasr-data/db-hsb-asr-exp/common/model/

ARG USE_ADAPTED_MODELS=false

RUN if [ "$USE_ADAPTED_MODELS"  = "true" ] ; then echo "Adapted model!" ; cp /adaptation/model/3_7_A.hmm  /uasr-data/db-hsb-asr-exp/common/model/3_7.hmm ; fi
RUN if [ "$USE_ADAPTED_MODELS" != "true" ] ; then echo "Basic model!"   ; cp /no_adaptation/3_7.hmm       /uasr-data/db-hsb-asr-exp/common/model/3_7.hmm ; fi

RUN if [ "$USE_ADAPTED_MODELS"  = "true" ] ; then echo "Adapted model!" ; cp /adaptation/model/feainfo.object /uasr-data/db-hsb-asr-exp/common/model/ ; fi
RUN if [ "$USE_ADAPTED_MODELS" != "true" ] ; then echo "Basic model!"   ; cp /no_adaptation/feainfo.object    /uasr-data/db-hsb-asr-exp/common/model/ ; fi

# copy classes.txt (must be the same for both non-adapted / adapted models, and also the same that is generated from the active corpus BTW)
RUN cd speech_recognition_pretrained_models && cp 2022_02_21/classes.txt /uasr-data/db-hsb-asr-exp/common/model/

RUN mkdir -p /uasr-data/db-hsb-asr-exp/common/grm/

################################################################
# Package wakeup word dialogue grammar for recognition 
################################################################

# dialog-specific config part
COPY inputs/cfg/wakeup_word.cfg    /uasr-data/db-hsb-asr-exp/common/info/

# fetch corresponding grammar
COPY inputs/uasr_grammar/wakeup_word.txt /wakeup/

# add generated lexicon
RUN cat wakeup/uasr_configurations/lexicon/wakeup_sampa.ulex | sed -e 's/^/LEX: /' > wakeup/wakeup_lexicon.txt
RUN cat wakeup/wakeup_lexicon.txt wakeup/wakeup_word.txt > /uasr-data/db-hsb-asr-exp/common/grm/wakeup_word.txt

RUN UASR_HOME=uasr /dLabPro/bin.release/dlabpro /UASR/scripts/dlabpro/tools/REC_PACKDATA.xtp dlg /uasr-data/db-hsb-asr-exp/common/info/wakeup_word.cfg

###################################################################
# Package merged active grammar with word classes for recognition 
###################################################################

# active grammar specific config
COPY inputs/cfg/digidom.cfg   /uasr-data/db-hsb-asr-exp/common/info/

# copy openFST language model
RUN cp /merge/combined_uasr_grammar.txt_ofst.txt   /uasr-data/db-hsb-asr-exp/common/grm/
RUN cp /merge/combined_uasr_grammar.txt_lex.txt    /uasr-data/db-hsb-asr-exp/common/grm/
# don't forget to copy the input and output symbol files!!! Packaging will not warn you if these are not found!
RUN cp /merge/combined_uasr_grammar.txt_ofst_is.txt   /uasr-data/db-hsb-asr-exp/common/grm/
RUN cp /merge/combined_uasr_grammar.txt_ofst_os.txt   /uasr-data/db-hsb-asr-exp/common/grm/

RUN UASR_HOME=uasr /dLabPro/bin.release/dlabpro /UASR/scripts/dlabpro/tools/REC_PACKDATA.xtp rec /uasr-data/db-hsb-asr-exp/common/info/digidom.cfg

##############################################
# Combine the two packaged grammars into one
##############################################

RUN mkdir /recognizer

# copy all output files for wakeup word dialogue grammar
RUN cp /grm_wakeup_word/* /recognizer

# add script for merging of packaged grammars
COPY tools/replace_rn.xtp /recognizer

# merge the active grammar (second argument) into the dialogue grammar (first argument)
RUN cd recognizer && /dLabPro/bin.release/dlabpro replace_rn.xtp sesinfo.object ../grm_active/sesinfo.object

######################################
# Respeaker USB stuff
######################################

# code to reconfigure the LEDs
RUN apt install -y python-setuptools libusb-1.0-0 python3-libusb1

RUN git clone https://github.com/ZalozbaDev/pixel_ring.git pixel_ring
RUN cd pixel_ring && git checkout 1a93e279f92bca31a78e52f1aa5658015643a6f7

RUN cd pixel_ring && python3 setup.py install

###################################
# Add scripts for running and reactions
###################################

COPY config/* /dLabPro/bin.release/

COPY startme.sh /

# prepare folder for bind-mount of scripts
RUN mkdir /scripts/

CMD ["/bin/bash", "-c", "/startme.sh"] 

# fetch SVGs of resulting grammar and all other data for recognition
## mkdir -p output 
## docker run --mount type=bind,source="$(pwd)"/output,target=/output/ -it digidom_spoznawanje cp -r /recognizer /output/ 


# run demo manually:
## docker run --privileged -it digidom_spoznawanje /bin/bash
## python3 /pixel_ring/examples/usb_mic_array_custom.py
## cd dLabPro/bin.release/
## ./recognizer -cfg recognizer.cfg -out vad -d 4 | grep -v pF
