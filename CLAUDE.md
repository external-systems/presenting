# CLAUDE.md

MkDocs site (`documentation/`) + reveal.js deck (`slides/`), built by a
Nix flake with zero npm. This repo is also a template
(`nix flake init -t github:external-systems/presenting`) and an
exportable flake-parts module (`flakeModules.default` / `.slides`,
`lib.mkSlides`) that other flakes consume.

## Rule: never commit build artifacts

The website and deck are built in CI and published to GitHub Pages only.
Never commit build output: no `result` / `result-*` links, no `_site/`,
`site/` or `documentation/site/` (all gitignored), no built deck copied
into the tree, no `gh-pages` branch pushes. To publish, merge to `main`;
`.github/workflows/ci.yml` calls the org CI (external-systems/pkgs
`org-ci.yml`): it runs `nix flake check`, builds `.#documentation` (deck
at `/slides/`) and deploys it. Change CI only in pkgs, never here.

## Build and check

```bash
nix flake check                 # both builds + alejandra/statix/deadnix
nix run .#watch-documentation   # live docs → http://127.0.0.1:8000
nix run .#serve-slides          # live deck → http://127.0.0.1:8000
```

Nix only sees files git tracks: `git add` new files before building.
