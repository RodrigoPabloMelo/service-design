# Direção do pitch da Coral

> **O que vale neste pitch, por cima do guia abaixo** (decidido com o Rodrigo em 2026-11-24):
>
> - **Sem som.** Ignore a seção "Som", a tecla M e a linha "Som" das tabelas de controles. Nada de Web Audio.
> - **Tema:** claro por padrão, com **slides brancos** (`#fff`) e a tinta do app; L troca tudo para o escuro (`#000`).
>   As fotos e o final em shader são iguais nos dois.
> - **Cor:** o **azul do app** (`#006FD6`, texto `#0A62C2` no claro e `#6AB0FF` no escuro, da skill `mare-design`) é o
>   acento. O coral aparece só como luz secundária no brilho. Identidade da marca segue em aberto (Q-26).
> - **Fonte:** só as do app. Aqui, **Plus Jakarta Sans** (com a itálica dela para a palavra-chave). **Nada de fonte
>   serifada ou script de fora da marca** (o app tem Jakarta, Oswald e Inter).
> - **Formato:** HTML + CSS + JS puro em `pitch/index.html`, publicado no mesmo deploy do protótipo em `/pitch`
>   (`vercel.json` + `prototype/app/tool/vercel_build.sh`). Exceção ao arquivo único: fotos em `pitch/img/` e vídeos
>   em `pitch/video/` (créditos em `CREDITS.md` de cada pasta).
> - **Texto na tela:** só o que o Rodrigo mandar pôr. O roteiro do pitch é contexto da narrativa, não copy.
> - **Nomes:** Coral é o serviço; Maré é a assistente de IA do app ([D-32](../docs/decisoes.md)).
> - **Movimento do texto** (pedido: "mais criativa mas que seja harmônico", refs Bleap, Google, Shapes).
>   **Tentativa atual, esperando a reação do Rodrigo:**
>   - Perguntas sobre a foto em P&B: palavra por palavra, saindo do desfoque (não mexer).
>   - Frases centrais: a frase **se monta palavra por palavra, linha por linha, sempre centrada**. Cada palavra nova
>     pousa num arco curto saindo do desfoque e as que já estão deslizam para abrir espaço (FLIP), com a mesma curva.
>   - Palavra-chave: as letras sobem uma a uma e depois ela ganha peso (300 → 500); nos "E se" acende em azul.
>   - Marca final: as letras sobem de uma fresta.
>   - Testadas e trocadas por embolar ou ficar soltas: palavras esticadas vindo dos lados e letras espalhadas.
> - **Marca:** logo oficial em `img/coral.svg` (enviado pelo Rodrigo em 2026-11-24; o "o" é um pino de mapa). É a máscara das texturas no slide 8, substitui o nome escrito na proposta de valor e fecha o pitch no final.
> - **Universo visual:** os desenhos de pincel das categorias do app (`img/ilustracoes/`), sempre na cor da categoria (`ExploreCategoryTones`). Hoje no "Apresentamos".
> - **Créditos do Magnific:** nunca gastar sem o Rodrigo aprovar. Antes, mostrar o saldo e a estimativa (`simulate_cost`).
> - Preview local: `python3 -m http.server 8090` na raiz do repo (config `pitch-preview` no `.claude/launch.json`) e
>   abrir `http://127.0.0.1:8090/pitch/`. Ensaio direto: `?momento=N&passo=N` (e `&tema=escuro`).
>
> **Roteiro atual**
>
> | Momento | O que acontece | Passos |
> | --- | --- | --- |
> | 1 | Branco | 0 |
> | 2 | Foto 1 (`rua.jpg`), empurrão lento de câmera | 0 |
> | 3 | Foto 2 (`calcada.jpg`); no passo 1 fica P&B e as 3 perguntas chegam sozinhas em cascata | 1 |
> | 4 | "Nem toda mulher que viaja sozinha se sente *livre* para experimentar o novo." | 0 |
> | 5 | Tambor 3D gira sozinho a cada 3 s entre Segurança, Confiança e Descoberta (↓ e ↑ giram na mão), frase de cada uma embaixo, brilho mais forte e circulando | 0 |
> | 6 | "E se sentir-se mais segura…" e, no passo 1, "E se a liberdade de explorar…" | 1 |
> | (…) | Espaço reservado: o Rodrigo marcou "…." entre os "E se" e a apresentação da Coral | — |
> | 7 | "Apresentamos": os desenhos das categorias do app (cultura, café, arte, história, museu, restaurantes), cada um na sua cor, nascem juntos no meio e se abrem girando em espiral; a palavra se revela letra por letra; eles ficam orbitando em volta, seguindo o mouse em camadas | 0 |
> | 8 | Apresentamos: Coral. **Entra por uma transição em tinta** (~4,6 s): manchas orgânicas (`img/aquarela/mancha.png`, tratada da imagem do Rodrigo) caem aos poucos, uma de cada vez, do centro para fora, e cada uma é uma janela para o slide 8 (vídeo do mar em tela cheia com o logo branco), que se espalha do miolo para as franjas; o "Apresentamos", com o branco e a luz, fica intacto até ser todo coberto; no fim o resto se desfaz num ruído. Nada é pintado por cima. Técnica: um canvas WebGL por cima do 7 desenha o próprio 8 (vídeo como textura e marca branca) só dentro da tinta; o 8 de verdade assume no mesmo lugar no fim, com um cross-fade curto do canvas. **Não voltar a usar `mask-image` com data URL a cada quadro**: no Chrome a imagem não decodificava a tempo, o 8 não aparecia e o segundo clique pulava o slide. Clicar durante a tinta só apressa a tinta (cobre em ~0,7 s) e fica no 8. Não usar a textura de respingos: ela vira uma caixa. A cada 1,5 s troca a textura (mar, folhagem, areia, entardecer) e alterna marca vazada e marca branca sobre o vídeo | 0 |
> | 9 | Proposta de valor, completa: cada parágrafo (o quê, para quem, para quê, como) entra inteiro, subindo do desfoque, um depois do outro a cada 1,5 s; clicar adianta; ← tira o último e para o automático. **Texto é rascunho** (de `docs/visao-do-servico.md` e `conceito-do-servico.md`: D-03, D-05, D-06), esperando o OK do Rodrigo; se aprovado, atualizar a proposta de valor em `visao-do-servico.md` | 3 |
> | 10 | Dado, em texto (não imagem): "96,7%" conta de 0 até o valor em algarismos tabulares (Jakarta, `tnum`), "das viagens dos brasileiros são dentro do país" chega do desfoque e "(IBGE, 2024)" embaixo, menor. Fonte também em `docs/visao-do-servico.md` | 0 |
> | 11 | Mapa do sistema (de `diagrams/ecossistema.html` e `docs/ecossistema.md`), redesenhado nas cores e na fonte do pitch: zonas, 7 atores e 11 fluxos; o azul marca o dinheiro. Ao entrar, os atores aparecem e os fluxos se desenham sozinhos (~4 s). Mouse num ator ou num item da legenda destaca os fluxos dele. O Grupo (A-2, quem faz a curadoria) aparece com a marca da Coral | 0 |
> | 12 | Blueprint (de `diagrams/blueprint.html`, v2, D-23), montado no script a partir do mesmo DATA. Passo 0: inteiro na tela. Passos 1 a 3: uma faixa por vez em leitura, com fases e etapas presas no topo e o resto apagado: jornada da viajante (ações, pontos de contato, gratuito × pago); linha de frente e bastidores; suporte e parceiros. Mouse numa coluna acende a etapa. "Agente" virou Maré (D-32); o que termina em "?" é questão em aberto e fica tracejado. Mudou o blueprint no repo, mude o DATA aqui | 3 |
> | 13 | Transição: "Vamos acompanhar *Camila* em uma viagem para Recife." Mouse em "Camila": a foto dela (`img/camila.webp`) aparece acima do mouse e vai atrás dele, até sair | 0 |
> | 14 | Camila (P-CAMILA): foto oval do Rodrigo nasce de baixo para cima e boia; "Camila" sobe letra por letra com "28 anos" ao lado; em cascata, do desfoque: "*Prefere* viajar sozinha.", "*Gosta de* conhecer a cidade de maneira mais próxima da rotina local" e "*e* ter autonomia para decidir horários e roteiro, sentindo que tem as informações necessárias e suficientes." (texto do Rodrigo; conectores em tinta secundária, palavras-chave em azul) | 0 |
> | 15 | Storyboard da Camila (P-CAMILA, sozinha, 3 dias em Recife): 10 quadros em tela cheia (`img/storyboard/01–10.jpg`), um por clique, legenda num bloco preto na largura toda (**legendas são rascunho**). Nos quadros 02–07 e 10 os celulares são prints reais do protótipo na moldura iOS do design canvas, sobre o fundo desfocado progressivamente (ver `img/CREDITS.md`); os devices ficam dentro da faixa que aparece numa tela 16:9. Busca → explorar → detalhe → selo e entorno → salvar → Maré organiza → chuva e troca → motorista → jantar → avaliação | 9 |
> | 16 | Final: logo branco (aparece no lugar, saindo do desfoque; não vem de baixo) sobre cor viva em shader (mar, mata, sol, coral), como a referência do Google. Depois da marca (~2 s), a tagline "Viaje segura. Experimente o novo" entra embaixo, palavra por palavra, saindo do desfoque. Passo 1: marca e tagline sobem e encolhem e aparece no centro o QR do app (`https://coral-services-three.vercel.app/`, raiz que abre na primeira tela), com "Acesse a plataforma" embaixo; clicar no QR abre o app | 1 |

