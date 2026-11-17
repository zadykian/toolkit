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
