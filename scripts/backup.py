#!/usr/bin/env python3
"""Back up existing managed targets before applying changes."""
import datetime
import os
from pathlib import Path
import shutil
import subprocess
home = Path.home()
root = Path(os.environ.get("XDG_STATE_HOME", home / ".local/state")) / "thinkpadSync/backups"
root.mkdir(parents=True, exist_ok=True, mode=0o700)
backup = root / datetime.datetime.now().strftime("%Y%m%d-%H%M%S-%f")
backup.mkdir(mode=0o700)
paths = subprocess.check_output([
    "chezmoi", "managed", "--include=files,symlinks", "--nul-path-separator"
], text=True).rstrip("\0").split("\0")
for relative in filter(None, paths):
    source = home / relative
    if source.is_file() or source.is_symlink():
        target = backup / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target, follow_symlinks=False)
print(f"Záloha: {backup}")
