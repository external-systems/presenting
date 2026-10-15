# Presentation

The slide deck from `slides/`, embedded in this site. Click it and use the
arrow keys, or <a href="../slides/index.html" target="_blank">open it on its own</a>.

<!-- Plain HTML links on purpose: MkDocs checks Markdown links against
     documentation/docs/, where the deck only exists during
     `nix build .#documentation`, and strict mode would fail the live
     preview. URLs are relative to this page's URL, /presentation/. -->

<iframe src="../slides/index.html" title="Slide deck"
  style="width: 100%; aspect-ratio: 16 / 9; border: 0;"
  allowfullscreen></iframe>

!!! info "How the deck gets here"
    `nix build .#documentation` builds the deck (`nix build .#slides`)
    first and copies it into the site at `/slides/` before MkDocs runs
    (`mkdocs-preBuildHook` in `flake-parts/default.nix`). The deck still
    builds and works on its own, too.

    The live preview (`nix run .#watch-documentation`) serves only
    `documentation/`, so the frame above is empty there. Preview the deck
    with `nix run .#serve-slides`, or build the whole site and serve it:
    `nix build .#documentation && python3 -m http.server -d result`.
