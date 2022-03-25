# Spóznawanje rěče - digidom

Přikład z Raspberry Pi 4.

Za tutón přikład trjeba so přidatne:
* "EXPLORER 500": https://joy-it.net/de/products/RB-EXP500
* "Respeaker 4 Mic Array": https://wiki.seeedstudio.com/ReSpeaker_4_Mic_Array_for_Raspberry_Pi/
* (fakultatiwne) "ReSpeaker USB Mic Array": https://wiki.seeedstudio.com/ReSpeaker-USB-Mic-Array/
    * zajimawa alternatiwa, kiž funguje lěpje při wulkim wotstawku rěčnika abo pódlanskeho šuma

Prošu změniće jumpery na EXP500 kaž na tutym wobrazu:

![EXP500 jumper settings](jumper_settings_exp500.jpg)

# Software

Sćěhowaca software dyrbi so instalować:

* docker
* docker-compose

Tutón nawod sćahnyće tak:

```console
git clone https://github.com/ZalozbaDev/raspberry_pi_demo_spoznawanje.git
```

Zakładny container twariće tak (hlej tež započatk "Dockerfile"):

```console
docker build -t digidom_spoznawanje .
```

Container wuwjesće tak:

```console
# wužiwajo "Respeaker 4 Mic Array"
docker-compose -f docker-compose-respeaker.yml up -d

# wužiwajo "ReSpeaker USB Mic Array"
docker-compose -f docker-compose-usb-respeaker.yml up -d
```

# Akustiska adapcija

Adapcija na rěčnika a wužiwany mikrofon zlěpši wukon tutoho prototypa.
Drobnosće k technologiji adapcije su tule wopisowane: https://github.com/ZalozbaDev/speech_recognition_acoustic_model_training/tree/main/step4_speaker_adaptation

Za wopisanje hromadźenja trěbnych nahrawanjow a přewjedźenje adapcije prošu hladajće do rjadowaka "adaptation".

Ručež předleži adaptowany model, móže so do containera zatwarić.

Container wužiwajo adaptowany model twariće tak (hlej tež započatk "Dockerfile"):

```console
docker build --build-arg USE_ADAPTED_MODELS=true -t digidom_spoznawanje .
```

Po tym so container móže na samsne wašnje wužiwać.

# Přiměrjenje

Za přiměrjenje abo zatwar nowych funkcijach su změny we tutych datajach trěbne: 

* "inputs/corpus/smartlamp_base.corp"
    * słowa kóždeje sady so awtomatisce zapisaja do fonetiskeho leksikona
* "inputs/uasr_grammar/digidom.txt"
    * nawod namakaće tule: https://zalozbadev.github.io/UASR/manual/automatic/tools/REC_PACKDATA.xtp.html#dlg_dlgfiles
* "scripts/reaction.sh"
    * tu so napisa, kak ma prototyp reagować, jeli je komando spóznał

# Licenca

Hlej dataja "LICENSE".

