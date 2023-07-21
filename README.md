# arch-install

## About

A simple __Arch Linux__ installer script.

## Summary

Includes:

 - fastest local region reflector mirrors
 - arch linux base
 - configs:
   - locale - `/etc/locale.conf`
   - timezone - `/usr/share/zoneinfo`
   - hosts - `/etc/hosts`
   - hostname
   - user + sudoers
   - enable 32-bit mirrors - `/etc/pacman.conf`
 - drivers
   - cpu microcode - `intel`
   - gpu drivers - `intel` + `nvidia`
 - display server - `x11`
 - bootloader - `refind` + `grub`
 - desktop environments - `awesome` + `i3` + `xfce` + `gnome`
 - applications
   - audio - `pavucontrol`
   - bluetooth - `blueman`
   - network - `network-manager`
   - other additional packages...
  - AUR - `yay`
  - HOOKS - `/etc/mkinitcpio.conf`
  - swapfile + hibernation


## Instructions

1. Prepare a disk partition and mount for example:

```bash
# LVM on LUKS in dualboot

# 1. Create LUKS container
$ cryptsetup luksFormat /dev/<sdX>

# 2. Open LUKS container
$ cryptsetup luksOpen /dev/<sdX> cryptlvm

# 3. Create LVM physical volume
$ pvcreate /dev/mapper/cryptlvm

# 4. Create LVM volume group
$ vgcreate MyVolGroup /dev/mapper/cryptlvm

# 5. Create logical volumes in the group
$ lvcreate -L <SIZE>G MyVolGroup -n <NAME>
$ lvcreate -l 100%FREE MyVolGroup -n <NAME>

# 6. Format the new volume
$ mkfs.ext4 /dev/MyVolGroup/<NAME>

# 7. Mount volumes and boot partition
$ mount /dev/MyVolGroup/<NAME> /mnt
$ mount --mkdir /dev/<BOOT_PARTITION> /mnt/
```

2. You may need to install `git` first:
```bash
$ pacman -Syy git
```

3. Clone repo:
```bash
$ git clone https://github.com/jhwshin/arch-install.git
```

4. Edit installer configs:
```bash
$ cd arch-install
$ nano arch-install.sh
```

5. Run installer:
```bash
$ bash arch-install.sh
```

6. You may needto edit kernel parameters in bootloader depending on which stack you chose (e.g LUKS, LVM, ext4, etc...) - `/mnt/boot/refind.conf`

```ini
rd.luks.name=<DEVICE_UUID>=cryptlvm root=/dev/MyVolGroup/root
```

When the install is complete you can chroot back to `/mnt` to modify or verify then exit to leave chroot:
```bash
$ arch-chroot /mnt
$ exit
```

7. Unmount and restart system:
```bash
$ umount -R /mnt
$ reboot
```

## Extras

rEFIND Theme - [refind-dreary fork](https://www.github.com/jhwshin/refind-dreary.git)

dotfiles - [jhwshin dotfiles](https://www.github.com/jhwshin/.dotfiles.git)

## TODO

 - dualboot fixes
