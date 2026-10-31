# reveal.js basics

[reveal.js](https://revealjs.com) is a presentation framework that runs in
the browser. A deck is a web page; each slide is a `<section>`. In this
repo you write the slides in Markdown and never touch JavaScript tooling.

## The files

```text
documentation/slides/
├── index.html   # the page: loads reveal.js, picks a theme, points at slides.md
└── slides.md    # the slides themselves, in Markdown
```

When you build, Nix copies `documentation/slides/`, folds `slides.md` into
`index.html`, and adds reveal.js under `reveal/`:

```text
result/
├── index.html   # with slides.md inlined
└── reveal/      # reveal.js' prebuilt dist/: reveal.js, reveal.css, theme/, plugin/
```

You only edit `documentation/slides/`. To add images, put them in `documentation/slides/` (or a
subfolder) and `git add` them.

## Writing slides in Markdown

`slides.md` is split into slides by separator lines (configured in
`index.html`):

| Separator (on its own line) | Makes |
| --- | --- |
| `---` | a new slide to the **right** |
| `--` | a new slide **below** (a vertical sub-topic) |
| `Note:` | the rest of the slide is **speaker notes** |

```markdown
# First slide

Hello!

---

## Second slide

- point one
- point two <!-- .element: class="fragment" -->

Note:
Only you see this, in the speaker view (press S).

--

## Below the second slide
```

The `<!-- .element: class="fragment" -->` comment makes that line appear
on the next key press. Other useful fragment classes: `fade-up`,
`highlight-red`, `strike`.

Code blocks get syntax highlighting, and `[1|2-3]` after the language
steps through highlighted lines:

````markdown
```python [1|2-3]
def greet(name):
    message = f"Hello, {name}"
    print(message)
```
````

## Presenting

| Key | Does |
| --- | --- |
| ++right++ / ++space++ | next slide or fragment |
| ++down++ | next vertical slide |
| ++s++ | speaker view: notes, timer, next slide |
| ++o++ or ++esc++ | overview of all slides |
| ++f++ | full screen |
| ++b++ | black screen (pause) |

To make a PDF, open the deck with `?print-pdf` at the end of the URL
(`http://127.0.0.1:8000/?print-pdf`) and print to PDF from Chrome or
Chromium.

## Themes and settings

Change the theme in `documentation/slides/index.html`:

```html
<link rel="stylesheet" href="reveal/theme/black.css" />
```

Built-in themes: `black`, `white`, `league`, `beige`, `night`, `serif`,
`simple`, `solarized`, `moon`, `dracula`, `sky`, `blood`, and the
high-contrast `black-contrast` / `white-contrast`.

Options such as transitions and slide numbers go in `Reveal.initialize({...})`
at the bottom of `index.html`. See the
[config reference](https://revealjs.com/config/).

## Why a web server for previews?

`index.html` loads `slides.md` with a web request, and browsers block those
requests from pages opened straight from disk (`file://`). That is why the
repo has `nix run .#serve-slides` instead of "double-click index.html".

The **built** deck does not have this problem: `nix build .#slides` copies
the Markdown into `index.html` itself (a `<textarea data-template>` block,
done by `flake-parts/scripts/inline-markdown.py`), so `result/index.html`
opens straight from disk and works on any host.

## The deck inside the docs site

`nix build .#documentation` also puts the built deck at `/slides/` of the
website, and the [Presentation](presentation.md) page embeds it with an
`<iframe>`. Anything you change in `documentation/slides/` shows up in both.

## More than one deck

Copy `index.html` to, say, `documentation/slides/talk-2.html`, point its
`data-markdown` at `talk-2.md`, and open `/talk-2.html`.
