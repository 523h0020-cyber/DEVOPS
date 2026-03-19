# Scripts (`scripts/`)

This directory contains automation and utility scripts used throughout the project.

## Available Scripts

| Script | Description |
|--------|-------------|
| `setup.sh` | Bootstrap local development environment |
| `deploy.sh` | Deploy application to the target environment |
| `cleanup.sh` | Remove temporary files and containers |

## Usage

```bash
# Make a script executable
chmod +x scripts/setup.sh

# Run it
./scripts/setup.sh
```

## Guidelines

- All scripts must include a usage/help section (`--help` flag).
- Use `set -euo pipefail` at the top of every Bash script.
- Document any external dependencies at the top of each script.
