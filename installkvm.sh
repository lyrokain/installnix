# Hypervisor:
# NixOS-System mit KVM

# Global Settings

	vmname=marvin
	hdd=sda
	rootpassword=somesupersecretpassword.Change.this.right.now!
	username=genericuser
	userpassword=somesecretpassword.Change.this!
	usersshkey=Put.gibberish.ssh.key.here!

#read -p "What will be the name of this machine:" vmname
#read -p "Device path of destination drive (i. e. /dev/sda):" hdd
#read -p "Name of user account to create:" username
#read -p "Password of $username:" userpassword

# Functions
createvolume(){
	local name=$1
	local size=$2
	local group=$3
	echo "Creating logical volume $name of $size on $group:"
	yes|lvcreate -L $size -n $name $group
	echo "Formatting /dev/$group/$name"
	mkfs.ext4 -F /dev/$group/$name
	echo "Setting file system label to $name:"
	tune2fs -f -L $name /dev/$group/$name
	lvdisplay $name
}

# Remove existing volume groups
groupname=$(vgdisplay|grep "VG Name"|cut -b 25-)
for i in $groupname; do vgremove -f $i; done

# Remove existing physical volume
pvremove /dev/$hdd

# Remove old partition:
sfdisk --delete /dev/$hdd

# For good measure:
dd if=/dev/zero of=/dev/$hdd bs=512 count=1

# Create physical volume:
pvcreate /dev/$hdd

# Create volume group
vgcreate $vmname /dev/$hdd

# Create logical volumes and file systems
createvolume boot "1G" "$vmname"
createvolume system "5G" "$vmname"
createvolume data "10G" "$vmname"

# Create swap space
lvcreate -L 500M -n swap $vmname
mkswap -f -L swap /dev/$vmname/swap

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
  swapDevices = [ { device = "/dev/$vmname/swap"; } ];

  networking.hostName = "$vmname"; # Define your hostname.
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

