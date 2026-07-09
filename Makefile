# Makefile for building experiment PDFs and the full manual.
#
# Requires a TeX distribution (pdflatex, run with -shell-escape) and
# Inkscape on PATH — the `svg` package shells out to Inkscape to render
# the SVG figures (e.g. the Birzeit logo).
#
# Two kinds of exports, both written to $(OUT) (default: dist/), a git
# worktree of the `pdf` branch:
#   make manual   -> encs4110_manual.pdf   (the whole manual)
#   make 1..9     -> encs4110_<n>.pdf      (a single experiment, standalone)
#   make all      -> every experiment + the manual
#
# Commit and push the `pdf` branch (from inside dist/) to sync the
# website submodule. See README.md for details.
#
# Override PDFLATEX if pdflatex is not on PATH, e.g.:
#   make all PDFLATEX=/c/Users/you/AppData/Local/Programs/MiKTeX/miktex/bin/x64/pdflatex.exe
#
# Note: the variable is deliberately NOT called TEX — that name collides
# with GNU Make's own built-in variable (defaults to plain `tex`), and a
# `TEX ?= pdflatex` assignment is silently ignored because of it.

PDFLATEX ?= pdflatex
TEX_OPTS   = -interaction=nonstopmode -shell-escape
OUT       ?= dist

EXPS := $(shell seq 1 9)
.PHONY: all manual clean help $(EXPS)

all: $(EXPS) manual

# Two passes: the first resolves the table of contents / cross-references,
# the second renders them. Errors from the first pass are expected and ignored.
manual: | $(OUT)
	@echo "==> Building full manual"
	@-$(PDFLATEX) $(TEX_OPTS) main.tex >/dev/null 2>&1
	@$(PDFLATEX) $(TEX_OPTS) main.tex \
		&& mv -f main.pdf $(OUT)/encs4110_manual.pdf \
		|| (test -f main.pdf && mv -f main.pdf $(OUT)/encs4110_manual.pdf || (echo "  x failed"; exit 1))

$(EXPS): | $(OUT)
	@echo "==> Building experiment $@"
	@-$(PDFLATEX) $(TEX_OPTS) "\def\EXPNUM{$@}\input{exp_standalone.tex}" >/dev/null 2>&1
	@$(PDFLATEX) $(TEX_OPTS) "\def\EXPNUM{$@}\input{exp_standalone.tex}" \
		&& mv -f exp_standalone.pdf $(OUT)/encs4110_$@.pdf \
		|| (test -f exp_standalone.pdf && mv -f exp_standalone.pdf $(OUT)/encs4110_$@.pdf || (echo "  x failed"; exit 1))

$(OUT):
	@mkdir -p $(OUT)

clean:
	@rm -f $(OUT)/encs4110_*.pdf main.pdf exp_standalone.pdf *.aux *.log *.toc *.out *.lof *.lot *.maf *.mtc *.mtc0

help:
	@echo "Usage: make <target>   (PDFs are written to $(OUT)/)"
	@echo ""
	@echo "Targets:"
	@echo "  1-9     Build a single standalone experiment PDF"
	@echo "  all     Build every experiment + the full manual"
	@echo "  manual  Build only the full manual"
	@echo "  clean   Remove generated PDFs and aux files"
	@echo "  help    Show this message"
