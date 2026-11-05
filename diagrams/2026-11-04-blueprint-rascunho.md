# Blueprint do serviço: rascunho v0

> **Atualizado:** 2026-11-04 · **Fonte:** panorama descrito pelo Rodrigo (conversa de 2026-11-04) + [docs/](../docs/README.md)
> **Status:** rascunho para preencher. Não é decisão: nada aqui entra em [decisoes.md](../docs/decisoes.md) até o grupo confirmar.
> **Diagrama:** [blueprint.html](blueprint.html) → [PNG v1](../docs/imagens/diagramas/2026-11-04-blueprint-servico-v1.png). O diagrama mostra só o serviço implementado: 8 etapas (Descobre o app · Pesquisa · Seleciona · Cria conta e salva · Organiza com o agente · Acompanha e reajusta · Vive o rolê · Fechamento e recompensas), com a viajante no topo e prestadores e parceiros na raia mais externa. A relação com a jornada atual está na seção 2. "?" = item em aberto.
> **Revisão 2026-11-04:** sem reserva integrada (D-13), então a etapa 5 "Reserva e confirma" saiu · retorno ao local = pontos quando o rolê é usado (D-14) · prestadores e parceiros viram a raia mais externa.
> **Revisão 2 (2026-11-04):** descoberta por buscador (D-15), rolês sem login (D-16), freemium com extras pagos (D-17), cards + vídeos curtos (D-18). O **diagrama** é a versão mais atual; as tabelas abaixo ainda trazem o detalhamento da revisão 1.
> **Legenda:** texto normal = veio do panorama do Rodrigo ou de decisão `D-xx` · **(hipótese)** = sugestão para completar · `[lacuna]` = falta definir, com a `Q-xx` correspondente.

---

## 1. Raias (linhas do blueprint)

O panorama atual tem três camadas: **usuária** → **camada de interação** ("adiciona os rolês na plataforma") → **empresa/curadoria**, com os **locais** do lado de fora. Para virar um blueprint completo, sugestão de raias, de cima para baixo:

| # | Raia | O que entra | De onde vem no panorama |
| --- | --- | --- | --- |
| R1 | **Evidências físicas** | O que ela vê/toca: telas, notificações, e-mails, convite no calendário, voucher, QR no balcão | **falta** |
| R2 | **Ações da viajante** (e da companhia) | Etapas 1 a 6 do panorama | Pool da usuária |
| ─ | *linha de interação* | | |
| R3 | **Frontstage: app + agente de IA** | Busca, cards, roteiro, mapa, calendário, notificações, avaliação, carteira | Agente de IA (etapas 4, 5, 6) |
| ─ | *linha de visibilidade* | | |
| R4 | **Backstage: grupo / empresa** | Curadoria, verificação, publicação, atendimento, gestão de parcerias | 2ª pool ("a gente como empresa") |
| R5 | **Atores externos** | Locais (`A-1`), prestadores (`A-6`), parceiros de benefício (99/Uber, restaurantes) | Locais que recomendam (só eles aparecem hoje) |
| ─ | *linha de interação interna* | | |
| R6 | **Processos de suporte / sistemas** | Base curada, motor de IA, mapas, clima, calendário, push, pagamento, carteira de pontos, antifraude | **falta** |
| + | **Linhas de leitura** (opcionais, abaixo) | Etapa da jornada `E-xx` · emoção · ponto de falha · métrica | **falta** |

---

## 2. Etapas: panorama atual → proposta

