{
  perSystem = {pkgs, ...}: {
    # Formatter: `nix fmt .`
    formatter = pkgs.alejandra;

    # The slide deck. The exported module (flakeModules/slides.nix,
    # imported in flake.nix) turns this one line into `packages.slides`,
    # `apps.serve-slides` and the /slides/ embed in the docs site below.
    presenting.slides.dir = ../slides;

    # Mkdocs (mkdocs-flake module, imported in flake.nix):
    #   nix build .#documentation      → ./result is the static website
    #   nix run .#watch-documentation  → live preview on http://127.0.0.1:8000
    documentation = {
      mkdocs-root = ../documentation;
      # Broken links / missing nav pages fail the build instead of warning.
      strict = true;
    };
  };
}
