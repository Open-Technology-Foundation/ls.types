#!/usr/bin/env bats
# test_ls.types.bats - Comprehensive tests for ls.types

# Get the directory where this test file lives
SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
LS_BASH="$SCRIPT_DIR/ls.bash"
LS_PYTHON="$SCRIPT_DIR/ls.python"
LS_PHP="$SCRIPT_DIR/ls.php"
LS_TYPES="$SCRIPT_DIR/ls.types"

setup() {
  # Create temporary test directory
  TEST_DIR=$(mktemp -d)
  TEST_SUBDIR="$TEST_DIR/subdir"
  TEST_DEEP="$TEST_DIR/subdir/deep"
  TEST_EMPTY="$TEST_DIR/empty"
  TEST_SPACES="$TEST_DIR/dir with spaces"

  mkdir -p "$TEST_SUBDIR" "$TEST_DEEP" "$TEST_EMPTY" "$TEST_SPACES"

  # Bash files
  cat > "$TEST_DIR/script.sh" <<'EOF'
#!/usr/bin/env bash
echo "hello"
EOF

  cat > "$TEST_DIR/script.bash" <<'EOF'
#!/bin/bash
echo "hello"
EOF

  # Bash file without shebang (extension only)
  cat > "$TEST_DIR/noshebang.sh" <<'EOF'
# No shebang, just a comment
echo "hello"
EOF

  # Bash shebang, no extension
  cat > "$TEST_DIR/noext" <<'EOF'
#!/usr/bin/env bash
echo "no extension"
EOF

  # Python file
  cat > "$TEST_DIR/script.py" <<'EOF'
#!/usr/bin/env python3
print("hello")
EOF

  # PHP file
  cat > "$TEST_DIR/script.php" <<'EOF'
#!/usr/bin/env php
<?php echo "hello"; ?>
EOF

  # Non-matching file
  cat > "$TEST_DIR/readme.txt" <<'EOF'
This is a text file
EOF

  # Binary file (with misleading .sh extension)
  printf '\x00\x01\x02\x03' > "$TEST_DIR/binary.sh"

  # Files in subdirectory (for depth testing)
  cat > "$TEST_SUBDIR/sub.sh" <<'EOF'
#!/bin/bash
echo "subdir"
EOF

  cat > "$TEST_DEEP/deep.sh" <<'EOF'
#!/bin/bash
echo "deep"
EOF

  # File in "dir with spaces"
  cat > "$TEST_SPACES/spaced.sh" <<'EOF'
#!/bin/bash
echo "spaces"
EOF
}

teardown() {
  rm -rf "$TEST_DIR"
}

# =============================================================================
# Basic Options
# =============================================================================

@test "help: -h shows usage" {
  run "$LS_BASH" -h
  [[ $status -eq 0 ]]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"Options:"* ]]
}

@test "help: --help shows usage" {
  run "$LS_BASH" --help
  [[ $status -eq 0 ]]
  [[ "$output" == *"Usage:"* ]]
}

@test "version: -V shows version" {
  run "$LS_BASH" -V
  [[ $status -eq 0 ]]
  [[ "$output" == "ls.bash 1.0.0" ]]
}

@test "version: --version shows version" {
  run "$LS_BASH" --version
  [[ $status -eq 0 ]]
  [[ "$output" == *"1.0.0"* ]]
}

@test "error: unknown option exits 22" {
  run "$LS_BASH" -X
  [[ $status -eq 22 ]]
  [[ "$output" == *"error"* ]]
  [[ "$output" == *"Unknown option"* ]]
}

@test "symlinks: -S lists symlinks" {
  run "$LS_BASH" -S
  [[ $status -eq 0 ]]
  [[ "$output" == *"Symlinks defined in"* ]]
  [[ "$output" == *"ls.bash"* ]]
}

@test "symlinks: ./ls.types -S works without symlink" {
  run "$LS_TYPES" -S
  [[ $status -eq 0 ]]
  [[ "$output" == *"Symlinks defined in"* ]]
}

@test "maxdepth: -d 2 finds files in subdirs" {
  run "$LS_BASH" -d 2 "$TEST_DIR"
  [[ $status -eq 0 ]]
  [[ "$output" == *"sub.sh"* ]]
}

# =============================================================================
# File Detection
# =============================================================================

@test "detection: finds file by bash shebang" {
  run "$LS_BASH" "$TEST_DIR"
  [[ $status -eq 0 ]]
  [[ "$output" == *"script.sh"* ]]
  [[ "$output" == *"script.bash"* ]]
}

@test "detection: finds file by extension only (no shebang)" {
  run "$LS_BASH" "$TEST_DIR"
  [[ $status -eq 0 ]]
  [[ "$output" == *"noshebang.sh"* ]]
}

@test "detection: finds file by shebang only (no extension)" {
  run "$LS_BASH" "$TEST_DIR"
  [[ $status -eq 0 ]]
  [[ "$output" == *"noext"* ]]
}

@test "detection: does not find non-matching files" {
  run "$LS_BASH" "$TEST_DIR"
  [[ $status -eq 0 ]]
  [[ "$output" != *"readme.txt"* ]]
}

@test "detection: excludes binary files" {
  run "$LS_BASH" "$TEST_DIR"
  [[ $status -eq 0 ]]
  [[ "$output" != *"binary.sh"* ]]
}

