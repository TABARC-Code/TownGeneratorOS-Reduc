#!/usr/bin/env python3
"""Check project files and local imports before building."""
from pathlib import Path
import re
import subprocess
import sys
from xml.etree import ElementTree

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / 'Source'


def main():
    failures = []
    paths = sorted(SOURCE.rglob('*.hx'))
    for path in paths:
        text = path.read_text(encoding='utf-8')
        package = re.search(r'^package\s+([\w.]+)\s*;', text, re.M)
        expected = '.'.join(path.relative_to(SOURCE).with_suffix('').parts[:-1])
        if not package or package.group(1) != expected:
            failures.append(f'{path.relative_to(ROOT)}: package mismatch')
        for imported in re.findall(r'^import\s+(com\.watabou\.[\w.*]+)\s*;', text, re.M):
            parts = imported.split('.')
            if parts[-1] == '*':
                candidate = SOURCE.joinpath(*parts[:-1])
                ok = candidate.is_dir()
            else:
                ok = any(SOURCE.joinpath(*parts[:i]).with_suffix('.hx').is_file()
                         for i in range(len(parts), 2, -1))
            if not ok:
                failures.append(f'{path.relative_to(ROOT)}: missing {imported}')

    for xml in ROOT.glob('project.xml'):
        root = ElementTree.parse(xml).getroot()
        for asset in root.findall('assets'):
            assetdir = ROOT / asset.attrib['path']
            for item in asset.findall('image'):
                if not (assetdir / item.attrib['path']).is_file():
                    failures.append('Missing asset: ' + item.attrib['path'])

    if not (ROOT / 'LICENSE').read_text().startswith('                    GNU GENERAL PUBLIC LICENSE'):
        failures.append('GPL licence missing or changed')
    readme = (ROOT / 'README.md').read_text()
    if 'Watabou' not in readme and 'watabou' not in readme:
        failures.append('Upstream attribution missing')
    if 'TABARC-Code' not in readme:
        failures.append('Maintainer attribution missing')

    architect = (SOURCE / 'com/watabou/towngenerator/building/Architect.hx').read_text()
    if re.search(r'\bpoly\.contains\s*\(', architect):
        failures.append('Architect still uses vertex identity for spatial tests')
    if 'containsPoint' not in (SOURCE / 'com/watabou/geom/Polygon.hx').read_text():
        failures.append('Point-in-polygon test missing')

    result = subprocess.run([sys.executable, str(ROOT / 'scripts/check_source.py')],
                            capture_output=True, text=True)
    if result.returncode:
        failures.append(result.stdout + result.stderr)

    if failures:
        print('\n'.join(failures))
        return 1
    print(f'Local imports, assets, licence and source structure OK: {len(paths)} Haxe files')
    return 0


if __name__ == '__main__':
    sys.exit(main())
