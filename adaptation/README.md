# Adapcija

## Zakładne informacije

Za adapciju na rěčnika a mikrofon su 40 nahrawanych sadow trěbnych. 
Wone maja předležeć w rjadowaku "speechrecorder/RECS/0001/".

Dataje dyrbja pomjenowane być z "0001HSB_1_000.wav" ... "0001HSB_1_039.wav", a kóžda
dataja wobsahuje tekst kaž wopisowany w dataji "speechrecorder/config/HSB-1/HSB-1.prt".
Format kóždeje dataje je 16kHz, 1 kanal a 16 bit.

## Nahrawanja

Za nahrawanje móže so mjez druhim program "BAS Speechrecorder" (https://www.bas.uni-muenchen.de/Bas/software/speechrecorder/) wužiwać.

Jeli wužiwaće USB mikrofon, móžeće sebi program na swójski ličak instalować a tam wuwjesć. 
Wotpowědny projekt namakajće w rjadowaku "speechrecorder/config". 

Za nahrawanja, wužiwajo mikrofon "Respeaker 4 Mic Array", je wuwjedźenje direktnje na Raspberry Pi trěbne. Za to
namakaće nawod w rjadowaku "speechrecorder".

## Wuwjedźenje adapcije

Ručež předleža nahrawanja, wuwjedźe so adapcija na sćěhowace wašnje:

Container za adapciju so twari takle:

```console
docker build -t digidom_spoznawanje_adapcija .
```

Po wuspěšnym wuwjedźenju maja so wuslědki do wosebiteho rjadowaka kopěrować:

```console
docker run --mount type=bind,source="$(pwd)"/output,target=/output/ -it digidom_spoznawanje_adapcija cp -r /uasr-data/db-hsb-asr/HSB-01/model/ /output/
```

Nětko je wšitko přihotowane za nowotwar digidom-containera.
