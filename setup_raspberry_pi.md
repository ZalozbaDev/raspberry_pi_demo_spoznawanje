# Nawod

## SD-Kartu přihotować

* wobstarajće sebi "Raspberry Pi Imager": https://www.raspberrypi.com/software/
* wuzwolće "Raspberry Pi OS (64 bit) Desktop"
* w nastajenjach zapodajće daty za WLAN a zaswěčće přistup přez SSH (wužiwarske mjeno a hesło)
    * alternatiwa: wužiwajće tastaturu, myšku a wobrazowku (wosebity HDMI kabel) a změnće nastajenja po zaswěćenju
    systema direktnje
    
## System nastajić

* zalogujće so přez SSH abo dźěłajće direktnje na systemje
* wšitke komanda w terminalu wuwjesć:

```console
sudo bash
apt update
apt dist-upgrade
reboot
```

* system znowa startuje

```console
sudo bash
apt install git docker docker-compose
systemctl enable docker
docker run hello-world
```

* wuslědk dyrbi wuspěšny być

```console
git clone https://github.com/ZalozbaDev/seeed-voicecard.git
cd seeed-voicecard
git checkout v6.1
./install.sh
reboot
```

* system znowa startuje

```console
sudo bash
arecord -l
```

* zwukowa karta "seeed4mic..." dyrbi so pokazać

```console
raspi-config
```

* 3 Interface options
    * I3 SPI
        * Yes
* Finish

```console
git clone https://github.com/ZalozbaDev/raspberry_pi_demo_spoznawanje.git
cd raspberry_pi_demo_spoznawanje
docker build -t digidom_spoznawanje .
docker-compose -f docker-compose-respeaker.yml up -d
```

* LED3 započnje so swěčić --> system poska
