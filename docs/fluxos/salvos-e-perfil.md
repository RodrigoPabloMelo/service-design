# FL-03 · Guardar rolês e cuidar da conta

> **Atualizado:** 2026-11-18 · **Código:** `lib/features/explore/presentation/views/saved_tab.dart`, `folder_page.dart`, `profile_tab.dart`; `lib/features/traveler/` (`traveler_cubit.dart`, `account_sheet.dart`, `save_to_sheet.dart`, `wallet_page.dart`) · Estados: [estados.md](estados.md)

**Objetivo dela:** juntar o que achou numa pasta da viagem, levar essa pasta pra Maré organizar, e ver a própria conta.
**Etapas:** `E-04`, `E-05`, `E-08` · **Decisões:** D-16, D-23, D-24, D-28 · **Questões:** [Q-37](../questoes-em-aberto.md#q-37) · **Achado:** F-11

---

## FL-03.1 · Salvos vazio

- **Gatilho:** abrir a aba Salvos sem nada salvo e sem viagem criada.
- **Passos:** "Nada salvo ainda" + "Toque em salvar num rolê e escolha a viagem." e o secundário "Explorar rolês".
- **Saídas:** "Explorar rolês" troca pra aba Explorar (`FL-01.1`).
- **Estados:** `ST-SALVOS.vazio`.

## FL-03.2 · Viagens (pastas)

- **Gatilho:** abrir Salvos com algum rolê salvo ou alguma viagem criada, pela tab bar ou pela gaveta da Maré (`FL-04.3`).
- **Passos:** "Salvos" e o botão + (nova viagem); embaixo, as viagens em grade (ref. pastas do Pinterest): capa-mosaico com as fotos dos rolês, nome e "N rolês, N dias". A pasta da viagem atual se chama cidade + datas (ou cidade + mês, sem datas) e só aparece quando tem rolê; as que ela criou aparecem mesmo vazias.
- **Saídas:** tocar numa viagem → `FL-03.7`; + → `FL-03.6` (só o passo do nome).
- **Estados:** `ST-SALVOS.pastas`; nome da pasta da viagem depende de `ST-VIAGEM`.

## FL-03.3 · Organizar com a Maré

- **Gatilho:** "Organizar com a Maré" na barra da pasta (`FL-03.7`).
- **Passos:** a Maré abre por cima, **numa conversa nova** (`FL-04.1`); a sugestão "Organizar meus 8 rolês" fica acima do composer.
- **Saídas:** `FL-04.4` / `FL-04.6`.
- **Lacuna (simulado):** a Maré não lê a pasta da sessão nem escreve os dias nela; parte sempre dos 8 rolês salvos do mock. O pedido também não é enviado sozinho — ela toca na sugestão ([Q-37](../questoes-em-aberto.md#q-37)).

## FL-03.6 · Salvar em uma viagem

- **Gatilho:** salvar um rolê já com conta (`FL-01.4`), em qualquer card, no detalhe, sobre a foto ou no vídeo curto.
- **Passos:**
  1. Sheet "Salvar em": "Suas viagens" (capa, nome, contagem) e, por último, "Nova viagem".
  2. Tocar numa viagem salva ali e fecha, com o aviso "Salvo em {viagem}".
  3. "Nova viagem" → campo com o nome já sugerido ("Olinda, dez") e "Criar e salvar"; "Voltar" volta pra lista.
  4. Fechar o sheet não salva.
- **Saídas:** volta à tela de origem; o rolê aparece na viagem (`FL-03.7`).
- **Estados:** rolê salvo/não salvo; `ST-SALVOS.pastas`.
- **Decisão:** D-28 · **Achado:** F-11.

## FL-03.7 · Dentro da viagem: separar por dia

- **Gatilho:** tocar numa viagem em Salvos (`FL-03.2`).
- **Passos:**
  1. Nome grande, "N rolês" e "N dias"; os **dias** como seções (capa, "Sexta, 14 nov", contagem) e, embaixo, os rolês **sem dia** em grade. Tocar num dia abre só os rolês daquele dia.
  2. Com datas informadas, a viagem já nasce com os dias delas; sem datas, os dias são criados por ela ("Dia 1", "Dia 2").
  3. Barra flutuante: **"Organizar"** (à mão) e **"Organizar com a Maré"** (`FL-03.3`).
  4. Organizando: tocar nos rolês escolhe (contorno azul + check); "Mover pra um dia" abre "Mover pra" com os dias, "Sem dia" (dentro de um dia) e "Novo dia"; aviso "Movido pra {dia}". "Concluir" sai do modo.
  5. Viagem vazia: "Nada nesta viagem ainda." + "Explorar rolês".
- **Saídas:** `FL-01.3` (tocar num rolê fora do modo), `FL-03.3`, volta a `FL-03.2`.
- **Estados:** `ST-SALVOS.pasta`, `ST-SALVOS.organizando`.
- **Decisão:** D-28 · **Questões:** [Q-37](../questoes-em-aberto.md#q-37), [Q-22](../questoes-em-aberto.md#q-22) (compartilhar com a companhia).

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
  - **Com conta:** "Oi, {nome}", o card **"Seus pontos"** (saldo + "Troque por cupons"), que abre a página de pontos (`FL-06.2`), e o bloco "Sua viagem" (pasta, hotel, rolês salvos, saídas avaliadas, transfer com motorista, se houver).
- **Saídas:** `FL-03.4`, `FL-06.2`.
- **Estados:** `ST-CONTA`, `ST-VIAGEM`, `ST-TRANSFER`, `ST-AVALIACAO`.
- **Etapa:** `E-08` · **Questões:** [Q-27](../questoes-em-aberto.md#q-27), [Q-32](../questoes-em-aberto.md#q-32).
