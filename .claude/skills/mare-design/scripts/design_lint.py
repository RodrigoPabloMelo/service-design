#!/usr/bin/env python3
"""Lint estático das regras visuais da Maré (arquivos Dart de UI).

Uso:
  design_lint.py <arquivo.dart|pasta> [...]      # imprime achados, sai 1 se houver erro
  design_lint.py --hook                          # lê o JSON do hook PostToolUse no stdin

Ignorar uma linha de propósito: comentário `// design-lint: ignore D07`
na própria linha ou na linha anterior (vários ids separados por vírgula).

Cada regra nasceu de um feedback do designer — ver ../tokens.md e
../patterns.md. Regra nova: adicione aqui E no SKILL.md.
"""
from __future__ import annotations

import json
import os
import re
import sys
from pathlib import Path

# Pastas cobertas (relativas à raiz do projeto).
SCOPES = ("prototype/app/lib/features/travel_agent/",)

# Arquivos que DEFINEM os tokens podem usar o que os outros não podem.
TOKEN_FILE = "travel_tokens.dart"
ICON_FILE = "travel_ui.dart"

STRING = re.compile(r"""(['"])(?:(?!\1).)*\1""")

RULES = [
    # id, severidade, regex, mensagem, arquivos isentos
    ("D01", "erro", re.compile(r"\bBoxShadow\(|\belevation:\s*(?!0(\.0)?\b)\d"),
     "Sem sombras: separe por camada sólida (s0/s1/s2) e espaço.", ()),
    ("D02", "erro", re.compile(r"FontWeight\.w(600|800|900)\b"),
     "Sem semibold/black: regular 400, médio 500, bold 700 só em títulos.", ()),
    ("D03", "erro", re.compile(r"(?<![\w.])(Icons|CupertinoIcons)\.\w+"),
     "Ícones só do Font Awesome via TravelIcons.", ()),
    ("D04", "erro", re.compile(r"\bFontAwesomeIcons\.\w+"),
     "Use TravelIcons (constantes próprias): FontAwesomeIcons direto some no "
     "tree-shaking do build web e vira quadrado.", ()),
    ("D05", "erro", None,
     "Sem '·' ou '→' como separador em texto: quebre em linhas/elementos ou corte o texto.", ()),
    ("D06", "erro", re.compile(r"\b(InkWell|Card|ElevatedButton|FloatingActionButton|Chip|ListTile)\("),
     "Visual Material proibido (ripple, card elevado, FAB): use Pressable, SolidBlock, PrimaryButton/SecondaryButton.", ()),
    ("D08", "erro", re.compile(r"copyWith\([^)]*\bfontWeight:"),
     "Fonte variável: copyWith(fontWeight:) não muda o peso desenhado; use .weight(FontWeight.wXXX).", (TOKEN_FILE,)),
    ("D10", "erro", re.compile(r"foregroundColor:[^,\n]*accentText"),
     "Botão secundário com texto neutro (p.ink), nunca azul.", ()),
    ("D07", "aviso", re.compile(r"\bColor\(0x(?![0-9A-Fa-f]{2}(000000|FFFFFF|ffffff)\))[0-9A-Fa-f]{8}\)|\bColors\.(?!black|white|transparent)\w+"),
     "Cor fora dos tokens: use TravelPalette (preto/branco com alfa são ok).", (TOKEN_FILE,)),
    ("D09", "aviso", re.compile(r"FontWeight\.(w700|bold)\b"),
     "Bold fora dos tokens: só títulos (TravelType.title1/title2).", (TOKEN_FILE,)),
]

IGNORE = re.compile(r"design-lint:\s*ignore\s+([\w, ]+)")

# D11 (multilinha): Semantics(button: true, excludeSemantics: true) sem
# onTap descarta a ação de toque do filho — o leitor de tela anuncia um
# botão que não faz nada (e no web pode nem ativar).
D11 = ("D11", "erro",
       "Semantics de botão com excludeSemantics precisa de onTap: (o mesmo "
       "handler do Pressable/GestureDetector filho).")


