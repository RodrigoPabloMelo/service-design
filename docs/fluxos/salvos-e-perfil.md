# FL-03 · Guardar rolês e cuidar da conta

> **Atualizado:** 2026-11-18 · **Código:** `lib/features/explore/presentation/views/saved_tab.dart`, `profile_tab.dart`; `lib/features/traveler/` (`traveler_cubit.dart`, `account_sheet.dart`, `wallet_page.dart`) · Estados: [estados.md](estados.md)

**Objetivo dela:** juntar o que achou numa pasta da viagem, levar essa pasta pra Maré organizar, e ver a própria conta.
**Etapas:** `E-04`, `E-05`, `E-08` · **Decisões:** D-16, D-23, D-24 · **Questões:** [Q-37](../questoes-em-aberto.md#q-37) · **Achado:** F-11

---

## FL-03.1 · Salvos vazio

- **Gatilho:** abrir a aba Salvos sem nada salvo.
- **Passos:** "Nada salvo ainda" + "Toque em salvar num rolê e ele entra na pasta da viagem." e o secundário "Explorar rolês".
- **Saídas:** "Explorar rolês" troca pra aba Explorar (`FL-01.1`).
- **Estados:** `ST-SALVOS.vazio`.

## FL-03.2 · Pasta da viagem

- **Gatilho:** abrir Salvos com pelo menos um rolê salvo (`FL-01.4`), pela tab bar ou pela gaveta da Maré (`FL-04.3`).
- **Passos:** bloco da pasta (nome = cidade + datas da viagem, ou cidade + mês enquanto ela não informou as datas) com a contagem e "Organizar com a Maré"; embaixo, os rolês na ordem em que salvou. Tocar abre o detalhe (`FL-01.3`); o salvar do card tira da pasta.
- **Saídas:** `FL-01.3`, `FL-03.3`, `FL-01.4`.
- **Estados:** `ST-SALVOS.com-rolês`; nome da pasta depende de `ST-VIAGEM`.
- **Notas:** uma pasta só no protótipo. Várias pastas e pasta compartilhada com a companhia: [Q-37](../questoes-em-aberto.md#q-37), [Q-22](../questoes-em-aberto.md#q-22).

## FL-03.3 · Organizar com a Maré

- **Gatilho:** "Organizar com a Maré" na pasta.
- **Passos:** a Maré abre por cima, **numa conversa nova** (`FL-04.1`); a sugestão "Organizar meus 8 rolês" fica acima do composer.
- **Saídas:** `FL-04.4` / `FL-04.6`.
- **Lacuna (simulado):** a Maré não lê a pasta da sessão; parte sempre dos 8 rolês salvos do mock. O pedido também não é enviado sozinho — ela toca na sugestão. Uma pasta virar roteiro com um toque está em [Q-37](../questoes-em-aberto.md#q-37).

## FL-03.4 · Conta rápida

- **Gatilho:** salvar sem conta (`FL-01.4`) ou "Entrar" no Perfil (`FL-03.5`).
- **Passos:** sheet com Apple, e-mail ou Google; um toque cria a conta, sem verificação e sem senha **(simulado)**. Fechar o sheet cancela.
- **Saídas:** volta à tela de origem, já com conta.
- **Estados:** `ST-CONTA.sem` → `ST-CONTA.com`.
- **Decisão:** D-16 · **Questão:** [Q-13](../questoes-em-aberto.md#q-13) (exclusividade, verificação).

## FL-03.5 · Perfil

- **Gatilho:** aba Perfil (tab bar ou gaveta da Maré, `FL-04.3`).
- **Passos:**
  - **Sem conta:** "Sua conta" + "Entre pra salvar rolês, montar o roteiro e juntar pontos." e o secundário "Entrar" (`FL-03.4`).
  - **Com conta:** "Oi, {nome}", bloco "Sua viagem" (pasta, hotel, rolês salvos, saídas avaliadas, transfer com motorista, se houver) e a carteira embaixo (`FL-06.2`).
- **Saídas:** `FL-03.4`, `FL-06.2`.
- **Estados:** `ST-CONTA`, `ST-VIAGEM`, `ST-TRANSFER`, `ST-AVALIACAO`.
- **Etapa:** `E-08` · **Questões:** [Q-27](../questoes-em-aberto.md#q-27), [Q-32](../questoes-em-aberto.md#q-32).
