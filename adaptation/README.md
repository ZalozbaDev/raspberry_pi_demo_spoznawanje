# Adapcija

## Zakładne informacije

Za adapciju na rěčnika a mikrofon su 40 nahrawane sady trěbne. 
Wone maja předležeć w rjadowaku "speechrecorder/RECS/0001/".

Dataje dyrbja pomjenowane być "0001HSB_1_000.wav" ... "0001HSB_1_039.wav", a kóžda
dataja wobsahuje tekst kaž wopisowane we dataje "speechrecorder/config/HSB-1/HSB-1.prt".
Format kóždej dataje je 16kHz, 1 kanal a 16 bit.

## Nahrawanja

Za nahrawanje je móžne wužiwać mjez druhim program "BAS Speechrecorder" (https://www.bas.uni-muenchen.de/Bas/software/speechrecorder/).

Jeli wužiwajće USB mikrofon, móžeće sebi program na swójski ličak instalować a tam wuwjesć. 
Wotpowědny projekt namakajće we rjadowaku "speechrecorder/config". 

Za nahrawanja wužiwajo mikrofon "Respeaker 4 Mic Array" je wuwjedźenje direktne na Raspberry Pi trěbne. Za to
namakajće nawod we rjadowaku "speechrecorder".

## Wuwjedźenje adapcije

Ručež předleža nahrawanja, wuwjedźe so adapcija sćěhowace:

Container za adapciju so twari tak:

```console
docker build -t digidom_spoznawanje_adapcija .
```

Po wuspěšnym wuwjedźenju maja so wuslědki do wosebiteho rjadowaka kopěrować:

```console
docker run --mount type=bind,source="$(pwd)"/output,target=/output/ -it digidom_spoznawanje_adapcija cp -r /uasr-data/db-hsb-asr/HSB-01/model/ /output/
```

Nětko je wšitko přihotowane za nowotwar digidom-containera.
