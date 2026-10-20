# The exportable flake-parts module. flake.nix bakes it with this repo's
# lib (and thus its reveal.js pin), so consumers never reference
# inputs.presenting inside their own config — they import this module and
# set `presenting.slides.dir`.
{presentingLib}: {
  perSystem = {
    pkgs,
    lib,
    config,
    options,
    ...
  }: let
    cfg = config.presenting.slides;
  in {
    options.presenting.slides = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        example = false;
        description = "Build the reveal.js slide deck.";
      };
      dir = lib.mkOption {
        type = lib.types.path;
        example = "./slides";
        description = ''
          Directory with the deck (index.html + one Markdown file per
          `data-markdown` deck). Built into `packages.slides` and served
          live by `apps.serve-slides`.
        '';
      };
      serveDirName = lib.mkOption {
        type = lib.types.str;
        default = "slides";
        description = ''
          Name of the slides directory in the consumer's checkout —
          `nix run .#serve-slides` serves live files from that folder.
        '';
      };
      embedInDocs = lib.mkOption {
        type = lib.types.bool;
        # Embed automatically when the mkdocs-flake module is imported (it
        # provides the `documentation.*` options); off otherwise, so this
        # module also works for slides-only flakes.
        default = options ? documentation;
        defaultText = lib.literalExpression "true when the mkdocs-flake module is imported";
        description = ''
          Copy the built deck into the MkDocs site at /slides/ via
          `documentation.mkdocs-preBuildHook`. Has no effect when the
          mkdocs-flake module is not imported.
        '';
      };
    };

    config = lib.mkIf cfg.enable (let
      built = presentingLib.mkSlides {
        inherit pkgs lib;
        slidesDir = cfg.dir;
        inherit (cfg) serveDirName;
      };
    in
      lib.mkMerge [
        {
          packages.slides = built.package;
          apps.serve-slides = built.serveApp;
        }
        # optionalAttrs, not mkIf: mkIf still requires the option to
        # exist, so it cannot guard `documentation.*` against a consumer
        # that never imported mkdocs-flake.
        (lib.optionalAttrs (options ? documentation) (lib.mkIf cfg.embedInDocs {
          # Ship the built slide deck inside the website at /slides/.
          # The hook runs in the build directory, where docs/ is a symlink
          # copy of the docs (read-only directories, hence the chmod).
          documentation.mkdocs-preBuildHook = "chmod u+w docs && cp -r ${config.packages.slides} docs/slides";
        }))
      ]);
  };
}
