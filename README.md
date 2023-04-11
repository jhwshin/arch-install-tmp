# arch-install

## About

Installer includes:
- base arch install
- set locale + timezone
- set hosts
- set hostname
- set username + passwords + sudoers
- edit pacman.conf - options + 32-bit mirrors
- install cpu microcode - `intel`
- install gpu drivers - `intel` + `nvidia`
- install display server - `x11`
- install bootloader - `rEFIND` + `GRUB`
- install desktop environments - (`i3`, `xfce`, `gnome`)
- install basic applications
    -   audio - `pavucontrol`
    -   bluetooth - `blueman`
    -   network - `network-manager`
    -   see `ADDITIONAL_PACKAGES` in script for more...
- AUR - `yay`
- edit mkinitcpio.conf `HOOKS`
- swapfile and hibernation

For more details on this script, refer to [DETAILED INSTRUCTIONS](https://github.com/jhwshin/arch-install/wiki) for a dualboot (Windows + Linux) system.

## Instructions

1.  Follow steps in the [wiki](https://github.com/jhwshin/arch-install/wiki/2.-Arch-Linux-Install#1-bootable-usb) prior to running this script:
    - Bootable USB
    - Disk Partition
    - Preparation

2. You may need to install `git` first:
```bash
$ pacman -Syy git
```

2. Clone repo:
```bash
$ git clone https://github.com/jhwshin/arch-install.git
```

3. Edit installer configs:
```bash
$ cd arch-install
$ nano arch-install.sh
```

4. Run installer:
```bash
$ bash arch-install.sh
```

When the install is complete you can chroot back to `/mnt` to modify or verify then exit to leave chroot:
```bash
$ arch-chroot /mnt
$ exit
```

6. Unmount and restart system:
```bash
$ umount -R /mnt
$ reboot
```
