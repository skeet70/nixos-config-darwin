# Mac Setup

1. install `Xcode` from the app store
1. install nix, either with the installer script or Determinate Systems' installer, but make sure the Intel version isn't being installed.
1. install homebrew using their installer
1. put the files in this repo into `~/.config/nix`
1. run `nix run --extra-experimental-features nix-command --extra-experimental-features flakes nix-darwin -- switch --flake ~/.config/nix`
1. run `darwin-rebuild switch --flake .` to rebuild with any flake changes

## Mac Settings changes

1. System Settings -> Mouse -> Advanced -> Turn off pointer acceleration 
1. System Settings -> Control Center -> Automatically hide and show the menu bar -> Always
1. System Settings -> Keyboard -> Keyboard Shortcuts -> Spotlight, turn both off

Orion has a bug that makes YubiKeys not work while the Bitwarden extension is enabled. Turn off Bitwarden's key support to fix.

TODO:
- why am i needing to run `nix run nix-darwin -- switch --flake ~/.config/nix-darwin` to get nix-darwin loaded initially?
