# Getting started

## 1. Install Nix

Nix is the only tool you install. Everything else (Python, MkDocs,
reveal.js) comes from the flake.

=== "Linux / macOS / WSL"

    Use the [Determinate Nix installer](https://docs.determinate.systems/),
    which turns on flakes for you:

    ```bash
    curl -fsSL https://install.determinate.systems/nix | sh -s -- install
    ```

=== "NixOS"

    Turn on flakes in your configuration:

    ```nix
    nix.settings.experimental-features = ["nix-command" "flakes"];
    ```

Check it works with `nix --version`.

## 2. Create your repo from this template

```bash
mkdir my-site && cd my-site
git init
nix flake init -t github:external-systems/presenting
git add .
```

!!! warning "Always `git add` new files"
    Inside a git repo, Nix only sees files git knows about. A new page that
    is not `git add`-ed is invisible to `nix build`, and the build fails
    with a "file not found" error. You do not need to commit, only add.

## 3. Preview while you edit

Each command starts a small web server. Leave it running, edit files, and
refresh the browser.

```bash
nix run .#watch-documentation   # docs   → http://127.0.0.1:8981 (auto-reloads)
nix run .#serve-slides -- 8982  # slides → http://127.0.0.1:8982 (refresh by hand)
```

Or run both at once in the devenv shell: `devenv up`. The docs port is
`dev_addr` in `documentation/mkdocs.yml`; the slides take the port as an
argument (default 8000).

The first run downloads and builds the tools, which takes a few minutes.
Later runs start in seconds.

## 4. Build the final sites

```bash
nix build .#documentation   # ./result = the docs website
nix build .#slides          # ./result = the slide deck
```

`result` is a read-only link into the Nix store. To publish, copy its
contents somewhere: `cp -rL result/. public/`. Build both at once with
separate links:

```bash
nix build .#documentation .#slides
# → ./result (docs) and ./result-1 (slides)
```

## 5. Check everything before you push

```bash
nix fmt             # format and lint (treefmt)
nix flake check     # builds both sites, lints, checks the lock files
```

## 6. Publish to GitHub Pages

The repo ships `.github/workflows/pages.yml`. On every push to `main` it
runs `nix flake check`, builds the docs site (slides included under
`/slides/`) and deploys it to GitHub Pages. Pull requests run the same
checks and build without deploying.

Turn it on once per repo: **Settings → Pages → Build and deployment →
Source: GitHub Actions**. The site then appears at
`https://<owner>.github.io/<repo>/`.

Any other static host works the same way: upload the contents of the
`nix build .#documentation` result.
