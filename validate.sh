#!/usr/bin/env bash
# Lint every device profile in this registry against a checked-out moddef stdlib.
#
# Profiles import moddef:stdlib:measurands, so the linter needs the stdlib on its
# package-root search path. By default this script expects a moddef checkout next
# to this repo (../moddef) and builds the CLI from it; override with MODDEF (the
# moddef checkout) and/or BIN (a prebuilt moddef binary).
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
moddef="${MODDEF:-$(cd "$here/../moddef" && pwd)}"

bin="${BIN:-}"
if [ -z "$bin" ]; then
  echo "building moddef from $moddef ..."
  ( cd "$moddef" && buf generate >/dev/null && cd go && go build -o /tmp/moddef ./cmd/moddef )
  bin=/tmp/moddef
fi
export MODDEF_PACKAGE_ROOTS="$moddef/stdlib"

# moddef lint exits 0 when there are no errors (warnings are allowed), 1 on
# validation errors, 2 on parse errors.
fail=0
while IFS= read -r f; do
  if out=$("$bin" lint "$f" 2>&1); then
    echo "ok   ${f#"$here"/}"
  else
    echo "FAIL ${f#"$here"/}"
    echo "$out"
    fail=1
  fi
done < <(find "$here" -name '*.moddef.yaml' | sort)
exit "$fail"