| # | Etapa proposta | Origem | Jornada |
| --- | --- | --- | --- |
| 0 | Descobre o app | **sugerida** | `E-01` `E-02` |
| 1 | Pesquisa rolês em Recife | panorama (1) | `E-03` |
| 2 | Seleciona rolês curados | panorama (2) | `E-04` |
| 3 | Cria conta, salva e monta o perfil da viagem | panorama (3) + perfil **sugerido** | `E-04`→`E-05` |
| 4 | Organiza o roteiro com o agente | panorama (4) | `E-05` |
| 6 | Acompanha e reajusta (durante) | panorama (5) | `E-06` |
| 7 | Vive o rolê: chega, paga, volta | **sugerida** (separada da 6) | `E-07` |
| 8 | Fechamento: avalia e ganha pontos | panorama (6) | `E-08` |
| 9 | Troca pontos e volta | **sugerida** (separada da 8) | depois de `E-08` |
| L | Laço dos locais (raia paralela) | panorama (curadoria + retorno aos locais) | — |

Por que as três sugeridas:

- **0**: a etapa 1 começa com ela já dentro do app. Falta o momento em que ela chega até ele (`E-01`/`E-02`).
- **7**: a etapa 5 do panorama junta replanejar (`E-06`) e estar no lugar (`E-07`). Estar no lugar é onde ficam a segurança, o pagamento no local e a comissão, e cada um precisa de espaço próprio.
- **9**: o fechamento junta avaliar e resgatar. Resgatar acontece depois, às vezes semanas depois e em outra cidade. Separar ajuda a desenhar a retenção.

---

## 3. Etapas detalhadas

### 0 · Descobre o app (sugerida)

| Raia | Conteúdo |
| --- | --- |
| Evidências | Resultado no buscador · site do app · indicação (secundária) (`D-15`) |
| Viajante | Pesquisa rolês em Recife no buscador, abre o site pelo link e vê rolês indicados por locais |
| Frontstage | Páginas de rolê abertas, **sem login** (`D-16`) |
| Backstage | Grupo publica páginas de rolê pensadas para busca |
| Externos | Locais indicam o app no boca a boca |
| Suporte | Site indexável (SEO) · link rastreável |
| Lacunas | `[lacuna]` Existe app nativo além do site? (`Q-25`) |

### 1 · Pesquisa rolês em Recife

| Raia | Conteúdo |
| --- | --- |
| Evidências | Tela de busca/explorar |
| Viajante | Busca e filtra por tipo, bairro, dia, companhia |
| Frontstage | Lista **curta** e curada (`F-06`); filtro "sozinha / com amiga / com parceiro(a)"; card com a anatomia mínima do [UX.md §5](../UX.md) |
| Backstage | Grupo mantém a base publicada |
| Externos | Locais já mandaram recomendações (ver laço L) |
| Suporte | Base curada (CMS), busca |
| Lacunas | `[lacuna]` A pesquisa é **dentro do app** ou no Google, onde o app precisa aparecer? Dá para ver sem conta? |

### 2 · Seleciona rolês curados

| Raia | Conteúdo |
| --- | --- |
| Evidências | Tela de detalhe do rolê |
| Viajante | Compara, confere quem recomendou, o entorno e o selo; manda opções para a companhia |
| Frontstage | Cards no estilo de sites de avaliação de viagem + **vídeos curtos curados** (`D-18`); detalhe com quem recomendou, por que pra você, entorno, selo, preço e "atualizado em" (`F-01`, `F-07`, `F-13`) |
| Backstage | Curadoria registrou a data de verificação; selo calculado a partir das avaliações |
| Suporte | Fonte dos dados de entorno |
| Lacunas | `[lacuna]` O que "curado" garante para ela (`Q-06`) · critérios do selo (`Q-10`) · como compartilhar com a companhia (`Q-22`) |

### 3 · Cria conta, salva e monta o perfil da viagem

| Raia | Conteúdo |
| --- | --- |
| Evidências | E-mail/SMS de boas-vindas |
| Viajante | Cria a conta **no momento de salvar** (já viu valor antes do cadastro); informa datas, bairro da hospedagem, companhia, interesses e ritmo **(hipótese)** |
| Frontstage | Cadastro curto; o perfil da viagem alimenta o agente |
| Backstage | Verificação de conta? (`Q-13`) |
| Suporte | Autenticação · perfil · consentimento LGPD (localização e calendário são dados sensíveis) |
| Lacunas | `[lacuna]` Só para mulheres, com verificação? (`Q-13`) · a companhia também cria conta? (`Q-22`) · o plano é oferecido aqui? (`Q-02`) |