@test "detection: ls.python finds python files" {
  run "$LS_PYTHON" "$TEST_DIR"
  [[ $status -eq 0 ]]
  [[ "$output" == *"script.py"* ]]
  [[ "$output" != *"script.sh"* ]]
}

@test "detection: ls.php finds php files" {
  run "$LS_PHP" "$TEST_DIR"
  [[ $status -eq 0 ]]
  [[ "$output" == *"script.php"* ]]
  [[ "$output" != *"script.sh"* ]]
}

# =============================================================================
# Output Modes
# =============================================================================

@test "output: default shows plain filenames" {
  run "$LS_BASH" "$TEST_DIR"
  [[ $status -eq 0 ]]
  # Should contain filename but not ls -l style output
  [[ "$output" == *"script.sh"* ]]
  [[ "$output" != *"rwx"* ]]
}

@test "output: -r shows absolute paths" {
  run "$LS_BASH" -r "$TEST_DIR"
  [[ $status -eq 0 ]]
  # Output should contain absolute paths
  [[ "$output" == *"$TEST_DIR"* ]]
}

@test "output: -l shows ls format" {
  run "$LS_BASH" -l "$TEST_DIR"
  [[ $status -eq 0 ]]
  # ls -l output has permission strings
  [[ "$output" == *"rw"* ]]
}

@test "output: -rl combines realpath and ls" {
  run "$LS_BASH" -rl "$TEST_DIR"
  [[ $status -eq 0 ]]
  # Should have absolute paths in ls format
  [[ "$output" == *"$TEST_DIR"* ]]
  [[ "$output" == *"rw"* ]]
}

# =============================================================================
# Directory Handling
# =============================================================================

@test "directory: defaults to current dir" {
  cd "$TEST_DIR"
  run "$LS_BASH"
  [[ $status -eq 0 ]]
  [[ "$output" == *"script.sh"* ]]
}

@test "directory: accepts single directory" {
  run "$LS_BASH" "$TEST_DIR"
  [[ $status -eq 0 ]]
  [[ "$output" == *"script.sh"* ]]
}

@test "directory: accepts multiple directories" {
  run "$LS_BASH" "$TEST_DIR" "$TEST_SUBDIR"
  [[ $status -eq 0 ]]
  [[ "$output" == *"script.sh"* ]]
  [[ "$output" == *"sub.sh"* ]]
}

@test "directory: errors on invalid directory" {
  run "$LS_BASH" "/nonexistent/path"
  [[ $status -eq 1 ]]
  [[ "$output" == *"error"* ]]
  [[ "$output" == *"Not a directory"* ]]
}

@test "directory: empty dir produces no output" {
  run "$LS_BASH" "$TEST_EMPTY"
  [[ $status -eq 0 ]]
  [[ -z "$output" ]]
}

# =============================================================================
# Symlink Management
# =============================================================================

@test "symlinks: -S list shows status" {
  run "$LS_BASH" -S
  [[ $status -eq 0 ]]
  [[ "$output" == *"[exists]"* ]] || [[ "$output" == *"[missing]"* ]]
}

@test "symlinks: -S create makes symlinks in temp dir" {
  local symlink_dir
  symlink_dir=$(mktemp -d)
  run "$LS_BASH" -S create "$symlink_dir"
  [[ $status -eq 0 ]]
  # Check that at least one symlink was created
  [[ -L "$symlink_dir/ls.bash" ]] || [[ -L "$symlink_dir/ls.python" ]]
  rm -rf "$symlink_dir"
}

@test "symlinks: -S invalid action errors" {
  run "$LS_BASH" -S invalidaction
  [[ $status -eq 1 ]]
  [[ "$output" == *"error"* ]]
  [[ "$output" == *"Unknown action"* ]]
}

@test "symlinks: -S create invalid dir errors" {
  run "$LS_BASH" -S create "/nonexistent/path"
  [[ $status -eq 1 ]]
  [[ "$output" == *"error"* ]]
  [[ "$output" == *"Directory not found"* ]]
}

# =============================================================================
# Edge Cases
# =============================================================================

@test "edge: handles paths with spaces" {
  run "$LS_BASH" "$TEST_SPACES"
  [[ $status -eq 0 ]]
  [[ "$output" == *"spaced.sh"* ]]
}

@test "edge: no matching files produces no output" {
  # Create dir with only non-matching files
  local nomatch_dir
  nomatch_dir=$(mktemp -d)
  echo "text" > "$nomatch_dir/file.txt"
  run "$LS_BASH" "$nomatch_dir"
  [[ $status -eq 0 ]]
  [[ -z "$output" ]]
  rm -rf "$nomatch_dir"
}

@test "edge: unreadable file is skipped" {
  local unread_dir
  unread_dir=$(mktemp -d)
  cat > "$unread_dir/unreadable.sh" <<'EOF'
#!/bin/bash
echo "unreadable"
EOF
  chmod 000 "$unread_dir/unreadable.sh"
  run "$LS_BASH" "$unread_dir"
  [[ $status -eq 0 ]]
  [[ "$output" != *"unreadable.sh"* ]]
  chmod 644 "$unread_dir/unreadable.sh"
  rm -rf "$unread_dir"
}

@test "edge: -d 3 finds deeply nested files" {
  run "$LS_BASH" -d 3 "$TEST_DIR"
  [[ $status -eq 0 ]]
  [[ "$output" == *"deep.sh"* ]]
}

#fin
