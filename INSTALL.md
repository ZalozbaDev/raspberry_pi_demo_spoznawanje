# install

- Raspberry Pi imager
    - Modell: Pi 4
    - Image: Other --> Raspberry Pi OS Lite (64 Bit)
    - Nastajenja:
        * Wifi
        * tastatura
        * hesło
        * ssh
    - SD-Kartu pisać

- boot, connect via SSH

```code
 ssh -l pi raspberrypi
```

- add required packages

```code
sudo apt update
sudo apt install docker.io git docker-compose
sudo systemctl enable docker
sudo adduser pi docker
sudo reboot
```

- install seeed microphone driver

```code
git clone https://github.com/ZalozbaDev/seeed-voicecard.git
cd seeed-voicecard
git checkout v6.6
sudo ./install.sh
sudo reboot
# test driver 
arecord -L
```

- LEDs nastajić

```code
sudo raspi-config
# Interace Options --> SPI --> yes
```

- žórła wobstarać a container twarić

```code
git clone https://github.com/ZalozbaDev/raspberry_pi_demo_spoznawanje.git
cd raspberry_pi_demo_spoznawanje/
git checkout dolnoserbski
docker build -t digidom_spoznawanje .
```

docker-compose -f docker-compose-respeaker.yml up -d
docker-compose -f docker-compose-respeaker.yml logs -f

