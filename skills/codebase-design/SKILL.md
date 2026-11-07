---
name: codebase-design
description: >-
  Give the shared vocabulary for deep modules: a lot of behaviour behind a small interface, at a
  clean seam. Use when designing or improving a module's interface, finding where to deepen,
  placing a seam, or making code easier to test, or when another skill needs the terms.
---

# Codebase design

Design deep modules: a lot of behaviour behind a small interface, placed at a clean seam, and
tested through that interface. Use this language wherever code is designed or restructured. The aim
is leverage for callers, locality for maintainers and testability for all.

## The repository's rules

The repository's CLAUDE.md and `.claude/rules/` name where its glossary lives, and its test
command. They add to this skill and change none of it. Where they name none, the glossary is
`GLOSSARY.md`. Use the glossary's words for the domain, and this skill's for the design.

## Glossary

Use these terms exactly. Do not swap in "component", "service", "API" or "boundary", as one
language is the point.

- **Module**: anything with an interface and an implementation. It has no fixed scale: a
  function, a class, a package or a slice across tiers. Avoid: unit, component, service.
- **Interface**: everything a caller must know to use the module correctly. It holds the type
  signature, and also invariants, ordering rules, error modes, required configuration and
  performance traits. Avoid: API, signature, which name only the type-level surface.
- **Implementation**: what is inside a module, its body of code. It differs from an adapter. A
  small adapter can have a large implementation, such as a database repository. A large adapter
  can have a small one, such as an in-memory fake. Say "adapter" when the seam is the topic, and
  "implementation" otherwise.
- **Depth**: leverage at the interface, or how much behaviour a caller or test exercises per unit
  of interface it must learn. A module is deep when much behaviour sits behind a small interface,
  and shallow when the interface is nearly as complex as the implementation.
- **Seam**: a place where you can change behaviour without editing in that place, and so the
  location of a module's interface. Where the seam goes is a design decision apart from what sits
  behind it. Avoid: boundary, which the bounded context of domain-driven design already uses.
- **Adapter**: any code that satisfies an interface at a seam. It names a role, the slot
  it fills, and not what is inside.
- **Leverage**: what callers get from depth, or more capability per unit of interface. One
  implementation pays back across many call sites and tests.
- **Locality**: what maintainers get from depth. Change, bugs, knowledge and checks gather in one
  place, so a fix made once holds everywhere.

## Deep and shallow

A deep module has a small interface, with few methods and simple parameters, over a deep
implementation that hides the complex logic:

```text
+-------------------------+
|     Small interface     |   few methods, simple parameters
+-------------------------+
|                         |
|   Deep implementation   |   complex logic hidden
|                         |
+-------------------------+
```

A shallow module has a large interface over a thin implementation that passes calls through.
Avoid it:

```text
+-------------------------------------+
|          Large interface            |   many methods, complex parameters
+-------------------------------------+
|  Thin implementation                |   only passes through
+-------------------------------------+
```

When designing an interface, ask:

- Can I reduce the number of methods?
- Can I simplify the parameters?
- Can I hide more complexity inside?

## Principles

- **Depth belongs to the interface, not the implementation.** A deep module can be built of small,
  swappable parts that stay out of its interface. It has internal seams, private to its
  implementation and used by its own tests, besides the external seam at its interface.
- **The deletion test.** Imagine deleting the module. If the complexity vanishes, it only passed
  calls through. If the complexity reappears across many callers, it earned its keep.
- **The interface is the test surface.** Callers and tests cross the same seam. A wish to test
  past the interface means the module has the wrong shape.
- **One adapter makes a hypothetical seam. Two make a real one.** Add a seam only where something
  varies across it.

## Designing for testability

A good interface makes testing natural:

1. **Accept dependencies, do not create them.** A function that takes its payment gateway as a
   parameter is testable with a stand-in. One that builds a real gateway inside is not.
2. **Return results, do not produce side effects.** A function that returns the discount for a
   cart is testable by its result. One that subtracts the discount from the cart's total in place
   can be checked only by reading the cart after.
3. **Keep the surface small.** Fewer methods need fewer tests, and fewer parameters need less
   setup.

## Relationships

- A module has exactly one interface, the surface it presents to callers and tests.
- Depth is a property of a module, measured against its interface.
- A seam is where a module's interface lives.
- An adapter sits at a seam and satisfies the interface.
- Depth gives leverage to callers and locality to maintainers.

## Rejected framings

- **Depth as the ratio of implementation lines to interface lines.** It rewards padding the
  implementation. Depth here is leverage.
- **"Interface" as a language's `interface` keyword, or a class's public methods.** Both are too
  narrow, as the interface here holds every fact a caller must know.
- **"Boundary".** The bounded context of domain-driven design uses it. Say seam or interface.

## Going deeper

- To deepen a cluster of modules given its dependencies, read [DEEPENING.md](DEEPENING.md): the
  dependency categories, seam discipline, and replacing tests rather than layering them.
