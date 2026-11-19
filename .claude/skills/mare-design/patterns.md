# Padrões de componente e fluxo

## Fluxo da tela

- **Conversa nova** (abertura padrão, com rolês salvos): tela cheia, **sem
  bloco azul**. Atrás da saudação, `TideBackdrop`: o mapa de Recife parado
  (sem toque, pontinhos da curadoria) + maré em pixels + véu radial `s0`;
  esvai junto com a aurora no primeiro envio (1,8 s) e o ticker morre.
  O mapa "de verdade" (pins, detents) continua só quando ela pede. Saudação centrada no espaço acima do
  rodapé (`AgentGreeting`: `MareMark` 28, "Oi, {nome}." em `inkMuted` +
  pergunta sorteada em `title1`), composer "Pergunte à Maré…" e só 3
  sugestões de maior valor (organizar, noite com as amigas, perto do
  hotel) presas em cima do composer. Sem carrossel de salvos nem outros cards ali (polui); eles entram
  quando o agente responde. Depois do primeiro envio o composer volta a
  "Peça um ajuste à Maré…".
- Bloco-resumo azul: só em conversa que já tem roteiro ou erro (`showSummary`).
- Aurora (`Aurora`, azul `accent` + `piscina`) atrás do composer, presa ao
  rodapé, **só enquanto nada foi enviado**. Na primeira mensagem se esvai
  devagar e desliga o ticker. Tem que aparecer no claro também
  (intensidade 0.6 claro / 0.8 escuro). Fica por baixo de tudo — nunca
  sobre o composer nem entre bloco e sugestões. Na prática é pintada sobre
  o véu `s0` do rodapé, recortada pela mesma rampa: só aparece onde o véu
  esconde a lista, nunca tingindo mensagens. Com o mapa aberto não anima.
