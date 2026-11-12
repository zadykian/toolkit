---
name: ci
description: >-
  Write a repository's GitHub Actions workflows: short jobs that run on every pull request, long
  jobs that wait for a ready stack on the default branch, and what every job sets. Use when
  writing or editing a workflow, or when CI's runners queue.
---

# CI jobs

A workflow sorts its jobs into two kinds and gates the long ones, as CI's load follows them. A
stack of pull requests then takes the runners once, on its top, and stacks take them in turn.

## The repository's rules

The rules below hold in every repository. Its CLAUDE.md names facts alone: its jobs, which of
them are long, the checks its ruleset requires, and its known flakes.

## 1. Short and long jobs

A job is short where its `timeout-minutes` is 15 or less, on one hosted Linux runner: lint, a
build, unit tests. A job is long where it takes more time, a matrix, or a runner that costs more,
such as macOS, Windows or a larger one. Integration and end-to-end tests are long.

A short job runs:

- on each pull request, a draft too, whatever its base;
- once per commit, on its push;
- on each push to the default branch.

A long job runs:

- on a ready pull request alone, as section 2 gates it: on its push, or as its draft goes ready;
- on each push to the default branch.

A job that its `if:` skips passes a required check, so the ruleset may require a long job. A
workflow that never starts leaves the check pending. So gate a job by `if:`, never by `paths:` or
`branches:` on the trigger of a workflow that holds a required job.

## 2. Stacks in turn

A long job runs on a ready pull request, the top of a stack on the default branch. The event
names the stack in `pull_request.stack`, as GitHub's [stack metadata][stack] gives it:

```yaml
jobs:
  e2e:
    if: >-
      github.event_name != 'pull_request' || (
      !github.event.pull_request.draft &&
      github.event.pull_request.stack.position == github.event.pull_request.stack.size &&
      (github.event.pull_request.stack.base.ref || github.event.pull_request.base.ref) ==
      github.event.repository.default_branch)
```

- **A draft** runs the short jobs alone. A stack opens as drafts, before its link, so its
  `opened` events name no stack: `ready_for_review` is the first event that does.
- **The top** of a stack holds every change below it, so it alone runs the long jobs.
- **A stack on another stack** has that stack's branch as its base, so its long jobs skip, even
  where a pull request of it goes ready by mistake. `atomic-commits` holds it as drafts, and
  `land` brings it onto the default branch once the stack below lands.
- **Outside a stack**, `stack` is null: null == null holds, and the pull request's own base
  stands for the stack's. On another event, such as a push or a release's call, the job runs.

Never start a draft's long jobs by hand, or mark a stack off the default branch ready to try
them. Run them locally, or wait for the stack's turn.

## 3. The workflows

The short jobs take one workflow, on the default types of `pull_request`:

```yaml
name: ci

on:
  pull_request:
  push:
    branches: [main]

concurrency:
  group: ci-${{ github.event.pull_request.number || github.run_id }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}

permissions: {}

jobs:
  lint:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@SHA # vX.Y.Z
        with:
          ref: ${{ github.event.pull_request.head.sha || github.sha }}
          persist-credentials: false
      - run: make lint
```

The long jobs take another, which adds `ready_for_review` to the types. Each of its jobs takes
the condition of section 2:

```yaml
name: e2e

on:
  pull_request:
    types: [opened, synchronize, reopened, ready_for_review]
  push:
    branches: [main]
  workflow_call:

concurrency:
  group: e2e-${{ github.event.pull_request.number || github.run_id }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}
```

- A newer event of a pull request cancels its runs in progress, as their head is gone. A push to
  the default branch takes a group of its own run, so nothing cancels it.
- Write the group's name out: in a called workflow, `github.workflow` names the caller.
- A release workflow calls the long jobs by `workflow_call` on its tag. The event there is the
  push, so the condition holds and they run.
- Where one workflow must hold both kinds, each short job takes
  `if: github.event.action != 'ready_for_review'`, since that event repeats the head's commit.
  The group then ends in `-${{ github.event.action == 'ready_for_review' }}`, so that the run of
  that event cancels no short job of the run before it.

## 4. Every workflow and job

- `permissions: {}` at the top, and each job names the scopes it needs.
- Each job sets `timeout-minutes`, so that a hung step frees its runner.
- Each `uses:` pins an action by its full commit SHA, with the version in a comment.
- A checkout sets `persist-credentials: false`. On a pull request it takes the head's SHA, not
  GitHub's test merge, where the ruleset requires branches up to date: the head's tree lands.
- A value of the event reaches a step through `env:`, never as `${{ }}` in `run:`.
- The trigger is `pull_request`, never `pull_request_target`, which runs a stranger's code with
  the repository's secrets. A job that reads a secret skips a fork's pull request:
  `if: github.event.pull_request.head.repo.full_name == github.repository`.
- A check that only warns takes a workflow of its own, which no ruleset requires.

## 5. Verify

Run the repository's gates on each workflow changed, such as actionlint and zizmor. Then read
the checks of a draft and of a ready pull request: `gh pr checks N`. The draft shows the long jobs
skipped, and the top of a ready stack shows them run.

[stack]: https://docs.github.com/en/pull-requests/how-tos/merge-and-close-pull-requests/optimizing-ci-for-stacked-pull-requests
