# ENCS 4110 — Computer Design Laboratory Manual

LaTeX sources for the ENCS 4110 lab manual (Birzeit University).

## Branches

- **`main`** — LaTeX source (chapters, preamble, resources, code snippets).
- **`pdf`** — published output only: the per-experiment PDFs and the full manual
  (`encs4110_1.pdf` … `encs4110_9.pdf`, `encs4110_manual.pdf`). This branch is
  consumed as a git submodule by the [encs4110](https://github.com/mabushelbaia/encs4110)
  website at `docs/public/manual`.

## Output worktree

The `dist/` directory is a **git worktree of the `pdf` branch**, created once with:

```sh
git worktree add dist pdf
```

The build writes PDFs straight into `dist/`, so committing there commits to the
`pdf` branch — that is how the PDFs get synced to the website. File names use a
**single digit** (`encs4110_1.pdf`), matching the links the website expects.

## Building

Requires a TeX distribution with `pdflatex` (`-shell-escape`) and **Inkscape**
on `PATH` (the `svg` package shells out to it to render the SVG figures, e.g.
the Birzeit logo). Build everything with `make`:

```sh
make all      # every experiment (1-10) + the full manual -> dist/
make manual   # just the full manual -> dist/encs4110_manual.pdf
make 5        # just one standalone experiment -> dist/encs4110_5.pdf
make clean    # remove generated PDFs and LaTeX aux files

# override PDFLATEX if pdflatex is not on PATH
make all PDFLATEX="C:/Users/.../MiKTeX/.../pdflatex.exe"
```

## Publishing PDFs

Because `dist/` is the `pdf` branch, publishing is just a commit + push there:

```sh
cd dist
git add -A
git commit -m "Update built PDFs"
git push origin pdf
```

Then bump the submodule pointer in the website repo:

```sh
cd ../encs4110            # the website repo
git submodule update --remote docs/public/manual
git add docs/public/manual && git commit -m "Update manual PDFs"
```
