# Protótipo — o que ele cobre

> **Atualizado:** 2026-11-09 · **Código:** [`prototype/app/`](../prototype/app/README.md) · **Tela:** `/agente` (`lib/features/travel_agent/`)
> **Status:** protótipo navegável em Flutter web, com **dados mockados** (sem backend, sem IA real). Nome de trabalho: **Maré** — o nome do serviço segue em aberto ([Q-01](questoes-em-aberto.md#q-01)).
> **Sistema visual:** skill [`mare-design`](../.claude/skills/mare-design/SKILL.md) (DESIGN.md provisório, ver [Q-26](questoes-em-aberto.md#q-26)).

## De onde vem

A tela `/agente` materializa a **etapa 04 "Organiza locais com o agente"** do [blueprint de serviço](../diagrams/blueprint.html) (viajante mulher, rolês em Recife). Na v1 do blueprint (PDF de 2026-11-04) era a etapa 05; a renumeração veio com D-23.

Na jornada atual ([jornada.md](jornada.md)), ela responde principalmente a `E-05` (montagem do roteiro: "IA erra rotas, horários e endereços") e `E-06` (ajustes na estadia: clima, cansaço, perto de onde está), e traz para dentro do app as provas que a viajante buscaria fora em `E-04` (validação e confiança).

## Como abrir

```bash
cd prototype/app && fvm flutter run -d chrome -t lib/main_design.dart
```

Abra `/agente`. Cenários do mock (`TravelAgentScenario`): `padrao` (8 rolês salvos), `vazio` (começo do zero), `erro`, `carregando`.

**No celular** (navegador), os efeitos caros entram sozinhos em **modo leve**: vidro sem refração, desfoque do topo em 3 faixas, frost sem blur e aurora a ~15 fps (regra 14 da skill `mare-design`). As barras do navegador (status e a de baixo no Safari, a barra do Chrome no Android) seguem o fundo do app. Para comparar no aparelho:

- `/agente?fps=1` mostra fps, o pior quadro e os tempos de build/raster;
- `?efeitos=completo` força o visual cheio, e `?efeitos=leve` força o leve no desktop.

## Telas e componentes ↔ docs

| Parte do protótipo | O que faz | Etapa | Personas | Decisões que aplica | Questões que toca |
| --- | --- | --- | --- | --- | --- |
| **Conversa com o agente** (abertura em tela cheia, sugestões "Organizar meus 8 rolês", "Noite com as amigas", "Perto do hotel") | A viajante pede em linguagem natural; o agente responde com rolês ou roteiro | `E-05`, `E-06` | todas; "Noite com as amigas" → `P-JULIA` | D-07 (IA usa só a base curada) | [Q-11](questoes-em-aberto.md#q-11) escopo da IA |
| **"Pensando" com passos** | Mostra o que o agente está fazendo antes de responder | `E-05` | — | — | Q-11 (hipótese: transparência do porquê da recomendação) |
| **Começo do zero** (cenário `vazio`: mapa com pontos da curadoria sem nome + saudação) | Primeira visita, nada salvo | `E-01`, `E-03` | — | D-05 (curadoria) | — |
| **Card do rolê** (quem indicou + vínculo com o lugar + citação, fotos reais, vídeos curtos, o que fazer, melhor horário, custo) | Junta num lugar só as provas de confiança | `E-04` | `P-CAMILA` (quem recomendou e por quê), `P-JULIA` (viral x bom) | D-03 (moradoras/es e criadoras de conteúdo), D-05 | [Q-08](questoes-em-aberto.md#q-08) publi, [Q-06](questoes-em-aberto.md#q-06) curadoria |
| **Entorno no card** (ex.: "Rua movimentada de dia", "Táxi na esquina", "Feche antes das 18h") + data de verificação | Contexto de segurança antes de ir | `E-04`, `E-07` | `P-CAMILA` | D-06 (contexto do entorno) | [Q-10](questoes-em-aberto.md#q-10) critérios do selo, [Q-12](questoes-em-aberto.md#q-12) "durante" |
| **Mapa** (desenho próprio de Recife, pins por rolê, hotel) | Ver rolês e roteiro no espaço | `E-05`, `E-06` | `P-MARINA` (lista pronta), todas | — | — |
| **Roteiro por dia** (manhã/tarde/noite, editar, remover parada, "Pedir ajuste") | Organiza os rolês salvos em dias | `E-05` | `P-MARINA`, `P-CAMILA` (autonomia) | D-07 | — |
| **Troca por chuva** (agente propõe trocar por rolê coberto; aceitar/recusar) | Replanejamento pelo clima | `E-06` | todas | D-07 (clima/contexto) | — |
| **Extras** ("Volta com motorista mulher", "Forró em grupo com guia") e comparação de corrida 99/Uber | Benefícios e transporte de ida/volta | `E-06`, `E-07` | `P-CAMILA` | D-01 (planos com motoristas mulheres) | [Q-02](questoes-em-aberto.md#q-02), [Q-03](questoes-em-aberto.md#q-03), [Q-05](questoes-em-aberto.md#q-05) |
| **Conectores** (Google Agenda, Google Maps, Gmail, 99, Uber) e "Conectar agenda" | Levar o roteiro para os apps que ela já usa | `E-05` | — | — | [Q-25](questoes-em-aberto.md#q-25) plataforma |
| **Seus limites** (mensagens semanais, assinatura "R$ 14,90/mês") | Modelo freemium do agente | — | — | — | [Q-02](questoes-em-aberto.md#q-02) planos — **valor e modelo são hipótese do protótipo**, não decisão |

## O que é hipótese no protótipo

- Pessoas que indicam, @handles e preços são **fictícios**; os rolês e as fotos são reais (créditos em `prototype/app/assets/images/roles/CREDITS.md`).
- Limite de mensagens: decidido que o agente grátis tem **mensagens limitadas** (D-17); o tamanho do limite e o que acontece durante a viagem seguem em [Q-35](questoes-em-aberto.md#q-35). A assinatura de R$ 14,90/mês é **(hipótese)** — D-17 coloca o pago nos serviços adicionais (transfer, rolês em grupo); estrutura e preço seguem em [Q-02](questoes-em-aberto.md#q-02).
- Conectores (Gmail, 99, Uber) **(hipótese)** — nenhuma integração foi decidida.
- O "durante" do rolê continua uma lacuna: o protótipo cobre entorno e volta com motorista, mas não acompanhamento em tempo real ([Q-12](questoes-em-aberto.md#q-12), D-06).

## O que ainda não está no protótipo

- Avaliação depois do rolê (`E-08`, D-09, [Q-17](questoes-em-aberto.md#q-17)).
- Fluxo de quem recomenda (moradora/criadora ganhando crédito — D-04, [Q-07](questoes-em-aberto.md#q-07)).
- Pagamento (D-08; sem reserva integrada no app, D-13; [Q-04](questoes-em-aberto.md#q-04), [Q-05](questoes-em-aberto.md#q-05)).
- Selo de segurança como elemento próprio: o card mostra entorno, e o selo só aparece como fonte "Selo Rolê Seguro" consultada no "Pensando" (nome **(hipótese)** — critérios em [Q-10](questoes-em-aberto.md#q-10)).
