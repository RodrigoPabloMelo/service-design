# Tokens da Maré

Fonte de verdade no código:
`prototype/app/lib/features/travel_agent/presentation/widgets/travel_tokens.dart`.
Esta página resume e explica; se divergir, o código vale e esta página é
atualizada.

## Cor (light / dark)

| Token | Light | Dark | Uso |
|---|---|---|---|
| `s0` | #F2F2F5 | #0B0B0D | fundo da tela e do sheet |
| `s1` | #FFFFFF | #1C1C1F | cards, menu, composer |
| `s2` | #E6E6EB | #2A2A2E | grupos, botão secundário, linha pressionada |
| `ink` | #131416 | #F2F2F5 | texto e ícone |
| `inkMuted` | #6A6E75 | #A1A1A8 | texto secundário |
| `inverse` | #131416 | #F2F2F5 | bolha da usuária, pins |
| `accent` | #006FD6 | #006FD6 | bloco-resumo, primário, rota, seleção (branco por cima 4,95:1) |
| `accentText` | #0A62C2 | #6AB0FF | texto azul sobre neutro (status do agente ao vivo); **não** em botão |
| `accentSoft` | #E0ECFA | #0D2A4A | tint de selecionado |
| `piscina` | #0ABAB5 | — | marca (símbolo, água, aurora); nunca texto |
| `sol` / `danger` | #E2A21F / #D13B2E | | uso ≥75% / ≥90% no limite |

- Mapa monocromático (ref. Uber): terra #E8E8EB, água #D8DEE2, parque
  #DDE3DC, ruas brancas; pins `inverse`, selecionado `accent`.
- Preto/branco com alfa (scrim, véus) podem ir direto no widget.
- Sheet de conectores é sempre escuro (paleta própria anotada no arquivo).

## Tipografia (`TravelType`)

| Estilo | Fonte / tamanho / linha | Peso |
|---|---|---|
| `cardTitleLarge`, `cardTitle` | Oswald 30/34, 19/23 | 700 — só título de card visual |
| `title1`, `title2` | Jakarta 28/34, 22/28 | 700 |
| `title3`, `headline` | 20/25, 17/22 | 500 |
| `summary` | 21/28 | 400 (destaques em 500 + cor) |
| `body`, `callout`, `subhead` | 17/25.5, 16/24, 15/22.5 (150%) | 400 |
| `calloutStrong`, `subheadStrong`, `footnoteStrong` | | 500 |
| `footnote`, `caption`, `section` | 13/18, 12/16, 13/18 | 400, 400, 500 |

- Números, horários, preços: `fontFeatures: TravelType.tabular`.
- Texto em uma linha só (rótulo, menu) pode usar `height: 1.2`.

## Espaço e raio (`TravelSpace`)

- Escala 4/8/12/16/24/32. Margem do sheet `gutter` 12, padding de card 12,
  texto solto alinhado a 24 (`content`).
- Raios: `rSheet` 36, `rCard` 24, `rInner` 12, `rTight` 8, `rComposer` 28,
  pílula 999. Cadeias usadas:
  - sheet 36 → card 24 (padding 12) → interno 12
  - composer 28 → padding 8 → botão 40 (círculo)
  - card do plano 24 → padding 12 → botão 12
  - menu ⋯ 22 → padding 6 → linha 16
- Alvo de toque mínimo 44 (`tap`). Botões 48 de altura.

## Movimento

- Curva padrão `Cubic(0.2, 0, 0, 1)`. Pressionar: escala 0.96.
- Feedback de estado ≤150 ms; menus 220 ms (saída 160); sheet 420 ms;
  troca conversa↔mapa 520 ms; aurora da abertura se esvai em 1,8 s
  (`easeInOut`).
- Segmented control: mola (rigidez 420, amortecimento 32), segue o dedo.
- `MediaQuery.disableAnimationsOf` → animações em 1 ms / estáticas.
- Nada de animação infinita no mapa (custo); mapa em `RepaintBoundary`
  com cache.
