FROM debian:bullseye-slim
MAINTAINER Daniel Sobe <daniel.sobe@sorben.com>

# normal call
# docker build -t digidom_spoznawanje_adapcija .

# rebuild from scratch
# docker build -t digidom_spoznawanje_adapcija . --no-cache

# enable in case you want to install tools from contrib or non-free
# RUN sed -i 's/ main/ main contrib non-free/' /etc/apt/sources.list

RUN apt update

# generic tools install 
RUN apt install -y g++ make git procps nano

##########################################
# Build dlabpro software (python wrapper)
##########################################

RUN git clone https://github.com/ZalozbaDev/dLabPro.git dLabPro
RUN cd dLabPro && git checkout 8b8a01b973356f974c4083510fa0275a4e53cf40

# need to build the C++ part first
RUN apt install -y libreadline-dev portaudio19-dev
RUN cd dLabPro && make -C programs/dlabpro RELEASE

# the python wrapper probably needs these deps anyway
RUN apt install -y python3 python3-numpy python3-matplotlib python3-yaml

# additional python deps for building the wrapper
RUN apt install -y python3-distutils cython3

# now build the python wrapper
RUN cd dLabPro/programs/python && ./setup.py build && ./setup.py install

############################################
# Fetch UASR tooling
############################################

RUN git clone https://github.com/ZalozbaDev/UASR.git UASR
RUN cd UASR && git checkout 8ff6eb727dc303fff4c5556574caa0dae204a3e6

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
# Process text corpus to generate phonetical lexicon
#######################################################

RUN mkdir -p corpus/

COPY inputs/corpus/adaptation.corp          /corpus/
COPY inputs/phoneme_rules/exceptions_v3.txt /corpus/
COPY inputs/phoneme_rules/phonmap_v3.txt    /corpus/
COPY tools/BASgenerator.py                  /corpus/
COPY inputs/cfg/adaptation.yaml             /corpus/

RUN apt install -y python3 python3-numpy python3-matplotlib python3-yaml

RUN cd corpus && python3 BASgenerator.py adaptation.yaml || /bin/true

##########################################################
# Collect all files and actually run the adaptation
##########################################################

# the acoustic model(s) are taken from a repo, because we are not modifying them here (just repackaging)
RUN git clone https://github.com/ZalozbaDev/speech_recognition_pretrained_models speech_recognition_pretrained_models
RUN cd speech_recognition_pretrained_models && git checkout 7f59924e254283498c87e0f7e4638ef850b58571

# copy all files required to run adaptation
RUN mkdir -p uasr-data/db-hsb-asr/HSB-01/flists uasr-data/db-hsb-asr/HSB-01/log uasr-data/db-hsb-asr/HSB-01/info uasr-data/db-hsb-asr/HSB-01/lexicon uasr-data/db-hsb-asr/HSB-01/model

COPY uasr-data/db-hsb-asr/HSB-01/info/*                          uasr-data/db-hsb-asr/HSB-01/info/

# these were generated just before
RUN cp /corpus/uasr_configurations/info/classes.txt              uasr-data/db-hsb-asr/HSB-01/info/
RUN cp /corpus/uasr_configurations/lexicon/adaptation_sampa.ulex uasr-data/db-hsb-asr/HSB-01/lexicon/

COPY inputs/flists/*                                             uasr-data/db-hsb-asr/HSB-01/flists/

# copy pretrained acoustic model
RUN cd speech_recognition_pretrained_models && cp 2022_02_21/3_7.hmm 2022_02_21/feainfo.object /uasr-data/db-hsb-asr/HSB-01/model/

# copy the adaptation recordings and transliterations
RUN mkdir -p uasr-data/db-hsb-asr/common/sig/ADP/RECS/ uasr-data/db-hsb-asr/common/trl/ADP/  

COPY speechrecorder/RECS/             uasr-data/db-hsb-asr/common/sig/ADP/RECS/
COPY inputs/trl/ADP                   uasr-data/db-hsb-asr/common/trl/ADP/

# now actually run the adaptation
RUN UASR_HOME="uasr" /dLabPro/bin.release/dlabpro UASR/scripts/dlabpro/HMM.xtp adp uasr-data/db-hsb-asr/HSB-01/info/adapt.cfg

# just a default instruction, might be handy
CMD ["/bin/bash"]

#########################################################
# how to fetch the trained models from the container
#########################################################

## mkdir -p output && rm -rf ./output/* 
## docker run --mount type=bind,source="$(pwd)"/output,target=/output/ -it speech_recognition_acoustic_model_training_step4 cp -r /uasr-data/db-hsb-asr/HSB-01/model/ /output/
