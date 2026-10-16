# Mapa do ecossistema

> **Atualizado:** 2026-10-16 · **Fonte:** esboço à mão [assets/2026-10-ecossistema-esboco.webp](../assets/2026-10-ecossistema-esboco.webp) + conversa com Rodrigo
> Transcrição do esboço; numeração dos atores igual à do desenho. Refinamento do ecossistema é próxima etapa.
> **Versão digital interativa:** [artifact](https://claude.ai/artifact/5i9EX1Tf66DbZX2kTZ3Wyc) · fonte em [diagrams/ecossistema.html](../diagrams/ecossistema.html). Ao mudar atores ou fluxos aqui, atualize também o SVG no HTML e republique. Pictogramas: Hugeicons (MIT), embutidos como `<symbol>`.
> **Imagem v1:** [imagens/diagramas/2026-10-16-ecossistema-servico-v1.png](imagens/diagramas/2026-10-16-ecossistema-servico-v1.png) (histórico de versões em [imagens/README.md](imagens/README.md)).

## Zonas

- **Externos — parceiros:** `A-1` Local, `A-6` Prestador(a) de serviço
- **Interno — usuária:** `A-3` App, `A-4`, `A-5`, `A-7` (a viajante em três momentos)
- **Grupo** (`A-2`) fica na fronteira: recebe dos externos e alimenta o app.

## Atores

| ID | Ator | Papel |
| --- | --- | --- |
| `A-1` | Local / prestador de serviço | **Recomenda** o rolê. Moradoras/es comuns e criadoras de conteúdo locais (D-03) |
| `A-2` | Grupo (equipe do projeto) | **Realiza a curadoria** (critérios + comunidade, D-05) e **sustenta o app** (bugs/updates) |
| `A-3` | App | **Reúne todas as recomendações curadas** de Recife/Olinda |
| `A-4` | Mulher viajante — **antes** | Procura rolês locais para adicionar ao roteiro da viagem |
| `A-5` | Viajante — **durante** (visita) | Ajusta o roteiro com base em recomendação, clima/tempo e app, e **paga pelos rolês** |
| `A-6` | Prestador(a) de serviço | **Oferece o rolê/passeio** (ex.: Uber/táxi, restaurante local) |
| `A-7` | Mulher — **depois** | Avalia e recomenda boca a boca |

## Fluxos

Legenda do esboço: tracejado = **informação** · contínuo = **financeiro** · pontilhado = **material**

| De → Para | Tipo | O que circula |
| --- | --- | --- |
| `A-1` → `A-2` | informação | Recomendação de rolê |
| `A-2` → `A-1` | financeiro | Crédito e desconto em rolês do app (D-04) |
| `A-6` → `A-2` | informação | Oferta do rolê/passeio (dados do serviço) |
| `A-2` → `A-3` | informação | Recomendações curadas publicadas |
| `A-2` → `A-3` | material | Sustentação: bugs/updates |
| `A-3` → `A-4` | informação | Recomendações para montar o roteiro |
| `A-4` → `A-2` | financeiro | Planos/pacotes (D-01) |
| `A-3` ↔ `A-5` | informação | Roteiro, ajustes por clima/localização |
| `A-5` → `A-6` | financeiro | Pagamento do rolê (no app ou no local, D-08) |
| `A-6` → `A-2` | financeiro | Comissão (D-02) — **não está no esboço**, decorre do modelo de receita |
| `A-7` → `A-3` | informação | Avaliação, selo de segurança, recomendação |

## Diagrama

```mermaid
flowchart LR
  subgraph EXT[Externos — parceiros]
    A1[A-1 Local<br/>recomenda rolê]
    A6[A-6 Prestador<br/>oferece rolê]
  end
  A2[A-2 Grupo<br/>curadoria]
  subgraph INT[Interno — usuária]
    A3[A-3 App<br/>recomendações curadas]
    A4[A-4 Viajante antes<br/>planeja]
    A5[A-5 Viajante durante<br/>visita e paga]
    A7[A-7 Viajante depois<br/>avalia]
  end

  A1 -.recomendação.-> A2
  A2 ==crédito/desconto==> A1
  A6 -.oferta.-> A2
  A2 -.curadoria.-> A3
  A2 -. bugs/updates .-o A3
  A3 -.recomendações.-> A4
  A4 ==planos/pacotes==> A2
  A3 -.roteiro/ajustes.-> A5
  A5 ==paga rolê==> A6
  A6 ==comissão==> A2
  A7 -.avaliação.-> A3
```

Mermaid: `-.->` informação · `==>` financeiro · `-.-o` material.

## Lacunas do ecossistema

- Parceiro de **transporte com motoristas mulheres** não aparece como ator ([Q-03](questoes-em-aberto.md#q-03)).
- Diferença entre `A-1` (prestador que recomenda) e `A-6` (prestador que oferece) e como prestadores entram na rede ([Q-21](questoes-em-aberto.md#q-21)).
- Fontes de dados para IA (clima, localização, mapas) não aparecem ([Q-11](questoes-em-aberto.md#q-11)).
- A companhia da viajante (amiga/parceiro(a)) não aparece como ator ([Q-22](questoes-em-aberto.md#q-22)).
