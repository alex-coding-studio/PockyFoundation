#!/usr/bin/env python3
from pathlib import Path
import re
import subprocess
import sys

root = Path(__file__).resolve().parent.parent
paths = subprocess.check_output(
    ["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z"], cwd=root
).decode().split("\0")
patterns = [
    r"semina" + r"://", r"alex-agent" + r"-infra", r"/" + r"Users/[^\s]+",
    r"/private/" + r"tmp/", r"[A-Za-z0-9._%+-]+@(?!users\.noreply\.github\.com)[A-Za-z0-9.-]+\.[A-Za-z]{2,}",
]
assert re.search(patterns[0], "semina" + "://example")
assert re.search(patterns[2], "/" + "Users/example/source")
assert re.search(patterns[-1], "person" + "@" + "example.com")
assert not re.search(patterns[-1], "bot" + "@" + "users.noreply.github.com")
failures = []
for name in filter(None, paths):
    path = root / name
    if path.is_symlink():
        failures.append(f"{name}: symbolic links are not portable")
        continue
    if not path.is_file():
        continue
    text = path.read_text()
    for pattern in patterns:
        if re.search(pattern, text):
            failures.append(f"{name}: contains private or nonportable content")
            break
    if name.startswith("Sources/") and name.endswith(".swift"):
        for number, line in enumerate(text.splitlines(), 1):
            stripped = line.lstrip()
            if stripped.startswith("//") and not stripped.startswith("///"):
                failures.append(f"{name}:{number}: only English public API documentation is allowed")
            if stripped.startswith("///") and re.search(r"[\u4e00-\u9fff]", stripped):
                failures.append(f"{name}:{number}: public API documentation must be English")
if failures:
    print("\n".join(failures), file=sys.stderr)
    sys.exit(1)
print("Public content and portability checks passed.")
