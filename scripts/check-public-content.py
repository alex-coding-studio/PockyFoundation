#!/usr/bin/env python3
from pathlib import Path
import re
import subprocess
import sys

ALLOWED_DIRECTIVE = re.compile(r"^//\s*(swift-tools-version:|swiftlint:|swiftformat:|sourcery:)")
STRING_START = re.compile(r'(#+)?("""|")')


def scan_block_comment(text, index, comments):
    comments.append((text.count("\n", 0, index) + 1, "/*"))
    depth = 1
    index += 2
    while index < len(text) and depth:
        if text.startswith("/*", index):
            depth += 1
            index += 2
        elif text.startswith("*/", index):
            depth -= 1
            index += 2
        else:
            index += 1
    return index


def scan_interpolation(text, index, comments):
    depth = 1
    while index < len(text) and depth:
        if text.startswith("//", index):
            end = text.find("\n", index)
            if end < 0:
                end = len(text)
            comments.append((text.count("\n", 0, index) + 1, text[index:end].strip()))
            index = end
        elif text.startswith("/*", index):
            index = scan_block_comment(text, index, comments)
        elif STRING_START.match(text, index):
            index = scan_string(text, index, comments)
        else:
            ch = text[index]
            if ch == "(":
                depth += 1
            elif ch == ")":
                depth -= 1
            index += 1
    return index


def scan_string(text, index, comments):
    match = STRING_START.match(text, index)
    hashes = match.group(1) or ""
    quote = match.group(2)
    index += len(match.group())
    end = quote + hashes
    escape = "\\" + hashes
    interp = escape + "("
    while index < len(text):
        if text.startswith(interp, index):
            index = scan_interpolation(text, index + len(interp), comments)
        elif text.startswith(escape, index):
            index += len(escape) + 1
        elif text.startswith(end, index):
            index += len(end)
            break
        else:
            index += 1
    return index


def disallowed_comments(text):
    comments = []
    index = 0
    while index < len(text):
        if text.startswith("//", index):
            end = text.find("\n", index)
            if end < 0:
                end = len(text)
            comments.append((text.count("\n", 0, index) + 1, text[index:end].strip()))
            index = end
        elif text.startswith("/*", index):
            index = scan_block_comment(text, index, comments)
        elif STRING_START.match(text, index):
            index = scan_string(text, index, comments)
        else:
            index += 1
    return [(line, token) for line, token in comments if not ALLOWED_DIRECTIVE.match(token)]


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
assert not disallowed_comments('let url = "https://example.com"\n')
assert not disallowed_comments("// swift-tools-version: 6.2\n")
assert disallowed_comments("/// doc\n") == [(1, "/// doc")]
assert disallowed_comments("let value = 1 // impl\n") == [(1, "// impl")]
assert disallowed_comments("/* block */\n") == [(1, "/*")]

failures = []
for name in filter(None, paths):
    path = root / name
    if path.is_symlink():
        failures.append(f"{name}: symbolic links are not portable")
        continue
    if not path.is_file():
        continue
    try:
        text = path.read_text()
    except UnicodeDecodeError:
        continue
    for pattern in patterns:
        if re.search(pattern, text):
            failures.append(f"{name}: contains private or nonportable content")
            break
    if name.endswith(".swift"):
        for number, token in disallowed_comments(text):
            failures.append(f"{name}:{number}: source comments are not allowed ({token})")
if failures:
    print("\n".join(failures), file=sys.stderr)
    sys.exit(1)
print("Public content and portability checks passed.")
