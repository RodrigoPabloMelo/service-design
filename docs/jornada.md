# Mapa da jornada (atual, sem o serviço)

> **Atualizado:** 2026-10-16 · **Fonte:** [assets/2026-10-mapa-jornada.webp](../assets/2026-10-mapa-jornada.webp)
> Jornada **as-is** (como a viajante faz hoje). A persona exata deste mapa não está explícita — ver [Q-15](questoes-em-aberto.md#q-15). Jornadas das outras personas são próxima etapa.

## Fases

- **Antes da viagem:** `E-01` a `E-05`
- **Durante a estadia:** `E-06` e `E-07`
- **Depois:** `E-08`

## Etapas

| ID | Etapa | Ações | Canais | Emoção | Dor |
| --- | --- | --- | --- | --- | --- |
| `E-01` | Inspiração | Vê conteúdos em redes sociais · recebe indicações de amigos · salva vídeos e lugares | TikTok, Instagram, amigos | **Empolgada** (alta) | Inspirações dispersas entre apps e salvos |
| `E-02` | Planejamento inicial | Define dias, região e orçamento · alinha prioridades com a companhia · decide o que deixar em aberto | Airbnb, Booking, companhia | **Expectante** (alta) | Orçamento limita o que cabe na viagem |
| `E-03` | Busca por atividades | Pesquisa "o que fazer em Recife" · busca roteiros por número de dias · envia opções para quem vai junto | TikTok, Instagram, Google, YouTube | **Indecisa** (baixa) | Excesso de opções parecidas trava a decisão |
| `E-04` | Validação e confiança | Compara avaliações recentes em várias fontes · tenta identificar publi · checa a segurança da região | Google Maps, TripAdvisor, comentários | **Desconfiada** (baixa) | Difícil separar review sincero de conteúdo patrocinado |
| `E-05` | Montagem do roteiro | Pede rascunho de roteiro à IA · marca os pontos no Google Maps · faz uma "limpa" e deixa dias livres | ChatGPT, Google Maps | **Confiante** (alta) | IA erra rotas, horários e endereços |
| `E-06` | Ajustes na estadia | Replaneja por clima, cansaço ou horário · busca algo perto de onde está · troca o plano por descobertas | Instagram, Google Maps, moradores | **Cansada** (baixa) | Cansaço e noite cortam atividades distantes |
| `E-07` | Vivência da experiência | Observa trajeto, entorno e movimento · compara o real com a pesquisa · avalia se se sente segura | App de transporte, localização ao vivo | **Encantada e alerta** (alta) | Hipervigilância constante quando está sozinha |
| `E-08` | Pós-experiência | Recomenda no boca a boca · publica stories e vídeos · avalia só quando foi bom | WhatsApp, Instagram, Airbnb, Booking | **Satisfeita** (alta) | Pouca motivação para avaliar nas plataformas |

## Curva emocional

```
alta   Empolgada  Expectante                      Confiante              Encantada/alerta  Satisfeita
         E-01 ──── E-02 ╮                        ╭─ E-05 ─╮            ╭─ E-07 ────────── E-08
                        ╰─ E-03 ──── E-04 ──────╯         ╰── E-06 ───╯
baixa                    Indecisa  Desconfiada               Cansada
```

Vales (maiores oportunidades): **`E-03` indecisão**, **`E-04` desconfiança**, **`E-06` cansaço**.

## Onde o conceito atual responde (hipótese)

Mapeamento do [conceito-do-servico.md](conceito-do-servico.md) às dores — a validar na ideação:

| Etapa | Resposta proposta |
| --- | --- |
| `E-01` / `E-03` | App reúne recomendações curadas num só lugar (contra dispersão e excesso de opções) |
| `E-04` | Curadoria + avaliações de usuárias + selo de segurança + contexto do entorno |
| `E-05` | Roteiro por IA usando só a base curada |
| `E-06` | IA reajusta por clima/localização/horário; motoristas mulheres (plano) para trajetos |
| `E-07` | Contexto do entorno e selo de segurança — **lacuna**: nada confirmado para o "durante" em si ([Q-12](questoes-em-aberto.md#q-12)) |
| `E-08` | Avaliação no app — **lacuna**: falta incentivo para avaliar ([Q-17](questoes-em-aberto.md#q-17)) |
