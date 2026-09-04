# Bookish

Write a book in Markdown, push it to GitHub, and cut a Release to get an EPUB and a PDF built
and attached automatically. Built on [Pandoc](https://pandoc.org/) and adapted from
[wikiti/pandoc-book-template](https://github.com/wikiti/pandoc-book-template).

## Folder structure

```
.
├── chapters/       # One Markdown file per chapter, ordered by filename
│   └── 00-legal.md # Copyright/legal page — unnumbered, appears before chapter 1
├── backmatter/     # EPUB-only content appended after the last chapter
│   └── colophon.md # QR code + license badge stamp (see "Legal page and colophon" below)
├── images/         # Image assets, including the EPUB cover
│   ├── cover.png
│   ├── qr.png             # Placeholder QR code for the colophon stamp
│   └── license-badge.png  # Placeholder license badge for the colophon stamp
├── templates/      # Pandoc output templates (epub, pdf/latex, html, docx)
├── metadata.yml    # Book title, author, language, etc.
├── Makefile        # Build automation (make epub / make pdf / make book)
└── .github/workflows/
    ├── release.yml # Builds epub+pdf and attaches them to a published GitHub Release
    └── ci.yml       # Builds all formats on every push/PR to catch breakage early
```

## Writing the book

1. Edit `metadata.yml` — title, author, language, rights, etc. It must start and end with `---`.
2. Replace `images/cover.png` with your cover art (used as the EPUB cover).
3. Add/edit chapters in `chapters/`, one Markdown file per chapter, named so they sort in
   reading order (`01-introduction.md`, `02-...`). Each `#` heading starts a new chapter.

See the [upstream template's README](https://github.com/wikiti/pandoc-book-template#readme) for
details on cross-references, images, tables, equations, and content filters — all of that carries
over unchanged.

## Legal page and colophon

`chapters/00-legal.md` sorts before every numbered chapter and has no heading, so it renders as an
unnumbered page right after the title page — use it for authorship, licensing terms, registration
codes, AI-assistance disclosure, or contact info for commercial licensing. Edit its text freely, or
delete the file if you don't need a legal page.

The table of contents is deliberately placed at the **back** of the PDF (not the EPUB, where
e-readers rely on their own built-in navigation instead of an inline TOC page). Right below it, the
PDF renders a small "colophon" stamp — a QR code next to a license badge — driven by the
`qr-image`/`license-badge-image` fields in `metadata.yml`. Replace `images/qr.png` and
`images/license-badge.png` with your own (e.g. a QR code linking to a copyright registration
service, and an official [Creative Commons badge](https://creativecommons.org/about/downloads) or
your own "all rights reserved" stamp), or remove both metadata fields to omit the stamp.

The EPUB shows the same two images at the very end of the book instead, via
`backmatter/colophon.md` — this is a separate file because Pandoc only bundles images into an EPUB
when they're referenced through real Markdown image syntax in the content, not through template
variables. Edit both `backmatter/colophon.md` and `metadata.yml`'s image paths together if you
change the images.

## Building locally

Requires [Pandoc](https://pandoc.org/installing.html), `make`, and (for PDF) a LaTeX
distribution (`texlive-xetex`) — or just run everything inside the `pandoc/latex` Docker image
used by CI:

```sh
docker run --rm --entrypoint sh -v "$PWD":/data -w /data pandoc/latex -c "apk add --no-cache make texlive-xetex texmf-dist-latexrecommended ttf-dejavu && export TEXINPUTS=/usr/share/texmf-dist/tex//: && make epub pdf"
```

Locally with Pandoc installed:

```sh
make epub   # build/epub/book.epub
make pdf    # build/pdf/book.pdf
make book   # epub + pdf + html + docx
```

## Publishing a release

Push your changes, then create and publish a
[GitHub Release](https://docs.github.com/en/repositories/releasing-projects-on-github) (a new
tag, e.g. `v1.0.0`). The `release.yml` workflow picks it up, builds the EPUB and PDF, and attaches
both files to that release automatically — no manual upload needed.

## Pulling framework updates

This repo is a [GitHub template](https://github.com/jdmasa/bookish) — using "Use this template"
(or `gh repo create my-book --template jdmasa/bookish`) gives your book its own repo with no git
history or link back here, so fixes made to bookish later never reach existing book repos on
their own.

To pull one in, add bookish as a remote in your book's repo and cherry-pick the specific fix
commit(s):

```sh
git remote add bookish https://github.com/jdmasa/bookish.git
git fetch bookish
git log bookish/main --oneline    # find the commit(s) you want
git cherry-pick <commit-sha>
```

This works cleanly because framework files (`Makefile`, `templates/`, `.github/workflows/`) never
overlap with your book's own content (`chapters/`, `metadata.yml`, `images/`), so a cherry-pick
only ever touches the framework side.
