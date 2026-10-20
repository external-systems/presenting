{
  description = "Static website (MkDocs) + slide deck (reveal.js), built with Nix";

  # Every outside dependency is an input below. `flake.lock` records the
  # exact commit + content hash of each one, so every machine builds the
  # same site. Update them with `nix flake update` (all) or
  # `nix flake update <name>` (one).
  inputs = {
    # Nixpkgs — the package set (python, mkdocs' runtime, alejandra, ...).
    # Pinned to a stable release branch; flake.lock holds the exact commit.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Utility Flakes
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "github:denful/import-tree";

    # Mkdocs — flake-parts module: set `documentation.mkdocs-root` and get
    # `packages.documentation` + `apps.watch-documentation`
    # (flake-parts/default.nix). Ships mkdocs + Material + common plugins.
    mkdocs-flake = {
      url = "github:applicative-systems/mkdocs-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    # reveal.js — source only (not a flake). Release tags commit the
    # prebuilt `dist/` (reveal.js, themes, plugins), so the slides need
    # zero npm: flake-parts/slides.nix copies `dist/` next to slides/.
    # Upgrade by bumping the tag, then `nix flake update reveal-js`.
    reveal-js = {
      url = "github:hakimel/reveal.js?ref=6.0.2";
      flake = false;
    };
  };

  outputs = inputs: let
    # The exportable pieces, bound to THIS flake's inputs (so the
    # reveal.js pin travels with them) and shared by this repo and its
    # consumers — one implementation, three ways in:
    #   lib.mkSlides         build a deck from any slides/ directory
    #   flakeModules.slides  packages.slides + apps.serve-slides
    #                        (+ /slides/ embed when mkdocs-flake is present)
    #   templates.default    this whole repo, for greenfield projects
    presentingLib = import ./lib {inherit inputs;};
    slidesModule = import ./flakeModules/slides.nix {inherit presentingLib;};
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      # Add "aarch64-linux" / "aarch64-darwin" here to build on those too.
      systems = [
        "x86_64-linux"
      ];

      imports = [
        # Every .nix file under ./flake-parts is a flake-parts module,
        # loaded automatically — no import list to keep in sync.
        (inputs.import-tree ./flake-parts)
        inputs.mkdocs-flake.flakeModules.default
        # This repo eats its own cooking: its deck is built by the same
        # exported module consumers import.
        slidesModule
      ];

      flake = {
        lib = presentingLib;
        flakeModules = {
          slides = slidesModule;
          # `default` additionally pulls in mkdocs-flake, so one import
          # gives a fresh flake docs + slides. If your flake already
          # imports mkdocs-flake itself, import `flakeModules.slides`
          # instead — importing both declares its options twice.
          default = {
            imports = [
              inputs.mkdocs-flake.flakeModules.default
              slidesModule
            ];
          };
        };
      };
    };
}