### 4 · Organiza o roteiro com o agente

| Raia | Conteúdo |
| --- | --- |
| Evidências | Roteiro com mapa no app · eventos no calendário dela |
| Viajante | Pede ao agente para distribuir os salvos pelos dias; edita, troca, deixa dias livres (`F-05`); salva o roteiro |
| Frontstage | Agente agrupa por proximidade, horário de funcionamento, melhor horário do entorno e volta; mostra o motivo de cada item (`F-13`); mapa integrado; manda para o calendário |
| Backstage | Grupo garante endereços e horários certos na base (`F-08`) |
| Suporte | IA restrita à base curada (`D-07`) · mapas/rotas · previsão do tempo · integração de calendário |
| Lacunas | `[lacuna]` O agente só organiza os salvos ou também sugere novos? O que faz quando um dia fica vazio? (`Q-11`) · Calendário: exporta ou sincroniza? (`Q-29`) · Roteiro compartilhado com a companhia? (`Q-22`) |

### 6 · Acompanha e reajusta (durante)

| Raia | Conteúdo |
| --- | --- |
| Evidências | Notificações push ("vai chover às 15h", "esse café fecha às 18h") · evento atualizado no calendário |
| Viajante | Segue o roteiro; recebe uma sugestão e aceita ou recusa; pede "algo perto daqui" ou "tô cansada" |
| Frontstage | Agente monitora gatilhos e propõe **1 troca principal + poucas alternativas**, perto e com motivo (`F-05`); atualiza mapa e calendário |
| Backstage | Grupo recebe sinais de "fechou/mudou" e corrige a base (`F-07`) |
| Suporte | Localização (com permissão) · clima · horários · motor de notificações com limite de frequência |
| Lacunas | `[lacuna]` "Necessidades multifatoriais" precisa virar uma **lista de gatilhos**: clima, horário de funcionamento, distância, noite/volta, cansaço declarado, orçamento. O ajuste é automático ou sempre pede confirmação? Quantas notificações por dia sem virar ruído? (`Q-29`) · Funciona com pouca conexão? (`Q-25`) |

### 7 · Vive o rolê: chega, paga, volta (sugerida)

| Raia | Conteúdo |
| --- | --- |
| Evidências | Adesivo do app no estabelecimento com QR **(hipótese)** · comprovante · corrida de volta |
| Viajante | Chega; faz check-in; paga no local ou mostra o voucher; volta para a hospedagem |
| Frontstage | Entorno e "como voltar" visíveis sem tocar em nada (UX.md §3); atalho para transporte |
| Backstage | Registra a comissão; acompanha incidentes |
| Externos | Prestador atende e valida o cupom/check-in · transporte |
| Suporte | Validação de QR/cupom · registro de comissão · crédito de pontos |
| Lacunas | `[lacuna]` A segurança **durante**, que é a promessa central, não aparece no panorama (`Q-12`) · rastrear a comissão no pagamento no local (`Q-04`) · o que acontece quando dá errado: lugar fechado, reserva não honrada, situação insegura (`Q-31`) |

> **Uma peça, três lacunas (hipótese):** um check-in no local (QR no balcão ou código no app) poderia ao mesmo tempo **rastrear a comissão** (`Q-04`), **provar a visita** para a avaliação valer (`Q-13`) e **gerar pontos** (`Q-27`). Ver `Q-30`.

### 8 · Fechamento: avalia e ganha pontos

