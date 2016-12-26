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
  
  #fileSystems = [
  #  {
  #    mountPoint = "/srv";
  #    label="data";
  #  }
  #];
  # swapDevices = [ { device = "/dev/$vmname/swap"; } ];

  networking.hostName = "claas2"; # Define your hostname.
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
  environment.systemPackages = with pkgs; [
    wget git
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.$username = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "networkmanager" "libvirtd" ];
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDQql8UmC+W+IF7fF2/3Bb9PreRsgjP3F4bnqRh+HkRb3saWPvipQ6onCPBS5BEcSKmiU052wYN+J0Pu4l77gNEOKx9EeG1SH1fdqJ07JvrQhnMZtRJO36cvX1b4ZgLXMgTKSEkaE4ZAYF077E+0g+dQ4yfFI3wqcvhqhn9wQZc25QJwM0yg8qdEnVX4eGenUVIFKeDAm3cCAW8Usd18GdRZilYQ+fEad/Wno6BSZ8kWY+6CWlh6/Dh60E3Q4G6rErBmRg8TmItoYDGuQhvaFeXi3+HXw8P+HNhjAK3IruXBhSiTKjQmnUe9mn39M1CH/nU4wUtSop7aMbl8p3KQbaj prometheus" ];
    };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";

}
