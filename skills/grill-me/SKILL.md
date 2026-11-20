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
the questions you can ask now without guessing at answers you have not heard. A round asks at most
four questions of the frontier, those that unblock the most first. Give each your recommended
answer. Then wait for the user's answers before the next round.

Each round's answers reshape the tree. Settled decisions push the frontier outward and unblock the
questions that hung on them. Recompute the frontier and ask the next round. A question whose
answer depends on one still open in this round belongs to a later round, as does a question of the
frontier past the first four.

## Asking a round

Ask a round in one call of the tool that puts questions to the user as choices, such as Claude
Code's `AskUserQuestion`:

- Each question's header names its decision in a word or two.
- Your recommended answer is the first option, its label ending in "(Recommended)". Add one to
  three alternatives that you would defend. The tool adds a free answer.
- Each option's description gives its cost. A choice between code, configs or layouts shows each
  in its option's preview.
- Where several answers can hold at once, let the user pick several.
- The dialog may hide what you wrote before it, so each question carries its own context in a few
  sentences. A question that needs more is often two.

Where no such tool exists, number each question and write the round as text:

```text
Q1 - <question title>: <question body, which may run to paragraphs and hold choices>

Recommended: <your recommended answer>

---

Q2 - <question title>: <question body>

Recommended: <your recommended answer>
```

Word each question so that "yes" accepts your recommended answer.

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
