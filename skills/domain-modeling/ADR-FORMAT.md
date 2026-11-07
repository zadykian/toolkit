# Decision record format

Decision records live in `docs/adr/` unless the repository's CLAUDE.md or `.claude/rules/` names
another path. They are numbered in order: `0001-slug.md`, `0002-slug.md`. Create the directory
lazily, when the first record is needed.

## Template

```text
# <Short title of the decision>

<1-3 sentences: the context, what we decided, and why.>
```

That is all. A record can be one paragraph. Its value is in recording that a decision was made,
and why, not in filling out sections.

## Optional sections

Add one only where it adds real value. Most records need none.

- **Status** frontmatter (`proposed | accepted | deprecated | superseded by ADR-NNNN`), which
  helps where decisions are revisited.
- **Considered options**, only where the rejected alternatives are worth remembering.
- **Consequences**, only where a downstream effect is not obvious and needs a call-out.

## Numbering

Scan the directory for the highest number and add one.

## When to offer a record

All three must hold:

1. **Hard to reverse.** Changing your mind later costs a meaningful amount.
2. **Surprising without context.** A future reader will look at the code and wonder why on earth it
   was done this way.
3. **A real trade-off.** There were genuine alternatives, and you picked one for specific reasons.

An easy decision to reverse needs no record, as you will reverse it. One that is not surprising
raises no question. One with no real alternative has nothing to record beyond "we did the obvious
choice".

### What qualifies

- **Architectural shape.** "We use a monorepo." "The write model is event-sourced, and the read
  model is projected into Postgres."
- **Integration patterns between contexts.** "Ordering and Billing communicate by domain events,
  not synchronous HTTP."
- **Technology choices that lock in.** The database, the message bus, the auth provider, the
  deployment target. Not every library: only those that would take a quarter to swap out.
- **Boundary and scope decisions.** "The Customer context owns customer data. Other contexts refer
  to it by ID alone." The explicit noes are as valuable as the yeses.
- **Deliberate deviations from the obvious path.** "We use hand-written SQL in place of an ORM,
  because of X." Anything where a reasonable reader would assume the opposite. These stop the next
  engineer from "fixing" what was deliberate.
- **Constraints not visible in the code.** "We cannot use AWS, because of compliance." "Responses
  must take under 200ms, because of the partner API's contract."
- **Rejected alternatives, where the rejection is not obvious.** If you weighed GraphQL and chose
  REST for subtle reasons, record it, or someone will suggest GraphQL again in six months.
