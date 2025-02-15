{ inputs, pkgs, lib, ... }:
let
  # Add your keys here. Name is arbitrary, but I recommend the associated host.
  keys = {
    argon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILU3q+/0jJLkAtvCk3hJ+QAXCvza7SZ9a0V6FZq6IJne";
    flagship = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILcon6Pn5nLNXEuLH22ooNR97ve290d2tMNjpM8cTm2r";
  };
in
{
  # MBR
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  systemd.services.NetworkManager-wait-online.enable = false;
  networking = {
    hostName = "helium";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 22 ];
  };

  services = {
    openssh = {
      enable = true;
      openFirewall = false;
      passwordAuthentication = false;
    };
  };

  # See ./auto-users.nix for `helion.users`
  users.users.root.openssh.authorizedKeys.keys = with keys; [ argon flagship ];
  helion.users = {
    skettisouls.sshKeys = with keys; [ argon ];
    lunarix.sshKeys = with keys; [ flagship ];
  };

  nixpkgs.config.allowUnfree = true;
  nix = {
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    package = pkgs.nix;
    registry = lib.mapAttrs (_: flake: { inherit flake; }) inputs;
    settings.experimental-features = [ "nix-command" "flakes" ];

    extraOptions = ''
      trusted-users = root skettisouls lunarix
    '';
  };

  time.timeZone = "America/Chicago";
  system.stateVersion = "24.11";
}
