# Imagens

> Exports em alta resolução (PNG 3x) dos diagramas do serviço.
> **Nome:** `AAAA-MM-DD-<assunto>-v<N>.png`, dentro da pasta da categoria. Uma nova versão vira um novo arquivo (`-v2`), e a anterior fica como histórico.

## Diagramas

| Versão | Arquivo | Fonte | Notas |
| --- | --- | --- | --- |
| v1 · 2026-10-16 | [diagramas/2026-10-16-ecossistema-servico-v1.png](diagramas/2026-10-16-ecossistema-servico-v1.png) | [diagrams/ecossistema.html](../../diagrams/ecossistema.html) | Mapa do ecossistema, 7 atores e 11 fluxos. Tema claro, 4224×2715 |
| v1 · 2026-11-04 | [diagramas/2026-11-04-blueprint-servico-v1.png](diagramas/2026-11-04-blueprint-servico-v1.png) | [diagrams/blueprint.html](../../diagrams/blueprint.html) | Blueprint do serviço implementado (to-be): 8 etapas × raias, da viajante no topo aos prestadores e parceiros na raia mais externa. Rascunho, itens com "?" estão em aberto. Gerado com a skill diagramas-servico (`render.mjs --scale 3`), 6000×5868 |

## Como gerar uma nova versão

1. Edite `diagrams/ecossistema.html` e republique o artifact.
2. Exporte em PNG com escala 3x e tema claro (headless Edge/Chrome, janela 1408×905).
3. Salve como `-v<N+1>` e adicione uma linha na tabela acima.
