#!/usr/bin/env bash

# BATS test helpers for OmniSec

setup() {
	export ROOT_DIR="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
	export PATH="$ROOT_DIR:$PATH"
}

assert_success() {
	[ "$status" -eq 0 ] || { echo "expected success, got status=$status output=$output"; return 1; }
}

assert_failure() {
	[ "$status" -ne 0 ] || { echo "expected failure, got status=$status output=$output"; return 1; }
}

assert_output_contains() {
	[[ "$output" == *"$1"* ]] || { echo "expected output to contain: $1"; echo "actual: $output"; return 1; }
}

assert_file_exists() {
	[ -f "$1" ] || { echo "expected file to exist: $1"; return 1; }
}

assert_file_executable() {
	[ -x "$1" ] || { echo "expected file to be executable: $1"; return 1; }
}

assert_syntax_ok() {
	run bash -n "$1"
	assert_success
}
