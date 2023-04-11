#!/usr/bin/env bash

# ================================================
#       Arch Installer by jhwshin
# ================================================

# print input commands
# set -x

# interactive and verify install
DEBUG_MODE=true

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#       START OF CONFIG
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# reflector --list-countries
MIRROR_REGIONS="AU,NZ"

# less /etc/locale.gen
# localectl list-locales
LOCALE_GEN=(
    "en_AU.UTF-8 UTF-8"
    "en_US.UTF-8 UTF-8"
)
LOCALE_SYSTEM="en_AU.UTF-8"
# ls /usr/share/zoneinfo/<REGION>/<CITY>
TIMEZONE_REGION="Australia"
TIMEZONE_CITY="Sydney"
USERNAME="USER"
HOSTNAME="ARCH"

# choose one - intel | amd
CPU="intel"
# choose any - intel | nvidia
GPU=(
    "intel"
    #"nvidia"
)
# choose one - refind | grub
BOOTLOADER="refind"

BASE_PACKAGES=(
    base
    base-devel
    linux-api-headers
    linux-firmware
    linux
    linux-headers
    linux-lts                   # lts for backup
    linux-lts-headers
    git
    nano
    nano-syntax-highlighting
    xdg-utils
    xdg-user-dirs
)

DE=(
    i3
    dmenu
    xfce4
    xfce4-goodies
    gnome
    gnome-extra
    # add more here...
)

ADDITIONAL_PACKAGES=(
    alsa-utils
    pavucontrol
    networkmanager
    network-manager-applet
    bluez
    bluez-utils
    blueman
    ntfs-3g
    openssh
    lvm2
    reflector
    # add more here...
)
AUR_PACKAGES=(
    firefox         # web browser
    # alacritty     # terminal emulator
    # barrier        # kvm
    # deluge         # torrent
    # syncthing      # network file sync
    # samba          # network file
    # vlc            # media player
    # mpv            # media player
    # visual-studio-code-bin     # code editor
)

SYSTEMD_STARTUPS=(
    NetworkManager
    bluetooth
    # sshd
    # reflector
    # reflector.timer
    # add more here...
)

# non-systemd - (inc. all)
# HOOKS="( base udev autodetect keyboard keymap consolefont modconf block encrypt lvm2 filesystems resume fsck )"

# systemd - (inc. all)
# HOOKS="( base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt lvm2 filesystems resume fsck )"

#   LUKS        - encrypt | sd-encrypt
#   LVM         - lvm2
#   Hibernation - resume
HOOKS="( base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt lvm2 filesystems resume fsck )"

# 0 = NO SWAPFILE
SWAPFILE_SIZE=17408             # (MB) = 17 GB

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
#   END OF CONFIG
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# ------------------------------------------------
#   Package Bundles
# ------------------------------------------------

XORG_PACKAGES=(
    xorg
    xorg-apps
)

GPU_INTEL_PACKAGES=(
    xf86-video-intel
    mesa
    lib32-mesa
    vulkan-intel
    lib32-vulkan-intel
)

GPU_NVIDIA_PACKAGES=(
    # nvidia
    # nvidia-lts
    nvidia-dkms
    nvidia-utils
    lib32-nvidia-utils
    nvidia-settings
)

# ------------------------------------------------
#   Helper Functions
# ------------------------------------------------

debug_halt() {
    if ${DEBUG_MODE}; then
        echo ">> Press ANY key to continue."
        read
        clear
    fi
}

# ------------------------------------------------
#   Pre-chroot Functions
# ------------------------------------------------

update_mirrorlist() {
    echo ">> Updating Mirrorlist..."

    # create backup mirrorlist incase
    cp -v /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

    # pacman -Syy archlinux-keyring --noconfirm
    # pacman-key --refresh-keys

    # get fastest mirrors
    reflector -c "${MIRROR_REGIONS}"  --latest 10 --number 10 --sort rate --save /etc/pacman.d/mirrorlist

    # verify
    cat /etc/pacman.d/mirrorlist

    debug_halt
}

pacstrap_arch() {
    echo ">> Installing Arch Base..."

    # sometimes keys become invalid so it is best to download the latest to prevent errors
    pacman -Syy archlinux-keyring --noconfirm

    # install base packages to root mount
    pacstrap /mnt ${BASE_PACKAGES[*]} --noconfirm

    # verify
    cat /mnt/var/log/pacman.log | head -n 1

    debug_halt
}

generate_fstab() {
    echo ">> Starting Chroot..."

    # use UUID for fstab
    genfstab -U /mnt > /mnt/etc/fstab

    # verify
    cat /mnt/etc/fstab

    debug_halt
}

