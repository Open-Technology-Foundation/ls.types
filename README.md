# ls.types

List script files by language type using shebang detection or file extension.

A single script that serves as multiple commands via symlink dispatch. Call it as `ls.bash` for Bash files, `ls.python` for Python, `ls.php` for PHP, etc.

## Installation

```bash
git clone https://github.com/Open-Technology-Foundation/ls.types.git
cd ls.types
sudo make install
```

`make install` lays down:

| Artefact | Destination |
|----------|-------------|
| `ls.types` binary + 7 dispatch symlinks | `/usr/local/bin/` |
| `types.conf` (preserved if already present) | `/etc/ls.types/` |
| Manpage `ls.types.1` + per-symlink aliases | `/usr/local/share/man/man1/` |
| Bash completion | `/etc/bash_completion.d/ls.types` |

Paths are overridable via `PREFIX`, `CONFDIR`, `MANDIR`, `COMPDIR`. `DESTDIR` is honoured for staged/packaged installs.

```bash
sudo make uninstall       # Remove installed files
make check                # Verify ls.types is in PATH
```

**Manual setup** (without make):
```bash
./ls.types -S create      # Create symlinks in script directory
```

## Usage

```bash
ls.bash                   # Bash files in current dir
ls.bash /ai/scripts       # Bash files in specified dir
ls.bash /dir1 /dir2       # Search multiple directories
ls.bash -d 2 .            # Depth 2 (recursive)
ls.bash -rl /ai/scripts   # Realpath + ls listing (clustered options)
ls.bash -L /scripts       # Include symlinked files

ls.python .               # Python files
ls.php /var/www           # PHP files
```

## Options

| Option | Description |
|--------|-------------|
| `-d, --maxdepth N` | Max find depth (default: 1) |
| `-r, --realpath` | Output absolute paths |
| `-l, --ls` | Format as `ls -lhA --color=always` listing |
| `-L, --follow` | Follow symbolic links |
| `--` | End of options |
| `-E, --edit` | Interactive config editor |
| `-S, --symlinks [ACTION] [DIR]` | Manage symlinks (list\|create) |
| `-V, --version` | Show version |
| `-h, --help` | Show help |

Short options can be clustered: `-Lrl` is equivalent to `-L -r -l`.

## Configuration

Config file format (`types.conf`):

```
symlink:filetype:shebang_pattern:extensions
ls.bash:Bash:bash:sh,bash
ls.python:Python:python:py,python
ls.php:PHP:php:php
```

**Fields:**
- `symlink` - Command name (dispatch key)
- `filetype` - Human-readable label
- `shebang_pattern` - Substring fragment inserted into regex `^#!.*{pattern}` (not a full regex — do not include anchors)
- `extensions` - Comma-separated file extensions (no dots)

### Config Search Order (FHS-compliant)

1. `/etc/ls.types/types.conf`
2. `/usr/local/share/ls.types/types.conf`
3. `/usr/share/ls.types/types.conf`
4. Script directory (development/fallback)

### Default Symlinks

The following symlinks are created by `make install` and listed in the shipped `types.conf`:

| Symlink | Type | Shebang pattern | Extensions |
|---------|------|-----------------|------------|
| `ls.bash` | Bash | `bash` | sh, bash |
| `ls.python` | Python | `python` | py, python |
| `ls.php` | PHP | `php` | php |
| `ls.js` | JavaScript | `node` | js, mjs, cjs |
| `ls.perl` | Perl | `perl` | pl, pm |
| `ls.ruby` | Ruby | `ruby` | rb |
| `ls.sh` | Shell | `/bin/sh` | sh |

### Adding a New Language

```bash
ls.bash -E                # Launch interactive config editor (honours $EDITOR, defaults to nano)
```

Add entry:
```
ls.js:JavaScript:node:js,mjs,cjs
```

After saving, the editor prompts to create symlinks for the updated config. Or run manually:
```bash
ls.bash -S create
```

Use:
```bash
ls.js .
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
ls.bash /scripts
# /scripts/deploy.sh
# /scripts/backup.sh
```

**Realpath** (`-r`):
```bash
ls.bash -r /scripts
# /home/user/scripts/deploy.sh
# /home/user/scripts/backup.sh
```

**Listing** (`-l`):
```bash
ls.bash -l /scripts
# -rwxr-xr-x 1 user group 1.2K 2026-01-13 09:15 /scripts/deploy.sh
```

**Combined** (`-rl`):
```bash
ls.bash -rl /scripts
# Absolute paths with ls -lhA formatting
```

## Symlink Management

**List symlinks:**
```bash
ls.bash -S                # Or: ls.bash -S list
# Symlinks defined in /path/to/types.conf:
#   ls.bash      [exists]  -> /path/to/ls.types
#   ls.python    [missing]
```

**Create symlinks:**
```bash
ls.bash -S create         # In script directory
ls.bash -S create /target # In specified directory
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Runtime failure (config not found, unknown symlink, invalid directory, symlink creation failed, unwritable config) |
| 22 | Invalid option or argument (unknown option, missing or non-numeric `-d` value) |

## Requirements

- Bash 5.2+
- GNU coreutils (find, realpath)
- file (MIME encoding detection)

## License

GPL-3.0