---

# Direção para apresentações cinemáticas interativas

> **Para o Claude que está lendo isto:** este arquivo é a sua direção de estilo, completo em si (não depende de nenhum
> outro arquivo). Ele define uma **linha** de apresentação, não um conceito nem uma marca. Use-o para conduzir a
> conversa (seção 2), montar os tokens com as escolhas da pessoa (seção 4), escolher efeitos do catálogo (seção 6) e
> entregar **sempre num único arquivo**, em HTML (com GSAP quando precisar) ou HTML com React (seção 8). A régua de
> qualidade é a de um site premiado no Awwwards. **Nenhum controle aparece na tela:** eles são explicados no chat,
> numa tabela (seção 8.5). Tudo o que for cor, fonte, tema e conteúdo vem da pessoa; o que vem daqui é o jeito.

---

## 1. A linha, em uma frase

**Uma apresentação que parece um filme que você controla:** tela inteira, sem interface visível, frases curtas que
nascem do desfoque, fundos vivos feitos em shader, uma única cor de acento usada como luz, e cada slide com algo que
se mexe sozinho ou responde ao toque.

### Referência: a estética dos sites do Awwwards

Pense cada momento como a dobra de abertura de um site premiado (Awwwards, FWA, CSS Design Awards), não como um
slide de escritório:

