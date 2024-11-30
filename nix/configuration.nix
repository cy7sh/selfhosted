{ config, lib, pkgs, ... }:

let
  fake-gitea = pkgs.writeShellScriptBin "gitea" ''
ssh -p 2222 -o StrictHostKeyChecking=no git@127.0.0.1 "SSH_ORIGINAL_COMMAND=\"$SSH_ORIGINAL_COMMAND\" $0 $@"
  '';

in {
  imports =
    [
      ./hardware-configuration.nix
    ];

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.age.keyFile = "/root/.config/sops/age/keys.txt";
  sops.secrets."borg/crash" = { };
  sops.secrets."anki/cy" = { };

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  system.stateVersion = "24.05";

  networking.hostName = "chunk";
  networking.networkmanager.enable = true;
  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];
    allowedUDPPorts = [ 443 ];
    extraInputRules = ''
      ip saddr 172.18.0.0/16 tcp dport 5432 accept
    '';
  };

  time.timeZone = "America/Toronto";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  users.users.yt = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker"];
    openssh.authorizedKeys.keys =
      [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPdhAQYy0+vS+QmyCd0MAbqbgzyMGcsuuFyf6kg2yKge yt@ytlinux" ];
    packages = with pkgs; [
      fzf
      eza
      zoxide
      delta
      lua-language-server
      vim-language-server
      python312Packages.python-lsp-server
      nixd
      gopls
      bash-language-server
      llvmPackages_19.clang-tools
      rust-analyzer
    ];
  };
  users.users.root.openssh.authorizedKeys.keys =
      [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPdhAQYy0+vS+QmyCd0MAbqbgzyMGcsuuFyf6kg2yKge yt@ytlinux" ];
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  users.users.git = {
    isNormalUser = true;
    packages = [ fake-gitea ];
  };

  environment.systemPackages = with pkgs; [
    vim
    neovim
    wget
    curl
    tree
    neofetch
    gnupg
    python3Full
    tmux
    borgbackup
    rclone
    restic
    htop
    btop
    file
    sops
    age
  ];

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  programs.gnupg.agent.enable = true;
  programs.git.enable = true;

  services.anki-sync-server = {
    enable = true;
    port = 27701;
    users = [
      {
        username = "cy";
        passwordFile = /run/secrets/anki/cy;
      }
    ];
  };

  services.caddy = {
    enable = true;
    configFile = ../Caddyfile;
  };

  services.postgresql = {
    enable = true;
    settings.port = 5432;
    package = pkgs.postgresql_17;
    enableTCPIP = true;
    ensureDatabases = [
      "forgejo"
      "linkding"
      "freshrss"
    ];
    ensureUsers = [
      {
        name = "forgejo";
        ensureDBOwnership = true;
      }
      {
        name = "linkding";
        ensureDBOwnership = true;
      }
      {
        name = "freshrss";
        ensureDBOwnership = true;
      }
    ];
    authentication = lib.mkForce ''
      local all all trust
      host  all all 127.0.0.1/32 trust
      host  all all ::1/128 trust
      host  all all 172.18.0.0/16 trust
    '';
  };
  services.postgresqlBackup.enable = true;

  virtualisation.docker.enable = true;

  services.borgbackup.jobs = {
    crashRsync = {
      paths = [ "/root" "/home" "/var/backup" "/var/lib" "/var/log" "/opt" "/etc" "/vw-data" ];
      exclude = [ "**/.cache" "**/node_modules" "**/cache" "**/Cache" "/var/lib/docker" ];
      repo = "de3911@de3911.rsync.net:borg/crash";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat /run/secrets/borg/crash";
      };
      environment = {
        BORG_RSH = "ssh -i /home/yt/.ssh/id_ed25519";
        BORG_REMOTE_PATH = "borg1";
      };
      compression = "auto,zstd";
      startAt = "hourly";
      extraCreateArgs = [ "--stats" ];
      # warnings are often not that serious
      failOnWarnings = false;
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.tor = {
    enable = true;
    openFirewall = true;
    relay = {
      enable = true;
      role = "relay";
    };
    settings = {
      ORPort = 9001;
      Nickname = "chunk";
    };
  };
}

