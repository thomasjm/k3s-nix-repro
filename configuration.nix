{ config, pkgs, ... }:

let
  configFile = ./configuration.nix;

  configFileNoConfigurationNix = pkgs.runCommand "configuration-no-self-reference.nix" {} ''
    cat "${configFile}" | grep -v configuration.nix | grep -v boot.loader | grep -v virtualisation > $out
  '';

in

{
  imports = [ <nixpkgs/nixos/modules/virtualisation/qemu-vm.nix> ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  users.users.alice = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    initialPassword = "test";
  };

  nix.nixPath = [
    "nixpkgs=${builtins.storePath <nixpkgs>}"
    "nixos-config=/etc/nixos/configuration.nix"
  ];

  environment.etc."nixos/configuration.nix".source = configFileNoConfigurationNix;

  environment.systemPackages = with pkgs; [
    emacs
    tmux

    k3s
  ];

  virtualisation.diskSize = 4096;
  virtualisation.memorySize = 8192;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.k3s = {
    enable = true;
    role = "server";

    token = "todo-replace-with-token-file";
    # token = "todo-replace-with-token-file-modified";

    extraFlags = "--write-kubeconfig-mode=644";
    clusterInit = true;
  };

  system.stateVersion = "23.11";
}
