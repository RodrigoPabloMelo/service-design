# UX.md — contexto de UX para geração com IA

> **O que é:** o contexto que qualquer IA deve ler **antes de gerar** telas, fluxos, textos (UX writing), protótipos, slides ou código de UI deste serviço. Formato inspirado em [UX-Context Design (NN/g, 2026)](https://www.nngroup.com/articles/ux-context-design/).
> **Não é** um documento de convencimento: o sucesso dele se mede pela melhora da saída da IA.
> **Atualizado:** 2026-11-09 · **Fonte de verdade:** [`docs/`](docs/README.md). Se algo aqui contradisser `docs/decisoes.md`, vale o docs — corrija este arquivo.
> **Identidade visual:** provisória, na skill [`mare-design`](.claude/skills/mare-design/SKILL.md) (D-16, [Q-26](docs/questoes-em-aberto.md#q-26) em discussão). Para o protótipo, siga-a; fora dele, não invente marca além dela e sinalize.

Convenção: `[F-xx]` achado de pesquisa · `[D-xx]` decisão · `[Q-xx]` questão aberta · **(hipótese)** = inferência ainda não validada.

---

## 1. O produto

App para **mulheres viajantes, sozinhas ou com mais 1 pessoa**, descobrirem **rolês não-turísticos com confiança**. As recomendações vêm de **moradoras/es e criadoras de conteúdo locais**, passam por **curadoria do grupo + comunidade** e trazem **informação de segurança**. Piloto: **Recife/Olinda**.

O que ele substitui: o vaivém entre TikTok → Instagram → Google Maps → TripAdvisor → ChatGPT para decidir **um** rolê.

## 2. Modelo da usuária

**Quem é:** mulher brasileira, ~22–28 anos, viagem de lazer doméstica. Fluente em tecnologia: descobre por TikTok/Instagram, valida no Maps/TripAdvisor, monta roteiro com ChatGPT, se desloca de app de transporte. **Não é novata**: não precisa de tutorial, precisa de **informação confiável e rápida**.

**O que ela quer fazer**
- Achar o que moradores fazem, **sem abrir mão de alguns pontos famosos** `[F-04]`.
- Planejar parte antes e **deixar espaço para decidir lá** `[F-05]`.
- Decidir **sozinha, com autonomia** — ou **junto com a companhia** `[F-12]`.
- Aproveitar sem **preço de turista** `[F-09]`.

**O que a preocupa (em ordem de peso)**
1. **Posso confiar?** Quem recomendou, por quê, é publi, está atualizado? `[F-02]` `[F-07]`
2. **Faz sentido para mim?** É tranquilo para ir sozinha / em duas mulheres / à noite? E a volta? `[F-03]`
3. **Vale meu tempo?** Excesso de opções iguais trava a decisão `[F-06]`.

**Como a companhia muda a geração**

| Situação | Persona | Ajuste na saída |
| --- | --- | --- |
| Sozinha | `P-CAMILA` | Mais peso a entorno, ida/volta, horário; reforçar autonomia ("você decide") |
| Com amiga | `P-JULIA` | "Adequado para duas mulheres"; facilitar compartilhar e decidir juntas; combater o "só viral" |
| Com parceiro(a) | `P-MARINA` | Opções que agradem às duas pessoas; equilíbrio famoso/local; lista pronta |

Nunca presuma a situação: pergunte ou use o que ela informou.

## 3. Modelo de mundo (contexto de uso)

| Momento | Onde/como ela está | Implica para a geração |
| --- | --- | --- |
| **Antes** (`E-01`–`E-05`) | Em casa, com tempo, comparando várias fontes, dividindo opções com a companhia, limitada por orçamento | Pode haver mais densidade e comparação; salvar e organizar é central; mostrar evidências (avaliações recentes, quem recomendou) |
| **Durante** (`E-06`–`E-07`) | **Na rua, celular na mão, cansada, às vezes à noite**, clima mudando o plano, **em alerta** com o entorno, decidindo **rápido** | Poucas opções, **perto de onde está**, ação principal óbvia, leitura em segundos; entorno e volta visíveis sem tocar em nada; nada de fluxos longos ou formulários |
| **Depois** (`E-08`) | Satisfeita, já em outra rotina; compartilha no WhatsApp/stories; **pouca motivação** para avaliar | Pedido de avaliação curto e leve, no momento certo; aproveitar o compartilhamento que ela já faz `[Q-17]` |

Condições que atravessam tudo:
- **Hipervigilância** quando está sozinha `[E-07]` — a interface não pode exigir atenção prolongada na rua.
- **Uma mão, tela pequena, sol/chuva** **(hipótese)** — alvos de toque grandes, alto contraste.
- **Conectividade instável** no destino **(hipótese)** — `[Q-25]`.

## 4. Achados de pesquisa → restrições de geração

| ID | Achado (pesquisa ciclo 1) | Restrição para o que for gerado |
| --- | --- | --- |
| F-01 | Descobre numa rede social e **confirma em outra** | Traga para a própria tela as provas que ela iria buscar fora: avaliações recentes, quem recomendou, fotos reais, data |
| F-02 | **Avaliações de outras mulheres** valem mais que publicidade; publi disfarçada gera desconfiança | Mostre **quem** recomendou/avaliou (moradora, criadora de conteúdo, viajante). Nunca apresente conteúdo pago como recomendação espontânea `[Q-08]` |
| F-03 | **Segurança percebida decide** se o roteiro muda; preocupação com ida **e volta** | Contexto do entorno e selo de segurança ficam **no ponto de decisão**, não numa aba escondida. Sempre considerar trajeto de volta e horário `[D-06]` |
| F-04 | Turístico é **pequena parte** da viagem, geralmente no início | Misture: destaque o local, mas não esconda pontos famosos |
| F-05 | Mesmo cansada, precisa **decidir muito rápido** se mantém ou troca o plano | No "durante": 1 recomendação principal + poucas alternativas, perto, com motivo claro |
| F-06 | **Excesso de opções parecidas** trava a decisão | Listas **curtas e curadas**; cada item diz **por que é diferente** — nada de feed infinito |
| F-07 | Chega e encontra **info desatualizada**; avaliações antigas ou sem contexto | Mostre **data da última verificação/avaliação**; sinalize quando estiver velha |
| F-08 | **IA erra rotas, horários e endereços** | Nunca invente endereço, horário, preço ou rota. Só dados da base curada; se faltar, escreva "não verificado" `[D-07]` |
| F-09 | Quer **conforto sem preço de turista** | Mostre faixa de preço e o que está incluso |
| F-10 | **Avalia só quando foi bom**, pouca motivação | Avaliação em 1–2 toques; não bloquear nada esperando avaliação |
| F-11 | Descobre algo bom **quando já não dá para encaixar** | "Salvar para depois" e "encaixar no roteiro" sempre a um toque |
| F-12 | Quer **compartilhar e decidir junto** com a companhia | Prever compartilhamento de opções; a forma exata está em aberto `[Q-22]` |
| F-13 | Quer saber **por que confiar** e por que aquilo foi indicado para ela | Toda recomendação (inclusive da IA) traz o **motivo**: perfil, companhia, interesse, momento da viagem |

## 5. Padrões de interação

**Anatomia mínima de um rolê** (qualquer card ou tela de detalhe)
1. Nome + tipo (café, bar, evento, passeio…)
2. **Quem recomendou** e o tipo de recomendadora `[F-02]` `[D-03]`
3. **Por que pra você** (1 linha) `[F-13]`
4. **Contexto do entorno**: região, horário bom, acesso, como voltar `[D-06]`
5. **Selo de segurança** das usuárias `[D-06]` — critérios em `[Q-10]`
6. Faixa de preço · como pagar (no app ou no local) `[D-08]`
7. **Atualizado em** `[F-07]`
8. Ações: salvar · encaixar no roteiro · compartilhar

**Roteiro com IA** `[D-07]`
- A IA só monta com itens da base curada; cada item mostra o motivo.
- Replanejar por clima, cansaço, horário e localização é um gesto primário no "durante".
- Quando a base não cobre o pedido, diga isso — não complete com conhecimento genérico.

**Segurança**
- Informação de segurança é **factual e contextual** ("rua movimentada até 22h", "melhor voltar de app") — nunca alarmista.
- Não confirmados: SOS, check-in, compartilhar localização. Não gere esses recursos como se existissem `[Q-12]`.
- Se a informação de segurança básica fica atrás de plano pago: **não definido** `[Q-02]`. Não gere paywall em informação de segurança.

**Planos/pacotes** `[D-01]`
- Benefícios conhecidos: motoristas mulheres, reservas pré-feitas, pratos sugeridos em restaurantes selecionados. Estrutura e preço indefinidos `[Q-02]` — use placeholders.
- Não usar upsell nos momentos de tensão (trajeto, volta, à noite).

## 6. Linguagem

- Fale **com ela, no feminino** ("você está sozinha?", "pronta pra sair?") — o público é de mulheres `[D-11]`.
- Vocabulário dela: **rolê**, **roteiro**, **moradora/local**, **selo de segurança**, **salvar**. Ver [docs/glossario.md](docs/glossario.md).
- Evite: "atração turística", "pontos imperdíveis", "top 10", "zona de risco/perigosa", "área a evitar".
- Tom **(hipótese)**: de amiga local — direto, concreto, sem exagero de marketing. Definição oficial em `[Q-24]`.
- Ao falar de bairro, descreva condição (horário, movimento, acesso), não rotule o lugar `[Q-10]`.

## 7. Não faça

- Listagem genérica estilo TripAdvisor, ranking por popularidade, feed infinito.
- Recomendação sem fonte, sem data ou sem motivo.
- Endereço, horário, preço ou rota inventados.
- Mapa de "perigo" por bairro ou linguagem de medo.
- Recursos de segurança não decididos (SOS, rastreamento) apresentados como existentes.
- Paywall ou upsell em cima de informação de segurança.
- Identidade visual "de marca" inventada enquanto não houver `DESIGN.md`.

## 8. Não definido — pergunte, não invente

| Tema | Questão |
| --- | --- |
| Nome do serviço | [Q-01](docs/questoes-em-aberto.md#q-01) — use "o app" |
| Planos, preços, comissão | [Q-02](docs/questoes-em-aberto.md#q-02), [Q-04](docs/questoes-em-aberto.md#q-04) |
| Critérios do selo de segurança | [Q-10](docs/questoes-em-aberto.md#q-10) |
| Segurança durante/depois | [Q-12](docs/questoes-em-aberto.md#q-12) |
| Exclusividade para mulheres / verificação | [Q-13](docs/questoes-em-aberto.md#q-13) |
| Papel da companhia | [Q-22](docs/questoes-em-aberto.md#q-22) |
| Tom de voz | [Q-24](docs/questoes-em-aberto.md#q-24) |
| Plataforma, conectividade, acessibilidade | [Q-25](docs/questoes-em-aberto.md#q-25) |
| Identidade visual (`DESIGN.md`) | [Q-26](docs/questoes-em-aberto.md#q-26) |

Ao esbarrar num desses temas: use placeholder visível (ex.: `[preço do plano — Q-02]`) e avise.

## 9. Checagem da saída

Antes de entregar algo gerado, confira:

- [ ] Cada rolê mostra quem recomendou, por quê, entorno, selo e data?
- [ ] No "durante", ela decide em segundos, com uma mão?
- [ ] Algum dado factual foi inventado?
- [ ] A linguagem é factual, no feminino, sem medo nem marketing?
- [ ] Algum recurso ou regra em aberto (seção 8) foi tratado como decidido?
- [ ] A situação de companhia (sozinha/amiga/parceiro(a)) foi respeitada?

## 10. Curadoria deste arquivo

Este arquivo nunca fica pronto. Ele é atualizado quando:
1. **Sai pesquisa nova** → novo `F-xx` na seção 4.
2. **Uma questão é decidida** → atualizar seções 5–8 e `docs/decisoes.md`.
3. **A IA erra de forma recorrente** → registrar abaixo e corrigir a regra que faltou.

**Log de erros observados na geração**

| Data | O que a IA gerou de errado | Regra criada/ajustada |
| --- | --- | --- |
| — | — | — |
