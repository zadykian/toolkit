# shellcheck shell=bash
# The cases of tools/pin --pr, which opens a pull request of app's pin into the main of origin, a
# bare repository. tests/pin.sh holds the cases of the pin itself.

# start makes toolkit, of the action x, its commit SHA tagged v1.2.3, and app, a clone of origin,
# whose workflow uses x.
start() {
    git init -q -b main "$FAKE/toolkit"
    mkdir -p "$FAKE/toolkit/tools" "$FAKE/toolkit/actions/x"
    cp "$ROOT/tools/pin" "$FAKE/toolkit/tools"
    touch "$FAKE/toolkit/actions/x/action.yml"
    git -C "$FAKE/toolkit" add .
    git -C "$FAKE/toolkit" commit -q -m 'feat: add tools/pin'
    git -C "$FAKE/toolkit" tag v1.2.3
    SHA=$(git -C "$FAKE/toolkit" rev-parse HEAD)
    git init -q --bare -b main "$FAKE/origin"
    git clone -q "$FAKE/origin" "$FAKE/app" 2>/dev/null
    mkdir -p "$FAKE/app/.github/workflows"
    cat >"$FAKE/app/.github/workflows/rules.yml" <<'EOF'
jobs:
  rules:
    steps:
      - uses: zadykian/toolkit/actions/x@v1.0.0
EOF
    git -C "$FAKE/app" add .
    git -C "$FAKE/app" commit -q -m 'ci: add the rules'
    git -C "$FAKE/app" push -q origin main
}

# pin runs toolkit's tools/pin --pr at v1.2.3 on app.
pin() {
    step "$FAKE/toolkit/tools/pin" --version v1.2.3 --pr "$FAKE/app"
}

# tidy checks that app keeps no branch or work tree of the pin.
tidy() {
    [ -z "$(git -C "$FAKE/app" branch --list chore/pin-v1.2.3)" ] || fail 'app kept the branch'
    [ "$(git -C "$FAKE/app" worktree list | wc -l)" = 1 ] || fail 'app kept a work tree'
}

setup opens-a-pull-request-of-the-pin-of-origins-main
start
echo '# mine' >>"$FAKE/app/.github/workflows/rules.yml"
pin
exits 0
prints ".github/workflows/rules.yml:4: - uses: zadykian/toolkit/actions/x@$SHA # v1.2.3"
prints https://github.com/o/r/pull/2
grep -qx "pr create --base main --head chore/pin-v1.2.3 --title chore: pin the toolkit to v1.2.3 \
--body-file .*" "$FAKE/calls" || fail "it opened no pull request: $(cat "$FAKE/calls")"
got=$(git -C "$FAKE/origin" show chore/pin-v1.2.3:.github/workflows/rules.yml)
[ "$got" = "${got%"# mine"}" ] || fail 'it pinned the work tree, not the main of origin'
[[ $got == *"x@$SHA # v1.2.3"* ]] || fail "it pushed: $got"
[ "$(git -C "$FAKE/app" status --porcelain)" = ' M .github/workflows/rules.yml' ] ||
    fail 'it changed the work tree of app'
tidy

setup opens-no-pull-request-where-origins-main-pins-already
start
step "$FAKE/toolkit/tools/pin" --version v1.2.3 "$FAKE/app"
git -C "$FAKE/app" commit -q -am 'chore: pin the toolkit to v1.2.3'
git -C "$FAKE/app" push -q origin main
pin
exits 0
prints "$FAKE/app pins v1.2.3 already"
[ ! -e "$FAKE/calls" ] || fail "it called gh: $(cat "$FAKE/calls")"
git -C "$FAKE/origin" rev-parse -q --verify chore/pin-v1.2.3 >/dev/null && fail 'it pushed'
tidy

setup refuses-a-branch-of-the-pin-that-app-has
start
git -C "$FAKE/app" branch chore/pin-v1.2.3
pin
exits 1
prints 'has a branch chore/pin-v1.2.3 already'
git -C "$FAKE/app" rev-parse -q --verify chore/pin-v1.2.3 >/dev/null || fail 'it deleted the branch'

setup opens-a-pull-request-from-a-pipe
start
# The inner sh expands $0 and $1: the script and app.
# shellcheck disable=SC2016
step TOOLKIT_URL="file://$FAKE/toolkit" sh -c 'sh -s -- --pr "$1" <"$0"' "$ROOT/tools/pin" \
    "$FAKE/app"
exits 0
prints https://github.com/o/r/pull/2
tidy
