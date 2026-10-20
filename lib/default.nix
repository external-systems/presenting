# Exportable, root-agnostic builders — the part of this repo other flakes
# reuse as `inputs.presenting.lib`. `mkSlides` takes the consumer's own
# slides/ directory, so nothing here is bound to this repo's checkout.
# reveal.js is pinned by THIS flake (inputs.reveal-js, locked in
# flake.lock) and travels with the function — consumers never add a
# reveal-js input of their own.
{inputs}: {
  mkSlides = {
    pkgs,
    lib ? pkgs.lib,
    # Directory with the deck (index.html + one Markdown file per
    # `data-markdown` deck) — the consumer's own, e.g. `./slides`.
    slidesDir,
    # Name of that directory in the consumer's checkout, for the serve
    # app (it serves live files from `$PWD/<serveDirName>`).
    serveDirName ? "slides",
    # reveal.js' prebuilt files (reveal.js, reveal.css, theme/, plugin/).
    # Release tags commit `dist/`, so the deck needs zero npm. Override to
    # use a different reveal.js source.
    revealSrc ? "${inputs.reveal-js}/dist",
    name ? "slides",
  }: {
    # The static slide deck: slidesDir plus reveal.js under reveal/
    # (index.html links reveal/...). Each `data-markdown="x.md"` deck gets
    # its Markdown inlined into the .html
    # (flake-parts/scripts/inline-markdown.py), so the built deck opens
    # straight from disk and nests cleanly inside a MkDocs site.
    package = pkgs.runCommand name {nativeBuildInputs = [pkgs.python3];} ''
      cp -r ${slidesDir} $out
      chmod -R u+w $out
      python3 ${../flake-parts/scripts/inline-markdown.py} $out
      cp -r ${revealSrc} $out/reveal
    '';

    # Serve slidesDir straight from the consumer's checkout, so edits show
    # up on a browser refresh. A web server is needed because browsers
    # refuse to load slides.md from a file:// page. Run from the repo root.
    serveApp = {
      type = "app";
      program = lib.getExe (pkgs.writeShellApplication {
        name = "serve-slides";
        runtimeInputs = [pkgs.python3];
        text = ''
          if [ ! -d ${serveDirName} ]; then
            echo "No ${serveDirName}/ folder here — run this from the repository root." >&2
            exit 1
          fi
          root=$(mktemp -d)
          trap 'rm -rf "$root"' EXIT
          ln -s ${revealSrc} "$root/reveal"
          for f in "$PWD"/${serveDirName}/*; do ln -s "$f" "$root/"; done
          port="''${1:-8000}"
          echo "Slides on http://127.0.0.1:$port — edit ${serveDirName}/slides.md, then refresh."
          python3 -m http.server --bind 127.0.0.1 --directory "$root" "$port"
        '';
      });
      meta.description = "Serve slides/ with reveal.js on localhost for live editing.";
    };
  };
}
