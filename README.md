# Spóznawanje rěče - digidom

Přikład z Raspberry Pi 4.

Za tutón přikład trjebaće přidatnje:
* "EXPLORER 500": https://joy-it.net/de/products/RB-EXP500
* "Respeaker 4 Mic Array": https://wiki.seeedstudio.com/ReSpeaker_4_Mic_Array_for_Raspberry_Pi/
* (fakultatiwne) "ReSpeaker USB Mic Array": https://wiki.seeedstudio.com/ReSpeaker-USB-Mic-Array/
    * zajimawa alternatiwa, kiž funguje lěpje, hdyž ma rěčnik wulki wotstawk abo hdyž je wulki pódlanski šum

Prošu změńće jumpery na EXP500 kaž na tutym wobrazu:

![EXP500 jumper settings](jumper_settings_exp500.jpg)

# Software

KEDŹBU! 64 bit hišće njefunguje, prošu zapisajće

* arm_64bit=0

do wašu "/boot/config.txt" a startujeće system znowa!


Sćěhowaca software dyrbi so instalować:

* docker
* docker-compose

Tule nawod za to:

```console
git clone https://github.com/ZalozbaDev/raspberry_pi_demo_spoznawanje.git
```

Zakładny container twariće sej takle (hlej tež započatk "Dockerfile"):

```console
docker build -t digidom_spoznawanje .
```

Container wuwjedźeće tak:

```console
# wužiwajo "Respeaker 4 Mic Array"
docker-compose -f docker-compose-respeaker.yml up -d

# wužiwajo "ReSpeaker USB Mic Array"
docker-compose -f docker-compose-usb-respeaker.yml up -d
```

# Akustiska adapcija

Adapcija na rěčnika a wužiwany mikrofon zlěpši wukon tutoho prototypa.
Drobnosće k technologiji adapcije su tule wopisane: https://github.com/ZalozbaDev/speech_recognition_acoustic_model_training/tree/main/step4_speaker_adaptation

Za wopisanje hromadźenja trěbnych nahrawanjow a přewjedźenje adapcije hladajće prošu do rjadowaka "adaptation".

Ručež předleži adaptowany model, móže so do containera zatwarić.

Container wužiwajo adaptowany model twariće sej takle (hlej tež započatk dataje "Dockerfile"):

```console
docker build --build-arg USE_ADAPTED_MODELS=true -t digidom_spoznawanje .
```

Po tym móže so container na samsne wašnje wužiwać.

# Přiměrjenje

Za přiměrjenje funkcijow, abo zatwar nowych funkcijow su změny we tutych datajach trěbne: 

* "inputs/corpus/smartlamp_base.corp"
    * słowa kóždeje sady so awtomatisce zapisaja do fonetiskeho leksikona
* "inputs/uasr_grammar/digidom.txt"
    * nawod namakaće tule: https://zalozbadev.github.io/UASR/manual/automatic/tools/REC_PACKDATA.xtp.html#dlg_dlgfiles
* "scripts/reaction.sh"
    * tu so napisa, kak ma prototyp reagować, jeli je komando spóznał

Po tym container prošu znowa twarić.
    
# Licenca

Hlej dataja "LICENSE".