start_chroot() {
    echo ">> Starting Chroot..."

    SCRIPT_NAME=$(basename "${0}")
    FULL_PATH=$(realpath "${0}")

    # copy over this script to new root
    cp -v ${FULL_PATH} /mnt/home

    # chroot and execute this script in --chroot mode
    arch-chroot /mnt sh /home/${SCRIPT_NAME} --chroot

    # clean up copied script
    rm /mnt/home/${SCRIPT_NAME}

    echo ">> Leaving Chroot..."

    debug_halt
}

# ------------------------------------------------
#   chroot functions
# ------------------------------------------------

set_locale() {
    echo ">> Setting Locale..."

    # select locales
    for locale in ${LOCALE_GEN[@]}; do
        sed -i "/^#${locale}/ s/^#//" /etc/locale.gen
    done

    # generate locales
    locale-gen

    # set system language
    echo "LANG=${LOCALE_SYSTEM}" > /etc/locale.conf

    # verify
    cat /etc/locale.conf

    debug_halt
}

set_timezone() {
    echo ">> Setting Timezone..."

    # create symlink to timezone
    ln -sfv /usr/share/zoneinfo/${TIMEZONE_REGION}/${TIMEZONE_CITY} /etc/localtime

    # sync hardware clock
    hwclock --systohc -v

    # verify
    ls -l /etc/localtime

    debug_halt
}

set_hosts() {
    echo ">> Setting Hosts..."

    # loopback ip to localhost in ipv4 and ipv6
    echo "127.0.0.1         localhost" >> /etc/hosts
    echo "::1               localhost" >> /etc/hosts

    # verify
    cat /etc/hosts

    debug_halt
}

set_hostname() {
    echo ">> Setting Hostname..."

    echo ${HOSTNAME} > /etc/hostname

    # verify
    cat /etc/hostname

    debug_halt
}

set_user() {
    echo ">> Setting Up Users..."

    # create user and add to group wheel
    useradd -m ${USERNAME} -G wheel

    # add user to sudoers
    EDITOR="sed -i '/^# %wheel ALL=(ALL:ALL) ALL/ s/^# //'" visudo

    # password for user
    echo ">> Enter password for ${USERNAME}:"
    passwd ${USERNAME}

    # password for root
    echo ">> Enter password for root:"
    passwd

    # verify
    cat /etc/sudoers
    cat /etc/passwd

    debug_halt
}

edit_pacman() {
    echo ">> Editing pacman.conf..."

    # change misc options in pacman
    sed -i "/^#UseSyslog/ s/^#//" /etc/pacman.conf
    sed -i "/^#Color/ s/^#//" /etc/pacman.conf
    sed -i "/^#VerbosePkgLists/ s/^#//" /etc/pacman.conf
    sed -i "/^#ParallelDownloads/ s/^#//" /etc/pacman.conf

    # add 32-bit source
    sed -i '/^#\[multilib\].*/,+1 s/^#//' /etc/pacman.conf

    # refresh pacman mirrors
    pacman -Syy

    # verify
    cat /etc/pacman.conf | grep "# Misc options" -A 6
    cat /etc/pacman.conf | grep "\[multilib\]" -A 1

    debug_halt
}

install_cpu_microcode() {
    echo ">> Installing CPU Microcode..."

    case ${CPU} in
        "intel")
            pacman -S intel-ucode --noconfirm
        ;;
    esac

    debug_halt
}

install_display_server() {
    echo ">> Installing Display Server..."

    pacman -S ${XORG_PACKAGES[*]} --noconfirm

    debug_halt
}

install_gpu_drivers() {
    echo ">> Installing GPU Drivers..."

    for gpu in ${GPU[@]}; do
        case ${gpu} in
            "intel")
                pacman -S ${GPU_INTEL_PACKAGES[*]} --noconfirm
            ;;
            "nvidia")
                pacman -S ${GPU_NVIDIA_PACKAGES[*]} --noconfirm

                # generate nvidia xorg
                nvidia-xconfig

                # create pacman hook to rebuild kernel when nvidia is updated
                mkdir /etc/pacman.d/hooks
                nvidia_systemd="[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia
Target=nvidia-dkms
Target=nvidia-utils
Target=lib32-nvidia-utils
Target=linux
Target=linux-lts
# add more kernels here...

[Action]
Description=Update Nvidia module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg; do case $trg in linux) exit 0; esac; done; /usr/bin/mkinitcpio -P'
"
                echo "${nvidia_systemd}" > /etc/pacman.d/hooks/nvidia.hooks
                #systemctl enable nvidia.hooks

                # enable nvidia powersaving for suspend / hibernate
                systemctl enable nvidia-hibernate
                systemctl enable nvidia-suspend
                systemctl enable nvidia-resume
            ;;
        esac

        # fix?
        sleep 5
    done

    debug_halt
}