- **Tipografia como imagem:** display gigante, peso leve, às vezes sangrando pela borda da tela; texto revelado por
  máscara, linha a linha.
- **Composição de revista:** assimetria, muito espaço vazio, elementos cortados pela tela, um ponto focal por
  momento.
- **WebGL como matéria:** fundos em shader, partículas, vidro, imagens que distorcem; nada de fundo chapado sem vida.
- **Movimento com peso:** entradas longas com curva exponencial, respostas rápidas ao toque, parallax de camadas,
  transições de cortina entre momentos.
- **Textura:** grão de filme, ruído, vinheta, luz recortada.
- **Cursor como personagem:** reage ao que está embaixo dele, nunca é só a seta do sistema nos momentos de assistir.

### Princípios (valem para qualquer tema)

1. **Zero HUD, zero controle na tela.** Nada de logo fixo, numeração, barra de progresso, rodapé, dica, botão de
   avançar, seta, menu, botão de tema ou de som. A navegação é teclado, clique, roda e passador de slides, e os
   controles são explicados **no chat, numa tabela** (seção 8.5).
2. **Uma frase por momento.** Texto curto e grande, peso leve (200 a 300), uma ideia por tela. Se a frase não cabe
   numa linha em tela larga, corte a frase.
3. **Tudo entra pelo desfoque.** Nada aparece de corte seco: opacidade, desfoque e um deslocamento pequeno, com
   curva de saída longa.
4. **Neutros dominam, o acento é luz.** Uma cor de acento, no máximo duas. Ela marca o que importa (a palavra-chave,
   a ação, o elemento vivo), nunca decora.
5. **Sem bordas.** Superfícies se separam por tom e transparência, não por contorno.
6. **Profundidade percebida.** Camadas, desfoque progressivo e sombra contam o que está perto e o que está longe.
7. **Vivo, mas com motivo.** Cada animação representa algo do conteúdo (um dado chegando, uma ideia se formando).
   Animação decorativa sem significado sai.
8. **Funciona nos dois temas.** Escuro (padrão de palco) e claro, alternáveis por tecla.
9. **Respeita movimento reduzido.** Com `prefers-reduced-motion`, mostra o estado final sem animar.

---

## 2. Como conduzir a conversa

Antes de gerar, faça **no máximo uma rodada de perguntas**, curtas e com opções. Se a pessoa já respondeu algo, não
pergunte de novo. Se ela disser "decide você", use os padrões entre parênteses.

1. **Sobre o quê e para quem?** Tema, público, duração ou número de momentos (padrão: 6 a 8 momentos).
2. **Navegação:** por momentos, como slides (teclado e passador), ou rolagem contínua, como um site em que a
   história anda com a roda (padrão: momentos).
3. **Clima:** cinematográfico escuro, editorial claro, tecnológico, orgânico, institucional sóbrio (padrão:
   cinematográfico escuro, com tema claro disponível).
4. **Cor de acento:** um hex, ou "da minha marca" (pedir o hex), ou deixar sugerir (padrão: um azul violeta saturado).
5. **Neutros:** frios, quentes ou puros (padrão: frios, levemente azulados).
6. **Fonte:** uma família variável com pesos de 200 a 600 (padrão: uma sans geométrica do Google Fonts; sugerir
   duas ou três opções).
7. **Efeitos:** mostrar o catálogo da seção 6 como menu curto e perguntar quais combinam (padrão: escolher um
   efeito de fundo, um efeito de transição e um efeito "herói" por momento).
8. **Som:** com ou sem (padrão: sem, com a tecla M ligando som sintetizado).
9. **HTML ou React?** Os dois saem num arquivo só. Antes de perguntar, cruze os efeitos que a pessoa escolheu com a
   seção 8.1: se tudo funciona bem em HTML, não pergunte, só avise que vai em HTML. Se algum efeito pedido fica
   limitado em HTML, explique a limitação **com o efeito dela como exemplo** e deixe ela escolher (padrão: HTML).

