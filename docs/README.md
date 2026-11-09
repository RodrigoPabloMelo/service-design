# Docs do serviço — índice

> **Status:** ciclo 1 concluído (pesquisa + personas + jornada + ecossistema). Blueprint feito (PDF 2026-11-04, ainda fora do repo) e protótipo da etapa 05 em [`prototype/app/`](../prototype/app/README.md) — ver [prototipo.md](prototipo.md).
> **Atualizado:** 2026-11-09 · **Nome do serviço:** ainda sem nome (ver [Q-01](questoes-em-aberto.md#q-01)) — nos docs usamos "o app" / "o serviço"; o protótipo usa **Maré** como nome de trabalho.

## Resumo em 30 segundos

App que ajuda **mulheres viajantes (sozinhas ou com mais 1 pessoa)** a **descobrir passeios e lugares não-turísticos de forma confiável e unificada**, através de **recomendações de pessoas locais curadas pelo grupo** e **recursos de segurança antes, durante e depois do rolê**. Piloto em **Recife/Olinda**. Receita via **planos/pacotes com benefícios** + **comissão dos prestadores**.

## Contexto para IA

[`../UX.md`](../UX.md) destila estes docs em restrições de geração: modelo da usuária, contexto de uso, achados `F-xx`, padrões de interação, linguagem e o que não inventar. A IA deve lê-lo antes de gerar telas, textos ou protótipos. Os arquivos abaixo continuam sendo a fonte de verdade.

## Arquivos

| Arquivo | Conteúdo | Quando ler |
| --- | --- | --- |
| [visao-do-servico.md](visao-do-servico.md) | Proposta de valor, problema, público, escopo, ODS, dados de contexto, modelo de receita | Sempre primeiro |
| [conceito-do-servico.md](conceito-do-servico.md) | Como o serviço funciona: recomendação, curadoria, segurança, IA, pagamento, planos, avaliações | Ao idear/especificar funcionalidades |
| [personas.md](personas.md) | Júlia, Marina, Camila — dores e amores | Ao avaliar qualquer decisão de UX |
| [jornada.md](jornada.md) | Mapa da jornada em 8 etapas (ações, canais, emoções, dores) | Ao trabalhar momentos antes/durante/depois |
| [ecossistema.md](ecossistema.md) | Mapa do ecossistema: 7 atores e fluxos de informação, dinheiro e material | Ao trabalhar blueprint, parceiros, modelo de negócio |
| [pesquisa.md](pesquisa.md) | Métodos, roteiro de entrevista, padrões/necessidades/oportunidades, concorrentes | Ao justificar decisões com evidência |
| [decisoes.md](decisoes.md) | Log de decisões já tomadas (com origem) | Antes de propor algo que pode contradizer o que foi decidido |
| [questoes-em-aberto.md](questoes-em-aberto.md) | Tudo que ainda não está definido, com ID, prioridade e status | Para acompanhar e atualizar o que falta |
| [glossario.md](glossario.md) | Termos do projeto (rolê, local, curadoria, selo…) | Quando um termo for ambíguo |
| [prototipo.md](prototipo.md) | O que o protótipo (`prototype/app`) cobre: telas ↔ etapas `E-xx`, personas, decisões e questões | Ao mexer no protótipo ou avaliar o que já foi materializado |

## Fontes originais

- Apresentação do ciclo 1: `[rod-eulalia-clara] Primeiro ciclo de design de um serviço.pdf` (DD032, 2026.2 — fora do repo)
- Esboço do mapa do ecossistema: [assets/2026-10-ecossistema-esboco.webp](../assets/2026-10-ecossistema-esboco.webp)
- Mapa da jornada: [assets/2026-10-mapa-jornada.webp](../assets/2026-10-mapa-jornada.webp)
- Diagramas digitais exportados (versionados): [imagens/](imagens/README.md)

## IDs usados para referência cruzada

- Personas: `P-JULIA`, `P-MARINA`, `P-CAMILA`
- Etapas da jornada: `E-01` … `E-08`
- Atores do ecossistema: `A-1` … `A-7` (mesma numeração do esboço)
- Decisões: `D-xx` · Questões em aberto: `Q-xx`

## Como manter (para pessoas e para o Claude)

1. Uma informação mora em **um** arquivo; os outros apontam para ele pelo ID.
2. Ao fechar uma questão: mude o status em `questoes-em-aberto.md` para `resolvida`, registre a decisão em `decisoes.md` (com data e origem) e atualize o arquivo temático.
3. Hipóteses não validadas vêm marcadas como **(hipótese)**. Não tratar como fato.
4. Atualize a linha **Atualizado** no topo do arquivo editado.
