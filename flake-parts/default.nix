{
  perSystem = {
    pkgs,
    config,
    ...
  }: {
    # Formatter: `nix fmt .`
    formatter = pkgs.alejandra;

    # Mkdocs (mkdocs-flake module, imported in flake.nix):
    #   nix build .#documentation      → ./result is the static website
    #   nix run .#watch-documentation  → live preview on http://127.0.0.1:8000
    documentation = {
      mkdocs-root = ../documentation;
      # Broken links / missing nav pages fail the build instead of warning.
      strict = true;
      # Ship the built slide deck inside the website at /slides/
      # (embedded by docs/presentation.md). Runs in the build directory,
      # where docs/ is a symlink copy of documentation/docs (read-only
      # directories, hence the chmod).
      mkdocs-preBuildHook = "chmod u+w docs && cp -r ${config.packages.slides} docs/slides";
    };
  };
}
