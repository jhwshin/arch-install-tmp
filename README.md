# arch-install

## About

A simple Arch Linux installer script written for myself.

Still learning so please be careful not to blindly copy / paste commands as they may not suit and break your system.

## Summary

- Dual Boot Compatible - `Windows` + `Linux`
- File System - `BTRFS` (CoW) on `LUKS` (Encryption)
- Bootloader - `rEFIND`
- Secure Boot - `shim-signed` + `sbsigntools` (MOK)
- Kernels - `linux` + `linux-lts` + `linux-zen`
- Drivers
  - CPU - `intel`
  - GPU - `nvidia-dkms` + `intel`
- Display Server - `X11`
- Display Manager - `lightdm`
- Desktop Environment - `i3` + `xfce` + `gnome`
- Applications
  - Audio - `pavucontrol`
  - Bluetooth - `blueman`
  - Network `NetworkManager` + `iwd` (backend)
  - AUR - `yay`
  - Other additional packages...
- Swap File + Hibernation
- Configs
  - Locale - `/etc/locale.gen` + `/etc/local.conf`
  - Timezone - `/etc/localtime`
  - Hosts - `/etc/hosts`
  - Hostname - `/etc/hostname`
  - Users + Sudoers
  - Pacman + 32-bit Mirrors - `/etc/pacman.conf`
  - Reflector Mirrors - `/etc/reflector`
- HOOKS
  - `shim` - secure boot sign
  - `sbsigntools` - secure boot sign
  - `nvidia` - rebuild with kernel updates
  - `zsh` - refresh cache

## Instructions

0. Verify system is running on EFI

```bash
# if directory is populated system is EFI
$ ls /sys/firmware/efi/efivars

# remove residual NVRAM entries from past installs if required
# $ rm -rf /sys/firmware/efi/efivars/Boot*
```

1. Sync Clock

```bash
# sync system clock with network time
$ timedatectl set-ntp true
```

2. List Partition Table

```bash
# quick disk list
$ lsblk

# verbose disk list
$ fdisk -l

# if not dualbooting create partition table
# GPT (EFI) or MBR (BIOS)
$ fdisk /dev/<sdX>
```

3. Connect to WiFi

```bash
$ iwctl

# get network adapter
[iwd]# device list

# scan wifi networks
[iwd]# station <DEVICE> scan

# list wifi networks
[iwd]# station <DEVICE> get-networks

# connect to wifi network
[iwd]# station <DEVICE> connect <SSID>

# check connection
$ ping 8.8.8.8
```

4. Install git:

```bash
$ pacman -Syy
$ pacman -S git glibc
```

5. Clone repo:

```bash
$ git clone https://github.com/jhwshin/arch-install.git
```

6. Verify and edit installer configs - __!! IMPORTANT !!__

```bash
$ cd arch-install
$ nano arch-install.sh
```

7. Run Installer:

```bash
$ bash arch-install.sh
```

Once installation is complete you may can chroot back into `/mnt` to modify or make further changes

```bash
$ arch-chroot /mnt
```

8. Finally umount and restart system:

```bash
$ umount -R /mnt
$ reboot
```

9. After reboot setup secure boot if required:

```bash
# install secure boot tools
$ yay -S shim-signed sbsigntools

# trigger hooks by reinstalling package
$ yay -S refind linux
```
