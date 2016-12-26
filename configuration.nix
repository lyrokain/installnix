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
  users.extraUsers.sunny = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "networkmanager" ];
    password = "Change me!";
    openssh.authorizedKeys.keys = [ 
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDQql8UmC+W+IF7fF2/3Bb9PreRsgjP3F4bnqRh+HkRb3saWPvipQ6onCPBS5BEcSKmiU052wYN+J0Pu4l77gNEOKx9EeG1SH1fdqJ07JvrQhnMZtRJO36cvX1b4ZgLXMgTKSEkaE4ZAYF077E+0g+dQ4yfFI3wqcvhqhn9wQZc25QJwM0yg8qdEnVX4eGenUVIFKeDAm3cCAW8Usd18GdRZilYQ+fEad/Wno6BSZ8kWY+6CWlh6/Dh60E3Q4G6rErBmRg8TmItoYDGuQhvaFeXi3+HXw8P+HNhjAK3IruXBhSiTKjQmnUe9mn39M1CH/nU4wUtSop7aMbl8p3KQbaj prometheus"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCyZ4AD59LEglKoROIQO1cfsEjrNq1lbvFBoIfZxUdgqY0YDc6FXnxflpvNbC6EPaTx3xwIcmTQYzo//rWM2M8LlKXv6sWhVPS3o5nVcu+3z1h3BtWqLQWpLWJlpc+/l6m4Y2EgIfCaB8hFBfN6ws+0peZu1Nxih6olP8qXnRRGhackuYjf46Vvzd2OyaVbrlHe4QiWP4Hq70ZIehen3t9zv06JRcEkuFVT3bBXqTBh75zuRGXVLi7dB4dEl/80YT4hfUCWWCWJgBshSRp6pvrVyauW5etZOsbF53xkns0oXI2cQdbrOET9sBdSiXaJEZMDnRe0vHaZjnmRxPEMwYjTZJZ7XljEdW65hNxw0Kq9IlBaf32Lzse4Dx3wK6DNGtLrQOf8+WhThPT/274I5NPOBEHRC5Qf6HRktsOTAhd4bwS7ekkFk7Dpuvz+OKS7a7YTt6HGT7tDXCng4b7qxmbJwMDuPrvFu3ighZ0hfqAbegswOxDR2fm0QwwQpRrfoqPEBuTmPDwf+wnNmofvDbMViwtCFnW6rfwifFH+yIhPRAfveyX3WOTmjw5AWmZRZyj5IlazivIvz7enUp3u6ebotmQyWBlmPW+C7Xo/Yjiv5PQ3qA5r8hPGLoLtbc+/NaJjZSs1dx4iLzop6Ez1eHyEgtuiI5OR99ZFmo9YEuHqfQ== sunny@k21.org"
      ];
    };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";
  system.autoUpgrade.enable = true;

}
