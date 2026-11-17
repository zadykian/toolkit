#!/bin/bash
# Warns on the terms of the banned-terms skill in what pull request $PR of $GH_REPO adds: the
# paths and lines of its files, its title, its description and its commit messages. It reads the
# environment that lib/report.sh names, and never fails the job. It skips the files that the globs
# of $EXCLUDE match, as lib/glob.sh reads them.
# shellcheck disable=SC2016 # The jq programs' $ variables are jq's, in single quotes.

set -euo pipefail

# shellcheck source=actions/lib/report.sh
. "$GITHUB_ACTION_PATH/../lib/report.sh"
# shellcheck source=actions/lib/glob.sh
. "$GITHUB_ACTION_PATH/../lib/glob.sh"
report_start banned-terms
skill=$(file_url skills/banned-terms/SKILL.md)

# The list is skills/banned-terms/terms.json, which the skill reads too, and no input changes it.
# The runner downloads the whole repository at the action's ref, skills/ included. The file holds
# one array of groups, each {"terms": [TERM...], "hint": HINT}, as group checks: a TERM at least,
# each with a letter or a digit, and a HINT that is not blank. A group's "except", where it has one,
# lists the regexes of well-known names that hold its terms, each of one line, that compile. A term
# splits at each character other than a letter or a digit. config holds on its first line the index,
# {TERM: KEY}, on its second the groups' regexes as one JSON string, then each group's rule, its
# KEY, TITLE and HINT, whose line ends become spaces. A group's key is its first term, which an
# Accepts line names. config is empty where the file holds no such array.
list=skills/banned-terms/terms.json
json=$GITHUB_ACTION_PATH/../../$list
[ -f "$json" ] || cannot_check "$list, which lists the terms, is missing."
jq empty "$json" 2>/dev/null || cannot_check "$list is not valid JSON."
config=$(jq -sr 'def group: type == "object" and (.hint | type == "string" and test("\\S"))
        and (.terms | type == "array" and length > 0
            and all(.[]; type == "string" and test("[A-Za-z0-9]")))
        and (.except // [] | type == "array" and all(.[]; type == "string" and length > 0
            and (contains("\n") | not) and (. as $re | try ("" | test($re) | true) catch false)));
    select(length == 1 and (.[0] | type == "array" and all(.[]; group))) | .[0]
    | ([.[] | .except // [] | .[] | "(?:\(.))"] | join("|")) as $except
    | map({terms: [.terms[] | ascii_downcase | splits("[^a-z0-9]+") | select(. != "")],
        hint: (.hint | gsub("\n"; " "))} | .key = .terms[0])
    | (reduce .[] as $group ({}; .[$group.terms[]] = $group.key)) as $index
    | ($index | tojson), ($except | tojson),
        (.[] | [.key, (.terms | join(", ")), .hint] | join("\t"))' "$json")
[ -n "$config" ] || cannot_check "$list holds no array of groups, each of its terms and a hint."
{
    read -r index
    read -r except
    [ "$index" != '{}' ] || cannot_check "$list lists no term."
    while IFS=$'\t' read -r key title hint; do rule "$key" "$title" "$skill" "$hint"; done
} <<<"$config"
readme=$(file_url actions/banned-terms/README.md)
rule unread 'Files with no patch' "$readme#limits" "GitHub gives no patch of a binary file, nor of \
a large one, so the check reads its path alone. Check the text that it adds by hand, or skip it \
with \`exclude\`."

# The jq functions of a scan. terms gives each term of $index that the text . holds, once. It
# first drops each match of $except, a well-known name, as Go's t.Helper(). It splits its
# tokens at each character other than a letter or a digit, then at each hump of camelCase,
# as getHTTPResponse gives get, http and response. It reads \n, \r and \t as a space too, so
# \tname gives name and tname. It drops each path from the root, as /etc/hosts, whose names
# are the system's: a / that no letter, digit, ., _, -, ~, / or } precedes, nor a quote that
# closes a word, and the letters, digits, ., _, - and / after it. A test of the text first skips
# most lines.
# find gives a finding of each, a line of KEY, MESSAGE, FILE and LINE, separated by tabs. file,
# pull and commit find those of a file, a pull request and a commit, line by line. file reads the
# path of a file added or renamed, and numbers each line of the new side from its hunk's header,
# @@ -OLD +NEW @@, to read the lines added. A file that changes with no patch takes a note. pull
# skips the description's `Accepts:` lines, which quote the term that they accept.
defs='($index | keys | join("|")) as $any
| def terms: select(test($any; "i")) | if $except == "" then . else gsub($except; " ") end
    | gsub("\\\\(?<c>[nrt])(?<w>[A-Za-z0-9]*)"; " \(.c)\(.w) \(.w)")
    | gsub("(?<![A-Za-z0-9._~/}-])(?<![A-Za-z0-9._~/}-][\"'"'"'`])/[A-Za-z0-9._-]+(/[A-Za-z0-9._-]*)*"; " ")
    | gsub("(?<a>[a-z0-9])(?<b>[A-Z])"; "\(.a) \(.b)")
    | gsub("(?<a>[A-Z])(?=[A-Z][a-z])"; "\(.a) ")
    | [ascii_downcase | splits("[^a-z0-9]+") | select($index[.])] | unique[];
  def code: gsub("\\s+"; " ") | sub("^ "; "") | sub(" $"; "")
    | if length > 120 then .[:119] + "…" else . end
    | ("`" * ([scan("`+") | length] + [0] | max + 1)) as $fence
    | if test("`") then "\($fence) \(.) \($fence)" else "\($fence)\(.)\($fence)" end;
  def record: map(tostring | gsub("[\t\n]"; " ")) | join("\t");
  def find($where; $file; $line): . as $text | terms
    | [$index[.], "\($where) says `\(.)`: \($text | code)", $file, $line] | record;
  def file: .filename as $path | .status as $status
    | ($path | select($status == "added" or $status == "renamed")
        | find("The path of the \($status) file"; $path; "")),
    (select((.patch // "") == "" and $status != "removed"
        and ($status != "renamed" or .changes > 0))
        | ["unread", "GitHub gives no patch of the file, so its lines go unread.", $path, ""]
        | record),
    (foreach (.patch // "" | split("\n")[]) as $row ({n: 0};
        if $row | startswith("@@") then
            {n: ($row | capture("^@@ -[0-9,]+ \\+(?<n>[0-9]+)").n | tonumber)}
        elif $row | startswith("+") then {n: (.n + 1), line: .n, text: $row[1:]}
        elif $row | startswith(" ") then {n: (.n + 1)}
        else {n} end)
    | select(.text) | .line as $line | .text | find("The added line"; $path; $line));
  def pull: (.title | find("The title"; ""; "")),
    ((.body // "" | split("\n") | to_entries[]) as {key: $i, value: $text}
        | $text | select(test("^Accepts:") | not) | find("Line \($i + 1) of the description"; ""; ""));
  def commit: .sha[:7] as $sha | (.commit.message | split("\n")) as $lines
    | range($lines | length) as $i | $lines[$i]
    | find(if $i == 0 then "The subject of commit `\($sha)`"
        else "Line \($i + 1) of commit \("\($sha) \($lines[0])" | code)" end; ""; "");'

# scan prints the findings of the jq filter $1, of defs, on its input.
scan() {
    jq -r --argjson index "$index" --argjson except "$except" "$defs $1"
}

found=$(gh api --paginate "repos/$GH_REPO/pulls/$PR/files?per_page=100" | scan '.[] | file')$'\n'
found+=$(gh api "repos/$GH_REPO/pulls/$PR" | scan pull)$'\n'
found+=$(gh api --paginate "repos/$GH_REPO/pulls/$PR/commits?per_page=100" |
    scan '.[] | commit')$'\n'
while IFS=$'\t' read -r key message file line; do
    [ -n "$key" ] || continue
    [ -z "$file" ] || ! excluded "$file" || continue
    finding "$key" "$message" "$file" "$line"
done <<<"$found"
report_finish
