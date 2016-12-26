loadkeys de
echo ",,83,*"|sfdisk /dev/sda
mkfs.ext4 -L nixos /dev/sda1
mount /dev/disk/by-label/nixos /mnt
read -p "Press Enter to install git"
nix-env --install git
git clone https://github.com/lyrokain/installnix /mnt/etc/nixos/
read -p "Press Enter to list config directory"
ls /mnt/etc/nixos/
read -p "Press Enter to generate config.nix and hardware.nix"
nixos-generate-config --root /mnt
# cp /etc/nixos/
# nano /mnt/etc/nixos/configuration.nix
echo "run time nixos-install to install the system"
