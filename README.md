# Service Design

Repositório central de documentação de service design do projeto: fluxos, diagramas, pesquisa e protótipos.

## Estrutura

| Pasta | Conteúdo |
| --- | --- |
| [`docs/`](docs/) | Documentação: visão do serviço, decisões, specs, glossário — **fonte de verdade** |
| [`diagrams/`](diagrams/) | Blueprints, jornadas, fluxos, arquitetura (Mermaid, SVG, exports do Figma/Miro) |
| [`research/`](research/) | Pesquisa com usuários: roteiros, notas, sínteses |
| [`prototype/app/`](prototype/app/README.md) | Protótipo navegável em Flutter web (app da Coral; Maré é a assistente de IA). O que cobre: [`docs/prototipo.md`](docs/prototipo.md) |
| [`pitch/`](pitch/DIRECAO.md) | Pitch da Coral em HTML/CSS/JS, publicado em `/pitch` no mesmo deploy do protótipo |
| [`assets/`](assets/) | Imagens, screenshots e arquivos de apoio |

## Convenções

- Diagramas de preferência em **Mermaid** (`.md` / `.mmd`) para versionar como texto; exports visuais (`.png`, `.svg`) ao lado do arquivo fonte.
- Nomes de arquivo em `kebab-case`, com prefixo de data quando fizer sentido: `2026-10-15-jornada-onboarding.md`.
- Links para fontes externas (Figma, Miro, Notion) ficam no topo de cada documento.
