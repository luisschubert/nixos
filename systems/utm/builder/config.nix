{ pkgs, luisschubertSSHKey, rootSSHKey, ... }:

{
  networking.hostName = "builder";

  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    zip
    unzip
    wget
    curl
    htop
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };
  swapDevices = [
    {
      device = "/dev/disk/by-label/swap";
    }
  ];

  documentation.nixos.enable = false;
  time.timeZone = "Americas/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";
  nix.settings.trusted-users = [ "luisschubert" "@wheel" ];
  nix.settings.system-features = [ "kvm" "nixos-test" ];

  boot = {
    tmp.cleanOnBoot = true;
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      systemd-boot = {
        enable = true;
      };
    };
    kernelModules = [ "kvm-amd" "kvm-intel" ];
  };
  virtualisation.libvirtd.enable = true;

  users.users = {
    root.hashedPassword = "!"; # Disable root login
    luisschubert = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        luisschubertSSHKey
        rootSSHKey
      ];
    };
  };

  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
  networking.firewall.allowedTCPPorts = [ 22 ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
