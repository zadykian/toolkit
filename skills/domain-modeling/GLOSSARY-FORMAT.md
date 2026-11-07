# Glossary format

The glossary is `GLOSSARY.md` unless the repository's CLAUDE.md or `.claude/rules/` names another
path.

## Structure

```text
# <Context name>

<One or two sentences on what this context is and why it exists.>

## Language

**Order**:
<A one or two sentence description of the term.>
_Avoid_: Purchase, transaction

**Invoice**:
A request for payment sent to a customer after delivery.
_Avoid_: Bill, payment request

**Customer**:
A person or organization that places orders.
_Avoid_: Client, buyer, account
```

## Rules

- **Be opinionated.** Where several words name one concept, pick the best and list the others
  under `_Avoid_`.
- **Keep definitions tight.** One or two sentences. Define what a term is, not what it does.
- **Hold only terms specific to this project's context.** General programming concepts, such as
  timeouts, error types and common patterns, do not belong, even where the project uses them much.
  Before adding a term, ask whether the concept is unique to this context.
- **Group terms under subheadings** where clusters emerge. If all belong to one cohesive area, a
  flat list is fine.

## One context or several

**One context**, as in most repositories: a single glossary at the root.

**Several**: a `GLOSSARY-MAP.md` at the root lists the contexts, where they live, and how they
relate:

```text
# Glossary map

## Contexts

- [Ordering](./src/ordering/GLOSSARY.md): receives and tracks customer orders
- [Billing](./src/billing/GLOSSARY.md): generates invoices and processes payments
- [Fulfillment](./src/fulfillment/GLOSSARY.md): manages warehouse picking and shipping

## Relationships

- **Ordering -> Fulfillment**: Ordering emits `OrderPlaced` events. Fulfillment consumes them to
  start picking.
- **Fulfillment -> Billing**: Fulfillment emits `ShipmentDispatched` events. Billing consumes them
  to generate invoices.
- **Ordering <-> Billing**: they share the types `CustomerId` and `Money`.
```

Infer which structure applies:

- With a `GLOSSARY-MAP.md`, read it to find the contexts.
- With a root `GLOSSARY.md` alone, there is one context.
- With neither, create a root `GLOSSARY.md` lazily, when the first term settles.

With several contexts, infer which one the topic relates to. If unclear, ask.
