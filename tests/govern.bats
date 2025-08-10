#!/usr/bin/env bats

setup() {
  REPO_ROOT="$BATS_TEST_DIRNAME/.."
  TMP_HOME="$(mktemp -d)"
  mkdir -p "$TMP_HOME/local"
  export HOME="$TMP_HOME"
}

teardown() {
  bash "$REPO_ROOT/govern.sh" stop >/dev/null 2>&1 || true
  rm -rf "$TMP_HOME"
}

@test "start stop and status works with mock process" {
  mark="mock_$BATS_TEST_NAME"
  cat > "$HOME/local/test.conf.sh" <<EOF2
MARK="$mark"
CMD="$BATS_TEST_DIRNAME/mock_process.sh"
ARGS="$mark"
EOF2

  run bash "$REPO_ROOT/govern.sh" start
  [ "$status" -eq 0 ]
  [[ "$output" =~ test.conf.sh\ started\ at\ pid\ [0-9]+ ]]

  run bash "$REPO_ROOT/govern.sh" status
  [ "$status" -eq 0 ]
  [[ "$output" =~ test.conf.sh\ running\ at\ pid\ [0-9]+ ]]

  run bash "$REPO_ROOT/govern.sh" stop
  [ "$status" -eq 0 ]
  [[ "$output" =~ test.conf.sh\ stopped\ \(pid\ [0-9]+\) ]]

  sleep 0.1
  run bash "$REPO_ROOT/govern.sh" status
  [ "$status" -eq 0 ]
  [[ "$output" =~ test.conf.sh\ stopped ]]
}

@test "arguments with spaces are handled" {
  logfile="$TMP_HOME/arg.log"
  mark="space_$BATS_TEST_NAME"
  cat > "$HOME/local/test.conf.sh" <<EOF2
MARK="$mark"
CMD="$BATS_TEST_DIRNAME/space_arg_process.sh"
ARGS="$mark $logfile 'hello world'"
EOF2

  run bash "$REPO_ROOT/govern.sh" start
  [ "$status" -eq 0 ]
  sleep 0.2
  [ -f "$logfile" ]
  content=$(cat "$logfile")
  [ "$content" = "hello world" ]

  run bash "$REPO_ROOT/govern.sh" stop
  [ "$status" -eq 0 ]
}

