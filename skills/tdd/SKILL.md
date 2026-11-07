---
name: tdd
description: >-
  Build a feature or fix a bug test-first, in red-green slices at agreed seams, with tests that
  state behaviour and survive a refactor. Use when asked to work test-first, to run
  red-green-refactor, or to add integration-style tests.
---

# Test-driven development

TDD is the red-green loop. This skill makes that loop produce tests worth keeping: what a good test
is, where tests go, the anti-patterns, and the rules of the loop. Each section applies on every
cycle. Read them before the loop and during it.

## The repository's rules

The repository's CLAUDE.md and `.claude/rules/` name where its glossary lives, and its test
command. They add to this skill and change none of it. Where they name none, the glossary is
`GLOSSARY.md`. Read it, if it exists, so test names and interface terms match the domain's words.
Respect the decision records of the area you touch.

## What a good test is

A test checks behaviour through an interface, not through the implementation. The code can change
entirely, and the tests should not. A good test reads like a specification.
"User can check out with a valid cart" says what capability exists. It survives a refactor, as it
does not care about the internal structure.

[tests.md](tests.md) has examples, and [mocking.md](mocking.md) says what to mock.

## Seams: where tests go

A test lives at a **seam** as `codebase-design` defines it: the place where a module's interface
sits, and where you can see behaviour without reaching inside. Tests live at seams, never against
internals. Say seam or interface, not "boundary".

**Test only at agreed seams.** Before writing a test, write down the seams under test, and confirm
them with the user where one is present. Where none is, state them in the plan and in the report,
and test at those alone. No test goes at a seam that is not agreed or stated. You cannot test
everything, so agreeing the seams up front puts the effort on the critical paths and the complex
logic, not on each edge case.

Ask: "What is the interface, and which seams should we test?" Give each proposed seam a one-line
note on what it catches and what it misses.

When the shape of the interface is itself in question, read `codebase-design` for the terms.
The question may be how deep the module is, where the seam belongs or what the interface should
show. The skill is a reference to consult, not a session to run.

## Anti-patterns

- **Implementation-coupled**: mocks internal collaborators, tests private methods, or checks
  through a side channel, such as a query on the database in place of the interface. The tell: the
  test breaks on a refactor that changes no behaviour.
- **Tautological**: the assertion works out the expected value the way the code does. Examples
  are `add(a, b)` expected to equal `a + b`, a snapshot derived by hand the same way, and a
  constant asserted equal to itself. It passes by construction and can never disagree with the
  code. An expected value comes from an independent source: a known literal, a worked example, the
  spec.
- **Horizontal slicing**: writing all the tests first, then all the implementation. Bulk tests
  check _imagined_ behaviour, so they test the _shape_ of the code, go blind to real changes, and fix
  the structure of the tests before you understand the implementation. Work in **vertical
  slices**: one test, then one implementation, and repeat. Each test is a **tracer bullet** that
  responds to what the last cycle taught you.

## Rules of the loop

- **Red before green.** Write the failing test first, then only enough code to pass it. Do not
  plan for later tests, and add no speculative feature.
- **One slice at a time.** One seam, one test and one minimal implementation per cycle.
- **Commit at green.** A commit holds a test with the code that makes it pass, and no commit holds
  a failing test. `atomic-commits` sets how commits are cut.
- **Refactor on green, in a commit of its own.** A refactor that eases the next test lands first,
  before that test. A cleanup of the code just made green lands after it. Each is a commit of its
  own, with the tests passing before and after, and with no change to behaviour.
