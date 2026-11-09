# Padrões de componente e fluxo

## Fluxo da tela

- Abertura da conversa: bloco-resumo azul e, logo abaixo, só 3 sugestões
  de maior valor (organizar, noite com as amigas, perto do hotel).
  Sem carrossel de salvos nem outros cards ali (polui); eles entram quando
  o agente responde.
- Aurora (`Aurora`, azul `accent` + `piscina`) atrás do composer, presa ao
  rodapé, **só enquanto nada foi enviado**. Na primeira mensagem se esvai
  devagar e desliga o ticker. Tem que aparecer no claro também
  (intensidade 0.6 claro / 0.8 escuro). Fica por baixo de tudo — nunca
  sobre o composer nem entre bloco e sugestões.
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
  até 0.52, **o mapa fica aberto** e os rolês sugeridos caem como pins;
  voltar na abertura sai da tela.
- **Começa na conversa em tela cheia** (com rolês salvos) (sheet a 100%, sem alça, raio 0,
  cabeçalho `voltar · Maré · ⋯`). O mapa não aparece até a pessoa pedir.
- Mapa abre por: menu ⋯ → "Ver no mapa", botão "Ver no mapa" (prévia do
  roteiro, card do rolê) ou pedindo ao agente ("me mostra no mapa").
- Transição: o sheet desce até o detent médio (0.52), o raio cresce até 36,
  a alça aparece, o cabeçalho sólido dá lugar aos botões de vidro (voltar,
  ⋯) — mesmas posições, continuidade.
- Volta: botão voltar no mapa, ou arrastar o sheet até o topo.
- Detents sobre o mapa: 0.2 / 0.52 / 0.92. Card do rolê e roteiro completo
  abrem dentro do sheet (0.92 no mapa), sem empilhar sheets.

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
