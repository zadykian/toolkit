# shellcheck shell=bash
# The cases of banned-terms/check.sh that run on a terms.json of their own: how it reads the list,
# and how it warns where the list is missing or malformed.

# start starts the case $1, of a pull request with no commit and no file.
start() {
    setup "$1"
    answer repos/o/r/pulls/1/commits '[]'
    answer repos/o/r/pulls/1/files '[]'
}

# titled answers the pull request with the title $1.
titled() {
    answer repos/o/r/pulls/1 "$(pull "$(jq -n --arg title "$1" '{title: $title}')")"
}

# listed leaves a tree of the action in $FAKE whose skill's terms.json holds the text $1, or which
# has no terms.json where $1 is omitted. Pass "$tree" to check, which then runs on that tree.
listed() {
    mkdir -p "$FAKE/actions/banned-terms" "$FAKE/skills/banned-terms"
    ln -s "$ROOT/actions/lib" "$FAKE/actions/lib"
    [ $# = 0 ] || printf '%s\n' "$1" >"$FAKE/skills/banned-terms/terms.json"
    tree=GITHUB_ACTION_PATH=$FAKE/actions/banned-terms
}

# An escape reads both ways: as a space, and as the letters of a word, as in a Windows path.
start reads-a-word-after-an-escape-both-ways
listed '[{"terms": ["things", "thing"], "hint": "Say it"}]'
titled 'feat: C:\things and \thing'
check banned-terms "$tree"
warns "::The title says \`things\`"
warns "::The title says \`thing\`"
warnings 2

# A term is lowercased, and splits at each character other than a letter or a digit. A hint's
# line ends become spaces.
start splits-each-term-of-the-list
listed '[{"terms": ["foo", "Bar-baz"], "hint": "Say it"}, {"terms": ["QUX"], "hint": "Drop\nit"}]'
titled 'feat: foo baz qux quux'
check banned-terms "$tree"
warns "::warning title=banned-terms%3A foo%2C bar%2C baz::The title says \`foo\`"
warns "::warning title=banned-terms%3A foo%2C bar%2C baz::The title says \`baz\`"
warns "::warning title=banned-terms%3A qux::The title says \`qux\`"
warnings 3
summarizes $'How to fix it:\n\nSay it'
summarizes $'How to fix it:\n\nDrop it'

start warns-without-the-list
listed
check banned-terms "$tree"
warns '::warning::banned-terms could not check #1: skills/banned-terms/terms.json, which lists'
warnings 1

start warns-where-the-list-is-no-json
listed '[{"terms": ["foo"], "hint": "Say it"}'
check banned-terms "$tree"
warns '::warning::banned-terms could not check #1: skills/banned-terms/terms.json is not valid JSON'
warnings 1

# Each of these is no array of groups: no value, two, no array, a group of no object, terms of no
# array, no term, a term with no letter or digit, no hint, and a blank one.
for json in '' '[] []' '{}' '["foo"]' '[{"terms": "foo", "hint": "Say it"}]' \
    '[{"terms": [], "hint": "Say it"}]' '[{"terms": ["--"], "hint": "Say it"}]' \
    '[{"terms": ["foo"]}]' '[{"terms": ["foo"], "hint": " "}]'; do
    start "warns-where-the-list-is-malformed: $json"
    listed "$json"
    check banned-terms "$tree"
    warns '::warning::banned-terms could not check #1: skills/banned-terms/terms.json holds no'
    warnings 1
done

start warns-where-the-list-is-empty
listed '[]'
check banned-terms "$tree"
warns '::warning::banned-terms could not check #1: skills/banned-terms/terms.json lists no term.'
warnings 1
