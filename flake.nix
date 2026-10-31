{
  description = "Static website (MkDocs) + slide deck (reveal.js), built with Nix";

  # Every outside dependency is an input below. `flake.lock` records the
  # exact commit + content hash of each one, so every machine builds the
  # same site. Update one with `nix flake update <name>`; after
  # `nix flake update org-pkgs`, run `sync-locks` in the same commit.
  inputs = {
    # Shared-input authority for the org: nixpkgs, flake-parts and
    # import-tree come from the artifact flake. Named org-pkgs, never
    # pkgs: `pkgs` is the nixpkgs package set everywhere else. Consumers
    # override nixpkgs/flake-parts with their own pins (README).
    org-pkgs.url = "github:external-systems/pkgs";
    nixpkgs.follows = "org-pkgs/nixpkgs";
    flake-parts.follows = "org-pkgs/flake-parts";
    import-tree.follows = "org-pkgs/import-tree";

    # Consumer-facing inputs only; dev-only inputs go in dev/flake.nix.

    # Mkdocs — flake-parts module: set `documentation.mkdocs-root` and get
    # `packages.documentation` + `apps.watch-documentation`. Part of
    # flakeModules.default. Ships mkdocs + Material + common plugins.
    mkdocs-flake = {
      url = "github:applicative-systems/mkdocs-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };

    # reveal.js — source only (not a flake). Release tags commit the
    # prebuilt `dist/` (reveal.js, themes, plugins), so the slides need
    # zero npm: lib.mkSlides copies `dist/` next to the deck.
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
      # Exposes debug.options / currentSystem.options, which nixd
      # (.vscode/settings.json) reads for flake-parts option hints.
      debug = true;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      imports = [
        inputs.flake-parts.flakeModules.partitions
        # Consumer-facing modules under ./flake-parts (the template
        # output), loaded automatically: no import list to keep in sync.
        (inputs.import-tree ./flake-parts)
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

      # Apps, checks, the formatter and this repo's own docs and deck are
      # evaluated only on demand; a consumer of lib, flakeModules or
      # templates never fetches dev/flake.nix's inputs. The dev shell is
      # devenv (devenv.yaml), not a flake output.
      partitionedAttrs = {
        apps = "dev";
        checks = "dev";
        formatter = "dev";
        # Docs/slides: `nix build .#documentation` / `.#slides`.
        legacyPackages = "dev";
      };

      partitions.dev = {
        module = ./dev/flake-module.nix;
        extraInputsFlake = ./dev;
      };
    };
}
