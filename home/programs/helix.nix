{ pkgs, ... }: {
  programs.helix = {
    enable = true;
    package = pkgs.helix;
    defaultEditor = true;
    settings = {
      theme = "jellybeans";
      editor = {
        line-number = "absolute";
        mouse = true;
        text-width = 120;
        file-picker = {
          hidden = false;
        };
      };
    };
    languages = {
      language = [
        {
          name = "javascript";
          formatter = {
            command = "prettier";
            args = [ "--parser" "typescript" ];
          };
          auto-format = true;
        }
        {
          name = "jsx";
          formatter = {
            command = "prettier";
            args = [ "--parser" "typescript" ];
          };
          auto-format = true;
        }
        {
          name = "typescript";
          formatter = {
            command = "prettier";
            args = [ "--parser" "typescript" ];
          };
          auto-format = true;
        }
        {
          name = "tsx";
          formatter = {
            command = "prettier";
            args = [ "--parser" "typescript" ];
          };
          auto-format = true;
        }
        {
          name = "python";
          formatter = {
            command = "black";
            args = [ "--quiet" "-" ];
          };
          auto-format = true;
        }
        {
          name = "nix";
          formatter = {
            command = "nixpkgs-fmt";
          };
          auto-format = true;
        }
        {
          name = "json";
          indent =
            {
              tab-width = 4;
              unit = " ";
            };
        }
        # [[language]]
        # name = "yaml"
        # file-types = ["yaml", "yml"]
        # language-servers = [ "yaml-language-server" ]

        # [language-server.yaml-language-server]
        # config = {
        #   yaml = {
        #     schemas = {
        #       kubernetes = "*.y{a,}ml",
        #       "http://json.schemastore.org/github-workflow" = ".github/workflows/*",
        #       "http://json.schemastore.org/github-action" = ".github/action.{yml,yaml}",
        #       "https://raw.githubusercontent.com/microsoft/azure-pipelines-vscode/master/service-schema.json" = "azure-pipelines.yml",
        #       "http://json.schemastore.org/ansible-stable-2.9" = "roles/tasks/*.{yml,yaml}",
        #       "http://json.schemastore.org/prettierrc" = ".prettierrc.{yml,yaml}",
        #       "http://json.schemastore.org/kustomization" = "kustomization.{yml,yaml}",
        #       "http://json.schemastore.org/ansible-playbook" = "*play*.{yml,yaml}",
        #       "http://json.schemastore.org/chart" = "Chart.{yml,yaml}",
        #       "https://json.schemastore.org/dependabot-v2" = ".github/dependabot.{yml,yaml}",
        #       "https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json" = "*gitlab-ci*.{yml,yaml}",
        #       "https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.1/schema.json" = "*api*.{yml,yaml}",
        #       "https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json" = "*docker-compose*.{yml,yaml}",
        #       "https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json" = "*flow*.{yml,yaml}"
        #     },
        #     format = {  enable = false  }
        #   }
        # }
        {
          name = "yaml";
          file-types = [ "yaml" "yml" ];
          language-servers = [ "yaml-language-server" ];
        }
      ];
      language-server = {
        yaml-language-server = {
          config = {
            yaml = {
              schemas = {
                kubernetes = "*.y{a,}ml";
                "http://json.schemastore.org/github-workflow" = ".github/workflows/*";
                "http://json.schemastore.org/github-action" = ".github/action.{yml,yaml}";
                "https://raw.githubusercontent.com/microsoft/azure-pipelines-vscode/master/service-schema.json" = "azure-pipelines.yml";
                "http://json.schemastore.org/ansible-stable-2.9" = "roles/tasks/*.{yml,yaml}";
                "http://json.schemastore.org/prettierrc" = ".prettierrc.{yml,yaml}";
                "http://json.schemastore.org/kustomization" = "kustomization.{yml,yaml}";
                "http://json.schemastore.org/ansible-playbook" = "*play*.{yml,yaml}";
                "http://json.schemastore.org/chart" = "Chart.{yml,yaml}";
                "https://json.schemastore.org/dependabot-v2" = ".github/dependabot.{yml,yaml}";
                "https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json" = "*gitlab-ci*.{yml,yaml}";
                "https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.1/schema.json" = "*api*.{yml,yaml}";
                "https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json" = "*docker-compose*.{yml,yaml}";
                "https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json" = "*flow*.{yml,yaml}";
              };
            };
          };
        };
      };
    };
  };

  home.packages = with pkgs; [
    # helix language support
    nodePackages.bash-language-server # bash
    shellcheck # bash
    clang-tools # cpp
    gopls # go
    haskell-language-server # haskell
    nodePackages.intelephense # php
    # the java one still needs some work. this installs the right lsp, but helix can't see it.
    # might see this, haven't tried env var https://dschrempf.github.io/emacs/2023-03-02-emacs-java-and-nix/
    jdt-language-server # java
    kotlin-language-server # kotlin
    nil # nix
    nixpkgs-fmt # nix
    marksman # markdown
    metals # scala
    python312Packages.python-lsp-server # python
    python312Packages.python-lsp-ruff # python
    python312Packages.pylsp-mypy # python
    black # python
    rust-analyzer # rust
    nodePackages.svelte-language-server # svelte
    taplo # toml
    nodePackages.typescript-language-server # typescript
    nodePackages.prettier # typescript, js
    vscode-langservers-extracted # css, json, html
    yaml-language-server # yaml
    # - vscode-github-actions equivalent?
    #   - see https://github.com/helix-editor/helix/issues/6988
    #   - see https://github.com/actions/languageservices/issues/56
    # end helix language support
  ];
}
