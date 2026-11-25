# CLAUDE.md

Repositório de service design de um app para **mulheres viajantes descobrirem rolês locais com confiança e segurança** (piloto Recife/Olinda). Projeto da disciplina DD032, 2026.2 — Rodrigo, Eulália e Maria Clara.

O repo tem duas partes: a **documentação do serviço** (`docs/`, `UX.md`, `diagrams/`, `research/`) — fonte de verdade — e o **protótipo navegável** em Flutter (`prototype/app/`), que materializa partes do serviço. O serviço se chama **Coral** ([D-32](docs/decisoes.md)); **Maré** é a assistente de IA do app (o agente de roteiros) e dá nome ao sistema visual de trabalho (`mare-design`). Junto mora o **pitch** da Coral (`pitch/`).

## Gerando qualquer coisa (telas, fluxos, textos, protótipos, slides, código de UI)

Leia [UX.md](UX.md) antes e siga as restrições, a seção "Não faça" e a "Checagem da saída". Quando a IA errar de forma recorrente, registre no log da seção 10 do UX.md e ajuste a regra.

## Contexto do serviço

Comece por [docs/README.md](docs/README.md): resumo, índice e IDs de referência. Leia o arquivo temático conforme a tarefa:

- O que é / modelo de receita → `docs/visao-do-servico.md`
- Como funciona (curadoria, segurança, IA, pagamento) → `docs/conceito-do-servico.md`
- Personas `P-*` → `docs/personas.md` · Jornada `E-01..E-08` → `docs/jornada.md` · Atores `A-1..A-7` → `docs/ecossistema.md`
- Evidências da pesquisa → `docs/pesquisa.md`
- Já decidido `D-xx` → `docs/decisoes.md` · Em aberto `Q-xx` → `docs/questoes-em-aberto.md`
- O que o protótipo cobre (telas ↔ etapas, personas, decisões) → `docs/prototipo.md`
- Fluxos, subfluxos e estados das telas (`FL-xx`, `ST-*`) → `docs/fluxos/` — mudou um caminho ou estado no protótipo, atualize ali

## Regras ao trabalhar aqui

- Escreva em português (pt-BR).
- Antes de propor algo, confira `decisoes.md` (não contradizer sem dizer) e `questoes-em-aberto.md` (não tratar questão aberta como resolvida).
- Quando uma questão for respondida: status → `resolvida` em `questoes-em-aberto.md`, nova linha em `decisoes.md` (data + origem), atualizar o doc temático.
- Ao surgir uma nova dúvida sem resposta, registre como novo `Q-xx` em vez de presumir.
- Marque inferências próprias como **(hipótese)**.
- Convenções de pastas e nomes: ver [README.md](README.md).

## Protótipo (app Flutter em `prototype/app/`)

Flutter web, roda com dados mockados (sem backend). A tela principal é o agente de roteiros `/agente` (`lib/features/travel_agent/`). Entry do protótipo: `lib/main_design.dart`.

### Ponte docs ↔ protótipo

- UI e copy seguem **[UX.md](UX.md)** (o que mostrar, para quem, em que momento) **e** a skill **`mare-design`** (como fica visualmente). Se as duas brigarem, pergunte.
- Decidiu algo no protótipo que muda o serviço (fluxo, regra, recurso, preço)? Registre `D-xx` em `docs/decisoes.md` ou abra `Q-xx` — e atualize a tabela de `docs/prototipo.md`.
- Tela nova ou mudança grande: atualize `docs/prototipo.md` (etapa `E-xx`, personas, decisões e questões que toca).

### Regras invioláveis

1. **O build web nunca quebra.** `flutter build web --release` verde antes de commit (`flutter analyze` no mínimo).
2. **Nada de `dart:io` em `features/**/presentation/`** nem em `main_design.dart` — quebra o web. Telas usam só `flutter/material.dart`, `go_router` e componentes de `core/components/`.
3. **Dados ficam no mock** (`data/travel_agent_mock.dart`, enum `TravelAgentScenario`), nunca hardcoded na view.
4. **Dependência nova só com aprovação explícita.** Proibidos sem discussão: `freezed`, `json_serializable`, `dartz`, `riverpod`, `injectable`, `auto_route`, `get`/GetX, `http` (use `dio`), `hive`, qualquer state management fora de `flutter_bloc`.
5. **Nenhum segredo no repo.** Chave, token ou account ID commitado é incidente.
6. Mudou `core/components/` ou `core/`? Diga no corpo do commit — outras telas dependem disso.

### Stack fixa

| Categoria | Escolha |
| --- | --- |
| Estado | `flutter_bloc` (Cubit — nunca Bloc com Events) |
| DI | `get_it` (`core/di/design_dependencies.dart`) |
| Navegação | `go_router`; telas registradas em `lib/features/feature_registry.dart` |
| Entidades | `equatable` manual — sem code gen |
| Vidro | `liquid_glass_widgets`, isolado em `core/components/glass/app_glass.dart` |
| Testes | `bloc_test` + `mocktail` |

### Comandos

Flutter 3.47.9 (`prototype/app/.fvmrc`). Use o binário do SDK direto (o wrapper `fvm` trava no sandbox):

```bash
cd prototype/app && ~/fvm/versions/3.47.9/bin/flutter analyze < /dev/null
cd prototype/app && ~/fvm/versions/3.47.9/bin/flutter test
cd prototype/app && ~/fvm/versions/3.47.9/bin/flutter build web --release -t lib/main_design.dart
```

Preview: `design-preview` em `.claude/launch.json` (porta 8080), abrir `/agente`.

### Skills, agentes e hooks

- `.claude/skills/mare-design/` — sistema visual da Maré (regras, `tokens.md`, `patterns.md`, `writing.md`, `scripts/design_lint.py`). **Leia antes de mexer em UI.**
- `.claude/skills/design-feedback/` — todo feedback visual do designer vira regra na `mare-design` (e no lint, quando detectável).
- `.claude/agents/design-reviewer.md` — revisão de UI contra o sistema.
- Hooks (`.claude/settings.json`): lint de design após Edit/Write em `prototype/app/lib/features/travel_agent/`; depois de `flutter build web`, roda `prototype/app/tool/check_icons.sh` (ícone Font Awesome cortado pelo tree-shaking).

### Commits

Conventional commits em pt-BR: `feat(agente): ...`, `fix(...)`, `docs: ...`, `chore: ...`.

## Pitch (`pitch/`)

Apresentação interativa da Coral, construída aos poucos. **Leia [pitch/DIRECAO.md](pitch/DIRECAO.md) antes de mexer**: direção de estilo e o que vale neste pitch (sem som, slides brancos no tema claro com o azul do app, só fontes do app, só põe na tela o texto que o Rodrigo mandar, créditos do Magnific só com aprovação).

- HTML + CSS + JS puro em `pitch/index.html`, fotos em `pitch/img/` e vídeos em `pitch/video/` (créditos no `CREDITS.md` de cada pasta). Fora do Flutter: as regras do protótipo não se aplicam aqui.
- Publica junto com o protótipo em `/pitch`: `vercel_build.sh` copia a pasta para `build/web/pitch` e o `vercel.json` tem os rewrites antes do catch-all.
- Preview: `pitch-preview` em `.claude/launch.json` (porta 8090), abrir `/pitch/`. Ensaio direto: `?momento=N&passo=N`.
