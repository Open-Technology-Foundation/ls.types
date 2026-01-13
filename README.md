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
```

## Usage

```bash
lsb                     # Bash files in current dir
lsb /ai/scripts         # Bash files in specified dir
lsb -d 2 .              # Depth 2 (recursive)
lsb -rl /ai/scripts     # Realpath + ls listing

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
| `-S, --symlinks [ACTION] [DIR]` | List or create symlinks (list\|create) |
| `-V, --version` | Show version |
| `-h, --help` | Show help |

## Configuration

Config file (`types.conf`) format:

```
symlink:filetype:shebang_pattern:extensions
lsb:Bash:bash:sh,bash
lsp:Python:python:py,python
```

**Add a new language:**

1. Edit config: `lsb -E`
2. Add entry: `lsjs:JavaScript:node:js,mjs,cjs`
3. Create symlink: `lsb -S create`
4. Use: `lsjs .`

## Requirements

- Bash 5.2+
- GNU coreutils (find, realpath, file)

## License

MIT

#fin
