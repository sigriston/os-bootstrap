#!/bin/bash

set -ex

# Time zone
# https://wiki.archlinux.org/index.php/Installation_guide#Time_zone
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

# Localization
# https://wiki.archlinux.org/index.php/Installation_guide#Localization
sed -i'' -e 's/#\(en_US\.UTF-8\)/\1/g' /etc/locale.gen
sed -i'' -e 's/#\(pt_BR\.UTF-8\)/\1/g' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

# Network configuration
# https://wiki.archlinux.org/index.php/Installation_guide#Network_configuration
echo "$NEWHOSTNAME" > /etc/hostname
cat <<EOF >> /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $NEWHOSTNAME.local  $NEWHOSTNAME
EOF

# Root password
# https://wiki.archlinux.org/index.php/Installation_guide#Root_password
echo 'Setting root password...'
passwd

# Boot loader
# https://wiki.archlinux.org/index.php/Installation_guide#Boot_loader
# https://wiki.archlinux.org/index.php/Arch_boot_process#Boot_loader
# https://wiki.archlinux.org/index.php/EFISTUB#efibootmgr
if [[ `systemd-detect-virt` == "none" ]]; then
  pacman -S intel-ucode
  INIT_PART='root=PARTLABEL=root rw initrd=\intel-ucode.img initrd=\initramfs-linux.img'
  BOOT_OPTIONS='acpi_backlight=vendor quiet loglevel=3 udev.log_priority=3 rd.systemd.show_status=auto rd.udev.log_priority=3 i915.fastboot=1 intel_iommu=on iommu=pt vsyscall=emulate resume=/dev/sda3'
else
  INIT_PART='root=PARTLABEL=root rw initrd=\initramfs-linux.img'
  BOOT_OPTIONS=''
fi

if [[ -d /sys/firmware/efi/efivars ]]; then
  efibootmgr --disk /dev/sda --part 1 --create --label 'Arch Linux' --loader /vmlinuz-linux --unicode "${INIT_PART} ${BOOT_OPTIONS}" --verbose
else
  # Install GRUB for BIOS
  # https://wiki.archlinux.org/index.php/GRUB#Installation
  pacman -S grub
  grub-install --target=i386-pc /dev/sda
  # https://wiki.archlinux.org/index.php/GRUB#Generate_the_main_configuration_file
  grub-mkconfig -o /boot/grub/grub.cfg
  sed -i'' -e "s/#?\\(GRUB_CMDLINE_LINUX\\).*$/\\1=\"${BOOT_OPTIONS}\"/g" /etc/default/grub
fi

# Clone this repo for post-install scripting
cd $HOME
git clone https://github.com/sigriston/os-bootstrap.git
