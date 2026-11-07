---
name: grill-with-docs
description: >-
  Interview the user to sharpen a plan or design, and keep the glossary and the decision records
  as the talk goes. Use when the user asks to be grilled and to have the terms and decisions
  written down.
disable-model-invocation: true
---

# Grill with docs

Interview the user as `grill-me` says: in rounds, over the tree of decisions, each question with
a recommended answer. Keep the domain model as `domain-modeling` says, as the talk
settles terms and decisions. Challenge the terms, update the glossary at once, and offer a
decision record only where it earns one.

## The repository's rules

The repository's CLAUDE.md and `.claude/rules/` name the paths of its glossary and its decision
records. They add to the steps above and change none of them. Where they name none, the glossary
is `GLOSSARY.md` and the decision records are `docs/adr/`, made lazily.
