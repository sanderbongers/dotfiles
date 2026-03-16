---
name: markdownlint-guard
description: >
  Keep touched Markdown files free of markdownlint warnings and errors. Use
  when creating, editing, or reviewing `.md` files and verify lint before
  finishing.
---

# Markdownlint guard

Treat Markdown work as incomplete until every touched `.md` file is lint-clean.
Prefer the repository's existing Markdown lint config if one exists.

## Instructions

1. Edit the Markdown.
2. Run `bash ~/.agents/skills/markdownlint-guard/scripts/run_markdownlint.sh`
   with explicit file paths, or with no arguments to lint changed Markdown
   files.
3. Fix every violation before finishing.
4. Report whether lint passed. If no supported linter is installed, say so
   explicitly.

## Rules

- Use existing repo conventions and lint config.
- Do not ignore warnings.
- Keep headings, lists, blank lines, and fenced code blocks markdownlint-clean.
- Use this skill only for Markdown lint hygiene, not general writing guidance.