Depois de gerar, peça ajustes no vocabulário da linha ("quer a frase mais lenta?", "troco o fundo de ondas por
partículas?"), e não em termos técnicos.

---

## 3. Estrutura de um deck nessa linha

- **Palco:** um contêiner `position: fixed; inset: 0; overflow: hidden` com o fundo do tema.
- **Momentos (slides):** um por vez na tela. O que sai vai para `opacity 0 + blur(18px) + scale(0.98)`; o que entra
  vem de `opacity 0 + blur(18px) + scale(1.02)`, em cerca de 1,1 s.
- **Passos internos:** cada momento pode ter passos (revelar uma frase, aprofundar um zoom, rolar um carrossel). A
  tecla de avançar consome o próximo passo; na ponta, passa ao momento seguinte. Voltar faz o inverso.
- **Abertura:** o primeiro momento começa no escuro total e "materializa" no primeiro clique. Esse clique também
  libera o áudio, porque o navegador só toca som depois de um gesto.
- **Entrada direta:** `?momento=N` na URL abre direto num momento (para ensaio).

### Controles (só no chat, nunca na tela)

Nenhum botão, seta, menu ou dica aparece na apresentação. Os controles existem no teclado, no clique e na roda, e são
contados à pessoa no chat, na entrega (seção 8.5).

| Tecla | Ação |
| --- | --- |
| → ↓ PageDown espaço Enter | Avança (passadores de slide mandam PageDown/PageUp) |
| ← ↑ PageUp Backspace | Volta |
| F | Tela cheia |
| L | Claro/escuro |
| M | Som |
| Esc | Sai (ou fecha painel aberto) |

Teclas não valem enquanto a pessoa digita num campo. Painéis abertos capturam as setas antes da navegação.

Na **rolagem contínua**, a roda e o trackpad conduzem a história: rolagem suavizada (Lenis), seções fixadas enquanto
a animação delas acontece (ScrollTrigger com `pin` e `scrub`), e as teclas ↓/↑ ainda andam de seção em seção.

### Cursor

Em momentos de "assistir": cursor próprio em anel fino (cerca de 30 px) que segue o mouse com atraso curto, encolhe
no clique e some depois de uns 3 s parado; o clique avança. Em momentos com coisas para tocar: cursor do sistema, e o
clique não avança.

---

## 4. Tokens: preencha com as escolhas da pessoa

Todo valor de cor vem destes tokens. Nenhum componente usa cor crua. O tema vive num atributo do palco.

```css
:root {
  /* Escolhas da pessoa */
  --acento: #5c5cff;            /* a única cor viva */
  --acento-claro: #b7a9ff;      /* o acento clareado, para texto sobre escuro */
  --fonte: "Sua Fonte", system-ui, sans-serif;
  --mono: ui-monospace, "SF Mono", Menlo, monospace;

  /* Tema escuro (padrão) */
  --fundo: #000;
  --texto: #f4f3ff;
  --texto-2: rgb(244 243 255 / 0.62);
  --texto-3: rgb(244 243 255 / 0.38);
  --preenchimento: rgb(255 255 255 / 0.06);
  --preenchimento-forte: rgb(255 255 255 / 0.11);
  --sombra: rgb(0 0 0 / 0.6);

  /* Movimento */
  --ease: cubic-bezier(0.2, 0, 0, 1);          /* interações, ~200 ms */
  --ease-saida: cubic-bezier(0.22, 1, 0.36, 1); /* cenas e entradas, 0,8 a 1,3 s */
}

[data-tema="claro"] {
  --fundo: #f1f2f7;
  --texto: #181a27;
  --texto-2: rgb(24 26 39 / 0.64);
  --texto-3: rgb(24 26 39 / 0.42);
  --preenchimento: rgb(24 26 39 / 0.05);
  --preenchimento-forte: rgb(24 26 39 / 0.09);
  --sombra: rgb(24 26 39 / 0.22);
}
```

### Regras para derivar o resto

- **Fundo suave e tinta forte de qualquer cor** saem por `color-mix`, e assim funcionam nos dois temas:
  `color-mix(in srgb, var(--acento) 16%, transparent)` e
  `color-mix(in srgb, var(--acento) 72%, var(--texto))`.
- **Escuro:** fundo preto absoluto (palco de cinema). Para relevo e sombra aparecerem, superfícies de "material"
  ficam um passo acima do preto, nunca no preto puro.
- **Claro:** um cinza muito leve como fundo, superfícies quase brancas com sombra longa e suave.
- **Cores de estado** (sucesso, aviso, erro, informação), se houver, só para estado e sempre com ícone junto.
- **Proporção:** neutros ocupam quase tudo; o acento aparece em pontos.

### Tipografia

- Uma família variável. Pesos: 200 para frases de palco, 300 para corpo, 400/500 para títulos de cartão.
- Escala por razão áurea (φ = 1,618) a partir do corpo: legenda 1/φ, corpo 1, subtítulo φ, título φ², display φ³.
- Frases de palco: `font-size: clamp(2rem, 4vw, 5rem)`, `line-height: 1.05`, `letter-spacing: -0.035em`.
- Dados, números e código em monoespaçada com `font-variant-numeric: tabular-nums`.
- Palavra-chave de uma frase pode ganhar o acento com um brilho suave (`text-shadow` na cor do acento com
  transparência).

---

## 5. Movimento

| Nome | Valor | Uso |
| --- | --- | --- |
| Padrão | `cubic-bezier(0.2, 0, 0, 1)` | Hover, toque, estado, cerca de 200 ms |
| Saída | `cubic-bezier(0.22, 1, 0.36, 1)` | Entradas, cenas, trocas, 0,8 a 2 s |
| Expo | `cubic-bezier(0.16, 1, 0.3, 1)` (GSAP `expo.out`) | Revelar texto por máscara, cortinas, display gigante |
| Mola | sem quique, cerca de 0,4 s | Alças, pilhas, contornos que seguem |
| Desfoque | de 18 px a 0 | Troca de estado e entrada de texto |

Padrões que dão a cara da linha:

- **Entrada pelo desfoque:** `opacity 0, blur(18px), translateY(14px)` → limpo. Ao terminar, tire o `filter`
  (filtro parado num ancestral cria camada e quebra desfoques de dentro).
- **Tipografia cinética:** cada palavra entra do desfoque com atraso de 0,12 a 0,16 s entre elas; a frase inteira sai
  pelo desfoque antes da próxima.
- **Cascata:** atraso por índice só para o que já está na tela na entrada do momento; o que chega depois entra sem
  atraso.
- **Texto que "está sendo escrito":** palavras com atraso de cerca de 36 ms cada, entrando de opacidade 0 e blur de
  4 px.
- **Laços só quando visível:** qualquer animação contínua (intervalo, `requestAnimationFrame`, roteiro) roda apenas
  enquanto o elemento está na tela e para ao sair.

---

## 6. Catálogo de efeitos

Ofereça à pessoa por nome e explique em uma linha. Cada item traz o que é, quando usar e como fazer.

### Fundos

| Efeito | O que é | Quando | Como |
| --- | --- | --- | --- |
| **Ondas cromáticas** | Faixas largas e macias de luz escorrendo em diagonal, franja colorida nas bordas, grão de filme | Momentos de abertura de tema, conceito | Fragment shader: soma de senos em diagonal, cada canal RGB lendo a onda levemente deslocado, ruído de grão; baixo contraste |
| **Galáxia de dados** | Partículas em órbita na cor do acento; no miolo, ligadas por filamentos como uma rede neural | Abertura, "dados", "inteligência" | three.js: pontos com órbita analítica + mola de deslocamento pelo cursor; linhas entre vizinhos próximos; bloom só no escuro |
| **Fita de fios de luz** | Muitos fios finos formando uma fita que ondula e torce, cruzando a tela atrás do texto | Transição de ideia, "conexão", "fluxo" | Curva central por soma de senos; N fios espalhados em volta com torção; traço de 1 px aditivo |
| **Brasa de glifos** | Grade de caracteres que acendem e apagam como brasa | "IA escrevendo", código, texto em massa | Shader com atlas de glifos numa textura; brilho por ruído no tempo |
| **Luz recortada** | Feixes granulados que varrem uma superfície, revelando o que tocam | Revelar um documento, destacar achados | Gradientes com grão em `mix-blend-mode: screen` (escuro) ou `multiply` (claro) |

### Elementos herói

| Efeito | O que é | Como |
| --- | --- | --- |
| **Orbe de vidro vivo** | Esfera de vidro com fios espectrais torcendo dentro; representa uma IA ou um sistema | Shader de esfera com refração, dispersão e borda iluminada; fios por senos dentro; reage a "pensando" e "ouvindo" |
| **Pilha de lajes** | Camadas de cor empilhadas em perspectiva, cortadas pela borda da tela | Divs em `transform: rotateX/rotateZ` com sombra caindo na de baixo; vista na altura dos olhos |
| **Leitura que cifra** | Um conteúdo atravessa uma linha vertical e, do outro lado, vira caracteres embaralhados que não param de trocar; só o importante fica legível | Duas cópias idênticas do conteúdo, recortadas com `clip-path: inset()` complementares, mesma animação de translação; o lado "lido" troca caracteres a cada ~85 ms; fonte mono para alinhar coluna por coluna |
| **Quadro com cursor agente** | Um cursor com etiqueta ("pensando…", "ligando provas") liga cartões por curvas, enquanto um painel ao lado narra o passo a passo | Curvas em S saindo perpendiculares das bordas; traço com `pathLength=1` e `stroke-dashoffset` 1 → 0; o cursor anda sobre `getPointAtLength`; roteiro assíncrono cancelável |
| **Linha do tempo que se constrói** | A linha desce, cada ponto nasce e o texto entra; curvas suaves entre níveis | Cada linha da lista desenha o próprio trecho do trilho, com altura fixa, e os trechos emendam sem costura |
| **Zoom semântico** | Um controle de níveis (resumo, essencial, completo) que aprofunda a mesma página | Seções que entram e saem pelo desfoque conforme o nível; o mesmo objeto ganha detalhe (`layoutId`) |

### Transições e superfícies

| Efeito | O que é | Como |
| --- | --- | --- |
| **Blur progressivo** | Bordas que desfocam cada vez mais em direção à saída, em vez de só esmaecer | 6 camadas de `backdrop-filter`, cada uma com o dobro do raio da anterior e uma faixa de `mask-image` própria |
| **Material em relevo** | A tela vira material: elementos cavados (baixo relevo) e um em alto relevo do mesmo material | Cavado: sombra interna em cima e luz na borda de baixo. Alto relevo: luz no topo, aresta embaixo, sombra projetada. Mesmo tom do fundo |
| **Vidro** | Painel que desfoca o que passa atrás | `backdrop-filter: blur()` com fundo translúcido; só em superfícies pequenas |
| **Card que vira painel** | Um cartão cresce até o centro e vira um painel de leitura | Animação de elemento compartilhado; véu desfocado atrás; Esc fecha |
| **Bento lateral** | Grade de cartões de tamanhos diferentes que rola de lado e sai pela borda da tela | Grid com linhas fixas pela altura disponível; roda do mouse vira rolagem horizontal suave; setas andam colunas inteiras |

### Tipografia, composição e cursor (o repertório Awwwards)

| Efeito | O que é | Como |
| --- | --- | --- |
| **Texto revelado por máscara** | Cada linha (ou palavra) sobe de dentro de uma fresta invisível, em cascata | GSAP SplitText em linhas, cada linha dentro de um contêiner com `overflow: hidden`, de `yPercent: 110` a 0 com `expo.out`; sem biblioteca, quebrar em spans à mão |
| **Display sangrando a borda** | Uma palavra gigante cortada pela tela, às vezes correndo devagar como letreiro | `font-size` em `vw`, `white-space: nowrap`; letreiro com duas cópias e `translateX(-50%)` em laço |
| **Cortina entre momentos** | O próximo momento entra por uma máscara que varre a tela | `clip-path: inset()` ou `circle()` animado no momento que entra |
| **Parallax de camadas** | Fundo, meio e frente andam em velocidades diferentes com o mouse ou a rolagem | Deslocamento proporcional à profundidade de cada camada; na rolagem contínua, ScrollTrigger com `scrub` |
| **Imagem que distorce** | Na transição ou no hover, a imagem ondula ou separa em RGB | Plano WebGL com a imagem como textura e um shader de deslocamento (three.js ou WebGL cru) |
| **Cursor com estados** | Cresce sobre o que é clicável, mostra uma palavra ("ver", "arrastar"), inverte as cores sob ele | Elemento fixo movido por interpolação a cada quadro; `mix-blend-mode: difference`; rótulo que entra pelo desfoque |
| **Botão magnético** | O elemento é puxado na direção do cursor quando ele chega perto | Deslocamento proporcional à distância do cursor ao centro, volta com mola |
| **Grão de filme** | Ruído fino e vivo sobre a tela inteira | Canvas ou shader de ruído em sobreposição com opacidade baixa; ou SVG `feTurbulence` |

### Microinterações

Contador que rola só o dígito que muda; pilha de avisos que abre em lista no hover; deslizar para confirmar; pasta
que abre e espalha as folhas; esqueleto que vira valor quando o dado chega. Cada uma com mola curta e sem quique.

### Som (opcional, tecla M)

Tudo sintetizado com Web Audio, sem arquivos: um zumbido grave de fundo, um "woosh" que atravessa a tela, cliques de
vidro quando algo é absorvido, um grave curto na entrada de cada frase e um sino limpo para "achado". Volume baixo;
só toca depois do primeiro clique.

---

## 7. Regras de copy

- Frases curtas e afirmativas. Uma ideia por tela.
- Sem travessão no texto visível; use dois-pontos ou ponto.
- A palavra que carrega a ideia pode levar o acento; só uma por frase.
- Nada de texto de interface na tela (nem "clique para continuar").
- Dados de exemplo coerentes entre si em todos os momentos (mesmos nomes, números e datas).

---

## 8. Formato de entrega

Sempre **um só arquivo**: estrutura, estilos, scripts, shaders (em strings no script), ícones e ilustrações (SVG
inline) e o som (sintetizado no script). Nada de arquivos à parte, pastas de assets ou build. Muda só o motor das
animações de interface: HTML puro ou React com framer-motion.

### 8.1 HTML ou React?

Os sites do Awwwards, em geral, são HTML com GSAP (animação e rolagem), Lenis (rolagem suave) e three.js ou WebGL
cru. Esse é o **padrão** aqui. React com framer-motion entra quando a apresentação tem muitas partes reagindo ao
mesmo estado.

Leia os efeitos que a pessoa pediu e decida:

- **Tudo funciona bem em HTML?** Faça em HTML e não transforme isso em pergunta; avise numa linha.
- **Algum efeito pedido fica limitado em HTML?** Explique em uma ou duas frases usando o efeito que **ela** pediu,
  por exemplo: "o cursor que liga as provas enquanto o painel ao lado narra fica mais estável em React; em HTML eu
  faço com menos passos". Pergunte qual ela prefere. Se escolher HTML, faça mesmo assim, com a aproximação descrita.

**Funciona igual em qualquer formato:** fundos em shader e cenas three.js; entrada e troca de momento pelo
desfoque; tipografia cinética; blur progressivo; material em relevo e vidro; leitura que cifra; linha do tempo e
conectores que se desenham; contador que rola; grão; tema claro e escuro; teclado e passador; som sintetizado.

**Onde muda:**

| Efeito | HTML sem biblioteca | HTML com GSAP | React com framer-motion |
| --- | --- | --- | --- |
| **Card que cresce até virar painel; grade que se reorganiza** | Medir e inverter na mão (FLIP); cantos e texto distorcem no caminho | Bom: plugin Flip | Bom: `layoutId` e `layout` |
| **Texto revelado por máscara, linha a linha** | Possível, quebrando o texto em spans à mão; quebra de linha não acompanha a largura | Melhor: SplitText refaz as linhas ao redimensionar | Possível com SplitText ou à mão |
| **Rolagem coreografada** (seções fixadas, animação presa à roda) | Difícil e propenso a tremer | Melhor: ScrollTrigger + Lenis, o padrão dos sites premiados | Possível (`useScroll`), com menos recursos |
| **Mola física e arraste com inércia** (alça que termina sozinha, contorno que segue com elasticidade) | Escrever a física à mão | Bom: Draggable + InertiaPlugin; molas viram curvas elásticas | Melhor: `spring` e `drag` herdam a velocidade do gesto |
| **Saída animada antes de sair da tela** (navegando rápido) | Timers frágeis, a ordem se perde | Bom com timelines, exige cuidado com o estado | Melhor: `AnimatePresence` espera a saída |
| **Roteiro com muitos estados ligados** (cursor agente que lê, liga e escreve enquanto um painel narra) | Frágil: cada passo atualiza vários lugares à mão | Médio: timelines cuidam do tempo, o estado da tela continua à mão | Melhor: um estado desenha a tela, o roteiro só muda o estado |

**Custo do React num arquivo só:** carrega React, framer-motion e um tradutor de JSX da internet na abertura (alguns
segundos na primeira vez e precisa de internet). GSAP também vem por CDN, mas é leve. Para apresentar sem internet,
prefira HTML sem biblioteca.

### 8.2 HTML

Carregado de fora, sempre com versão fixa: a fonte (Google Fonts), o GSAP e só os plugins usados, o Lenis se houver
rolagem contínua e o three.js se houver 3D. O GSAP é gratuito, plugins inclusos:

```html
<script src="https://cdn.jsdelivr.net/npm/gsap@3.13.0/dist/gsap.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/gsap@3.13.0/dist/SplitText.min.js"></script>     <!-- texto por máscara -->
<script src="https://cdn.jsdelivr.net/npm/gsap@3.13.0/dist/Flip.min.js"></script>          <!-- card que vira painel -->
<script src="https://cdn.jsdelivr.net/npm/gsap@3.13.0/dist/ScrollTrigger.min.js"></script> <!-- rolagem contínua -->
<script src="https://cdn.jsdelivr.net/npm/gsap@3.13.0/dist/Draggable.min.js"></script>     <!-- arraste -->
<script src="https://cdn.jsdelivr.net/npm/gsap@3.13.0/dist/InertiaPlugin.min.js"></script> <!-- inércia -->
<script src="https://cdn.jsdelivr.net/npm/lenis@1.3.4/dist/lenis.min.js"></script>         <!-- rolagem suave -->
<script type="module">import * as THREE from 'https://cdn.jsdelivr.net/npm/three@0.170.0/build/three.module.min.js'</script>
```

Abre com duplo clique em qualquer navegador e funciona como Artifact. Esqueleto mínimo, sem biblioteca:

```html
<body>
  <main id="palco" data-tema="escuro">
    <section class="momento" data-passos="0">…</section>
    <section class="momento" data-passos="2">…</section>
  </main>
  <script>
    const momentos = [...document.querySelectorAll('.momento')]
    let atual = Number(new URLSearchParams(location.search).get('momento') || 1) - 1
    let passo = 0
    function mostrar(i) {
      momentos.forEach((m, j) => m.toggleAttribute('data-ativo', j === i))
      passo = 0
      momentos[i].dispatchEvent(new CustomEvent('entrar'))
    }
    function avancar() {
      const m = momentos[atual]
      if (passo < Number(m.dataset.passos)) { passo++; m.dispatchEvent(new CustomEvent('passo', { detail: passo })); return }
      if (atual < momentos.length - 1) mostrar(++atual)
    }
    function voltar() { if (atual > 0) mostrar(--atual) }
    addEventListener('keydown', (e) => {
      if (e.target.closest('input, textarea, [contenteditable="true"]')) return
      if (['ArrowRight', 'ArrowDown', 'PageDown', ' ', 'Enter'].includes(e.key)) { e.preventDefault(); avancar() }
      else if (['ArrowLeft', 'ArrowUp', 'PageUp', 'Backspace'].includes(e.key)) { e.preventDefault(); voltar() }
      else if (e.key === 'f') document.fullscreenElement ? document.exitFullscreen() : document.documentElement.requestFullscreen()
      else if (e.key === 'l') palco.dataset.tema = palco.dataset.tema === 'claro' ? 'escuro' : 'claro'
    })
    mostrar(atual)
  </script>
</body>
```

```css
#palco { position: fixed; inset: 0; overflow: hidden; background: var(--fundo); color: var(--texto); font-family: var(--fonte); transition: background-color 1.4s var(--ease), color 1.4s var(--ease); }
.momento { position: absolute; inset: 0; opacity: 0; filter: blur(18px); transform: scale(1.02); pointer-events: none; transition: opacity 1.1s var(--ease-saida), filter 1.1s var(--ease-saida), transform 1.1s var(--ease-saida); }
.momento[data-ativo] { opacity: 1; filter: blur(0); transform: none; pointer-events: auto; }
@media (prefers-reduced-motion: reduce) { .momento { transition: opacity 0.3s; filter: none; transform: none; } }
```

### 8.3 React num arquivo só

React, framer-motion e o tradutor de JSX vêm por CDN com versão fixa, num `importmap`. Na versão React, `.momento` só
posiciona (`position: absolute; inset: 0`); opacidade, desfoque e escala são do framer. Para passos internos, cada
momento expõe `{ avancar(): boolean, voltar(): boolean }` como na seção 3.

```html
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <style>/* tokens da seção 4 e estilos */</style>
  <script type="importmap">
  {
    "imports": {
      "react": "https://esm.sh/react@18.3.1",
      "react-dom/client": "https://esm.sh/react-dom@18.3.1/client",
      "framer-motion": "https://esm.sh/framer-motion@11.11.17?deps=react@18.3.1,react-dom@18.3.1"
    }
  }
  </script>
  <script src="https://unpkg.com/@babel/standalone@7.26.4/babel.min.js"></script>
</head>
<body>
  <div id="raiz"></div>
  <script type="text/babel" data-type="module" data-presets="react">
    import React, { useEffect, useState } from 'react'
    import { createRoot } from 'react-dom/client'
    import { AnimatePresence, MotionConfig, motion } from 'framer-motion'

    const MOMENTOS = [
      () => <h1 className="frase">Primeira frase.</h1>,
      () => <h1 className="frase">Segunda frase.</h1>,
    ]
    const SAIDA = [0.22, 1, 0.36, 1]

    function Deck() {
      const [atual, setAtual] = useState(Number(new URLSearchParams(location.search).get('momento') || 1) - 1)
      const [tema, setTema] = useState('escuro')
      useEffect(() => {
        const tecla = (e) => {
          if (e.target.closest('input, textarea, [contenteditable="true"]')) return
          if (['ArrowRight', 'ArrowDown', 'PageDown', ' ', 'Enter'].includes(e.key)) setAtual((i) => Math.min(MOMENTOS.length - 1, i + 1))
          else if (['ArrowLeft', 'ArrowUp', 'PageUp', 'Backspace'].includes(e.key)) setAtual((i) => Math.max(0, i - 1))
          else if (e.key === 'l') setTema((t) => (t === 'claro' ? 'escuro' : 'claro'))
        }
        addEventListener('keydown', tecla)
        return () => removeEventListener('keydown', tecla)
      }, [])
      const Momento = MOMENTOS[atual]
      return (
        <MotionConfig reducedMotion="user">
          <main id="palco" data-tema={tema}>
            <AnimatePresence mode="wait">
              <motion.section
                key={atual}
                className="momento"
                initial={{ opacity: 0, filter: 'blur(18px)', scale: 1.02 }}
                animate={{ opacity: 1, filter: 'blur(0px)', scale: 1, transitionEnd: { filter: 'none' } }}
                exit={{ opacity: 0, filter: 'blur(18px)', scale: 0.98 }}
                transition={{ duration: 1.1, ease: SAIDA }}
              >
                <Momento />
              </motion.section>
            </AnimatePresence>
          </main>
        </MotionConfig>
      )
    }

    createRoot(document.getElementById('raiz')).render(<Deck />)
  </script>
</body>
</html>
```

### 8.4 Fundo em shader sem biblioteca

Vale nos dois formatos (em React, chame dentro de um `useEffect` com o canvas do componente).

Um triângulo que cobre a tela e um fragment shader bastam para qualquer fundo 2D (ondas, brasa, grão):

```js
function shaderDeFundo(canvas, corpoDoFragment) {
  const gl = canvas.getContext('webgl2', { premultipliedAlpha: true, alpha: true })
  const vert = `#version 300 es
  void main(){ vec2 p = vec2(float((gl_VertexID<<1)&2), float(gl_VertexID&2)); gl_Position = vec4(p*2.-1., 0., 1.); }`
  const frag = `#version 300 es
  precision highp float; uniform vec2 uResolucao; uniform float uTempo; out vec4 corSaida;
  ${corpoDoFragment}`
  const prog = gl.createProgram()
  for (const [tipo, src] of [[gl.VERTEX_SHADER, vert], [gl.FRAGMENT_SHADER, frag]]) {
    const s = gl.createShader(tipo); gl.shaderSource(s, src); gl.compileShader(s); gl.attachShader(prog, s)
  }
  gl.linkProgram(prog); gl.useProgram(prog)
  const uRes = gl.getUniformLocation(prog, 'uResolucao'), uT = gl.getUniformLocation(prog, 'uTempo')
  let id = 0
  const quadro = (t) => {
    const dpr = Math.min(devicePixelRatio, 1.5)
    canvas.width = canvas.clientWidth * dpr; canvas.height = canvas.clientHeight * dpr
    gl.viewport(0, 0, canvas.width, canvas.height)
    gl.uniform2f(uRes, canvas.width, canvas.height); gl.uniform1f(uT, t / 1000)
    gl.drawArrays(gl.TRIANGLES, 0, 3)
    id = requestAnimationFrame(quadro)
  }
  // Só roda enquanto aparece.
  new IntersectionObserver(([e]) => { cancelAnimationFrame(id); if (e.isIntersecting) id = requestAnimationFrame(quadro) }).observe(canvas)
}
```

### 8.5 Ao entregar: os controles vão no chat, numa tabela

A apresentação não mostra nenhum controle. Junto com o arquivo, mande no chat **só os controles que esta
apresentação tem**, numa tabela, mais como abrir. Modelo:

| Para | Faça |
| --- | --- |
| Avançar | → ou espaço (o passador de slides também funciona) |
| Voltar | ← |
| Tela cheia | F |
| Tema claro ou escuro | L |
| Som | M |
| Fechar um painel aberto | Esc |
| Abrir num momento específico | Acrescente `?momento=3` ao endereço |

Se for rolagem contínua, troque as duas primeiras linhas por "Rolar a história: roda do mouse ou trackpad" e
"Pular de seção: ↓ e ↑". Se algum momento tiver algo para tocar (arrastar, passar o mouse), acrescente uma linha
para ele.

---

## 9. Antes de entregar, confira

- [ ] Nenhum controle nem texto de interface na tela (botão, seta, menu, barra, dica).
- [ ] Controles explicados no chat numa tabela (seção 8.5), só os que existem nesta apresentação.
- [ ] Parece a dobra de abertura de um site premiado, não um slide de escritório.
- [ ] Uma cor de acento, usada como luz; neutros com transparência; nenhuma borda.
- [ ] Tudo entra e sai pelo desfoque; nenhum corte seco.
- [ ] Funciona e fica bonito no escuro e no claro (tecla L).
- [ ] Com movimento reduzido, mostra o estado final.
- [ ] Animações contínuas param fora da tela; nada de laço rodando escondido.
- [ ] Cada efeito tem um motivo ligado ao conteúdo.
- [ ] Frases curtas, sem travessão, dados coerentes entre momentos.
- [ ] Abre direto num momento com `?momento=N`.
- [ ] Tudo num único arquivo `.html` (fora a fonte, o three.js se houver 3D e, na versão React, React, framer-motion
      e o tradutor de JSX por CDN).
- [ ] Se algum efeito pedido tinha limite em HTML, a pessoa foi avisada com o exemplo dela antes de escolher o formato.
