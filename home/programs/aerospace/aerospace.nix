{ ... }: {
  home.file.".config/aerospace" = {
    source = ./src;
    recursive = true;
  };
}
