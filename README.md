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
Node or npm to install, only Nix.

```bash
nix run .#watch-documentation   # live docs preview   → http://127.0.0.1:8000
nix run .#serve-slides          # live slides preview → http://127.0.0.1:8000

nix build .#documentation       # ./result = docs website
nix build .#slides              # ./result = slide deck
nix flake check                 # build both + lint the Nix code
```

Remember to `git add` new files: Nix only sees files git tracks.

Never commit build output (`result`, `_site/`, `site/`): CI builds the
docs site, deck included, and deploys it to GitHub Pages
(`.github/workflows/pages.yml`).

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
flake.nix          inputs + exports (lib, flakeModules, template), locked in flake.lock
lib/               mkSlides: the root-agnostic deck builder other flakes reuse
flakeModules/      the exportable flake-parts module (presenting.slides.* options)
flake-parts/       this repo's own config, auto-imported: docs settings, checks
.github/workflows/ pages.yml: check, build and deploy the docs site to GitHub Pages
documentation/     MkDocs site: mkdocs.yml + docs/*.md
slides/            reveal.js deck: index.html + slides.md
```
