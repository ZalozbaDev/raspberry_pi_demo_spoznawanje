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

```

