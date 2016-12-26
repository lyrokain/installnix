loadkeys de
echo ",,83,*"|sfdisk /dev/sda
mkfs.ext4 -L nixos /dev/sda1
mount /dev/disk/by-label/nixos /mnt
nixos-generate-config --root /mnt
nix-env --install git
git clone https://github.com/lyrokain/installnix /mnt/etc/nixos/

# cp /etc/nixos/
# nano /mnt/etc/nixos/configuration.nix
time nixos-install
