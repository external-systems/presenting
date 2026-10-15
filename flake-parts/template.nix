{
  # This repo is its own template:
  # `nix flake init -t github:external-systems/presenting`
  flake.templates.default = {
    path = ../.;
    description = "MkDocs docs site + reveal.js slides (flake-parts, mkdocs-flake, zero npm)";
    welcomeText = ''
      # MkDocs + reveal.js

      Run `git add .` first (Nix only sees files git tracks), then:

          nix run .#watch-documentation   # docs preview
          nix run .#serve-slides          # slides preview
          nix build .#documentation       # docs website  -> ./result
          nix build .#slides              # slide deck    -> ./result

      Start reading at documentation/docs/getting-started.md.
    '';
  };
}