def semantics_without_tap(text: str) -> list[int]:
    """Linhas de `Semantics(` com button + excludeSemantics e sem onTap
    nos argumentos antes de `child:`."""
    hits = []
    for m in re.finditer(r"\bSemantics\(", text):
        i = j = m.end()
        depth = 1
        while j < len(text) and depth > 0:
            c = text[j]
            if c in "([{":
                depth += 1
            elif c in ")]}":
                depth -= 1
            if depth == 1 and text.startswith("child:", j):
                break
            j += 1
        args = text[i:j]
        if ("button: true" in args and "excludeSemantics: true" in args
                # Argumento `onTap:` de verdade — não vale `onTap != null`
                # dentro de `enabled:`.
                and not re.search(r"\bonTap\s*:", args)):
            hits.append(text.count("\n", 0, m.start()) + 1)
    return hits


def in_scope(path: Path, root: Path) -> bool:
    try:
        rel = path.resolve().relative_to(root.resolve()).as_posix()
    except ValueError:
        return False
    return rel.endswith(".dart") and rel.startswith(SCOPES)


def lint_file(path: Path) -> list[tuple[str, str, int, str, str]]:
    found = []
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    for n in semantics_without_tap(text):
        prev = lines[n - 2] if n > 1 else ""
        m = IGNORE.search(lines[n - 1]) or IGNORE.search(prev)
        if m and D11[0] in {x.strip() for x in m.group(1).split(",")}:
            continue
        found.append((D11[1], D11[0], n, D11[2], lines[n - 1].strip()[:100]))
    for n, line in enumerate(lines, 1):
        code = line.split("//", 1)[0] if "'" not in line and '"' not in line else line
        if line.lstrip().startswith(("//", "///", "*")):
            continue
        ignored = set()
        for src in (line, lines[n - 2] if n > 1 else ""):
            m = IGNORE.search(src)
            if m:
                ignored |= {x.strip() for x in m.group(1).split(",")}
        for rid, sev, rx, msg, exempt in RULES:
            if rid in ignored or path.name in exempt:
                continue
            if rid == "D05":
                hit = any(("·" in s.group(0) or "→" in s.group(0))
                          for s in STRING.finditer(code))
            else:
                hit = rx.search(code) is not None
            if hit:
                found.append((sev, rid, n, msg, line.strip()[:100]))
    return found


def report(path: Path, root: Path, items) -> str:
    try:
        rel = path.resolve().relative_to(root.resolve()).as_posix()
    except ValueError:
        rel = str(path)
    return "\n".join(f"  {rel}:{n} [{rid} {sev}] {msg}\n      {src}"
                     for sev, rid, n, msg, src in items)


def project_root() -> Path:
    env = os.environ.get("CLAUDE_PROJECT_DIR")
    if env:
        return Path(env)
    return Path(__file__).resolve().parents[4]


def main() -> int:
    root = project_root()
    if sys.argv[1:] == ["--hook"]:
        data = json.load(sys.stdin)
        fp = (data.get("tool_input") or {}).get("file_path")
        if not fp:
            return 0
        path = Path(fp)
        if not path.is_absolute():
            path = Path(data.get("cwd") or root) / path
        if not path.exists() or not in_scope(path, root):
            return 0
        items = lint_file(path)
        if not items:
            return 0
        print("Regras visuais da Maré (skill mare-design) violadas neste arquivo; "
              "corrija ou justifique com `// design-lint: ignore Dxx`:\n"
              + report(path, root, items), file=sys.stderr)
        return 2  # PostToolUse: stderr vai para o Claude

    targets = [Path(a) for a in sys.argv[1:]] or [root / SCOPES[0]]
    files = []
    for t in targets:
        files += sorted(t.rglob("*.dart")) if t.is_dir() else [t]
    errors = warns = 0
    for f in files:
        items = lint_file(f)
        if items:
            print(report(f, root, items))
            errors += sum(1 for i in items if i[0] == "erro")
            warns += sum(1 for i in items if i[0] == "aviso")
    print(f"design_lint: {len(files)} arquivos, {errors} erros, {warns} avisos.")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
