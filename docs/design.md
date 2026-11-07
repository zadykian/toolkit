# design

The `design` plugin sharpens a design before code is written: an interview that tests a plan, and a
glossary and decision records kept as the talk goes. Its skills are a one-time fork of
[mattpocock/skills](https://github.com/mattpocock/skills) at commit 4ae2317, under its MIT licence.
The fork tracks no upstream, and each skill carries a copy of that licence. The bundle is
`design@zadykian`, as [the README](../README.md#install) shows.

The skills name each other, so `grill-with-docs` needs `grill-me` and
`domain-modeling` installed with it. A repository names for it the paths of its glossary and its
decision records, and its test command.

## grill-me

Interviews the user about a plan, a decision or an idea, until both understand it. It maps the
topic as a tree of decisions and asks in rounds: every question whose prerequisites are settled,
each with a recommended answer worded so that "yes" accepts it. Claude looks facts up itself, inline
or through a subagent as `delegate` says, and puts only decisions to the user. The session ends
when no branch is left, and Claude acts on it once the user agrees.

## grill-with-docs

Interviews the user as `grill-me` does, and keeps the domain model as `domain-modeling` does while
it goes. Run as `/design:grill-with-docs`, by hand alone. It needs both of those skills.

## domain-modeling

Builds and sharpens the project's domain model. It challenges a term against the glossary and
offers a precise one for a fuzzy term. It tests a relationship with a concrete scenario, and
checks the code against what the user says. A term that settles goes into the glossary at once.
A decision that is hard to reverse, surprising and a real trade-off may become a decision record.

A repository names, in its CLAUDE.md or `.claude/rules/`, the paths of its glossary and its
decision records. Where it names none, they are `GLOSSARY.md` and `docs/adr/`, made lazily. Two
format files, beside the skill, set what each holds.

## codebase-design

Gives one vocabulary for the shape of code: module, interface, depth, seam, adapter, leverage and
locality, and the rule that a deep module hides much behind a small interface. Tests cross that interface.
Two pages sit beside it. `DEEPENING.md` classes a cluster's dependencies into four categories, and
says how each is tested across the seam: mock only a true external one. `DESIGN-IT-TWICE.md` has
several designers draw radically different interfaces in parallel, as `delegate` and `fan-out` say,
and compares them.

A repository names, in its CLAUDE.md or `.claude/rules/`, the path of its glossary and its test
command. Where it names none, the glossary is `GLOSSARY.md`.
