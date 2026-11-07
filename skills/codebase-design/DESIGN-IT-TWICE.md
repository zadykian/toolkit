# Design it twice

To explore alternative interfaces for a chosen deepening candidate, design it several ways in
parallel. The first idea is unlikely to be the best. It uses the vocabulary of
[SKILL.md](SKILL.md): module, interface, seam, adapter and leverage.

## Process

### 1. Frame the problem space

Before handing out the designs, write the user an account of the problem space for the candidate:

- The constraints any new interface must meet.
- The dependencies it would rely on, and their category in [DEEPENING.md](DEEPENING.md).
- A rough sketch in the project's language to make the constraints concrete, and no proposal.

Show it, and go straight on to step 2, so the user reads while the designers work.

### 2. Hand out the designs

Run 3 or more designers in parallel, each in a fresh context and each making a radically different
interface for the deepened module. Spawn them as `delegate` says: this is an open design, so each
takes the tier it names for one. In a Workflow, each `agent()` names its `agentType` as `fan-out`
says, and the siblings share a prompt prefix with the constraint last.

Give each a separate technical brief: file paths, coupling details, the dependency category from
[DEEPENING.md](DEEPENING.md), and what sits behind the seam. The brief stands apart from the
account in step 1. Give each designer one constraint:

- Designer 1: minimise the interface, with 1 to 3 entry points at most, and maximise leverage per
  entry point.
- Designer 2: maximise flexibility, for many use cases and for extension.
- Designer 3: serve the most common caller, so that the default case is trivial.
- Designer 4, where it applies: build on ports and adapters for the dependencies across the seam.

Put the vocabulary of [SKILL.md](SKILL.md) and the repository's glossary in each brief, so every
designer uses the architecture's words and the domain's.

Each designer returns:

1. The interface: types, methods and parameters, with invariants, ordering and error modes.
2. A usage example of how callers use it.
3. What the implementation hides behind the seam.
4. The dependency strategy and adapters, per [DEEPENING.md](DEEPENING.md).
5. Trade-offs: where leverage is large, and where thin.

### 3. Present and compare

Present the designs one at a time, so the user can take in each. Then compare them in prose by
depth (leverage at the interface), locality (where change gathers) and seam placement.

Then give your own recommendation: which design is strongest, and why. If parts of different
designs combine well, propose a hybrid. Be opinionated, as the user wants a strong read and not a
menu.
