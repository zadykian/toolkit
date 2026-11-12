---
name: repo-settings
description: >-
  Check a GitHub repository's merge settings, rulesets and Actions permissions against those that
  stacked pull requests land by, report each difference, and apply them once approved.
disable-model-invocation: true
---

# Repository settings

Check the settings of the clone's repository against the ones below, and report each difference.
Change nothing until the maintainer approves: a setting is no file, so no pull request reviews it.

## The repository's rules

The settings below hold in every repository. Its CLAUDE.md names facts alone: the short jobs that
its ruleset requires, the reviews it asks for, and whether it publishes release files.

## Read

Run each from a clone, whose remote names the repository to `gh`:

```sh
gh api 'repos/{owner}/{repo}' --jq '{default_branch, allow_merge_commit, allow_squash_merge,
    allow_rebase_merge, allow_update_branch, delete_branch_on_merge}'
gh api 'repos/{owner}/{repo}/actions/permissions/workflow'
gh api 'repos/{owner}/{repo}/rulesets' --jq '.[] | {id, name, target, enforcement}'
gh api 'repos/{owner}/{repo}/rulesets/ID' --jq '{conditions, bypass_actors, rules}'
gh api 'repos/{owner}/{repo}/immutable-releases'
```

A ruleset's details need a token that administers the repository. On a refusal, report what gh
printed, and stop.

## The merge

- `allow_merge_commit` is `true`, and `allow_squash_merge` and `allow_rebase_merge` are `false`. A
  pull request's signed commits then land as they are, under a merge commit that GitHub signs. A
  squash drops the commits that CI checked, and GitHub signs none that a rebase writes.
- `allow_update_branch` is `false`: its button merges the base branch in, and a stack catches up
  by a rebase.
- `delete_branch_on_merge` is `true`. GitHub then retargets each pull request on a landed branch
  at that branch's base, which gives the stack above its turn.

## Actions

- `default_workflow_permissions` is `read`, so a job's token writes only what its workflow names.
- `can_approve_pull_request_reviews` is `false`: no workflow approves a pull request.

## The ruleset of the default branch

[main.json](main.json) holds it: active, on `~DEFAULT_BRANCH`, with no bypass actor.

- `deletion` and `non_fast_forward`: nobody deletes the branch or force-pushes to it.
- `required_signatures`: each commit is signed.
- `pull_request`: a change lands by a pull request, by the `merge` method alone, with each review
  conversation resolved. `required_approving_review_count` is the repository's own: 0 where one
  maintainer works alone.
- `required_status_checks`: the short jobs, as `ci` sorts them, each by the name that
  `gh pr checks N` shows. `strict_required_status_checks_policy` requires a branch up to date, so
  that a merge's tree is the tree CI checked. A long job may be required too, as `ci` says.
- No `required_linear_history`, which refuses a merge commit.

A classic branch protection rule guards the branch twice: report one, read by
`gh api 'repos/{owner}/{repo}/branches/BRANCH/protection'`, for the maintainer to delete.

## The ruleset of the release tags

[tags.json](tags.json) holds it: active, on `refs/tags/v*`, with no bypass actor. `deletion`,
`non_fast_forward` and `update` keep a release's tag on its commit. Where the repository
publishes release files, immutable releases are on too, so that a release's files never change.

## Report, then apply

Report each setting that differs: its name, its value now, and the value above. Report a setting
stricter than the one above, such as more required reviews or checks, and keep it. Then wait for
the maintainer's approval, and apply what they approve:

```sh
gh api -X PATCH 'repos/{owner}/{repo}' -F allow_merge_commit=true -F allow_squash_merge=false \
    -F allow_rebase_merge=false -F allow_update_branch=false -F delete_branch_on_merge=true
gh api -X PUT 'repos/{owner}/{repo}/actions/permissions/workflow' \
    -f default_workflow_permissions=read -F can_approve_pull_request_reviews=false
gh api -X POST 'repos/{owner}/{repo}/rulesets' --input FILE
gh api -X PUT 'repos/{owner}/{repo}/rulesets/ID' --input FILE
gh api -X PUT 'repos/{owner}/{repo}/immutable-releases'
```

- FILE is a copy of the skill's JSON, outside the work tree, with the repository's facts in
  place. Each short job takes a context in place of `SHORT_JOB`, and the count of reviews is the
  repository's.
- `POST` makes a ruleset. `PUT` replaces the one of that ID whole, so FILE keeps each rule that
  it has beyond those above.
- Never add a bypass actor, loosen a rule, or delete a ruleset or a protection rule.

Read the settings again, and report what changed and what still differs.
