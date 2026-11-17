# shellcheck shell=bash
# The cases of lib/accept.sh: which findings a check's report accepts, through a check that sources
# report.sh. The description's `Accepts:` footers say which.

# probe runs a check.sh of the lines of stdin, between report_start probe and report_finish. It
# declares the rules a and b, and fails the case where the check exits non-zero.
probe() {
    {
        printf '#!/bin/bash\nset -euo pipefail\n. %q\nreport_start probe\n' "$ROOT/actions/lib/report.sh"
        printf "rule a 'Rule A' https://example.test/a 'Fix A.'\n"
        printf "rule b 'Rule B' https://example.test/b 'Fix B.'\n"
        cat
        printf 'report_finish\n'
    } >"$FAKE/check.sh"
    chmod +x "$FAKE/check.sh"
    step "$FAKE/check.sh"
    [ "$STATUS" = 0 ] || fail "the check exited with $STATUS: $(cat "$FAKE/out")"
}

# described answers pull request #1 with the description $1.
described() {
    answer repos/o/r/pulls/1 "$(pull "$(jq -n --arg body "$1" '{body: $body}')")"
}

# A line of its action, a rule and a glob accepts the findings it matches, with its reason.
setup accepts-the-findings-a-line-matches
described $'# T\n\n## Problem\n\nA.\n\nAccepts: probe a src/**: A name of git.\nAccepts: other a: Not ours.'
probe <<'CHECK'
finding a 'In src.' src/x.go 12
finding a 'Elsewhere.' docs/y.md
finding b 'Of Rule B.' src/z.go
CHECK
warns "::Elsewhere.%0AThe rule: https://example.test/a"
warns "::Of Rule B."
warnings 2
summarizes "It found 2 findings as of"
summarizes "#### Accepted

The description accepts these findings, and each warns no more:

- \`src/x.go:12\`: In src.
  Reason: A name of git."

setup accepts-a-rule-of-all-files
described $'# T\n\nAccepts: probe a: Names of git.'
probe <<'CHECK'
finding a 'One.' src/x.go
finding a 'Two.'
CHECK
warnings 0
summarizes "No findings remain as of"
summarizes "Reason: Names of git."

setup comments-nothing-when-all-are-accepted
described $'# T\n\nAccepts: probe a: Names of git.'
probe <<<"finding a 'Found.'"
writes 0

setup edits-the-comment-when-all-are-accepted
answer repos/o/r/issues/1/comments '[{"id": 5, "body": "<!-- zadykian/actions:probe -->\nOld."}]'
described $'# T\n\nAccepts: probe a: Names of git.'
probe <<<"finding a 'Found.'"
wrote PATCH repos/o/r/issues/comments/5 'No findings remain'

setup ignores-a-line-outside-the-footers
described $'# T\n\nAccepts: probe a: Names of git.\n\nMore text.'
probe <<<"finding a 'Found.'"
warnings 1

# A line of its action that names no rule, has no reason or matches no finding is a finding.
setup finds-a-bad-line
described $'# T\n\nAccepts: probe c: Not a rule.\nAccepts: probe: No rule.\nAccepts: probe a:\nAccepts: probe a docs/**: Nothing there.\nAccepts: other c: Not ours.'
probe <<<"finding a 'Found.' src/x.go"
summarizes "\`Accepts: probe c: Not a rule.\` names no rule of probe: a, b."
summarizes "\`Accepts: probe: No rule.\` names no rule of probe: a, b."
summarizes "\`Accepts: probe a:\` has no reason."
summarizes "\`Accepts: probe a docs/**: Nothing there.\` matches no finding."
summarizes "#### An Accepts line accepts nothing"
warnings 5

# GitHub keeps the \r\n that a browser sent, which an attribution line ends the footers after.
setup reads-a-description-with-crlf-line-ends
described $'# T\r\n\r\nAccepts: probe a: Names of git.\r\n\r\n🤖 Generated with [Claude Code](https://claude.com/claude-code)\r\n'
probe <<<"finding a 'Found.'"
warnings 0
