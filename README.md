# cl-ssg Documentation

A Static Site Generator in Common Lisp

## 1. Introduction

**cl-ssg** is a static site generator written in Common Lisp. It compiles input files (such as Markdown and Lisp files) into a working static website while preserving directory structures, handling metadata inheritance via YAML frontmatter and configuration files, and resolving relative links automatically.

## 2. Features & Capabilities

- **Directory Structure:** Input directory structure is preserved in the output directory.
- **Automatic Indexing:** `index.*` and `404.*` files are mapped directly to `index.html` and `404.html`. Other files are placed in directories with `index.html` to generate clean URLs (e.g., `foo.md` -> `foo/index.html`).
- **YAML Frontmatter & Config:** Files can specify YAML frontmatter for metadata (such as `layout`, `permalink`, and `publish`). Subdirectories can have a `config.yaml` to apply metadata presets to all files within that directory.
- **Markdown Processing:** Powered by `3bmd` with support for smart quotes, header IDs, code blocks, tables, math, and wiki links (`[[wiki-links]]`). Relative links and images are automatically resolved against site root and link prefixes.
- **Lisp File Support:** `.lisp` files can be processed where the final evaluated form returns a string (e.g. generated HTML via Spinneret).
- **Layouts:** Layouts can be defined in a `layouts` package and specified via the `layout` YAML frontmatter key.

## 3. Quick Start & Usage

To compile a site using `cl-ssg`:

1. Ensure ASDF system `cl-ssg` is loaded:
   `(asdf:load-system "cl-ssg")`
2. Set input and output roots:
   `(setf cl-ssg:*input-root* #p"path/to/src/")`
   `(setf cl-ssg:*output-root* #p"path/to/build/")`
3. Run compilation:
   `(cl-ssg:process-input-dir)`

## 4. Configuration & Frontmatter

Every processable file can start with YAML frontmatter bounded by `---`:

```yaml
---
title: "My Note"
layout: "default-layout"
publish: t
permalink: "/custom-url/"
---
```

Files must have `publish: t` in their metadata to be included in the build queue.
