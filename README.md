# ls.types

List script files by language type using shebang detection or file extension.

A single script that serves as multiple commands via symlink dispatch. Call it as `lsb` for Bash files, `lsp` for Python, `lsphp` for PHP, etc.

## Installation

```bash
# Clone or copy to your preferred location
cd /path/to/ls.types

# Create symlinks
./ls.types -S create

# Add to PATH (optional)
ln -s /path/to/ls.types/lsb ~/.local/bin/
ln -s /path/to/ls.types/lsp ~/.local/bin/
```

## Usage

```bash
lsb                     # Bash files in current dir
lsb /ai/scripts         # Bash files in specified dir
lsb -d 2 .              # Depth 2 (recursive)
lsb -r .                # Output absolute paths
lsb -l .                # Output as ls -lhA listing
lsb -rl /ai/scripts     # Combine options

lsp .                   # Python files
lsphp /var/www          # PHP files
```

## Options

| Option | Description |
|--------|-------------|
| `-d, --maxdepth N` | Max find depth (default: 1) |
| `-r, --realpath` | Output absolute paths |
| `-l, --ls` | Output as `ls -lhA` listing |
| `-E, --edit` | Edit config file |
| `-S, --symlinks [ACTION] [DIR]` | List or create symlinks |
| `-V, --version` | Show version |
| `-h, --help` | Show help |

## Symlink Management

```bash
# List defined symlinks and their status
lsb -S

# Create missing symlinks in script directory
lsb -S create

# Create symlinks in custom directory
lsb -S create /usr/local/bin
```

## Configuration

Edit `types.conf` to add or modify language types:

```bash
lsb -E    # Interactive config editor
```

Config format (colon-delimited):

```
symlink:filetype:shebang_pattern:extensions
```

Example entries:

```
lsb:Bash:bash:sh,bash
lsp:Python:python:py,python
lsphp:PHP:php:php
```

After editing, create symlinks for new entries:

```bash
lsb -S create
```

## Adding a New Language

1. Edit config: `lsb -E`
2. Add entry: `lsjs:JavaScript:node:js,mjs,cjs`
3. Create symlink: `lsb -S create`
4. Use: `lsjs .`

## How It Works

The script uses symlink dispatch: it reads `$0` to determine which symlink invoked it, then looks up that name in `types.conf` to get the filetype, shebang pattern, and extensions.

Files are matched by:
1. Shebang line (`#!/usr/bin/env bash`, `#!/usr/bin/python3`, etc.)
2. File extension (`.sh`, `.py`, `.php`, etc.)

Binary files are automatically excluded.

## Requirements

- Bash 5.0+
- GNU coreutils (find, realpath, file)

## License

MIT

#fin
