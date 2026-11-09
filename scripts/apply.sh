#!/usr/bin/env bash
set -euo pipefail
repo=$(chezmoi source-path)
python3 "$repo/scripts/backup.py"
chezmoi diff
chezmoi apply --interactive
