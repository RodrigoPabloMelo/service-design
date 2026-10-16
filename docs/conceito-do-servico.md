# Conceito do serviço — como funciona

> **Atualizado:** 2026-10-16 · **Fonte:** conversa com Rodrigo (2026-10-16) + esboço do ecossistema
> Ideação ainda não aconteceu: este arquivo registra o que já foi **decidido** no conceito. O resto está em [questoes-em-aberto.md](questoes-em-aberto.md).

## Ciclo do serviço (visão rápida)

```
Local recomenda (A-1) ──▶ Grupo faz curadoria (A-2) ──▶ App reúne recomendações (A-3)
        ▲                                                         │
        │ crédito/desconto                                        ▼
        │                                     Viajante planeja (A-4, antes)
        │                                                         │
Prestador oferece o rolê (A-6) ◀── paga ── Viajante visita (A-5, durante)
                                                                  │
                                         Viajante avalia e recomenda (A-7, depois) ──▶ App
```

Detalhe de atores e fluxos: [ecossistema.md](ecossistema.md).

## 1. Recomendações de locais

- **Quem recomenda:** moradoras/es comuns de Recife/Olinda **e** criadoras de conteúdo locais (D-03).
- **Incentivo:** quem recomenda ganha **créditos/descontos em rolês do app** (D-04).
- Em aberto: regras do crédito ([Q-07](questoes-em-aberto.md#q-07)), transparência com criadoras de conteúdo x dor de "publi" ([Q-08](questoes-em-aberto.md#q-08)), recomendações de homens no recorte de confiança ([Q-09](questoes-em-aberto.md#q-09)).

## 2. Curadoria

- **Modelo:** o grupo define **critérios** de entrada; a **comunidade** (avaliações das usuárias) mantém ou derruba recomendações (D-05).
- O grupo também **sustenta o app** (bugs/updates) — fluxo material A-2 → A-3.
- Em aberto: quais critérios, quem revisa e com que frequência, como lidar com info desatualizada ([Q-06](questoes-em-aberto.md#q-06)).

## 3. Segurança

Recursos confirmados no conceito (D-06):

- **Contexto do entorno** — região, horário, acesso, ida e volta, movimento ao redor.
- **Selo/avaliação de segurança** — usuárias avaliam se o lugar é tranquilo/adequado (ex.: "tranquilo para ir sozinha", "ok para duas mulheres").

Não confirmados (fora por enquanto): compartilhamento de localização em tempo real, check-in/SOS. A proposta promete segurança "antes, durante e depois" — como cobrir o **durante** e o **depois** está em [Q-12](questoes-em-aberto.md#q-12). Critérios do selo: [Q-10](questoes-em-aberto.md#q-10).

O transporte com motoristas mulheres (benefício de plano) também atua como recurso de segurança na ida/volta.

## 4. Roteiro com IA

- O app **monta e ajusta roteiros com IA usando apenas a base curada**, somando contexto como clima, localização e horário (D-07).
- Responde a dores da jornada: "IA erra rotas, horários e endereços" (`E-05`) e replanejamento por clima/cansaço (`E-06`).
- Oportunidade da pesquisa a respeitar: **deixar claro por que cada experiência está sendo recomendada** (perfil, companhia, interesses, momento da viagem).
- Em aberto: escopo exato da IA ([Q-11](questoes-em-aberto.md#q-11)).

## 5. Pagamento e planos

- **Pagamento em dois caminhos** (D-08): pacotes/reservas **dentro do app**; rolês avulsos **pagos direto no local**.
- **Comissão** do prestador em ambos os casos — como rastrear no pagamento no local: [Q-04](questoes-em-aberto.md#q-04).
- **Planos/pacotes** com benefícios (motoristas mulheres, reservas, pratos sugeridos): [Q-02](questoes-em-aberto.md#q-02), [Q-03](questoes-em-aberto.md#q-03).

## 6. Avaliações

- **Qualquer usuária do app** que esteve no lugar pode avaliar e recomendar (D-09) — sem verificação forte por enquanto.
- As avaliações alimentam a curadoria comunitária e o selo de segurança.
- Em aberto: o app é exclusivo para mulheres? Como evitar avaliações falsas? ([Q-13](questoes-em-aberto.md#q-13)). Como motivar a avaliação, já que há pouca motivação para avaliar (`E-08`) ([Q-17](questoes-em-aberto.md#q-17)).
