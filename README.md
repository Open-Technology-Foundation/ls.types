# ls.types

List script files by language type using shebang detection or file extension.

A single script that serves as multiple commands via symlink dispatch. Call it as `lsb` for Bash files, `lsp` for Python, `lsphp` for PHP, etc.

## Installation

```bash
# Clone repository
git clone https://github.com/Open-Technology-Foundation/ls.types.git
cd ls.types

# System-wide install (root)
sudo make install

# User install (no root)
make install

# Uninstall
[sudo] make uninstall
```

| Context | Script | Config |
|---------|--------|--------|
| `sudo make install` | `/usr/local/bin/` | `/etc/ls.types/` |
| `make install` | `~/.local/bin/` | `~/.local/share/ls.types/` |

**Manual setup** (without make):
```bash
./ls.types -S create      # Create symlinks in script directory
```

## Usage

```bash
lsb                       # Bash files in current dir
lsb /ai/scripts           # Bash files in specified dir
lsb /dir1 /dir2           # Search multiple directories
lsb -d 2 .                # Depth 2 (recursive)
lsb -rl /ai/scripts       # Realpath + ls listing (clustered options)

lsp .                     # Python files
lsphp /var/www            # PHP files
```

## Options

| Option | Description |
|--------|-------------|
| `-d, --maxdepth N` | Max find depth (default: 1) |
| `-r, --realpath` | Output absolute paths |
| `-l, --ls` | Format as `ls -lhA --color=always` listing |
| `-E, --edit` | Interactive config editor |
| `-S, --symlinks [ACTION] [DIR]` | Manage symlinks (list\|create) |
| `-V, --version` | Show version |
| `-h, --help` | Show help |

Short options can be clustered: `-rl` is equivalent to `-r -l`.

## Configuration

Config file format (`types.conf`):

```
symlink:filetype:shebang_pattern:extensions
lsb:Bash:bash:sh,bash
lsp:Python:python:py,python
lsphp:PHP:php:php
```

**Fields:**
- `symlink` - Command name (dispatch key)
- `filetype` - Human-readable label
- `shebang_pattern` - Regex matched against `^#!.*{pattern}`
- `extensions` - Comma-separated file extensions (no dots)

### Config Search Order (FHS-compliant)

1. `/etc/ls.types/types.conf`
2. `/usr/local/share/ls.types/types.conf`
3. `/usr/share/ls.types/types.conf`
4. Script directory (development/fallback)

### Adding a New Language

```bash
lsb -E                    # Launch interactive config editor
```

Add entry:
```
lsjs:JavaScript:node:js,mjs,cjs
```

Create symlinks:
```bash
lsb -S create
```

Use:
```bash
lsjs .
```

## File Matching

Files are matched using priority-based logic:

1. **Shebang match** (primary) - First line matches `^#!.*{pattern}`
2. **Extension fallback** - Checked only if shebang doesn't match
3. **Binary exclusion** - Files detected as binary via `file --mime-encoding` are skipped
4. **Readability** - Unreadable files are silently skipped

## Output Modes

**Plain** (default):
```bash
lsb /scripts
# /scripts/deploy.sh
# /scripts/backup.sh
```

**Realpath** (`-r`):
```bash
lsb -r /scripts
# /home/user/scripts/deploy.sh
# /home/user/scripts/backup.sh
```

**Listing** (`-l`):
```bash
lsb -l /scripts
# -rwxr-xr-x 1 user group 1.2K 2026-01-13 09:15 /scripts/deploy.sh
```

**Combined** (`-rl`):
```bash
lsb -rl /scripts
# Absolute paths with ls -lhA formatting
```

## Symlink Management

**List symlinks:**
```bash
lsb -S                    # Or: lsb -S list
# Symlinks defined in /path/to/types.conf:
#   lsb          [exists]  -> /path/to/ls.types
#   lsp          [missing]
```

**Create symlinks:**
```bash
lsb -S create             # In script directory
lsb -S create /target     # In specified directory
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Config not found, invalid directory, or symlink creation failed |
| 22 | Unknown option |

## Requirements

- Bash 5.2+
- GNU coreutils (find, realpath)
- file (MIME encoding detection)

## License

GPL-3.0

#fin
