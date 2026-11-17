# shellcheck shell=bash
# The accepted findings of a check, which report.sh sources. A footer of the description accepts
# one that no change can fix:
#
#   Accepts: NAME RULE [GLOB]: REASON
#
# NAME is the action's, RULE the key that its rule declares, and GLOB, as glob.sh reads one,
# narrows the line to the findings of the files it matches. Sourcing it defines functions and sets
# the accepted_ variables, and runs nothing.
# shellcheck source=actions/lib/glob.sh
. "$(dirname "${BASH_SOURCE[0]}")/glob.sh"
# shellcheck source=actions/lib/markdown.sh
. "$(dirname "${BASH_SOURCE[0]}")/markdown.sh"

# The accepted findings, as report.sh's findings are by index, and the reason of each.
accepted_rules=() accepted_messages=() accepted_files=() accepted_lines=() accepted_reasons=()

# report_accept moves each finding that a line of the footers of the description $1 accepts from
# the findings to the accepted ones.
report_accept() {
    local first last i j line rest head reason action key glob gone=' ' keep=()
    markdown_read "$1"
    read -r first last <<<"$(footers)"
    for ((i = first; i <= last; i++)); do
        line=${texts[i]}
        [ "${kinds[i]}" = text ] && [[ $line == 'Accepts:'* ]] || continue
        rest=${line#Accepts:}
        if [[ $rest == *': '* ]]; then
            head=${rest%%': '*} reason=${rest#*': '}
        else
            head=${rest%:} reason=''
        fi
        read -r action key glob <<<"$head"
        [ "$action" = "${report_name-}" ] || continue
        for j in "${!report_messages[@]}"; do
            [ "${report_keys[${report_rules[j]}]-}" = "$key" ] || continue
            [ -z "$glob" ] || { [ -n "${report_files[j]}" ] &&
                (EXCLUDE=$glob && excluded "${report_files[j]}"); } || continue
            [[ $gone != *" $j "* ]] || continue
            accepted_rules+=("${report_rules[j]}") accepted_messages+=("${report_messages[j]}")
            accepted_files+=("${report_files[j]}") accepted_lines+=("${report_lines[j]}")
            accepted_reasons+=("$reason")
            gone+="$j "
        done
    done
    for j in "${!report_messages[@]}"; do
        [[ $gone == *" $j "* ]] || keep+=("$j")
    done
    report_keep "${keep[@]}"
}

# report_keep keeps the findings of the indices $@ alone.
report_keep() {
    local i kept_rules=() kept_messages=() kept_files=() kept_lines=()
    for i; do
        kept_rules+=("${report_rules[i]}") kept_messages+=("${report_messages[i]}")
        kept_files+=("${report_files[i]}") kept_lines+=("${report_lines[i]}")
    done
    report_rules=("${kept_rules[@]}") report_messages=("${kept_messages[@]}")
    report_files=("${kept_files[@]}") report_lines=("${kept_lines[@]}")
}