| Raia | Conteúdo |
| --- | --- |
| Evidências | Notificação pós-rolê · resumo da viagem (mapa do que ela fez + pontos ganhos) |
| Viajante | Avalia em 1–2 toques e dá o selo de segurança; recebe pontos; conversa com o agente sobre a viagem |
| Frontstage | Pedido de avaliação **logo depois de cada rolê** (não só no fim da viagem) **(hipótese)**; mensagens do agente; catálogo personalizado pela última visita |
| Backstage | Avaliações alimentam a curadoria comunitária (`D-05`) e o selo |
| Externos | Locais recebem o retorno ("sua indicação foi visitada e avaliada") + pontos |
| Suporte | Carteira de pontos · antifraude · recomendação personalizada |
| Lacunas | `[lacuna]` O que dispara o fechamento: o fim da viagem (pelo calendário) ou cada rolê? · Pontos premiam **avaliar** ou avaliar **bem**? Premiar a nota distorce o selo e incentiva avaliação falsa (`F-10`, `Q-13`, `Q-27`) · Para que servem as "mensagens com o agente" nesse momento? |

### 9 · Troca pontos e volta (sugerida)

| Raia | Conteúdo |
| --- | --- |
| Evidências | Cupom 99/Uber · voucher em restaurante/experiência · catálogo de recompensas |
| Viajante | Troca pontos por cupons e serviços; volta a Recife ou indica uma amiga |
| Frontstage | Carteira e catálogo de recompensas |
| Backstage | Grupo gere as parcerias e acerta as contas com os parceiros |
| Externos | **Parceiros de benefício**: 99/Uber, restaurantes (modelo clube de descontos), outras experiências. Novo ator `A-8` **(hipótese)** |
| Suporte | Emissão de cupons integrada aos parceiros · conciliação financeira |
| Lacunas | `[lacuna]` Ela vai a Recife uma vez: os pontos só têm valor se servirem **depois** da viagem. Cupom de 99/Uber na cidade dela serve; restaurante em Recife só serve se ela voltar (`Q-32`) · Quem paga o desconto: o app, o parceiro ou os dois? Os pontos expiram? (`Q-27`, `Q-28`) |

### L · Laço dos locais (raia paralela)

| Passo | Quem | O que acontece | Lacuna |
| --- | --- | --- | --- |
| L1 | Local (`A-1`) | Recomenda um rolê: "adiciona os rolês na plataforma" | Por onde? App, formulário? O local tem conta? (`Q-21`) |
| L2 | Grupo (`A-2`) | Analisa pelos critérios; confere endereço, horário, entorno | Critérios e frequência (`Q-06`) |
| L3 | Grupo → App | Publica com data de verificação e crédito ao local | Publica com o nome de quem indicou? (`Q-08`) |
| L4 | Viajante | Encontra, visita, avalia | — |
| L5 | Grupo → Local | Retorno ("X viajantes foram") + **pontos quando o rolê é usado** (`D-14`) | Quanto vale e como se comprova o uso (`Q-07`, `Q-30`) |
| L6 | Comunidade + grupo | Revisão periódica; avaliações mantêm ou derrubam (`D-05`) | O que derruba um rolê (`Q-06`) |

Fora do panorama: a raia dos **prestadores** (`A-6`): como entram na rede, como ofertam, como recebem reservas e pagam comissão (`Q-21`, `Q-04`).

---

## 4. Linhas de leitura (sugestão para a base do diagrama)

| Etapa | Emoção (jornada as-is) | Ponto de falha principal | Métrica possível **(hipótese)** |
| --- | --- | --- | --- |
| 1 Pesquisa | Indecisa | Excesso de opções iguais | Tempo até salvar o 1º rolê |
| 2 Seleciona | Desconfiada | Parecer publi / info velha | % de rolês com "atualizado em" < 90 dias |
| 4 Organiza | Confiante | IA errar horário/rota | Edições manuais por roteiro |
| 6 Reajusta | Cansada | Notificação demais ou na hora errada | Sugestões aceitas / enviadas |
| 7 Vive | Encantada e alerta | Insegurança na volta | Check-ins por roteiro |
| 8 Fecha | Satisfeita | Não avaliar | % de rolês visitados com avaliação |
| 9 Troca | — | Pontos sem uso | % de pontos resgatados |
