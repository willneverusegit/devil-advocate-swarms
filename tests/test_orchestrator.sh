#!/usr/bin/env bash
# test_orchestrator.sh — Tests fuer devil-advocate-swarms orchestrator.sh
# Aufruf: bash devil-advocate-swarms/tests/test_orchestrator.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORCH_SCRIPT="$SCRIPT_DIR/../scripts/orchestrator.sh"
PASS=0
FAIL=0
TOTAL=0

assert_exit() {
    local desc="$1" expected_exit="$2"
    shift 2
    local actual_exit=0
    "$@" > /dev/null 2>&1 || actual_exit=$?
    TOTAL=$((TOTAL + 1))
    if [[ "$expected_exit" == "$actual_exit" ]]; then
        echo "[PASS] $desc"
        PASS=$((PASS + 1))
    else
        echo "[FAIL] $desc — expected exit $expected_exit, got $actual_exit"
        FAIL=$((FAIL + 1))
    fi
}

assert_contains() {
    local desc="$1" needle="$2" haystack="$3"
    TOTAL=$((TOTAL + 1))
    if echo "$haystack" | grep -qF -- "$needle"; then
        echo "[PASS] $desc"
        PASS=$((PASS + 1))
    else
        echo "[FAIL] $desc — '$needle' not found in output"
        FAIL=$((FAIL + 1))
    fi
}

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "=== test_orchestrator.sh (devil-advocate-swarms) ==="
echo "Temp dir: $TMPDIR"
echo ""

# Test 1: No arguments shows error and exits 1
OUTPUT=$(bash "$ORCH_SCRIPT" 2>&1 || true)
assert_contains "no args shows error" "--target and --goal are required" "$OUTPUT"
assert_exit "no args exits 1" 1 bash "$ORCH_SCRIPT"

# Test 2: --help exits 0
assert_exit "--help exits 0" 0 bash "$ORCH_SCRIPT" --help

# Test 3: --help shows usage and examples
OUTPUT=$(bash "$ORCH_SCRIPT" --help 2>&1)
assert_contains "--help shows usage" "Usage:" "$OUTPUT"
assert_contains "--help shows examples" "Examples:" "$OUTPUT"

# Test 4: Unknown argument exits 1
assert_exit "unknown arg exits 1" 1 bash "$ORCH_SCRIPT" --bogus

# Test 5: --target without --goal exits 1
assert_exit "target without goal exits 1" 1 bash "$ORCH_SCRIPT" --target /tmp

# Test 6: --goal without --target exits 1
assert_exit "goal without target exits 1" 1 bash "$ORCH_SCRIPT" --goal "test"

# Test 7: --scanners capped at 5 (timeout 5s — will try to run claude after banner)
OUTPUT=$(timeout 5 bash "$ORCH_SCRIPT" --target /tmp --goal "test" --scanners 10 2>&1 || true)
assert_contains "scanners capped at 5" "Capping scanners at 5" "$OUTPUT"

# Test 8: --no-fix flag accepted (timeout 5s — reaches orchestrator banner)
OUTPUT=$(timeout 5 bash "$ORCH_SCRIPT" --target /tmp --goal "test" --no-fix 2>&1 || true)
assert_contains "no-fix reaches orchestrator" "Devil's Advocate Swarm" "$OUTPUT"

# Test 9: extract_json unwraps claude wrapper
EXTRACTED=$(echo '{"result": "{\"key\": \"value\"}"}' | python3 -c "
import json, re, sys
text = sys.stdin.read()
try:
    wrapper = json.loads(text)
    if 'result' in wrapper:
        text = wrapper['result']
except (json.JSONDecodeError, TypeError):
    pass
text = re.sub(r'\x60{3}json\s*', '', text)
text = re.sub(r'\x60{3}\s*', '', text)
match = re.search(r'\{.*\}', text, re.DOTALL)
if match:
    try:
        obj = json.loads(match.group())
        print(json.dumps(obj, indent=2))
        sys.exit(0)
    except json.JSONDecodeError:
        pass
sys.exit(1)
" 2>/dev/null || echo "FAILED")

TOTAL=$((TOTAL + 1))
if echo "$EXTRACTED" | grep -qF '"key"'; then
    echo "[PASS] extract_json unwraps claude wrapper"
    PASS=$((PASS + 1))
else
    echo "[FAIL] extract_json failed to unwrap"
    FAIL=$((FAIL + 1))
fi

# Test 10: extract_json handles markdown fences
EXTRACTED=$(printf '```json\n{"findings": []}\n```' | python3 -c "
import json, re, sys
text = sys.stdin.read()
try:
    wrapper = json.loads(text)
    if 'result' in wrapper:
        text = wrapper['result']
except (json.JSONDecodeError, TypeError):
    pass
text = re.sub(r'\x60{3}json\s*', '', text)
text = re.sub(r'\x60{3}\s*', '', text)
match = re.search(r'\{.*\}', text, re.DOTALL)
if match:
    try:
        obj = json.loads(match.group())
        print(json.dumps(obj, indent=2))
        sys.exit(0)
    except json.JSONDecodeError:
        pass
sys.exit(1)
" 2>/dev/null || echo "FAILED")

TOTAL=$((TOTAL + 1))
if echo "$EXTRACTED" | grep -qF '"findings"'; then
    echo "[PASS] extract_json strips markdown fences"
    PASS=$((PASS + 1))
else
    echo "[FAIL] extract_json failed with markdown fences"
    FAIL=$((FAIL + 1))
fi

# --- Summary ---
echo ""
echo "=== Results: $PASS/$TOTAL passed, $FAIL failed ==="
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
