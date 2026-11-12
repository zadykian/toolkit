---
name: repo-settings
description: >-
  Check a GitHub repository's merge settings and Actions permissions against those that stacked
  pull requests land by, report each difference, and apply them once approved.
disable-model-invocation: true
---

# Repository settings

Check the settings of the clone's repository against the ones below, and report each difference.
Change nothing until the maintainer approves: a setting is no file, so no pull request reviews it.

## The repository's rules

The settings below hold in every repository, with no value of its own.

## Read

Run each from a clone, whose remote names the repository to `gh`:

```sh
gh api 'repos/{owner}/{repo}' --jq '{default_branch, allow_merge_commit, allow_squash_merge,
    allow_rebase_merge, allow_update_branch, delete_branch_on_merge}'
gh api 'repos/{owner}/{repo}/actions/permissions/workflow'
```

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

## Report, then apply

Report each setting that differs: its name, its value now, and the value above. Then wait for the
maintainer's approval, and apply what they approve:

```sh
gh api -X PATCH 'repos/{owner}/{repo}' -F allow_merge_commit=true -F allow_squash_merge=false \
    -F allow_rebase_merge=false -F allow_update_branch=false -F delete_branch_on_merge=true
gh api -X PUT 'repos/{owner}/{repo}/actions/permissions/workflow' \
    -f default_workflow_permissions=read -F can_approve_pull_request_reviews=false
```

Read the settings again, and report what changed and what still differs.
