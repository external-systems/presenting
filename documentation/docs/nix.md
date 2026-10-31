# How the Nix flake works

You can use this repo without understanding Nix. This page is for when
you want to change how it builds.

## The files

```text
flake.nix              # inputs (outside dependencies) + the exported lib/modules
flake.lock             # exact versions of every input (generated, commit it)
lib/
└── default.nix        # mkSlides: the deck builder other flakes call with THEIR slides/
flakeModules/
└── slides.nix         # the exportable flake-parts module (presenting.slides.* options)
flake-parts/
├── scripts/
│   └── inline-markdown.py  # folds slides.md into index.html at build time
└── template.nix       # lets `nix flake init -t` copy this repo (delete it in your copy if you like)
dev/
├── flake.nix          # dev-only inputs (treefmt-nix), locked in dev/flake.lock
└── flake-module.nix   # the dev partition: formatter, checks, this repo's docs + deck
devenv.yaml            # the dev shell (devenv CLI): the org shell from external-systems/pkgs
documentation/
├── flake-module.nix   # MkDocs settings + presenting.slides.dir
├── mkdocs.yml, docs/  # the MkDocs site
└── slides/            # the reveal.js deck
```

This repo builds its own deck with the same module it exports — what you
get from `inputs.presenting.flakeModules.slides` is exactly what builds
`documentation/slides/` here. The docs and deck live in the flake's `dev`
[partition](https://flake.parts/options/flake-parts-partitions.html), so
a consumer of the exports never fetches this repo's dev inputs.

## Inputs and the lock file

`flake.nix` lists the **inputs**, the outside code the build uses:

| Input | What it is |
| --- | --- |
| `org-pkgs` | external-systems/pkgs: the org's pins; `nixpkgs`, `flake-parts` and `import-tree` follow it |
| `nixpkgs` | the Nix package collection (Python, ...) |
| `flake-parts` | splits the flake into small modules |
| `import-tree` | loads every file in `flake-parts/` automatically |
| `mkdocs-flake` | MkDocs + Material + plugins, as a flake-parts module |
| `reveal-js` | the reveal.js source at a release tag (not a flake) |

`flake.lock` records the exact commit and content hash of each one. Commit
it: it is what makes the build reproducible.

```bash
nix flake update reveal-js    # update one input
nix flake update org-pkgs     # move the org pins (nixpkgs, ...), then:
sync-locks                    # re-pin dev/flake.lock and devenv.lock to the same nixpkgs
nix flake metadata            # show what is locked
```

To move reveal.js to a new release, change the tag in its URL
(`github:hakimel/reveal.js?ref=6.0.2`) and run
`nix flake update reveal-js`.

## Why no npm?

reveal.js publishes its built files (`dist/`) inside the git repo at every
release tag. The flake fetches that tag as plain files and copies `dist/`
next to your slides, so there is no `package.json`, `node_modules` or
JavaScript build step. MkDocs is Python, and mkdocs-flake builds it from
pinned wheels.

## flake-parts and import-tree

[flake-parts](https://flake.parts) lets the flake be written as small
modules. Every `.nix` file in `flake-parts/` is one module, and
[import-tree](https://github.com/denful/import-tree) imports them all, so
adding a file there is enough to add an output (no list to update). Each
module sets options inside `perSystem`, for example `packages.slides` or
`apps.serve-slides`.

## Outputs

| Command | Output |
| --- | --- |
| `nix build .#documentation` | the docs website, with the deck at `/slides/` |
| `nix build .#slides` | the slide deck |
| `nix run .#watch-documentation` | live docs preview |
| `nix run .#serve-slides` | live slides preview |
| `nix fmt` | format and lint (treefmt: alejandra, deadnix, statix, nixf-diagnose, shellcheck, sizelint) |
| `nix flake check` | build both sites, lint, and check the three lock files agree |
| `devenv shell` | the dev shell: `fmt`, `check`, `docs`, `slides`, `docs-build` |
| `nix flake show` | list all of the above |

## Exports

Other flakes consume this repo as an input instead of copying it:

| Export | What a consumer gets |
| --- | --- |
| `lib.mkSlides` | build a deck from any `slides/` dir (`{ pkgs, slidesDir, ... }` → `{ package, serveApp }`) |
| `flakeModules.slides` | `packages.slides` + `apps.serve-slides`, plus the `/slides/` embed when mkdocs-flake is imported |
| `flakeModules.default` | the above **and** mkdocs-flake, in one import |
| `templates.default` | this whole repo (`nix flake init -t`) |

The reveal.js pin travels inside these exports (they are bound to this
flake's `inputs` in `flake.nix`), so consumers never add a reveal-js
input or copy the build. Consumer config is one line:
`presenting.slides.dir = ./slides;`.

## Other systems

The flake builds for `x86_64-linux` and `aarch64-linux`. Add
`"aarch64-darwin"` to `systems` in `flake.nix` to build on Apple Silicon
Macs.
