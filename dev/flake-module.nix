# Dev partition: the org base (treefmt, lock-sync, docs and slides as
# checks) from pkgs, and this repo's own docs site and deck. A consumer
# of lib, flakeModules or templates never evaluates it.
{inputs, ...}: {
  imports = [
    inputs.org-pkgs.flakeModules.dev
    ../documentation/flake-module.nix
  ];
}
