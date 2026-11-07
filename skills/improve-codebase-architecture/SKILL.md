---
name: improve-codebase-architecture
description: >-
  Scan a codebase for deepening opportunities, write them up as a Markdown report, then grill
  through the one the user picks. Use when the user asks to improve the architecture, or to find
  shallow modules to deepen.
disable-model-invocation: true
---

# Improve codebase architecture

Surface architectural friction and propose **deepening opportunities**: refactors that turn
shallow modules into deep ones. The aim is testability and ease of navigation for an AI.

The scan is informed by the domain model. It builds on the vocabulary of `codebase-design`. Use
its terms (**module**, **interface**, **depth**, **seam**, **adapter**, **leverage**, **locality**)
and its principles exactly in every suggestion. They are the deletion test, the interface as the
test surface, and one adapter as a hypothetical seam where two make a real one. Do not drift into
"component", "service", "API" or "boundary".

## The repository's rules

The repository's CLAUDE.md and `.claude/rules/` name the paths of its glossary and its decision
records. They add to the steps below and change none of them. Where they name none, the glossary
is `GLOSSARY.md` and the decision records are `docs/adr/`, made lazily. The glossary's words
give names to good seams. The decision records hold choices the scan does not re-litigate.

## 1. Explore

Scope before you scan. Deepening a module pays off by making later changes to it easier, so weight
the parts of the codebase that changed recently. Decide where to look before you look:

- If the user named a direction, such as a module, a subsystem or a pain point, take it and skip
  the inference below.
- Otherwise, read back a good stretch of `git log --oneline` to find the hot spots: the files and
  areas that keep coming up. Let those paths pull your attention first. If the changes are
  scattered with no hot spot, widen the net.

Read the glossary, and the decision records of the area you touch, first.

Then walk the codebase as `delegate` says: read a small area inline, and hand a larger read to a
subagent. Do not follow rigid heuristics. Explore, and note where you meet
friction:

- Where does one concept take bouncing between many small modules?
- Where is a module **shallow**, its interface nearly as complex as its implementation?
- Where was a pure function extracted only for testability? The real bugs may hide in how
  callers use it, with no **locality**.
- Where do tightly coupled modules leak across their seams?
- Which parts are untested, or hard to test through their current interface?

Apply the **deletion test** to anything you suspect is shallow. Would deleting it concentrate
complexity, or only move it? If it concentrates, that is the signal you want.

## 2. Present the candidates

Write the report as Markdown to a new file each run, `architecture-review-TIMESTAMP.md`, so that
no scan overwrites another. It goes in the session's scratchpad, or another directory outside the
repository, so that nothing lands in the work tree. Give its absolute path, and list the
candidates in chat, each with its strength. Open nothing, and load nothing from the network.

For each candidate, the report gives:

- **Files**: which files and modules are involved.
- **Problem**: why the current structure causes friction.
- **Solution**: in plain words, what would change.
- **Benefits**: gained locality and leverage, and how the tests would improve.
- **Before and after**: a sketch of each as an indented `text` block, a list of modules with
  their calls, to show the shallowness and the deepening.
- **Strength**: one of `Strong`, `Worth exploring` or `Speculative`.

End the report with a **Top recommendation**: which candidate to take first, and why.

Use the glossary for the domain and `codebase-design` for the architecture. If the glossary
defines "Order", write "the Order intake module", not "the FooBarHandler" or "the Order service".

**Conflicts with a decision record.** Surface a candidate that contradicts one only when the
friction is real enough to warrant reopening it. Mark it in the candidate, such as "contradicts
ADR-0007, but worth reopening because...". Do not list every refactor a record forbids.

Do not propose interfaces yet. After the report is written, ask the user: "Which of these would
you like to explore?"

## 3. Grill the pick

Once the user picks a candidate, walk its decision tree with them as `grill-me` says. Cover the
constraints, the dependencies, the shape of the deepened module, what sits behind the seam, and
which tests survive.

Keep the domain model current as the decisions settle, as `domain-modeling` says:

- If you name a deepened module after a concept missing from the glossary, add the term. Create
  the file lazily.
- If the talk sharpens a fuzzy term, update the glossary there and then.
- If the user rejects a candidate with a load-bearing reason, offer a decision record. Ask:
  "Want me to record this as an ADR so future architecture reviews don't re-suggest it?" Offer one
  only where a later explorer would need the reason. Skip a passing reason, such as "not worth it
  right now", and a self-evident one.
- If the user wants alternative interfaces for the deepened module, use the design-it-twice
  pattern of `codebase-design`.
