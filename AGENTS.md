# AGENTS.md

MkDocs docs site + reveal.js slide deck tooling for external-systems
flakes. Consumers import `flakeModules.default` (docs + slides) or
`flakeModules.slides`, or call `lib.mkSlides`; `templates.default` is
this whole repo. The reveal.js pin travels with those exports. This repo
builds its own docs and deck with the same module.

## Layout
- `flake.nix`: consumer-facing inputs (org-pkgs; mkdocs-flake, reveal-js) and exports (lib, flakeModules), plus the dev partition wiring.
- `lib/default.nix`: `mkSlides`. `flakeModules/slides.nix`: the `presenting.slides.*` module.
- `flake-parts/`: consumer-facing modules, auto-imported (import-tree): `template.nix`. `flake-parts/scripts/inline-markdown.py` is used by `mkSlides`.
- `dev/flake.nix` + `dev/flake.lock`: dev-only inputs. `dev/flake-module.nix`: the dev partition (formatter, checks, this repo's docs and deck).
- `devenv.yaml` + `devenv.lock` + `devenv.nix`: the dev shell. The org shell comes from external-systems/pkgs (`org-pkgs/devenv` in devenv.yaml).
- `documentation/`: `flake-module.nix`, MkDocs site (`mkdocs.yml`, `docs/`) and reveal.js deck (`slides/`).

## Tool loop
- The shell is devenv. If `DEVENV_ROOT` is unset, run commands with `devenv shell -- <cmd>`.
- `git add` new files before any `nix` command.
- `fmt`, then `check`. Both must pass before a change is done.
- After `nix flake update org-pkgs`, run `sync-locks` in the same commit.

## Rules
- Load the `nix-style` skill before editing any `.nix` file, and `mkdocs-reveal` before changing the exports.
- Dev-only inputs go in `dev/flake.nix`, never `flake.nix`.
- Never change the shape of `lib`, `flakeModules` or `templates` without updating every consumer (pkgs template, skills, secrets, not-secrets, modules, home, clanServices).
- Work on a branch and open a PR. Never push to `main`.
