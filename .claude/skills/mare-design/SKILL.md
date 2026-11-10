---
name: mare-design
description: Sistema visual da Maré (agente de roteiros, prototype/app/lib/features/travel_agent) — regras de cor, tipografia, raios, botões, ícones, movimento, texto e fluxo conversa→mapa que o designer já definiu. Use antes de criar ou mudar qualquer tela, widget ou copy de UI do app, e ao revisar design.
when_to_use: "mexer na tela do agente", "ajusta esse card", "cria um componente", "revisa o visual", feedback visual do designer sobre a interface Flutter.
paths: "prototype/app/lib/features/travel_agent/**, prototype/app/lib/core/components/**"
allowed-tools: Bash(/usr/bin/python3 -I ${CLAUDE_SKILL_DIR}/scripts/design_lint.py *)
---

# Maré — sistema visual

Flat, limpo, iOS (HIG). Sem cara de Material. Cada regra abaixo veio de um
feedback do designer; não reabra sem ele pedir.

## Regras que mais quebram

1. **Sem sombra, sem borda de separação, sem "linha de pixel".** Separe por
   camada sólida (`s0` fundo → `s1` card → `s2` grupo) e espaço.
   Exceção: cards de sugestão da abertura — sem fundo, só borda fina
   (`ink` 10%), raio do composer (ver patterns.md).
2. **Neutros cinza** (nada de areia/bege). **Uma** cor de contraste: azul
   `accent #006FD6`. Tiffany `#0ABAB5` é só marca (símbolo, água, aurora).
   Tiffany também nos bichos da maré em pixels (são água).
   Exceção: **cor por tipo de rolê** (`TravelCategoryTones`) nos blocos do
   calendário e na hora do guia — música roxo, arte amarelo, comida
   laranja, natureza verde, praia azul-água; fundo com cor de verdade (sem
   lavar) e texto no tom escuro da mesma cor.
3. **Plus Jakarta Sans em 99%.** Oswald 700 só no título de card visual
   (nome do rolê). Pesos: 400 regular, 500 ênfase, 700 só títulos. **Nunca
   semibold.** Texto livre com entrelinha 150%. Peso de fonte variável muda
   com `.weight()`, não `copyWith(fontWeight:)`.
4. **Raios concêntricos:** externo = interno + padding (sheet 36 → card 24
   → interno 12 → 8). Padding simétrico: esquerda = direita.
5. **Dois botões: sempre empilhados, largura total, primário embaixo.** Um
   primário por vista. Secundário = fundo `s2` com **texto neutro** (`ink`),
   nunca azul. Ação única dentro de um card = secundário dentro do card.
6. **Ícones Font Awesome só via `TravelIcons`** (constantes próprias com
   codepoint — `FontAwesomeIcons.x` direto some no build web). Ícone neutro
   direto na superfície, sem bolinha colorida. Centralize o ícone no botão.
   Mesmo estilo (outline/solid) dentro de uma seção.
7. **Nada de brilhinho/varinha/esfera 3D pra dizer "IA".** O símbolo é o
   `MareMark` flat (disco + ondas). A `Aurora` (brilho de marca, de fundo)
   só em dois lugares: atrás do composer na abertura e no sheet de
   conectores. A "maré em pixels" (`PixelTide`) só no começo do zero.
8. **Texto mínimo, pt-BR, sentence case. Sem `·` ou `→` como separador.**
   Corte o texto antes de enfeitar.
9. **Vidro (Liquid Glass) em controle flutuante**: sobre o mapa e nos
   cabeçalhos/rodapés flutuantes do roteiro (voltar, dias, Editar, "Pedir
   ajuste"); frost sobre foto; nunca vidro sobre vidro.
10. **Topo do sheet em tela cheia = desfoque progressivo do iOS**
    (`ProgressiveBlurTop`) + véu `s0`; o conteúdo começa no topo do sheet
    (`SheetTopInset`), nunca cortado numa borda dura. Fundo escuro passando
    por baixo (`DarkBackdrop`) → título e ícones do cabeçalho em claro.
11. **Fade de rolagem suave** (rampa senoidal) sob o composer e a alça.
12. **Pouca coisa por vez.** Abertura da conversa = bloco azul + sugestões,
    nada entre eles. Começo do zero (nada salvo) = mapa + saudação central,
    sem bloco azul. Conteúdo (cards de rolês, roteiro) só aparece quando o
    agente responde.
13. **Botão acessível:** `Semantics(button: true, excludeSemantics: true)`
    sempre com `onTap:` (o mesmo do `Pressable` filho) — sem ele o leitor
    de tela anuncia um botão que não faz nada. Lint D11.

Valores exatos: [tokens.md](tokens.md). Padrões de componente e de fluxo
(conversa→mapa, menu ⋯, composer, sheet de limites, card do rolê, player,
pensamento do agente): [patterns.md](patterns.md). Regras de texto:
[writing.md](writing.md). Leia o arquivo que toca o que você vai mexer.

## Fluxo de trabalho

1. Padrão novo? Busque referência no Mobbin (skill `mobbin-search`) antes.
2. Reuse o que existe: `travel_tokens.dart` (paleta, `TravelType`,
   `TravelSpace`), `travel_ui.dart` (`TravelIcons`, `PrimaryButton`,
   `SecondaryButton`, `SolidBlock`, `Pressable`, `EdgeFadeScroll`,
   `PillSegmented`). Token novo entra nesses arquivos, não solto no widget.
3. Ao editar, o hook roda o lint e devolve violações. Rodar à mão:
   `/usr/bin/python3 -I ${CLAUDE_SKILL_DIR}/scripts/design_lint.py`
4. Gate (Flutter direto do SDK, sandbox off — fvm trava):
   `cd prototype/app && ~/fvm/versions/3.47.9/bin/flutter analyze < /dev/null`,
   `flutter test`, `flutter build web --release -t lib/main_design.dart`.
   Depois do build o hook roda `prototype/app/tool/check_icons.sh`.
5. Veja de verdade: sirva `prototype/app/build/web` (porta 8765) ou `design-preview`
   do `.claude/launch.json` (release, sem hot reload) e confira no browser
   embutido em `/agente`, com screenshot do estado mexido.
6. Feedback visual novo do designer → skill `design-feedback` (registra a
   regra aqui e, se der, no lint).

## Revisão

Para revisar uma mudança de UI contra estas regras, delegue ao agent
`design-reviewer`.
