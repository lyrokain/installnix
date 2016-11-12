# Hypervisor:
# NixOS-System mit KVM

# Global Settings

hdd=sda
rootpassword=somesupersecretpassword.Change.this.right.now!
username=genericuser
userpassword=somesecretpassword.Change.this!
usersshkey=Put.gibberish.ssh.key.here!

# Insert code here to query user input for variables above

# Partitioning
# Turn whole disk into one volume group
# with four logical volumes: boot, system, data and swap
# all of which are formattet as ext4 or swap respectively
sfdisk --delete /dev/$hdd		# Remove old partition
dd if=/dev/zero of=/dev/$hdd bs=512 count=1
# echo ",,8e"|sfdisk /dev/$hdd
pvcreate /dev/$hdd
vgcreate marvin /dev/$hdd

lvcreate -L 1G -n boot marvin # Debugging size. For production use 5G
mkfs.ext4 -F /dev/marvin/boot
tune2fs -f -L boot /dev/marvin/boot 

lvcreate -L 5G -n system marvin # Debugging size. For production use 16G
mkfs.ext4 -F /dev/marvin/system
tune2fs -f -L system /dev/marvin/system 

lvcreate -L 8G -n data marvin # Debugging size. For production use 100G
mkfs.ext4 -F /dev/marvin/data
tune2fs -f -L data /dev/marvin/data 

lvcreate -L 500M -n swap marvin
mkswap /dev/marvin/swap

# For debugging exit here.
exit

# Mounting
mount -L system /mnt
mkdir /mnt/boot
mount -L boot /mnt/boot


# Generate config from basic NixOS installation on boot media 
nixos-generate-config --root /mnt

# Overwrite configuration.nix with custom version
cat << EOF > /mnt/etc/nixos/configuration.nix

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
  
  fileSystems = [
    {
      mountPoint = "/srv";
      label="data";
    }
  ];
  swapDevices = [ { device = "/dev/marvin/swap"; } ];

  networking.hostName = "marvin"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "de";
    defaultLocale = "de_DE.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  # environment.systemPackages = with pkgs; [
  #   wget
  # ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "de";
  services.xserver.xkbOptions = "eurosign:e";
  services.xserver.monitorSection = ''
     Modeline "1440x900@60" 108.84 1440 1472 1880 1912 900 918 927 946
  '';

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.kdm.enable = true;
  services.xserver.desktopManager.kde4.enable = true;

  # Enable libvirt-daemon and KVM
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.enableKVM = true;

  # Setup root account
  users.extraUsers.root.password = "$rootpassword";
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.$username = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "networkmanager" "libvirtd" ];
    password = "$userpassword";
    # openssh.authorizedKeys.keys = [ "$usersshkey" ];
    };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";

}

EOF

# nixos-install
