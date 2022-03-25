# Speechrecorder za Raspberry Pi

Bohužel so program "BAS Speechrecorder" njemóže jednorje na Raspberry Pi wuwjesć.
Z pomocy technologiji "docker" spytamy so tutoho problema wuhibać.

Sćěhowace kročele su trěbne:

* Container twarić:

```console
docker build -t bas_speechrecorder_pi .
```

* Awtentifikaciju za wuwjedźenje grafiskeho programa we containeru namakać:

```console
xauth list
```

Jeli namakajće wjacore zapiski, wuzwolće tón, kiž ma "/unix" we mjenu. Přikład:

```console
raspbery-pi/unix:51  MIT-MAGIC-COOKIE-1  XYZABCatdatdatd
```

* Wuwjesće program we containeru tak (zasadźiće wašu awtentifikaciju):

```console
docker run --privileged -it --net=host -e DISPLAY -v /tmp/.X11-unix \
--mount type=bind,source="$(pwd)"/RECS,target=/root/speechrecorder/HSB-1/RECS \ 
--env HOST_MAGIC_COOKIE="raspbery-pi/unix:51  MIT-MAGIC-COOKIE-1  XYZABCatdatdatd" \ 
bas_speechrecorder_pi /startme.sh
```

Jeli pokaza so powjerch programa, běše wuwjedźenje wuspěšne.
