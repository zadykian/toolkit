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