setup_swapfile() {

    if [[ ${SWAPFILE_SIZE} -gt 0 ]]; then
        echo ">> Creating Swapfile..."

        # create new swapfile given size and make sure its zeroed out
        dd if=/dev/zero of=/swapfile bs=1M count=${SWAPFILE_SIZE} status=progress

        # change permission
        chmod 600 /swapfile

        # make and turn on swap
        mkswap /swapfile
        swapon /swapfile

        # add swapfile to fstab
        echo "/swapfile     none    swap    defaults    0   0" >> /etc/fstab

        debug_halt
    else
        echo ">> Skipping Swapfile..."
        debug_halt
    fi
}

install_bootloader() {
    echo ">> Installing Bootloader..."

    root_part=$(mount | grep -oP '(?<=^)/dev/.*(?= on / )')
    uuid=$(lsblk $root_part -n -o UUID)

    # add swapfile resume parameter
    resume_parameters=""
    if [[ ${SWAPFILE_SIZE} -gt 0 ]]; then

        # swap offset location required for /swapfile
        swap_offset=$(filefrag -v /swapfile | sed -n 4p | awk '{print $4}' | grep -o [0-9]*)

        # final kernel parameter to add to bootloader
        resume_parameters="resume=${root_part} resume_offset=${swap_offset}"
    fi

    case ${BOOTLOADER} in
        "refind")
            pacman -S refind --noconfirm

            # install refind to /boot
            refind-install

            # refind entries (bug fix)
            echo "\"Boot with standard options\" \"root=UUID=${uuid} rw ${resume_parameters}\"" > /boot/refind_linux.conf

            # verify
            cat /boot/refind_linux.conf
        ;;
        "grub")

            pacman -S grub efibootmgr os-prober --noconfirm

            # install refind to /boot
            grub-install

            # add resume to grub entry
            sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=/& ${resume_parameters}/" /etc/default/grub

            # generate grub configs
            grub-mkconfig -o /boot/grub/grub.cfg
        ;;
    esac

    debug_halt
}

install_desktop_env() {
    echo ">> Installing Desktop Environment..."

    pacman -S ${DE[*]} --noconfirm

    # copy over default xinitrc
    cp /etc/X11/xinit/xinitrc /home/${USERNAME}/.xinitrc

    # comment out xorg and xorg-apps
    sed -i '/^twm .*/,+4 s/^/#/' /home/${USERNAME}/.xinitrc

    # add another de to run with 'startx'
    printf "\nexec i3\n" >> /home/${USERNAME}/.xinitrc
    echo "#exec xfce4-session" >> /home/${USERNAME}/.xinitrc
    echo "#exec gnome-session" >> /home/${USERNAME}/.xinitrc

    # change owner of .xinitrc
    chown ${USERNAME}:${USERNAME} /home/${USERNAME}/.xinitrc

    # verify
    cat /home/${USERNAME}/.xinitrc

    debug_halt
}

install_basic_packages() {
    echo ">> Installing Basic Packages..."

    pacman -S ${ADDITIONAL_PACKAGES[*]} --noconfirm

    systemctl enable ${SYSTEMD_STARTUPS[*]}

    debug_halt
}

install_aur() {
    echo ">> Installing AUR..."

    # leave root
    su - ${USERNAME} << EOF
cd && git clone https://aur.archlinux.org/yay
cd yay && makepkg -si --noconfirm
cd .. && rm -rf yay
exit
EOF

    # install AUR packages
    yay -Syy ${AUR_PACKAGES[*]} --noconfirm

    debug_halt
}

rebuild_initramfs() {
    echo ">> Rebuilding Initramfs..."

    # replace HOOKS array - tofix?
    sed -i "s/^HOOKS=.*/HOOKS=${HOOKS}/" /etc/mkinitcpio.conf

    # rebuild
    mkinitcpio -P

    # verify
    cat /etc/mkinitcpio.conf | grep '^HOOKS=.*'

    debug_halt
}

# ------------------------------------------------
#   Main Function
# ------------------------------------------------

main() {

    # pre-chroot functions
    if [[ $# -eq 0 ]]; then

        echo ">> Starting Arch Install..."

        update_mirrorlist
        pacstrap_arch
        generate_fstab
        start_chroot

        exit

        echo ">> Arch Install Finished!"

    # chroot functions
    elif [[ ${1} == "--chroot" ]]; then

        # setting basic system configurations
        set_locale
        set_timezone
        set_hosts
        set_hostname
        set_user
        edit_pacman

        # setting up drivers, packages, environment
        install_cpu_microcode
        install_display_server
        install_gpu_drivers
        setup_swapfile
        install_bootloader
        install_desktop_env
        install_basic_packages
        install_aur

        rebuild_initramfs

    fi
}

# ------------------------------------------------

# need to pass "--chroot parameter" if specified
main $@

# ------------------------------------------------

# refind_linux.conf - options for luks boot lvm etc..
# glxinfo?
# ntp?
# dualboot timefix
# timedatectl set-local-rtc 1 --adjust-system-clock
# hwclock --systohc --localtime
# gdm vs lightdm?
