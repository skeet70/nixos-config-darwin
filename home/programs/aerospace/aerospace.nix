{ ... }: {
  programs.aerospace = {
    enable = true;
    launchd.enable = true;

    settings = {
      # i3 doesn"t have "normalizations" feature that why we disable them here.
      # But the feature is very helpful.
      # Normalizations eliminate all sorts of weird tree configurations that don"t make sense.
      # Give normalizations a chance and enable them back.
      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;
      # run sketchybar when aerospace starts
      after-startup-command = [ "exec-and-forget sketchybar" ];
      # notify sketchybar about workspace changes
      exec-on-workspace-change = [
        "/bin/bash"
        "-c"
        "sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE"
      ];
      # Mouse follows focus when focused monitor changes
      on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
      key-mapping.preset = "dvorak";
      mode.main.binding = {
        # See: https://nikitabobko.github.io/AeroSpace/goodness#open-a-new-window-with-applescript
        alt-enter = "exec-and-forget alacritty msg create-window || TERMINFO_DIRS=/Users/mumu/.nix-profile/share/terminfo:/etc/profiles/per-user/mumu/share/terminfo:/run/current-system/sw/share/terminfo:/nix/var/nix/profiles/default/share/terminfo:/usr/share/terminfo open -na Alacritty.app";
        alt-left = "focus left";
        alt-down = "focus down";
        alt-up = "focus up";
        alt-right = "focus right";

        alt-shift-left = "move left";
        alt-shift-down = "move down";
        alt-shift-up = "move up";
        alt-shift-right = "move right";

        # Consider using "join-with" command as a "split" replacement if you want to enable normalizations
        # all this karabiner stuff is to work around https://github.com/nikitabobko/AeroSpace/discussions/959
        # even with a hyper key and karabiner mapping to `cmd-ctrl-alt-shift` or other variations, AeroSpace still
        # wasn't catching combos.
        # alt-h from karabiner
        f13 = "join-with down";
        # alt-v from karabiner
        f14 = "join-with right";
        # alt-f from karabiner
        f15 = "fullscreen";
        # alt-s from karabiner
        f16 = "layout v_accordion"; # "layout stacking" in i3
        # alt-w from karabiner
        f17 = "layout h_accordion"; # "layout tabbed" in i3
        # alt-e from karabiner
        f18 = "layout tiles horizontal vertical"; # "layout toggle split" in i3
        # alt-q from karabiner
        f19 = "close --quit-if-last-window";
        alt-shift-space = "layout floating tiling"; # "floating toggle" in i3

        # Not supported, because this command is redundant in AeroSpace mental model.
        # See: https://nikitabobko.github.io/AeroSpace/guide#floating-windows
        #alt-space = "focus toggle_tiling_floating"

        # `focus parent`/`focus child` are not yet supported, and it"s not clear whether they
        # should be supported at all https://github.com/nikitabobko/AeroSpace/issues/5
        # alt-a = "focus parent"

        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";
        alt-4 = "workspace 4";
        alt-5 = "workspace 5";
        alt-6 = "workspace 6";
        alt-7 = "workspace 7";
        alt-8 = "workspace 8";
        alt-9 = "workspace 9";
        alt-0 = "workspace 10";

        alt-shift-1 = "move-node-to-workspace 1";
        alt-shift-2 = "move-node-to-workspace 2";
        alt-shift-3 = "move-node-to-workspace 3";
        alt-shift-4 = "move-node-to-workspace 4";
        alt-shift-5 = "move-node-to-workspace 5";
        alt-shift-6 = "move-node-to-workspace 6";
        alt-shift-7 = "move-node-to-workspace 7";
        alt-shift-8 = "move-node-to-workspace 8";
        alt-shift-9 = "move-node-to-workspace 9";
        alt-shift-0 = "move-node-to-workspace 10";
        alt-shift-x = "move-workspace-to-monitor --wrap-around next";

        # alt-c from karabiner
        f20 = "reload-config";
        # alt-r from karabiner
        # WARN: ran out of virtual keys, no resizing for now
        # f21 = "mode resize";
      };
      mode.resize.binding = {
        h = "resize width -50";
        j = "resize height +50";
        k = "resize height -50";
        l = "resize width +50";
        enter = "mode main";
        esc = "mode main";
      };
    };
  };
}
