# Protótipo — o que ele cobre

> **Atualizado:** 2026-11-18 · **Código:** [`prototype/app/`](../prototype/app/README.md) · **Telas:** `/explorar` (`lib/features/explore/`, abre por padrão) e `/agente` (`lib/features/travel_agent/`)
> **Status:** protótipo navegável em Flutter web, com **dados mockados** (sem backend, sem IA real). Nome de trabalho: **Maré** — o nome do serviço segue em aberto ([Q-01](questoes-em-aberto.md#q-01)).
> **Sistema visual:** skill [`mare-design`](../.claude/skills/mare-design/SKILL.md) (DESIGN.md provisório, ver [Q-26](questoes-em-aberto.md#q-26)).

## De onde vem

A tela `/agente` materializa a **etapa 04 "Organiza locais com o agente"** do [blueprint de serviço](../diagrams/blueprint.html) (viajante mulher, rolês em Recife). Na v1 do blueprint (PDF de 2026-11-04) era a etapa 05; a renumeração veio com D-23.

Na jornada atual ([jornada.md](jornada.md)), ela responde principalmente a `E-05` (montagem do roteiro: "IA erra rotas, horários e endereços") e `E-06` (ajustes na estadia: clima, cansaço, perto de onde está), e traz para dentro do app as provas que a viajante buscaria fora em `E-04` (validação e confiança).

## Como abrir

```bash
cd prototype/app && fvm flutter run -d chrome -t lib/main_design.dart
```

Publicado na Vercel em <https://service-design-three.vercel.app/agente>. A Vercel builda sozinha a cada push na `main` ([`vercel.json`](../vercel.json) chama [`tool/vercel_build.sh`](../prototype/app/tool/vercel_build.sh)). O script baixa o Flutter do `.fvmrc`, roda analyze e testes e gera o build web. Ramos que não são a `main` ganham um preview.

Abra `/explorar` (home, abre por padrão) ou `/agente`. Momentos da narrativa: `/agente/chuva` (cena 5, alerta de chuva já em Recife), `/avaliar` (cena 8, pedido de avaliação) e `/carteira`. Cenários da home (`ExploreScenario`): `padrao`, `carregando`, `erro`. Cenários do agente (`TravelAgentScenario`): `padrao` (8 rolês salvos), `vazio` (começo do zero), `erro`, `carregando`, `chuva` (roteiro pronto + notificação de chuva).

**No celular** (navegador), os efeitos caros entram sozinhos em **modo leve**: vidro sem refração, desfoque do topo em 3 faixas, frost sem blur e aurora a ~15 fps (regra 14 da skill `mare-design`). As barras do navegador (status e a de baixo no Safari, a barra do Chrome no Android) seguem o fundo do app. Para comparar no aparelho:

- `/agente?fps=1` mostra fps, o pior quadro e os tempos de build/raster;
- `?efeitos=completo` força o visual cheio, e `?efeitos=leve` força o leve no desktop.

## Telas e componentes ↔ docs

O passo a passo de cada tela (fluxos `FL-xx`, subfluxos `FL-xx.y`) e os estados por onde passa (`ST-*`) estão em [fluxos/](fluxos/README.md).

| Parte do protótipo | O que faz | Etapa | Personas | Decisões que aplica | Questões que toca |
| --- | --- | --- | --- | --- | --- |
| **Explorar (home)** (busca no topo, botão da Maré à direita, "Explore rolês" com as categorias, seções curtas: "Pra esta tarde/noite", "Vídeos curtos", "Pra ir sozinha", "Mais perto do hotel", "Se chover") | Porta de entrada: rolês curados com quem indicou e por quê, sem feed infinito | `E-01`, `E-03`, `E-04` | todas; seção da companhia segue o perfil (mock: Camila, sozinha, `P-CAMILA`) | D-24, D-03, D-21 | [Q-25](questoes-em-aberto.md#q-25), [Q-37](questoes-em-aberto.md#q-37) |
| **Vídeos curtos** (prateleira 9:16 na home → feed vertical em tela cheia, ref. Shorts; quem indicou, legenda, atalho pro rolê, salvar; fila finita com página de fim "Você viu tudo por hoje" + "Se cuida e bom rolê.") | Ver o rolê no formato que ela já consome, sem rolagem sem fim | `E-01`, `E-04` | todas | D-29, D-18 | [Q-34](questoes-em-aberto.md#q-34) (origem dos vídeos); vídeo é foto com movimento **(simulado)** |
| **Categorias** (foto de lugar de Recife + véu de cor + ícone ilustrado: restaurantes, café, museu, cultura, arte, história) | Atalho por tipo de rolê; abre os resultados já filtrados | `E-03` | — | D-24 | [Q-38](questoes-em-aberto.md#q-38) (café sem rolê curado: vazio honesto) |
| **Busca guiada + filtros** (onde: campo de busca com sugestões "Por perto", Recife e Olinda e resultados por cidade/bairro ao digitar; quando: calendário com intervalo, ±1/±2 dias ou flexível por fim de semana/semana e mês; com quem; que tipo; depois coberto, grátis, perto do hotel, período, preço). Resultados em card grande com carrossel de fotos (ref. Airbnb) | Ela diz o que precisa; o resultado é curto e só da base curada | `E-03`, `E-04`, `E-06` | `P-CAMILA` (sozinha), `P-JULIA` (amiga), `P-MARINA` (parceiro(a)) | D-25, D-07, D-11 | [Q-10](questoes-em-aberto.md#q-10) (sem filtro de segurança), [Q-22](questoes-em-aberto.md#q-22) ("com quem" ainda não muda o resultado) |
| **Tab bar** (Explorar, Salvos, Perfil) | Navegação do app | — | — | D-24 | [Q-37](questoes-em-aberto.md#q-37) |
| **Conta rápida ao salvar** (folha com Apple, e-mail ou Google; um passo, sem verificação) | Salvar pede conta; ver continua sem login. Depois de entrar, o rolê já fica salvo | `E-04` | todas | D-16, D-23 | [Q-13](questoes-em-aberto.md#q-13) |
| **Salvos** (ref. Pinterest: sheet "Salvar em" com as viagens e "Nova viagem"; grade de viagens com capa-mosaico; dentro, dias como seções e rolês sem dia, "Organizar" à mão e "Organizar com a Maré"; vazio honesto) | As pastas da viagem, separadas por dia | `E-04`, `E-05` | todas; `P-MARINA` (lista pronta) | D-24, D-28 | [Q-37](questoes-em-aberto.md#q-37), [Q-22](questoes-em-aberto.md#q-22) |
| **Perfil** (card "Seus pontos" → página de pontos; resumo da viagem: datas, hotel, salvos, avaliações, transfer) | Pós-serviço e conta | `E-08` | todas | — | [Q-27](questoes-em-aberto.md#q-27), [Q-32](questoes-em-aberto.md#q-32) |
| **Conversa com o agente** (abre numa **conversa nova**: saudação central sobre o mapa com bichos do mar em pixels, sem bloco-resumo; sugestões "Organizar meus 8 rolês", "Noite com as amigas", "Perto do hotel" acima do composer). Vale também para quem chega pelo Explorar e por "Organizar com a Maré" em Salvos | A viajante pede em linguagem natural; o agente responde com rolês ou roteiro | `E-05`, `E-06` | todas; "Noite com as amigas" → `P-JULIA` | D-07 (IA usa só a base curada) | [Q-11](questoes-em-aberto.md#q-11) escopo da IA |
| **Conversas anteriores (gaveta ☰)** (ref. ChatGPT: Explorar, Salvos, Perfil, Fixadas, Recentes, "Nova conversa"; a conversa desliza pra direita com cantos arredondados) | Retomar uma conversa (o roteiro da viagem fica fixado), começar outra ou voltar a uma aba da home | `E-05`, `E-06` | todas | D-27 | [Q-40](questoes-em-aberto.md#q-40) (conta e retenção do histórico) |
| **"Pensando" com passos** | Mostra o que o agente está fazendo antes de responder | `E-05` | — | — | Q-11 (hipótese: transparência do porquê da recomendação) |
| **Começo do zero** (cenário `vazio`: mapa com pontos da curadoria sem nome + saudação) | Primeira visita, nada salvo | `E-01`, `E-03` | — | D-05 (curadoria) | — |
| **Card do rolê** (quem indicou + vínculo com o lugar + citação, fotos reais, vídeos curtos, o que fazer, melhor horário, custo, nota no cabeçalho e, depois das fotos, a seção **"Avaliações"**: "Como foi pra você?" com a média ao lado e as estrelas, avaliações por data com quem e em que situação) | Junta num lugar só as provas de confiança | `E-04`, `E-08` | `P-CAMILA` (quem recomendou e por quê, avaliações com data e contexto), `P-JULIA` (viral x bom), `P-MARINA` (avaliações contraditórias) | D-03 (moradoras/es e criadoras de conteúdo), D-05, D-18, D-30 | [Q-08](questoes-em-aberto.md#q-08) publi, [Q-06](questoes-em-aberto.md#q-06) curadoria, [Q-41](questoes-em-aberto.md#q-41) moderação, [Q-13](questoes-em-aberto.md#q-13) — avaliações das outras viajantes **(simulado)** |
| **Entorno no card** (checks do selo, "Avaliado pra ir sozinha", e do entorno, "Rua movimentada de dia", "Táxi na esquina"; sem data desde D-31) | Contexto de segurança antes de ir | `E-04`, `E-07` | `P-CAMILA` | D-06 (contexto do entorno) | [Q-10](questoes-em-aberto.md#q-10) critérios do selo, [Q-12](questoes-em-aberto.md#q-12) "durante" |
| **Selo "Rolê seguro"** (marca no card da home, pílula na foto do card de resultado; no detalhe: só o nome, as situações viram checks — D-31) | Selo visível no ponto de decisão | `E-04` | `P-CAMILA` | D-06, D-25 (sem filtro), D-31 | [Q-10](questoes-em-aberto.md#q-10) — nome e critérios **(hipótese)** |
| **Datas e hospedagem no agente** (card com chips antes do roteiro) | Ela informa a viagem; só então o agente monta | `E-05` | todas | D-23 | — |
| **Mapa** (desenho próprio de Recife, pins por rolê, hotel) | Ver rolês e roteiro no espaço | `E-05`, `E-06` | `P-MARINA` (lista pronta), todas | — | — |
| **Roteiro por dia** (manhã/tarde/noite, editar, remover parada, "Pedir ajuste") | Organiza os rolês salvos em dias | `E-05` | `P-MARINA`, `P-CAMILA` (autonomia) | D-07 | — |
| **Troca por chuva** (notificação simulada → agente propõe trocar o Box Vitória Régia, ao ar livre, pelo Parraxaxá, coberto; aceitar/recusar; mapa e agenda atualizados) | Replanejamento pelo clima | `E-06` | todas | D-07 (clima/contexto) | [Q-29](questoes-em-aberto.md#q-29) notificações (hipótese) |
| **Acesso sem alagamento** ("Trajeto sugerido sem pontos de alagamento conhecidos", com fonte e data) | Decidir a troca sabendo do trajeto, sem promessa | `E-06` | `P-CAMILA` | D-06 | [Q-39](questoes-em-aberto.md#q-39) (fonte do dado) |
| **Transfer pago no app** (oferta depois da troca → checkout: motorista parceira, ida e volta, preço, cartão mock → "Abrir app da parceira") e **atalho no dia** no topo do Explorar | Contratar e pagar aqui; acompanhar a corrida no app da parceira | `E-06`, `E-07` | `P-CAMILA` | D-26, D-17 | [Q-03](questoes-em-aberto.md#q-03), [Q-02](questoes-em-aberto.md#q-02) (preço de mock), [Q-12](questoes-em-aberto.md#q-12) |
| **Avaliação em 2 toques** (notificação ou estrela no card do rolê → 5 estrelas pro rolê e o transfer, motivos rápidos da faixa da nota, "Enviar"; "Contar mais" com texto e fotos; rascunho ao fechar) e **pontos** (ref. Google Pay: saldo, cupons do serviço e de parceiros em grade — bloqueado, disponível, trocado —, sheet do cupom com o código e "Copiar código" | "usar no app", histórico) | Fechamento e recompensa, sem bloquear nada | `E-08` | todas | D-09, D-30 | [Q-41](questoes-em-aberto.md#q-41), [Q-17](questoes-em-aberto.md#q-17), [Q-27](questoes-em-aberto.md#q-27), [Q-28](questoes-em-aberto.md#q-28), [Q-30](questoes-em-aberto.md#q-30) — pontos, cupons e parceiros **(hipótese)** |
| **Extras** ("Volta com motorista mulher", "Forró em grupo com guia") e comparação de corrida 99/Uber | Benefícios e transporte de ida/volta | `E-06`, `E-07` | `P-CAMILA` | D-01 (planos com motoristas mulheres) | [Q-02](questoes-em-aberto.md#q-02), [Q-03](questoes-em-aberto.md#q-03), [Q-05](questoes-em-aberto.md#q-05) |
| **Conectores** (Google Agenda, Google Maps, Gmail, 99, Uber) e "Conectar agenda" | Levar o roteiro para os apps que ela já usa | `E-05` | — | — | [Q-25](questoes-em-aberto.md#q-25) plataforma |
| **Seus limites** (mensagens semanais, assinatura "R$ 14,90/mês") | Modelo freemium do agente | — | — | — | [Q-02](questoes-em-aberto.md#q-02) planos — **valor e modelo são hipótese do protótipo**, não decisão |

## O que é hipótese no protótipo

- Pessoas que indicam, @handles e preços são **fictícios**; os rolês e as fotos são reais (créditos em `prototype/app/assets/images/roles/CREDITS.md`).
- Limite de mensagens: decidido que o agente grátis tem **mensagens limitadas** (D-17); o tamanho do limite e o que acontece durante a viagem seguem em [Q-35](questoes-em-aberto.md#q-35). A assinatura de R$ 14,90/mês é **(hipótese)** — D-17 coloca o pago nos serviços adicionais (transfer, rolês em grupo); estrutura e preço seguem em [Q-02](questoes-em-aberto.md#q-02).
- Conectores (Gmail, 99, Uber) **(hipótese)** — nenhuma integração foi decidida.
- Conversas da gaveta da Maré: as antigas são mock (refeitas a partir do pedido que as abriu) e a lista vive só na sessão, sem conta (D-27, [Q-40](questoes-em-aberto.md#q-40)). A Maré parte sempre dos 8 rolês salvos do mock, não da pasta de Salvos da sessão ([Q-37](questoes-em-aberto.md#q-37)).
- Home com tab bar **(hipótese)** de app (Q-25). O "com quem" da busca só muda o texto do resultado, ainda não o filtro (Q-22). Paço do Frevo, Parque das Esculturas e Rua do Bom Jesus entraram no mock (lugares reais, quem indica é fictício; horários e preços são de mock). Fotos da home em `prototype/app/assets/images/explore/CREDITS.md`.
- O "durante" do rolê continua uma lacuna: o protótipo cobre entorno, transfer pago e o atalho para o app da parceira, mas não acompanhamento em tempo real nem compartilhar localização ([Q-12](questoes-em-aberto.md#q-12), D-06).
- Troca por chuva usa lugares reais de Casa Forte (Box Vitória Régia e Parraxaxá). **A confirmar:** mesas descobertas do Box, horário do Parraxaxá (no mock: "não verificado") e distância a pé. Quem indica, motorista, preços do transfer, cartão e pontos são fictícios. Foto do Parraxaxá é de divulgação (uso acadêmico).

## O que ainda não está no protótipo

- Fluxo de quem recomenda (moradora/criadora ganhando crédito — D-04, [Q-07](questoes-em-aberto.md#q-07)).
- Pagamento além do transfer (planos, rolês em grupo; D-08, D-13, [Q-04](questoes-em-aberto.md#q-04), [Q-05](questoes-em-aberto.md#q-05)).
- Prova de que ela foi ao rolê ([Q-30](questoes-em-aberto.md#q-30)): a avaliação abre por notificação, sem verificar a visita.
- Pasta compartilhada com a companhia ([Q-22](questoes-em-aberto.md#q-22)) e a Maré escrevendo os dias direto na pasta ([Q-37](questoes-em-aberto.md#q-37)).
- Vídeo de verdade nos vídeos curtos (hoje é foto com movimento, sem dependência de vídeo).
