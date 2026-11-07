---
name: grill-me
description: >-
  Interview the user, round by round, until a plan, decision or idea is understood by both. Use
  when the user asks to be grilled, or wants to stress-test their thinking.
---

# Grill me

Interview the user until you reach a shared understanding. Map the topic as a **design tree**:
every decision branches into the decisions that hang off it.

## The repository's rules

The repository's CLAUDE.md and `.claude/rules/` name its facts, such as where its notes on the
design live. They add to the steps below and change none of them.

## Rounds

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are settled:
the questions you can ask now without guessing at answers you have not heard. Ask the whole
frontier in one round. Number each question and give your recommended answer. Then wait for the
user's answers before the next round.

Format a round like so:

```text
Q1 - <question title>: <question body, which may run to paragraphs and hold choices>

Recommended: <your recommended answer>

---

Q2 - <question title>: <question body>

Recommended: <your recommended answer>
```

Word each question so that "yes" accepts your recommended answer.

Each round's answers reshape the tree. Settled decisions push the frontier outward and unblock the
questions that hung on them. Recompute the frontier and ask the next round. A question whose
answer depends on one still open in this round belongs to a later round.

## Facts

Finding facts is your job, never the user's. Do not ask for what you could look up. Look a fact up
inline, as it needs a file or a command. Where it needs a larger read, hand it to a subagent, as
`delegate` says, and do not block on it. A running lookup is an unsettled prerequisite, so only
the questions downstream of it wait. Ask the rest of the frontier now. The decisions are the
user's: put each to them and wait.

## Done

The session is done when the frontier is empty: every branch of the tree visited, and nothing
assumed in silence. Act on it only once the user confirms that you share an understanding. A plan
to file as an issue goes on to `issue`.
