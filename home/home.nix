{ config, pkgs, karabinix, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  imports = [
    ./programs/helix.nix
    ./programs/sketchybar/sketchybar.nix
    ./programs/aerospace/aerospace.nix
  ];

  programs = {
    git = {
      enable = true;
      lfs = {
        enable = true;
      };
      settings = {
        user = {
          name = "Murph Murphy";
          email = "murph.murphy@ironcorelabs.com";
          # can specify if needed, but it's left off in favor of the git alias that dynamically gets the
          # signing key on commit and tag 
          # signingKey = "8FBF0A12F79B63D5";
        };
        commit.gpgSign = true;
        tag.gpgSign = true;
        gpg.program = "gpg2";
        alias = {
          # find how a given commit made it into a given branch, ex `git find-merge 2f87703c main`
          find-merge = ''!sh -c 'commit=$0 && branch=''${1:-HEAD} && (git rev-list $commit..$branch --ancestry-path | cat -n; git rev-list $commit..$branch --first-parent | cat -n) | sort -k2 -s | uniq -f1 -d | sort -n | tail -1 | cut -f2' '';
          # show the commit that brought a commit into the current branch, ex `git show-merge a7a040dcd7c2 sa-tagging-events`
          show-merge = ''!sh -c 'merge=$(git find-merge $0 $1) && [ -n \"$merge\" ] && git show $merge' '';
          # remove branches that are no longer on the remote
          gone = ''! git fetch -p && git for-each-ref --format '%(refname:short) %(upstream:track)' | awk '$2 == "[gone]" {print $1}' | xargs -r git branch -D'';
        };
        github.user = "skeet70";
        # Use vim as our default git editor
        core.editor = "hx";
        # Cache git credentials for 15 minutes
        credential.helper = "cache";
        push.autoSetupRemote = true;
        init.defaultBranch = "main";
        color.ui = true;
        pull.rebase = true;
        "branch \"main\"".pushRemote = "no_push";
      };
    };

    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    zsh = {
      enable = true;
      shellAliases = {
        ll = "ls -l";
        cat = "bat";
        unar = "ouch decompress";
        unzip = "ouch decompress";
        # for jdt-language-server
      };
      initContent = ''
        git() { if [[ "$1" == "commit" ]] || [[ "$1" == "tag" ]]; then local KEY=$(gpg --card-status 2>/dev/null | grep "Signature key" | awk '{gsub(/ /, ""); print substr($0, length($0)-15)}'); if [ -n "$KEY" ]; then command git -c user.signingkey=$KEY "$@"; else command git "$@"; fi; else command git "$@"; fi; }
      '';
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;
      enableVteIntegration = true;
      history = {
        expireDuplicatesFirst = true;
        ignoreSpace = true;
        save = 10000; # save 10,000 lines of history
      };
      oh-my-zsh = {
        enable = true;
        theme = "lambda";
      };
    };

    # Rust-based terminal emulator
    alacritty = {
      enable = true;
      settings = {
        env.TERM = "alacritty";
        font = {
          size = 14;
        };
        window = {
          decorations = "full";
          title = "Alacritty";
          dynamic_title = true;
          class = {
            instance = "Alacritty";
            general = "Alacritty";
          };
        };
      };
    };

    ssh = {
      enable = true;
      matchBlocks."*" = {
        compression = true;
        controlMaster = "auto";
      };
      includes = [ "*.conf" ];
      extraConfig = ''
        AddKeysToAgent yes
      '';
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };

  # download the public_key from Bitwarden gpg entry(s)
  # gpg2 --import ~/.ssh/public_key
  # gpg2 --card-status
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableZshIntegration = true;
  };

  services.karabinix = {
    enable = true;
    configuration = with karabinix.lib;
      let
        helpers = import "${karabinix}/lib/rules.nix" { lib = pkgs.lib; };
        inherit (helpers) mkRule mkManipulator mkFromEvent mkModifiers;
      in
      {
        profiles = [
          (mkProfile {
            name = "Default profile";
            selected = true;
            complex_modifications = mkComplexModification
              {
                rules = [
                  (mkRule "Alt+letter to Hyper+letter for AeroSpace" [
                    # Alt+h -> F13 (join-with down)
                    (mkManipulator {
                      from = mkFromEvent {
                        key_code = keyCodes.h;
                        modifiers = mkModifiers { mandatory = modifiers.alt; };
                      };
                      to = [ (mkToEvent { key_code = keyCodes.f13; }) ];
                    })
                    # Alt+v -> F14 (join-with right)
                    (mkManipulator {
                      from = mkFromEvent {
                        key_code = keyCodes.v;
                        modifiers = mkModifiers { mandatory = modifiers.alt; };
                      };
                      to = [ (mkToEvent { key_code = keyCodes.f14; }) ];
                    })
                    # Alt+f -> F15 (fullscreen)
                    (mkManipulator {
                      from = mkFromEvent {
                        key_code = keyCodes.f;
                        modifiers = mkModifiers { mandatory = modifiers.alt; };
                      };
                      to = [ (mkToEvent { key_code = keyCodes.f15; }) ];
                    })
                    # Alt+s -> F16 (layout v_accordion)
                    (mkManipulator {
                      from = mkFromEvent {
                        key_code = keyCodes.s;
                        modifiers = mkModifiers { mandatory = modifiers.alt; };
                      };
                      to = [ (mkToEvent { key_code = keyCodes.f16; }) ];
                    })
                    # Alt+w -> F17 (layout h_accordion)
                    (mkManipulator {
                      from = mkFromEvent {
                        key_code = keyCodes.w;
                        modifiers = mkModifiers { mandatory = modifiers.alt; };
                      };
                      to = [ (mkToEvent { key_code = keyCodes.f17; }) ];
                    })
                    # Alt+e -> F18 (layout tiles)
                    (mkManipulator {
                      from = mkFromEvent {
                        key_code = keyCodes.e;
                        modifiers = mkModifiers { mandatory = modifiers.alt; };
                      };
                      to = [ (mkToEvent { key_code = keyCodes.f18; }) ];
                    })
                    # Alt+q -> F19 (close)
                    (mkManipulator {
                      from = mkFromEvent {
                        key_code = keyCodes.q;
                        modifiers = mkModifiers { mandatory = modifiers.alt; };
                      };
                      to = [ (mkToEvent { key_code = keyCodes.f19; }) ];
                    })
                    # Alt+c -> F20 (reload-config)
                    (mkManipulator {
                      from = mkFromEvent {
                        key_code = keyCodes.c;
                        modifiers = mkModifiers { mandatory = modifiers.alt; };
                      };
                      to = [ (mkToEvent { key_code = keyCodes.f20; }) ];
                    })
                    # Alt+r -> F21 (mode resize)
                    # WARN: ran out up supported virtual keys, no resizing for now
                    # (mkManipulator {
                    #   from = mkFromEvent {
                    #     key_code = keyCodes.r;
                    #     modifiers = mkModifiers { mandatory = modifiers.alt; };
                    #   };
                    #   to = [ (mkToEvent { key_code = "f21"; }) ];
                    # })
                  ])
                ];
              };
          })
        ];
      };
  };
  # Force overwrite the karabiner config
  home.file.".config/karabiner/karabiner.json".force = true;

  home = {
    packages = with pkgs;
      [
        colima
        docker
        bat
        # disabled until https://github.com/NixOS/nixpkgs/issues/339576
        #bitwarden-cli
        gnupg
        htop
        ironhide
        jq
        # commented out, can't find cocoa during build, should look into it later
        # matui # lightweight matrix tui client
        nixpkgs-fmt
        obsidian
        opensc
        ouch
        postman
        # CAD 3D parametric modeling (3D printing)
        openscad-unstable
        # settings -> keyboard -> keyboard shortcuts -> spotlight, turn both off
        raycast
        slack
        spotify-player
        yubikey-personalization
        # block youtube ads network-wide
        isponsorblocktv
      ];


    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    file = {
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      # ".screenrc".source = dotfiles/screenrc;

      # # You can also set the file content immediately.
      # ".gradle/gradle.properties".text = ''
      #   org.gradle.console=verbose
      #   org.gradle.daemon.idletimeout=3600000
      # '';
    };

    # You can also manage environment variables but you will have to manually
    # source
    #
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  /etc/profiles/per-user/davish/etc/profile.d/hm-session-vars.sh
    #
    # if you don't want to manage your shell through Home Manager.
    sessionVariables = {
      EDITOR = "hx";
      # workarounds to get colima working with testcontainers from https://node.testcontainers.org/supported-container-runtimes/#known-issues_1
      DOCKER_HOST = "unix://${config.home.homeDirectory}/.colima/default/docker.sock";
      TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE = "/var/run/docker.sock";
      TESTCONTAINERS_RYUK_DISABLED = 1;
    };
  };
}
