{
  inputs = {
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    helix.url = "github:helix-editor/helix";
    helix.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # makes home-manager/nix-darwin installed apps show up in spotlight
    mac-app-util.url = "github:hraban/mac-app-util";
    ironhide.url = "github:IronCoreLabs/ironhide";
    ironhide.inputs.nixpkgs.follows = "nixpkgs";
    matui.url = "github:pkulak/matui";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # # SFMono w/ patches
    sf-mono-liga-src = {
      url = "github:shaunsingh/SFMono-Nerd-Font-Ligaturized";
      flake = false;
    };
    # declarative configuration for karabiner-elements
    karabinix.url = "github:pepegar/karabinix";
  };

  outputs = inputs@{ self, darwin, home-manager, nixpkgs, mac-app-util, karabinix, ... }:
    let
      configuration = { pkgs, ... }: {
        nix.package = pkgs.nixVersions.nix_2_31;
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
            # sketchybar resolves through this tap, and Homebrew 6 refuses untrusted taps during activation.
            { name = "FelixKratz/formulae"; trusted = true; }
          ];
          brews = [
            # (macOS Sonoma) Hide the default macOS menu bar in System Settings -> Control Center -> Automatically hide and show the menu bar -> Always:
            { name = "sketchybar"; restart_service = "changed"; }
            { name = "syncthing"; restart_service = "changed"; }
          ];
          casks = [
            "signal"
            "slack"
            "proton-drive"
            "sf-symbols"
            "font-sf-mono"
            "font-sf-pro"
            "qobuz"
            "orcaslicer"
            "karabiner-elements"
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

        launchd.user.agents.isponsorblocktv = {
          script = ''
            exec ${pkgs.isponsorblocktv}/bin/isponsorblocktv --data "/Users/mumu/Library/Application Support/iSponsorBlockTV" start
          '';
          serviceConfig = {
            KeepAlive = true;
            RunAtLoad = true;
            StandardOutPath = "/Users/mumu/Library/Logs/isponsorblocktv.out.log";
            StandardErrorPath = "/Users/mumu/Library/Logs/isponsorblocktv.err.log";
          };
        };

        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";
        # simplify use, trust self
        nix.settings.trusted-users = [ "root" "mumu" ];

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
            (final: prev: {
              # Backport of nixpkgs 5530e24f, not yet in nixpkgs-unstable; drop it once the channel has it.
              brave = prev.brave.overrideAttrs (_: { sourceRoot = "Brave Browser.app"; });
            })
          ];
        };

        modules = [
          mac-app-util.darwinModules.default
          configuration
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.useUserPackages = true;
            home-manager.users.mumu = import ./home/home.nix;
            home-manager.sharedModules = [ mac-app-util.homeManagerModules.default karabinix.homeManagerModules.karabinix ];
            home-manager.extraSpecialArgs = {
              inherit karabinix;
            };
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."gsv".pkgs;
    };
}
