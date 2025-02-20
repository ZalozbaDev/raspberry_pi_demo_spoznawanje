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
sudo apt install docker.io git
sudo systemctl enable docker
sudo adduser pi docker
sudo reboot
```

- žórła wobstarać

```code
git clone https://github.com/ZalozbaDev/raspberry_pi_demo_spoznawanje.git
cd raspberry_pi_demo_spoznawanje/
git checkout dolnoserbski
```

- container twarić

```code
docker build -t digidom_spoznawanje .
```

