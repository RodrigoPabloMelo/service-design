#!/usr/bin/env bash
# Confere se o tree-shaker de ícones do último `flutter build web` manteve
# todos os glifos declarados em TravelIcons. Glifo cortado = quadrado na tela.
# Uso: tool/check_icons.sh   (rodar a partir de app/, depois do build web)
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION=$(grep -o '"flutter": *"[^"]*"' .fvmrc | grep -o '[0-9][0-9.]*')
FLUTTER_ROOT="${FLUTTER_ROOT:-$HOME/fvm/versions/$VERSION}"
DART="$FLUTTER_ROOT/bin/cache/dart-sdk/bin/dart"
SNAP=$(find "$FLUTTER_ROOT/bin/cache/artifacts/engine" -name const_finder.dart.snapshot | head -1)
DILL=$(ls -t .dart_tool/flutter_build/*/app.dill 2>/dev/null | head -1 || true)
ICONS=lib/features/travel_agent/presentation/widgets/travel_ui.dart

if [[ -z "$DILL" || -z "$SNAP" ]]; then
  echo "check_icons: rode 'flutter build web --release' antes." >&2
  exit 2
fi

"$DART" "$SNAP" --kernel-file "$DILL" \
  --class-library-uri package:flutter/src/widgets/icon_data.dart --class-name IconData \
  --annotation-class-library-uri package:flutter/src/widgets/icon_data.dart \
  --annotation-class-name _StaticIconProvider 2>/dev/null |
/usr/bin/python3 -I -c '
import json, re, sys
found = {int(c["codePoint"]) for c in json.load(sys.stdin)["constantInstances"]
         if "FontAwesome" in str(c.get("fontFamily"))}
src = open(sys.argv[1]).read()
declared = {int(cp, 16): name for name, cp in
            re.findall(r"static const (\w+) = FaIconData\(IconData\((0x[0-9a-f]+)", src)}
missing = {n: hex(cp) for cp, n in declared.items() if cp not in found}
if missing:
    print("check_icons: glifos cortados no build:", missing)
    sys.exit(1)
print(f"check_icons: ok, {len(declared)} ícones mantidos no build.")
' "$ICONS"
