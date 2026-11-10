#!/usr/bin/env sh
set -eu
cd "$(dirname "$0")/.."
python3 scripts/check_integrity.py
python3 -m unittest discover -s tests -p 'test_*.py'
if ! command -v haxe >/dev/null 2>&1; then
    printf '%s\n' 'Haxe is not installed. Python checks passed; Haxe tests were not run.' >&2
    exit 2
fi
haxe -D debug -cp Source -cp tests -lib openfl -lib msignal --run Regression
if [ "${1:-}" = "full" ]; then
    haxe -D debug -cp Source -lib openfl -lib msignal --run com.watabou.towngenerator.tests.RegressionSuite full
else
    haxe -D debug -cp Source -lib openfl -lib msignal --run com.watabou.towngenerator.tests.RegressionSuite
fi
