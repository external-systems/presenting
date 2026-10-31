# presenting

reveal.js + MkDocs, built by a Nix flake. Two ways to use it:

- **Start a new project** from the template:
  `nix flake init -t github:external-systems/presenting` (or GitHub's
  "Use this template" button).
- **Add docs + slides to an existing flake** by consuming this repo as an
  input — no boilerplate copied, the reveal.js pin and the deck build
  travel inside the input (see below).

A static documentation website ([MkDocs](https://www.mkdocs.org) +
[Material](https://squidfunk.github.io/mkdocs-material/)) and a slide deck
([reveal.js](https://revealjs.com)), both built by a Nix flake. No Python,
Node or npm to install, only Nix (and devenv for the dev shell).

```bash
devenv allow                    # auto-activates the shell on cd (after `devenv hook`)
fmt                             # nix fmt: treefmt with the org linters
check                           # nix flake check: lint, lock sync, both builds
docs-build                      # static docs to ./result-docs; open index.html from disk
devenv up                       # live docs on :8981 and slides on :8982

nix build .#documentation       # ./result = docs website
nix build .#slides              # ./result = slide deck
```

Remember to `git add` new files: Nix only sees files git tracks.

The docs site this repo builds is also its tutorial: start with
`documentation/docs/getting-started.md`, or run the preview and read it in
the browser.

## Consume from your flake

```nix
inputs.presenting = {
  url = "github:external-systems/presenting";
  # Reuse your own pins instead of this repo's (recommended). Nested
  # `inputs = {...}`: three flat `inputs.<x>.follows` lines trip statix's
  # repeated-keys lint (W20).
  inputs = {
    nixpkgs.follows = "nixpkgs";
    flake-parts.follows = "flake-parts";
  };
};
```

Then, in your flake-parts `imports`:

- `inputs.presenting.flakeModules.default` — docs **and** slides (pulls
  in mkdocs-flake for you), or
- `inputs.presenting.flakeModules.slides` — slides only; use this one if
  your flake already imports mkdocs-flake itself (importing both declares
  its options twice).

One line of config builds the deck and embeds it in the docs site at
`/slides/`:

```nix
presenting.slides.dir = ./slides;   # your index.html + slides.md
```

You get `packages.slides`, `apps.serve-slides` and — when mkdocs-flake is
present — the embed via `documentation.mkdocs-preBuildHook`
(`presenting.slides.embedInDocs = false;` opts out). For full control,
call the builder directly: `inputs.presenting.lib.mkSlides { inherit pkgs; slidesDir = ./slides; }`.

```text
flake.nix          inputs (follow external-systems/pkgs) + exports (lib, flakeModules, template)
lib/               mkSlides: the root-agnostic deck builder other flakes reuse
flakeModules/      the exportable flake-parts module (presenting.slides.* options)
flake-parts/       consumer-facing modules, auto-imported: the template output
dev/               dev partition: inputs (dev/flake.lock), formatter, checks, docs
devenv.yaml        dev shell (devenv CLI), the org shell from external-systems/pkgs
documentation/     flake-module.nix + MkDocs site (mkdocs.yml, docs/) + slides/ deck
.github/workflows/ pages.yml: check, build and deploy the docs site to GitHub Pages
.vscode/           nixd (Nix language server) settings
```

The repo follows the org flake standard (nix-style skill): after
`nix flake update org-pkgs`, run `sync-locks` in the same commit.
