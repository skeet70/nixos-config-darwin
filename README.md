# Mac Setup

1. install `Xcode` from the app store
1. install nix, either with the installer script or Determinate Systems' installer, but make sure the Intel version isn't being installed.
1. install homebrew using their installer
1. put the files in this repo into `~/.config/nix`
1. run `nix run --extra-experimental-features nix-command --extra-experimental-features flakes nix-darwin -- switch --flake ~/.config/nix`
1. run `darwin-rebuild switch --flake .` to rebuild with any flake changes
1. run `gcloud auth configure-docker`

## Mac Settings changes

1. System Settings -> Keyboard -> Keyboard Shortcuts -> Spotlight, turn both off

## Long Term Notes

1. `colima start --arch aarch64 --vm-type=vz` starts the docker machine engine, `docker` commands and `testcontainer`s should work after that. If you get `user-v2/user-v2_qemu.sock: connect: connection refused`, then run `rm -rf ~/.colima/_lima/_networks/user-v2`
1. `spotify_player` can't auth via the API anymore, I had to use [this](https://github.com/dspearson/librespot-auth) tool, then copy the credentials to `~/.cache/spotify_player`
1. [This](https://astrid.tech/2022/11/03/0/overlay-nixpkgs-pr/) is helpful for patching specific packages
1. `syncthing` for syncing notes from phones to the Mac, where they get synced to Proton Drive. Running at http://localhost:8384/

Orion has a bug that makes YubiKeys not work while the Bitwarden extension is enabled. Turn off Bitwarden's key support to fix.

## New Mac M4

Some things I needed to do to get things working on the new M4, coming from an M3

1. uninstall Nix following the official instructions. Before you do this, try using [determinatesystems repairer](https://determinate.systems/posts/nix-support-for-macos-sequoia/). I didn't find out about it till after all this.
2. install nix with [Lix](https://lix.systems/install/) `curl -sSf -L https://install.lix.systems/lix | sh -s -- install`
3. run `ls -la /etc/ssl/certs/ca-certificates.crt` and if it's pointing to `/etc/static/ssl/certs/ca-certificates.crt`, run
    ```
    sudo rm /etc/ssl/certs/ca-certificates.crt
    sudo ln -s /nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt
    ```
4. had to update the system name in `flake.nix` to the new one
5. need to run `xattr -d com.apple.quarantine /Applications/FreeTube.app` each time Freetube updates

TODO:
- why am i needing to run `nix run nix-darwin -- switch --flake ~/.config/nix-darwin` to get nix-darwin loaded initially?