- **Começo do zero** (nada salvo, sem datas — cenário Vazio): abre **no
  mapa**, sem sheet e sem bloco azul (`BlankStartHero`). No centro, véu
  radial `s0`, `MareMark` 28, "Oi, {nome}." em `inkMuted` + pergunta em
  `title1`, composer ("Pergunte à Maré…") e **um** chip suave (`s1`, texto
  `ink`, nunca `accent`). Saudação, chip e cena sorteados por visita. Em
  volta, a **maré em pixels** (`PixelTide`, ref. Inspora "shark ascii
  animation"): bichos do mar em mosaico de células de 5 px com dither Bayer
  4×4, cinza do `ink` com toque `piscina`, nadando pelas bordas e sumindo
  perto do texto — tartaruga, cardume, arraia ou jangada. **Sem tubarão**
  (em Boa Viagem é aviso de perigo). Reduce Motion = quadro parado; o
  ticker morre no primeiro envio. Mapa com pontinhos apagados da curadoria
  (`ghostSpots`) até haver pins. No primeiro envio o sheet entra deslizando
  até 0.52, **o mapa fica aberto** e os rolês sugeridos caem como pins.
  No topo, ☰ (vidro) no lugar do voltar.
- **Começa na conversa em tela cheia** (com rolês salvos) (sheet a 100%, sem alça, raio 0,
  cabeçalho `☰ · Maré · ⋯`). O mapa não aparece até a pessoa pedir.
  O ☰ (`TravelIcons.sidebar`, "Conversas") substitui o voltar **só onde o
  voltar saía da tela**; no mapa, o voltar volta pra conversa.
- Mapa abre por: menu ⋯ → "Ver no mapa", botão "Ver no mapa" (prévia do
  roteiro, card do rolê) ou pedindo ao agente ("me mostra no mapa").
- Transição: o sheet desce até o detent médio (0.52), o raio cresce até 36,
  a alça aparece, o cabeçalho sólido dá lugar aos botões de vidro (voltar,
  ⋯) — mesmas posições, continuidade.
- Volta: botão voltar no mapa, ou arrastar o sheet até o topo.
- Detents sobre o mapa: 0.2 / 0.52 / 0.92. Card do rolê e roteiro completo
  abrem dentro do sheet (0.92 no mapa), sem empilhar sheets.

## Gaveta de conversas (☰)

Ref. ChatGPT, no nosso sistema (`ConversationDrawer`):
- A página **desliza pra direita** (gaveta = min(82% da tela, 320)), a
  gaveta entra com parallax curto, **cantos da página arredondados**
  (crescem até 36, também no modo leve — ref. ChatGPT) e um **véu preto
  12%** cobre a página. **Sem sombra.** Recorte só enquanto a gaveta está
  aberta. Tocar no véu, arrastar pra esquerda ou o voltar do sistema
  fecham.
- Gaveta em `s0`: "Maré" em `title2` na altura do cabeçalho (44); linhas
  **Explorar, Salvos e Perfil** (mesmos ícones e rótulos da tab bar), que
  saem do agente e abrem a home naquela aba; `SectionHeader` "Fixadas" e
  "Recentes"; linhas de 48 **só texto**, 1 linha com reticências, sem
  divisores; aberta/pressionada em `s2` raio 16 (igual ao menu ⋯).
  Recentes vazia: "Nenhuma conversa ainda" em `inkMuted`.
- Rodapé: `PrimaryButton` "Nova conversa" com `pen` (único primário), sobre
  fade `s0` da lista.
- **Não copiar do ChatGPT:** sombra na página, busca, engrenagem e itens de
  navegação que o protótipo não tem (só as abas da home entram).

## Sugestões da abertura

**Sem título, presas logo acima do composer** (`AgentInputBar.above`, 8 px
de respiro), só enquanto a Maré está ociosa e fora do roteiro.
Linha rolável na horizontal (sangra até a borda), cards de 148×76 **sem
fundo, só borda de 1 px** (`ink` 10%), raio `rComposer` 28 — nada de
canto quadrado (ref. Claude, mas mais redondo). Texto em até 2 linhas:
primeira palavra em `subheadStrong` `ink`, resto em `subhead` `inkMuted`.
Todos iguais, nenhum em `accent`.

## Sheets modais (todos)

Barra iOS (`SheetBar`): título centralizado e X em círculo à direita (36
visível, alvo 44); sem alça. Vale pra corrida, limites e conectores (no
escuro, X com `fg` 10%). Listas de escolha: lista segmentada (abaixo);
item selecionado vira pílula (raio = meia altura) além do tint, sem sombra.

## Menu ⋯

Popover iOS ancorado no canto superior direito: superfície `s1` raio 22,
padding 6, linhas de 48 com rótulo à esquerda e ícone à direita, sem
divisores, linha pressionada em `s2` raio 16. Véu preto 12% atrás (figura-
fundo sem sombra). Itens curtos: "Ver no mapa", "Ver roteiro", "Conectar
agenda"/"Agenda conectada", "Seus limites".

## Botões

- `PrimaryButton`: fundo `accent`, texto branco. `SecondaryButton`: fundo
  `s2`, texto e ícone `ink` (neutro, nunca azul). Altura 48, raio 12,
  largura total.
- Dois botões: empilhados, primário embaixo. Nunca lado a lado.
- Botões de ícone no composer: ghost (sem fundo); só o enviar tem fundo
  neutro secundário.
- Sem ícone de brilho/varinha em botão de assinatura ou de IA.

## Composer

Compacto (ref. Claude): campo em `s1` raio 28, **sem borda**, placeholder
curto ("Peça um ajuste à Maré…"), anexar e microfone ghost, anel de uso
(20 px em alvo de 40) ao lado do enviar. **Nada embaixo do composer** —
nem nota, nem chip (sugestões vêm antes dele).

## Sheet "Seus limites"

Título "Seus limites". Seção "Semanal" num card `s1` raio 24: "9 de 20
mensagens" + %, barra de 8 px com trilho visível (`ink` 10%) para comparar,
"Reinicia segunda, 00h". Anel/barra ficam amarelos ≥75% e vermelhos ≥90%.
Plano grátis: card do Maré+ **sempre escuro** (paleta dark forçada só no
card), aurora da marca (azul + tiffany) nascendo do topo com véu escuro
embaixo, `MareMark` 20 + "Maré+", benefícios **escritos numa frase** em
`title3` (sem lista, sem check) e um único botão secundário com o preço:
"Assinar por R$ 14,90/mês". Sem pílula "PLUS" colorida, sem brilhinho.
Sem texto "restam X".

## Pensamento do agente

Linha do tempo de passos (linhas de 24, shimmer no passo ativo); no pedido
de roteiro, visão de agente: cursor recolhe rolês do catálogo para uma
pasta. Ao terminar vira "Pensou por Xs", recolhível. Bloco-resumo azul no
topo da conversa com rostos de quem indicou e metadados com ícone, sem
bolinhas separadoras.

## Card do rolê

- Fotos principais: abrem em tela cheia (viewer com zoom, arrastar fecha,
  crédito só ali). Contador aparece só depois que a pessoa desliza; dots
  alinhados com ele.
- Carrossel de fotos estilo M3 Expressive (`CarouselView.weighted`), sem
  contagem.
- Selo de curadoria só uma vez, em "Selo e entorno"; "Rolê seguro" separado
  dos checks; lista agrupada Apple (ícone à parte, divisor recuado).
- **Linhas de lista agrupada = Ajustes do iPhone, sem quadrado:** glifo
  20 em `ink`, centrado na linha numa coluna de 30, sem fundo; divisor de
  1 pixel físico começando no texto. Vale pra "Bom saber" (melhor horário,
  quanto custa — rótulo pequeno em cima, valor embaixo), "Rolê seguro" e
  os checks do entorno.
- Dicas (o que fazer, melhor horário, quanto custa) em cards com ícone, em
  rolagem horizontal com fade nas bordas.
- Vídeos curtos em linha 9:16; o terceiro corta na borda indicando que há
  mais. Ícone de compartilhar em outline (coesão da seção).
- CTA: já no roteiro → só "Ver no mapa"; senão "Ver no mapa" em cima e
  "Adicionar ao roteiro" (primário) embaixo.
- Ao rolar: botão voltar flutua (vidro), conteúdo some sob ele com fade e o
  título transita pro centro com fade — só quando rola.

## Player de vídeos curtos

Sem rótulo "prévia" nem legenda técnica. Layout Reels: progresso segmentado no topo + pausar/som/fechar; @, origem e
legenda embaixo à esquerda; ações à direita. Expande a partir do tile
tocado e encolhe de volta ao fechar (botão, arrastar, fim da fila).

## Roteiro

Prévia na conversa: 3 primeiras paradas + "Ver no mapa" + "Ver roteiro
completo". Extras pagos em carrossel de cards com preço e botão "+".

Roteiro completo:
- **Entrada:** grade da semana 9h–24h compacta (cabe inteira), dias no
  topo da grade, eventos na cor do tipo (`TravelCategoryTones`). Pinça
  (toque/trackpad) e ctrl+rolagem dão zoom na altura da hora (22–84),
  como no Google Agenda; o bloco mostra mais conforme cresce.
- **Dia escolhido:** a grade recolhe e entra o guia do dia (cards em
  cascata): foto em selo postal (picote), hora na cor do tipo, nome em
  Oswald, dica (`whatToDo`), melhor horário e até 3 vídeos curtos; entre
  os cards, trajeto (a pé/carro + tempo). Ref.: Inspora "travel app".
- **Cabeçalho fixo:** voltar (semana ← dia ← conversa), título "Roteiro",
  "Editar" em vidro que vira "Concluir"; editando, cada card ganha "−"
  vermelho e sai recolhendo.
- **Troca de dias = segmented do iPhone** (`PillSegmented`), largura total
  no topo do conteúdo do guia: trilho `s2`, indicador `s1`, texto neutro —
  sem vidro, sem flutuar, sem azul. O guia arrasta de lado (sexta → sábado →
  domingo, resiste nas pontas) e o indicador acompanha o dedo; tocar num
  dia desliza o guia do lado certo.
- **Composer escondido:** só a pílula "Pedir ajuste" (vidro + símbolo);
  tocar abre o composer já focado.

## Visão de agente (pensando)

Passo "Recolhendo": cursor leva fotos do catálogo pra uma **pasta
skeuomórfica** (azul da marca, aba, fotos impressas aparecendo, frente que
inclina ao receber). Passo "Agrupando": a grade vira mini calendário
Sex/Sáb/Dom e o cursor tira cada rolê da pasta e encaixa no horário real.

## Extra de transfer (escolha da corrida)

- O "+" do transfer não adiciona direto: abre o sheet "Escolha a corrida"
  (`ride_sheet.dart`) com **uma lista só** das categorias da 99 e da Uber,
  ordenada por preço; a mais em conta no topo, pré-selecionada, com selo
  pílula `accent` "Mais em conta". Ref. Mobbin: Uber + Gojek.
- **Lista segmentada (M3 Expressive):** cada opção é um tile `s1` de 64
  separado por 2 (`segmentGap`, o fundo aparece entre eles), cantos de
  fora 24 (primeiro em cima, último embaixo) e cantos entre itens 8.
  Tiles na margem 12; texto solto a 24, alinhado com o conteúdo dos tiles.
  Use esse padrão para listas de escolha em sheet.
- Tile: ícone do app (`ConnectorTile` 36), nome + descrição, preço
  tabular à direita; selecionado = fundo `accentSoft` (sem radio, sem
  divisor).
- Um primário "Adicionar {categoria}". Legenda: preço estimado + cancelamento.
- No card: antes só o menor preço (sem "a partir de"); depois
  "Sáb, 23h30, UberX" e o preço escolhido. Check remove.

## Sheet de conectores

Escuro, aurora no rodapé. Lista: Google Agenda (Recomendado, conecta pelo
botão principal) + Google Maps, Uber e 99, cada um conectando **na própria
linha**: pílula "Conectar" (`fg` 10%, 32, alvo 44) → girando → só o
check, alinhado à direita (sem rótulo "Conectado"). Detalhe de cada app
curto (≈20 caracteres) pra caber ao lado da pílula.

## Mapa

Desenhado (CustomPainter), sem tiles nem marca d'água, monocromático.
Pins estilo Google em `inverse`, selecionado em `accent`, roteiro com
números e rota azul. Controles de vidro (recentrar, camadas) somem quando o
sheet passa de 0.7.

## Fotos e pessoas

Fotos reais com licença livre (Wikimedia Commons) em `assets/images/roles/`
com `CREDITS.md`; rostos em `assets/images/people/`. Crédito só no viewer.

## Explorar (home)

- **Topo:** pílula de busca `s1` (56, raio 28: lupa + "Inicie sua
  pesquisa" centralizados, ref. Airbnb) e, à direita, botão circular `s1` 56 com `MareMark` que
  abre o agente como página separada (fade + escala do canto). O agente
  **não é aba**. Conteúdo rola sob `ProgressiveBlurTop`.
- **Busca compacta ao rolar** (ref. busca compacta do iOS): rolando pra
  baixo, a pílula encolhe (56 → 44) pra só lupa + "Pesquisar"
  (`calloutStrong`), com largura do conteúdo e **centrada na tela inteira**
  — ignora o botão da Maré à direita. Maré vai junto (56 → 44). Rolando pra
  cima ou no topo, volta. Mesmo controle da tab bar: tudo anda junto.
- Sem saudação (o designer tirou): logo abaixo da busca, título de seção "Explore rolês" e as categorias em carrossel (cards 116×148,
  raio 24); seções curtas (até 5) em carrossel com título `title3`. A
  seção da hora vem primeiro. Nada de feed infinito.
- **Card do rolê:** foto (raio 24, Hero até o detalhe) com salvar em frost
  36; nome em Oswald; bairro e preço (ou "a X km do hotel"); avatar 20 +
  "Indicado por Nome" ("Seu Zé", "Dona X" inteiros); motivo em 1–2 linhas.
- **Tab bar** (ref. Yelp): pílula de Liquid Glass 64 (raio 32, padding 6),
  3 itens ícone regular + rótulo (Explorar, Salvos, Perfil); ativo com
  pílula de tint sólido `ink` 8% (escuro 14%) que desliza na mola do
  segmented. **Arrastável** (iOS 26/27): a pílula segue o dedo, cresce 6%
  enquanto segura, tique de haptic ao cruzar aba, encaixa ao soltar
  projetando a velocidade. Vidro com **véu claro** por cima (branco 58% no
  claro, `s1` 42% no escuro). Atrás dela, **scroll edge effect** soft:
  `ProgressiveBlurBottom` (desfoque progressivo + véu `s0` subindo do
  rodapé), no fundo amostrado pelo vidro. Recolhe ao rolar pra baixo
  **saindo inteira da tela, e o blur do rodapé desce junto** (mesma curva,
  320 ms); volta ao rolar pra cima. Troca de aba em fade-through (opacidade + escala 0.98,
  220 ms).

- **Vídeos curtos** (ref. Shorts, D-29): prateleira logo depois da seção
  da hora, tiles 9:16 de 136 (raio 24), legenda em `footnoteStrong` branco
  sobre véu escuro + nome do rolê. Tocar abre o feed vertical em tela
  cheia (`ShortsFeedPage`): "vídeo" = foto com Ken Burns, tocar pausa,
  progresso fino no pé, quem indicou + @ + legenda + pílula frost do rolê
  à esquerda; salvar e compartilhar à direita; som e X no topo (o arrastar
  vertical é da fila, não fecha). **Fila finita**: depois do último vem a
  página de fim — `MareMark` com duas ondas `piscina` se abrindo (uma vez),
  haptic leve, "Você viu tudo por hoje" + "Se cuida e bom rolê." e o
  frost "Voltar pro Explorar". Nunca "carregar mais".

## Salvos (pastas de viagem, ref. Pinterest)

- **Salvar = sheet "Salvar em"** (depois da conta rápida, se não tiver):
  "Suas viagens" em lista segmentada (tile 72, capa 56 raio 12, nome em
  `headline`, contagem), por último "Nova viagem" (tile `accent` com +),
  que vira o passo do nome no mesmo sheet (campo `s2` 52, "Voltar" à
  esquerda, primário "Criar e salvar"). Já salvo: o toque tira de todas
  as pastas ("Tirado de …").
- **Aba:** "Salvos" + botão + (nova viagem); grade de 2 colunas com
  **capa-mosaico** (1 foto grande à esquerda + 2 pequenas, gap 2, raio
  24), nome e "N rolês, N dias".
- **Pasta:** voltar no cabeçalho, nome em `title1`, meta com ícone
  (rolês, dias); dias como seções em lista segmentada `s1` (capa 56,
  "Sexta, 14 nov", contagem, chevron); "Sem dia" em grade 4:5. Barra de
  vidro flutuante (pílula 64 da tab bar) com "Organizar" e "Organizar com
  a Maré". Organizando: toque escolhe (anel `accent` 1,5 + check no
  canto), "Concluir" no cabeçalho, primário "Mover pra um dia" → sheet
  "Mover pra" (dias, "Sem dia", "Novo dia").

## Pontos e recompensas (ref. Google Pay)

- **Perfil:** card `s1` raio 24 "Seus pontos" com o saldo em `title1`,
  "Troque por cupons", presente e chevron, sem bolinha atrás do ícone.
- **Página "Pontos":** saldo grande (56, tabular, conta animando) +
  "pontos"; "Trocar por" em grade 2 colunas de cards quadrados (exceção
  de cor 3 da SKILL); selo pílula `s1` no canto: "Novo", "Faltam N" com
  cadeado (card cinza) ou "Trocado" com check. Histórico embaixo.
- **Sheet do cupom:** só o X; o card grande (16:10), título `title3`,
  regra em uma linha, validade e custo com ícone. Antes de trocar: um
  primário "Trocar por N pontos" (desligado com "Faltam N pontos"). Ao
  trocar, haptic e o card **vira** (rotação Y) e mostra o código
  (`title1` espaçado, picote de ticket); entra o **botão segmentado**
  "Copiar código" (`accent`; vira "Copiado" com check por 1,6 s) |
  "Abrir na 99"/"Usar no transfer" (`s2`).

## Busca guiada e filtros (ref. Airbnb, no nosso sistema)

- Tela cheia; a pílula da home voa até o card "Onde?" (Hero do fundo).
  Barra: "Limpar" (texto) à esquerda, X à direita (`SheetBar.leading`).
- **Sanfona** de cards `s1` raio 24: aberto mostra a pergunta em `title1`
  e chips; fechado, rótulo à esquerda e valor à direita (linha de 60).
  Escolha única avança sozinha pro próximo card (220 ms). Ordem: Onde?,
  Quando?, Com quem?, Que tipo?. Rodapé: só o primário "Buscar".
- **Chip:** pílula 40, padding 14/14. Dentro de card: contorno `ink` 12%
  sem fundo, selecionado contorno `accent` 1,5. Solto no fundo: `s1`,
  selecionado com anel `accent` 1,5. Chip de categoria leva o ícone SVG em `ink`.
- **Tiles de escolha em card** (mês no "Flexível", "Foi bom/Não curti"):
  mesmo contorno dos chips, raio 12, ícone `ink` em cima e texto embaixo.
- **Quando?:** abas "Datas | Flexível" (`PillSegmented`). Datas =
  calendário de intervalo (dias da semana fixos, meses rolando, passado
  riscado, círculo `accent` nas pontas, faixa `accentSoft` no meio) e
  chips de folga ±1/±2. Flexível = duração em chips + cards de mês.
- **Onde?:** campo de busca `s2` raio 12 (52) com lupa; vazio mostra
  sugestões com ilustração de traço em tile 56 tingido; digitando, pino +
  trecho buscado em negrito.
- **Vazio da busca:** ocupa a tela. No centro: ilustração de traço em
  círculo `accentSoft` (mapa + pino com X, `accent`), título `title2` e
  uma linha `inkMuted`, tudo centralizado. Embaixo, na zona do polegar e a
  40 da borda: opções pra afrouxar a busca (contorno, rótulo + quantos
  rolês traria, seta), só as que trazem algum rolê, e o secundário "Mudar
  a busca". Nunca completa com rolê de fora da base (D-07).
- **Resultados:** três containers `s1` de 56, separados por 8: voltar
  (círculo), resumo da busca (pílula raio 28, reabre a busca) e filtrar
  (círculo, contador `accent`); "N rolês" em `title1` + "Pra ir com…"; lista curta.
  Vazio diz que a base curada não cobre (D-07) e oferece um secundário.
- **Filtros** (sheet `s0` raio 36), seções separadas por 40:
  - "Pra você": tiles 104 (raio 24, padding 16/18), ícone regular 20
    `inkMuted`, rótulo até 2 linhas; selecionado branco + anel `accent`.
  - **Período = arco do dia** (`DayArcPicker`, ref. card de nascer/pôr do
    sol): card com cúpula e arco; arrasta o astro (manhã à esquerda,
    tarde no alto, noite à direita). **Cada período tem um céu próprio**
    em gradiente vertical (`DayArcTones`), igual nos dois temas, com
    contraste no texto: manhã pêssego (texto marrom-escuro, sol laranja),
    tarde azul vivo (texto branco, sol amarelo), noite azul-tinta (texto
    branco, lua). Nunca o card cinza claro com brilho fraco: as cores se
    misturavam. Sol e lua **preenchidos** (`sunSolid`/`moonSolid`).
    Solta → encaixa no período mais perto (mola 420/32), haptic ao cruzar.
    Rótulos no chão tocáveis; "Qualquer" no topo limpa.
  - **Preço por pessoa = histograma + faixa** (`PriceRangePicker`, ref.
    Airbnb): barras dos rolês por preço (R$ 5 por barra, até R$ 60+) em
    `accent` dentro da faixa e cinza fora; range slider na base (polegar
    `s1` com anel fino, sem sombra); mínimo e máximo em pílulas `s1`.
  - Chips de tipo. Aplica ao vivo; primário "Mostrar N rolês" com o número
    animando. Sem filtro de segurança (Q-10).

