---
name: domain-modeling
description: >-
  Build and sharpen a project's domain model: challenge its terms, keep its glossary, and record
  its hard decisions. Use when discussing a codebase's terminology, or writing or editing a
  glossary or a decision record.
---

# Domain modeling

Build and sharpen the project's domain model as you design. This is the active discipline:
challenge terms, invent edge-case scenarios, and write the glossary and the decisions down the
moment they settle. Merely reading the glossary for its vocabulary is not this skill, as any skill
does that in a line. This skill is for when you change the model.

## The repository's rules

The repository's CLAUDE.md and `.claude/rules/` name where its glossary and its decision records
live. They add to the steps below and change none of them. Where they name none, the glossary is
`GLOSSARY.md` and the decision records are `docs/adr/`, in the form of this skill's two formats.

## File structure

Most repositories have one context:

```text
/
├── GLOSSARY.md
├── docs/
│   └── adr/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

Where a `GLOSSARY-MAP.md` exists at the root, the repository has several contexts. The map points
to where each lives:

```text
/
├── GLOSSARY-MAP.md
├── docs/
│   └── adr/                          <- system-wide decisions
├── src/
│   ├── ordering/
│   │   ├── GLOSSARY.md
│   │   └── docs/adr/                 <- context-specific decisions
│   └── billing/
│       ├── GLOSSARY.md
│       └── docs/adr/
```

Create files lazily, only when you have something to write. Where no glossary exists, create one
when the first term settles. Where no directory of decision records exists, create it when the
first record is needed.

## During the session

### Challenge against the glossary

When the user uses a term that conflicts with the glossary, say so at once. "Your glossary defines
'cancellation' as X, but you seem to mean Y. Which is it?"

### Sharpen fuzzy language

When the user uses a vague or overloaded term, propose a precise canonical one. "You say
'account': do you mean the Customer or the User? Those differ."

### Discuss concrete scenarios

When domain relationships come up, stress-test them with specific scenarios. Invent ones that
probe edge cases, and force the user to be exact about the boundaries between concepts.

### Cross-reference with code

When the user states how something works, check that the code agrees. Where it contradicts, say
so. "Your code cancels entire Orders, but you just said a partial cancellation is possible. Which
is right?"

### Update the glossary inline

When a term settles, update the glossary there and then. Do not batch: capture each as it happens.
Use the [glossary format](GLOSSARY-FORMAT.md).

The glossary holds no implementation detail. Treat it as no spec, no scratch pad and no store for
implementation decisions: a glossary alone.

### Offer decision records sparingly

Offer a record only when all three hold:

1. **Hard to reverse.** Changing your mind later costs a meaningful amount.
2. **Surprising without context.** A future reader will ask why it came out this way.
3. **A real trade-off.** There were genuine alternatives, and you picked one for specific reasons.

Where any is missing, skip the record. Use the [decision record format](ADR-FORMAT.md).
