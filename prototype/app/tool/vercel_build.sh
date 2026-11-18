#!/usr/bin/env bash
# Build do protótipo (Flutter web) na Vercel — chamado pelo vercel.json da
# raiz do repositório. A imagem de build da Vercel não tem Flutter: baixa o
# SDK na versão do .fvmrc (a mesma usada localmente), roda analyze e testes
# (build quebrado não sobe — CLAUDE.md, regra 1) e gera build/web.
#
# Local: FLUTTER_HOME=~/fvm/versions/<versão> bash tool/vercel_build.sh
set -euo pipefail

cd "$(dirname "$0")/.."

VERSION=$(node -p "JSON.parse(require('fs').readFileSync('.fvmrc', 'utf8')).flutter")
SDK="${FLUTTER_HOME:-$HOME/flutter-$VERSION}"

if [ ! -x "$SDK/bin/flutter" ]; then
  echo "Baixando Flutter $VERSION..."
  git clone --depth 1 --branch "$VERSION" https://github.com/flutter/flutter.git "$SDK"
fi

FLUTTER="$SDK/bin/flutter"
"$FLUTTER" --version
"$FLUTTER" config --no-analytics >/dev/null
"$FLUTTER" pub get
"$FLUTTER" analyze
"$FLUTTER" test
# Na Vercel o app mora na raiz do domínio: base href padrão (/).
"$FLUTTER" build web --release -t lib/main_design.dart
