{
  inputs = {
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    helix.url = "github:helix-editor/helix";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # makes home-manager/nix-darwin installed apps show up in spotlight
    mac-app-util.url = "github:hraban/mac-app-util";
    ironhide.url = "github:IronCoreLabs/ironhide";
    matui.url = "github:pkulak/matui";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # # SFMono w/ patches
    sf-mono-liga-src = {
      url = "github:shaunsingh/SFMono-Nerd-Font-Ligaturized";
      flake = false;
    };
  };

  outputs = inputs@{ self, darwin, home-manager, nixpkgs, mac-app-util, ... }:
    let
      configuration = { pkgs, ... }: {
        nix.package = pkgs.nixVersions.nix_2_28;
        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        environment = {
          systemPackages = [ ];
          systemPath = [ "/run/current-system/sw/bin" ];
        };

        homebrew = {
          enable = true;
          onActivation = {
            autoUpdate = true;
            cleanup = "zap";
            upgrade = true;
          };

          taps = [
            "homebrew/services"
            "FelixKratz/formulae"
          ];
          brews = [
            # (macOS Sonoma) Hide the default macOS menu bar in System Settings -> Control Center -> Automatically hide and show the menu bar -> Always:
            { name = "sketchybar"; restart_service = "changed"; }
            { name = "syncthing"; restart_service = "changed"; }
          ];
          casks = [
            "steam"
            "league-of-legends"
            "signal"
            "orion"
            "proton-drive"
            "whisky"
            "sf-symbols"
            "font-sf-mono"
            "font-sf-pro"
            "qobuz"
            "orcaslicer"
          ];

          masApps = {
            WireGuard = 1451685025;
          };
        };

        fonts.packages = with pkgs; [ sf-mono-liga-bin ];

        launchd.user.agents = {
          raycast = {
            serviceConfig.ProgramArguments = [ "${pkgs.raycast}/Applications/Raycast.app/Contents/MacOS/Raycast" ];
            serviceConfig.RunAtLoad = true;
          };
        };

        # TODO(murph): this can't see the binary installed by home manager so it doesn't work
        launchd.daemons.isponsorblocktv = {
          script = ''
            exec isponsorblocktv start
          '';
          serviceConfig = {
            KeepAlive = true;
            RunAtLoad = true;
            StandardOutPath = "/var/log/isponsorblocktv.out.log";
            StandardErrorPath = "/var/log/isponsorblocktv.err.log";
          };
        };

        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";

        # Create /etc/zshrc that loads the darwin environment.
        programs = {
          zsh.enable = true; # default shell on catalina
        };

        system = {
          # Set Git commit hash for darwin-version.
          configurationRevision = self.rev or self.dirtyRev or null;
          # allow hidden files everywhere
          defaults.NSGlobalDomain.AppleShowAllFiles = true;
          defaults.NSGlobalDomain._HIHideMenuBar = true;
          defaults.CustomUserPreferences.NSGlobalDomain."com.apple.mouse.linear" = true;
          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          stateVersion = 5;
          activationScripts.postActivation.text = ''
            # Following line should allow us to avoid a logout/login cycle
            sudo -u mumu /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
          '';
          primaryUser = "mumu";
        };

        services.tailscale.enable = true;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";

        users.users.mumu = {
          name = "mumu";
          home = "/Users/mumu";
        };

        security.pam.services.sudo_local.touchIdAuth = true;
      };
      nixpkgsConfig = {
        config = {
          allowUnfree = true;
        };
      };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#gsv
      darwinConfigurations."gsv" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          inherit (nixpkgsConfig) config;
          overlays = [
            (final: prev: {
              inherit (inputs.ironhide.packages.${prev.stdenv.system}) ironhide;
              inherit (inputs.matui.packages.${prev.stdenv.system}) matui;
              inherit (inputs.helix.packages.${prev.stdenv.system}) helix;
            })
            (final: prev: {
              sf-mono-liga-bin = prev.stdenvNoCC.mkDerivation {
                pname = "sf-mono-liga-bin";
                version = "dev";
                src = inputs.sf-mono-liga-src;
                dontConfigure = true;
                installPhase = ''
                  mkdir -p $out/share/fonts/opentype
                  cp -R $src/*.otf $out/share/fonts/opentype/
                '';
              };
            })
          ];
        };

        modules = [
          mac-app-util.darwinModules.default
          configuration
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mumu = import ./home/home.nix;
            home-manager.sharedModules = [ mac-app-util.homeManagerModules.default ];
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."gsv".pkgs;
    };
}
