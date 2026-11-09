#!/usr/bin/env bash
# PostToolUse (Bash): depois de um `flutter build web`, confere se o
# tree-shaker manteve todos os ícones de TravelIcons. Falha = stderr pro Claude.
set -uo pipefail
cmd=$(/usr/bin/python3 -I -c 'import json,sys; print((json.load(sys.stdin).get("tool_input") or {}).get("command",""))')
[[ "$cmd" == *"build web"* ]] || exit 0
out=$("${CLAUDE_PROJECT_DIR:-.}/prototype/app/tool/check_icons.sh" 2>&1)
status=$?
[[ $status -eq 0 ]] && exit 0
echo "Build web gerado com ícones faltando (vão aparecer como quadrados): $out" >&2
echo "Ícone novo precisa ser constante própria em TravelIcons (ver skill mare-design)." >&2
exit 2
