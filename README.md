# cl-ssg Documentation

A Static Site Generator in Common Lisp

## Introduction

**cl-ssg** is a static site generator written in Common Lisp. It compiles input
files (such as Markdown and Lisp files) into a working static website while
preserving directory structures, handling metadata inheritance via YAML
frontmatter and configuration files, and resolving relative links
automatically.

## Features & Capabilities

- **Directory Structure:** Input directory structure is preserved in the output
  directory.
- **Automatic Indexing:** `index.*` and `404.*` files are mapped directly to
  `index.html` and `404.html`. Other files are placed in directories with
  `index.html` to generate clean URLs (e.g., `foo.md` -> `foo/index.html`).
- **YAML Frontmatter & Config:** Files can specify YAML frontmatter for
  metadata (such as `layout`, `icon` and `publish`). Subdirectories can
  have a `config.yaml` to apply metadata presets to all files within that
  directory.
- **Markdown Processing:** Powered by `3bmd` with support for smart quotes,
  header IDs, code blocks, tables, math, and wiki links (`[[wiki-links]]`).
  Relative links and images are automatically resolved against site root and
  link prefixes.
- **Lisp File Support:** `.lisp` files can be processed where the final
  evaluated form returns a string (e.g. generated HTML via Spinneret).
- **Layouts:** Layouts can be defined in a `layouts` package and specified via
  the `layout` YAML frontmatter key.

## Quick Start & Usage

To compile a site using `cl-ssg`:

1. Ensure ASDF system `cl-ssg` is loaded: `(asdf:load-system "cl-ssg")`
2. Set input and output roots: `(setf cl-ssg:*input-root* #p"path/to/src/")`
`(setf cl-ssg:*output-root* #p"path/to/build/")`
3. Run compilation: `(cl-ssg:process-input-dir)`
4. Copy any directories through: `(cl-ssg:passthrough-copy "assets")`

## Configuration & Frontmatter

Every processable file can start with YAML frontmatter bounded by `---`:

```yaml
---
title: "My Note"
layout: "default-layout"
publish: true
---
```

Files must have `publish: true` in their metadata to be included in the build
queue.

To invert this workflow (publish by default), put  `publish: true` in the
`config.yaml` at the root, and then omit it in every other file. YAML metadata
is inherited by subdirectories, so any amount of nesting will be supported. If
you then don't want to include a file, you can add `publish: false` to its
frontmatter.

## Special variables

There are two [special
variables](https://www.lispworks.com/documentation/lcl50/aug/aug-109.html) that
must be set by the user before running `process-input-dir`.

### `*input-root*`

This is the root of the files that will be converted to HTML. Any files that
are not supported will be ignored.

### `*output-root*`

This is the website root. For this to be a functional website, it should have
an `index.html` file, therefore there should me a `index.[md|lisp|html]` file
in `*input-root*`.

## Supported file types

All file types below can be compiled into HTML, and they all support YAML
frontmatter

- Markdown: relatively well supported, including tables. Code
  highlighting is not supported, and $\LaTeX$ is coming soon.
- Common Lisp: this is the preferred alternative to JavaScript. Any .lisp files
  should evaluate to a string of HTML text. The best way to do this is using
  `(with-output-to-string (spinneret:*html*) ...)` and the [spinneret
  library](https://github.com/ruricolist/spinneret).
- HTML: This is the simplest implementation, since it is simply copied across
  after removing the frontmatter.
