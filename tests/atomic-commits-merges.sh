# shellcheck shell=bash
# The cases of atomic-commits/check.sh on the merges of an integration branch's pull request.
# Backticks quote the report's Markdown here, never a command.
# shellcheck disable=SC2016

# atomic runs the check.
atomic() {
    check atomic-commits
}

# A merge that landed a pull request into this one's head branch, and the commits it brought in, as
# compare lists them, take no finding and count no lines. A merge of no landed pull request does.
setup passes-the-merges-of-an-integration-branchs-pull-requests
answer repos/o/r/pulls/1/commits '[
    {"sha": "aaaaaaa", "parents": [{}], "commit": {"message": "Add a"}},
    {"sha": "bbbbbbb", "parents": [{}], "commit": {"message": "Add b"}},
    {"sha": "ccccccc", "parents": [{"sha": "0000000"}, {}], "commit": {"message": "Merge pull request #7"}},
    {"sha": "ddddddd", "parents": [{}], "commit": {"message": "feat: add d"}},
    {"sha": "eeeeeee", "parents": [{"sha": "ccccccc"}, {}], "commit": {"message": "Merge pull request #8"}},
    {"sha": "fffffff", "parents": [{"sha": "eeeeeee"}, {}], "commit": {"message": "Merge branch '\''x'\''"}}]'
answer repos/o/r/commits/ccccccc/pulls '[{"number": 7, "merged_at": "2026-01-01T00:00:00Z",
    "base": {"ref": "feat"}}]'
answer repos/o/r/commits/eeeeeee/pulls '[{"number": 8, "merged_at": null, "base": {"ref": "feat"}},
    {"number": 9, "merged_at": "2026-01-01T00:00:00Z", "base": {"ref": "main"}}]'
answer repos/o/r/commits/fffffff/pulls '[]'
answer repos/o/r/compare/0000000...ccccccc '{"commits": [{"sha": "aaaaaaa"}, {"sha": "bbbbbbb"},
    {"sha": "ccccccc"}]}'
for sha in aaaaaaa bbbbbbb ddddddd; do
    answer repos/o/r/commits/$sha '{"files": [{"filename": "a", "additions": 400, "deletions": 0}]}'
done
atomic
warns 'Commit `eeeeeee Merge pull request #8` is a merge commit, of 2 parents.'
warns "Commit \`fffffff Merge branch 'x'\` is a merge commit, of 2 parents."
warns 'Commit `ddddddd feat: add d` changes 400 lines'
warnings 3

# gh stack merge lands a stack under one merge commit, which commits/SHA/pulls lists for its bottom
# pull request alone. The commits of the upper ones come in with it, and take no finding.
setup passes-a-stack-landed-under-one-merge
answer repos/o/r/pulls/1/commits '[
    {"sha": "aaaaaaa", "parents": [{}], "commit": {"message": "Add a"}},
    {"sha": "bbbbbbb", "parents": [{}], "commit": {"message": "Add b"}},
    {"sha": "ccccccc", "parents": [{"sha": "0000000"}, {}], "commit": {"message": "Merge pull request #7"}}]'
answer repos/o/r/commits/ccccccc/pulls '[{"number": 7, "merged_at": "2026-01-01T00:00:00Z",
    "base": {"ref": "feat"}}]'
answer repos/o/r/compare/0000000...ccccccc '{"commits": [{"sha": "aaaaaaa"}, {"sha": "bbbbbbb"},
    {"sha": "ccccccc"}]}'
atomic
warnings 0

# A lookup that GitHub refuses stops the check, rather than read a landed merge as a finding.
setup stops-where-a-landed-lookup-is-refused
answer repos/o/r/pulls/1/commits '[
    {"sha": "ccccccc", "parents": [{"sha": "0000000"}, {}], "commit": {"message": "Merge pull request #7"}}]'
refuse GET repos/o/r/commits/ccccccc/pulls 500
atomic
warns 'could not check #1'
warnings 1
