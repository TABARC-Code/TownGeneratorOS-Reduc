#!/usr/bin/env python3
"""Check Haxe source structure before building."""
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent
PAIRS = {'{': '}', '(': ')', '[': ']'}
CLOSING = {v: k for k, v in PAIRS.items()}


def scan(path):
    source = path.read_text(encoding='utf-8')
    stack = []
    directives = []
    i = 0
    line = 1
    errors = []
    mode = 'code'
    while i < len(source):
        char = source[i]
        ahead = source[i:i + 2]
        if char == '\n':
            line += 1
        if mode == 'line_comment':
            if char == '\n':
                mode = 'code'
        elif mode == 'block_comment':
            if ahead == '*/':
                mode = 'code'
                i += 1
        elif mode in ('"', "'"):
            if char == '\\':
                i += 1
            elif char == mode:
                mode = 'code'
        elif ahead == '//':
            mode = 'line_comment'
            i += 1
        elif ahead == '/*':
            mode = 'block_comment'
            i += 1
        elif char in ('"', "'"):
            mode = char
        elif char in PAIRS:
            stack.append((char, line))
        elif char in CLOSING:
            if not stack or stack[-1][0] != CLOSING[char]:
                errors.append(f'{path}:{line}: unexpected {char}')
            else:
                stack.pop()
        i += 1
    for opener, number in stack:
        errors.append(f'{path}:{number}: unmatched {opener}')
    if mode in ('"', "'", 'block_comment'):
        errors.append(f'{path}:{line}: unterminated string or comment')
    for number, text in enumerate(source.splitlines(), 1):
        token = text.strip().split(' ', 1)[0]
        if token == '#if':
            directives.append(number)
        elif token == '#end':
            if directives:
                directives.pop()
            else:
                errors.append(f'{path}:{number}: #end without #if')
    for number in directives:
        errors.append(f'{path}:{number}: #if without #end')
    return errors


def main():
    paths = sorted((ROOT / 'Source').rglob('*.hx')) + sorted((ROOT / 'tests').rglob('*.hx'))
    errors = []
    for path in paths:
        errors.extend(scan(path))
    required = [ROOT / 'LICENSE', ROOT / 'README.md', ROOT / 'project.xml']
    errors.extend(f'Missing {path}' for path in required if not path.exists())
    if errors:
        print('\n'.join(errors))
        return 1
    print(f'Source structure OK: {len(paths)} Haxe files')
    return 0


if __name__ == '__main__':
    sys.exit(main())
