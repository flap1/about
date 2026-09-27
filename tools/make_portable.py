#!/usr/bin/env python3
"""Pack this static site into one offline HTML file. Python 3, standard library only.
Usage: python3 tools/make_portable.py [output.html]
"""
from __future__ import annotations
import base64
import mimetypes
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
PAGES = {'home': 'index.html', 'research': 'research.html', 'work': 'work.html', 'notes': 'notes.html', 'about': 'about.html', 'hobbies': 'hobbies.html'}


def read(relative: str) -> str:
    return (ROOT / relative).read_text(encoding='utf-8')


def embed(relative: str) -> str:
    path = (ROOT / relative).resolve()
    if not path.is_relative_to(ROOT):
        raise ValueError(f'Asset is outside the site directory: {relative}')
    mime = mimetypes.guess_type(str(path))[0] or 'application/octet-stream'
    return 'data:' + mime + ';base64,' + base64.b64encode(path.read_bytes()).decode('ascii')


def main() -> None:
    output = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else ROOT / 'portable.html'
    html = read('index.html')
    sections = []
    for name, filename in PAGES.items():
        match = re.search(r'<main\b[^>]*>(.*?)</main>', read(filename), flags=re.S)
        if not match:
            raise ValueError(f'Missing <main> in {filename}')
        classes = 'route is-current' if name == 'home' else 'route'
        sections.append(f'<section id="{name}" data-route="{name}" class="{classes}">{match.group(1)}</section>')
    combined_main = '<main id="content" tabindex="-1">' + ''.join(sections) + '</main>'
    html = re.sub(r'<main\b[^>]*>.*?</main>', lambda _: combined_main, html, count=1, flags=re.S)
    html = html.replace('<body data-page="home">', '<body data-page="home" data-standalone>')
    html = html.replace('href="work.html#space"', 'href="#space"')
    for name, filename in PAGES.items():
        html = html.replace(f'href="{filename}"', f'href="#{name}"')
    css = re.sub(r'''url\(['"]?(assets/[^)'\"]+)['"]?\)''', lambda m: 'url("' + embed(m.group(1)) + '")', read('style.css'))
    html = html.replace('<link rel="stylesheet" href="style.css">', '<style>\n' + css + '\n</style>')
    html = re.sub(r'''(src|href)="(assets/[^"]+)"''', lambda m: m.group(1) + '="' + embed(m.group(2)) + '"', html)
    html = html.replace('<script src="script.js" defer></script>', '<script>\n' + read('script.js') + '\n</script>')
    # Detect packaging regressions instead of silently generating a network-dependent preview.
    if 'src="assets/' in html or 'href="assets/' in html or 'src="script.js"' in html or 'href="style.css"' in html:
        raise ValueError('An external local asset remains unbundled.')
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(html, encoding='utf-8')
    print(f'Created {output} ({output.stat().st_size:,} bytes)')


if __name__ == '__main__':
    main()
