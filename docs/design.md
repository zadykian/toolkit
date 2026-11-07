# design

The `design` plugin sharpens a design before code is written. It has an interview that tests a
plan, and a glossary and decision records kept as the talk goes. It adds a vocabulary of deep
modules, test-first slices, and a scan for architecture to deepen. Its skills are a one-time fork of
[mattpocock/skills](https://github.com/mattpocock/skills) at commit 4ae2317, under its MIT licence.
The fork tracks no upstream, and each skill carries a copy of that licence. The bundle is
`design@zadykian`, as [the README](../README.md#install) shows.

The skills name each other, so `grill-with-docs` needs `grill-me` and `domain-modeling` installed
with it, `tdd` needs `codebase-design`, and `improve-codebase-architecture` needs `codebase-design`,
`grill-me` and `domain-modeling`. `grill-me`, `codebase-design` and `improve-codebase-architecture`
defer to the lean bundle's `delegate`, and `codebase-design` to its `fan-out` too. `tdd` defers to
the flow bundle's `atomic-commits`, and `grill-me` to its `issue`. A repository names for it the
paths of its glossary and its decision records, and its test command.

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
locality, and the rule that a deep module hides much behind a small interface. Tests cross that
interface. Two pages sit beside it. `DEEPENING.md` classes a cluster's dependencies into four
categories, and says how each is tested across the seam: mock only a true external one.
`DESIGN-IT-TWICE.md` has several designers draw radically different interfaces in parallel, as
`delegate` and `fan-out` say, and compares them.

A repository names, in its CLAUDE.md or `.claude/rules/`, the path of its glossary and its test
command. Where it names none, the glossary is `GLOSSARY.md`.

## tdd

Runs red-green slices at seams the user agrees: one test, then the code that passes it, and
repeat. It says what a good test is, which anti-patterns to avoid, and what to mock. Where no user
is present, the plan and the report state the seams. A commit holds a test with its code, as
`atomic-commits` says. A refactor that eases the next test lands first, and a cleanup after green
lands last, each in a commit of its own. `tests.md` has good and bad examples, and `mocking.md`
follows the dependency categories of `codebase-design`: mock only a true external one.

A repository names, in its CLAUDE.md or `.claude/rules/`, the path of its glossary and its test
command. Where it names none, the glossary is `GLOSSARY.md`.

## improve-codebase-architecture

Scans for deepening opportunities: shallow modules whose deletion would concentrate complexity.
It starts at the hot spots of the recent history, or at the direction the user names, and applies
the vocabulary and the deletion test of `codebase-design`. It writes the candidates as a Markdown
report outside the work tree, gives the path, and lists them in chat. Once the user picks one, it
grills through that one as `grill-me` says, and keeps the glossary and the decision records as
`domain-modeling` says. It runs by hand only.

A repository names, in its CLAUDE.md or `.claude/rules/`, the path of its glossary and its
decision records. Where it names none, they are `GLOSSARY.md` and `docs/adr/`.
