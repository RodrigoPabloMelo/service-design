# Questões em aberto

> **Atualizado:** 2026-11-04 · **Origem:** levantadas na documentação do ciclo 1 (conversa com Rodrigo, 2026-10-16); `Q-27` a `Q-32` no rascunho do blueprint (2026-11-04)
> **Status:** `aberta` · `em discussão` · `resolvida` (→ registrar em [decisoes.md](decisoes.md) com o `D-xx`)
> **Prioridade:** **alta** = bloqueia ideação/blueprint · **média** = precisa antes do protótipo · **baixa** = pode esperar

## Painel

| ID | Questão | Área | Prioridade | Status |
| --- | --- | --- | --- | --- |
| [Q-01](#q-01) | Nome do serviço | Marca | média | aberta |
| [Q-02](#q-02) | Estrutura dos planos/pacotes | Receita | alta | aberta |
| [Q-03](#q-03) | Como funciona o transporte com motoristas mulheres | Receita/Segurança | alta | aberta |
| [Q-04](#q-04) | Comissão: valor e rastreio no pagamento no local | Receita | alta | aberta |
| [Q-05](#q-05) | O que se paga no app x no local | Pagamento | média | aberta |
| [Q-06](#q-06) | Critérios e operação da curadoria | Curadoria | alta | aberta |
| [Q-07](#q-07) | Regras do crédito/desconto para locais | Recomendação | média | em discussão |
| [Q-08](#q-08) | Criadoras de conteúdo x desconfiança de publi | Confiança | alta | aberta |
| [Q-09](#q-09) | Recomendações de homens no recorte de confiança | Confiança | média | aberta |
| [Q-10](#q-10) | Critérios do selo de segurança | Segurança | alta | aberta |
| [Q-11](#q-11) | Escopo e dados da IA de roteiro | IA | média | aberta |
| [Q-12](#q-12) | Segurança "durante" e "depois" do rolê | Segurança | alta | aberta |
| [Q-13](#q-13) | App exclusivo para mulheres? Confiabilidade das avaliações | Avaliações | alta | aberta |
| [Q-14](#q-14) | Refinamento das personas ainda vai acontecer? | Pesquisa | baixa | aberta |
| [Q-15](#q-15) | Para qual persona é o mapa de jornada atual | Pesquisa | média | aberta |
| [Q-16](#q-16) | Detalhe da análise de concorrentes | Pesquisa | média | aberta |
| [Q-17](#q-17) | Como motivar a viajante a avaliar | Avaliações | média | aberta |
| [Q-18](#q-18) | Número e perfil das entrevistadas | Pesquisa | baixa | aberta |
| [Q-19](#q-19) | Conteúdo da Matriz CSD | Pesquisa | baixa | aberta |
| [Q-20](#q-20) | Sustentabilidade do serviço além da disciplina | Negócio | baixa | aberta |
| [Q-21](#q-21) | Entrada e relação com prestadores | Ecossistema | alta | aberta |
| [Q-22](#q-22) | Papel da companhia no serviço | Ecossistema/UX | média | aberta |
| [Q-23](#q-23) | Medição de impacto (ODS 12.b) | Impacto | baixa | aberta |
| [Q-24](#q-24) | Tom de voz e linguagem | UX writing | média | aberta |
| [Q-25](#q-25) | Plataforma, conectividade e acessibilidade | Produto | média | aberta |
| [Q-26](#q-26) | Identidade visual / DESIGN.md | Visual | média | aberta |
| [Q-27](#q-27) | Programa de pontos/moedas da viajante | Receita/Avaliações | alta | aberta |
| [Q-28](#q-28) | Parceiros de benefício (99/Uber, restaurantes) | Ecossistema | alta | aberta |
| [Q-29](#q-29) | Agente de IA: calendário e notificações | IA | alta | aberta |
| [Q-30](#q-30) | Como o app sabe que ela foi ao rolê | Confiança/Receita | alta | aberta |
| [Q-31](#q-31) | Atendimento e recuperação de falhas | Operação | média | aberta |
| [Q-32](#q-32) | Retenção depois da viagem | Negócio | média | aberta |
| [Q-33](#q-33) | Rolês em grupo só com mulheres | Receita/Segurança | alta | aberta |
| [Q-34](#q-34) | Origem e curadoria dos vídeos curtos | Conteúdo/Confiança | alta | aberta |
| [Q-35](#q-35) | Limite de mensagens do agente durante a viagem | IA/Receita | alta | aberta |

---

<a id="q-01"></a>
### Q-01 · Nome do serviço
Ainda sem nome. Nos docs: "o app" / "o serviço".

<a id="q-02"></a>
### Q-02 · Estrutura dos planos/pacotes
Ref.: D-01. Quantos planos? O que é grátis e o que é pago? Preço? Plano por viagem (passe) ou recorrente? Pacote é por rolê (ex.: jantar com reserva + prato + motorista) ou por período?
**2026-11-04 (D-17):** modelo freemium definido: grátis = rolês curados + agente com mensagens limitadas; pagos = transfer com motoristas mulheres e rolês em grupo só com mulheres. Ainda em aberto: preço, se os extras são avulsos ou num plano, se o plano pago amplia as mensagens do agente.

<a id="q-03"></a>
### Q-03 · Transporte com motoristas mulheres
Ref.: D-01, [ecossistema.md](ecossistema.md). É parceria com app existente, cooperativa ou rede própria de motoristas? Quem paga e como? Esse parceiro vira ator do ecossistema. Também é recurso de segurança na ida/volta.
**2026-11-04 (D-17):** o transfer com motoristas mulheres é um **serviço adicional pago**. Segue em aberto quem opera (parceiro de app de transporte ou rede própria) e como se paga.

<a id="q-04"></a>
### Q-04 · Comissão do prestador
Ref.: D-02, D-08. Qual percentual/modelo? Quando o rolê é pago **direto no local**, como o app sabe que a venda veio dele (cupom, QR, código, check-in)?

<a id="q-05"></a>
### Q-05 · O que se paga no app x no local
Ref.: D-08. Quais tipos de rolê entram como pacote/reserva no app e quais ficam avulsos? Bares e cafés têm comissão?
**2026-11-04 (D-13):** não há reserva integrada no app. Resta saber: o que ainda se paga no app (só os planos?) e como fica o benefício "reservas pré-feitas" de D-01 (feito à mão pelo grupo? sai do plano?).

<a id="q-06"></a>
### Q-06 · Curadoria: critérios e operação
Ref.: D-05. Quais critérios o grupo usa para aprovar uma recomendação (local de verdade? acessível? seguro? preço justo)? Quem do grupo revisa e com que frequência? Qual sinal da comunidade derruba uma recomendação (nota, denúncia, "fechou/mudou")? Como se combate a dor de **info desatualizada** (`P-JULIA`)?

<a id="q-07"></a>
### Q-07 · Crédito/desconto para locais
Ref.: D-04. Quanto vale uma recomendação? Ganha ao enviar, ao ser aprovada ou ao ser usada? Moradores locais usam rolês do próprio app (que é para viajantes)? Isso não incentiva recomendação em massa/baixa qualidade?
**2026-11-04 (D-14):** o local ganha pontos **quando o rolê é usado** por uma viajante. Ainda em aberto: quanto vale, como o uso é comprovado (`Q-30`), onde o local troca os pontos (`Q-27`).

<a id="q-08"></a>
### Q-08 · Criadoras de conteúdo x desconfiança de publi
Ref.: D-03, `E-04`, `P-JULIA`. Publi disfarçada é uma das maiores dores. Se criadoras recomendam e ganham crédito, e prestadores pagam comissão, como o app **sinaliza transparência** (quem recomendou, se há vínculo, por que está ali)? Prestador pode pagar para aparecer?

<a id="q-09"></a>
### Q-09 · Recomendações de homens
Ref.: D-03. A pesquisa diz que **avaliações de outras mulheres** são as mais confiáveis. Moradores homens também recomendam — isso é sinalizado? Pesa diferente no selo de segurança?

<a id="q-10"></a>
### Q-10 · Selo de segurança
Ref.: D-06. O selo é dado pela comunidade, pela curadoria ou pelos dois? Quais critérios (sozinha, em dupla, à noite, transporte de volta)? É por lugar, por horário ou por trajeto? Como evitar estigmatizar bairros periféricos (conflito com ODS 8.9 / 11.7)?

<a id="q-11"></a>
### Q-11 · IA de roteiro
Ref.: D-07. A IA gera roteiro inteiro, sugere encaixes ou só replaneja durante a estadia? De onde vêm dados de clima, localização, horários de funcionamento e rotas? Como mostrar **por que** cada item foi recomendado? O que acontece quando a base curada não cobre um pedido?

<a id="q-12"></a>
### Q-12 · Segurança durante e depois
Ref.: D-06, `E-07`. A proposta promete segurança "antes, durante e depois", mas o confirmado (entorno + selo) atua sobretudo **antes**. O que cobre a **hipervigilância** de `E-07` e a volta para o hotel? O que é segurança "depois"? Compartilhar localização / check-in / SOS foram descartados ou só despriorizados?

<a id="q-13"></a>
### Q-13 · App exclusivo para mulheres? Avaliações confiáveis
Ref.: D-09. O app é só para mulheres? Há cadastro/verificação? Como saber que a avaliadora esteve no lugar? Como evitar avaliações falsas (inclusive de prestadores)?

<a id="q-14"></a>
### Q-14 · Refinamento das personas
O PDF lista "refinamento das personas a partir das entrevistas feitas após a apresentação", mas não entrou nas próximas etapas confirmadas (D-12). Vai acontecer? Há entrevistas novas a incorporar?

<a id="q-15"></a>
### Q-15 · Persona do mapa de jornada
A jornada atual mistura sinais de viagem acompanhada ("alinha prioridades com a companhia", "envia opções para quem vai junto") e sozinha ("hipervigilância quando está sozinha"). É de uma persona específica ou uma jornada geral? As jornadas das outras personas (D-12) precisam saber de qual partir.

<a id="q-16"></a>
### Q-16 · Análise de concorrentes
Ref.: [pesquisa.md](pesquisa.md). A página do PDF está em imagem. Registrar: quais apps de mulheres viajantes foram analisados, critérios, forças/fraquezas e o diferencial do serviço frente a cada um.

<a id="q-17"></a>
### Q-17 · Motivação para avaliar
Ref.: `E-08`. Elas "avaliam só quando foi bom" e têm pouca motivação nas plataformas. Viajantes também ganham crédito ao avaliar? Como capturar o boca a boca (WhatsApp, stories) para dentro do app?

<a id="q-18"></a>
### Q-18 · Entrevistas
Quantas entrevistas no ciclo 1? Perfil (idade, cidade de origem, sozinha/acompanhada)? Onde estão as notas? (ir para [`research/`](../research/))

<a id="q-19"></a>
### Q-19 · Matriz CSD
Citada nos métodos, mas o conteúdo (certezas, suposições, dúvidas) não está no material. Registrar em [pesquisa.md](pesquisa.md).

<a id="q-20"></a>
### Q-20 · Sustentabilidade do serviço
O grupo faz curadoria e sustentação (bugs/updates). No conceito, quem opera o serviço no longo prazo e na expansão para outras cidades? Curadoria manual escala?

<a id="q-21"></a>
### Q-21 · Prestadores
Ref.: `A-1`, `A-6`. Como um prestador entra na rede (convite, cadastro, via recomendação de local)? Há contrato/critério? Um prestador pode recomendar o próprio negócio (`A-1` = `A-6`)? Qual o benefício para ele além de vendas (ODS 8.3)?

<a id="q-22"></a>
### Q-22 · Papel da companhia
Ref.: `P-JULIA` ("decidir juntas"), `P-MARINA` ("agradar às duas pessoas"), `E-02`/`E-03`. A amiga/parceiro(a) usa o app também? Há roteiro/lista compartilhada? Planos valem para duas pessoas?

<a id="q-23"></a>
### Q-23 · Medição de impacto
Ref.: ODS 12.b em [visao-do-servico.md](visao-do-servico.md). O serviço vai medir impacto (gasto em negócios locais, dispersão para fora do circuito turístico)? Quais indicadores?

<a id="q-24"></a>
### Q-24 · Tom de voz e linguagem
Ref.: [UX.md](../UX.md) §6. A hipótese atual é um tom "de amiga local": direto, concreto, no feminino, sem alarmismo. Isso é o tom oficial? Como falar de segurança sem gerar medo nem estigmatizar bairros?

<a id="q-25"></a>
### Q-25 · Plataforma, conectividade e acessibilidade
App nativo (iOS/Android), PWA ou os dois? **2026-11-04 (D-15, D-16):** a entrada é pela **web** (buscador → site, rolês abertos sem login); falta decidir se existe app nativo além do site. Precisa funcionar offline ou com pouca conexão no "durante" (roteiro e entorno salvos)? Quais requisitos de acessibilidade (contraste no sol, uso com uma mão, leitor de tela)?

<a id="q-26"></a>
### Q-26 · Identidade visual / DESIGN.md
Não há identidade visual. Quando houver, registrar num `DESIGN.md` na raiz (tokens + regras de uso), referenciado pelo [UX.md](../UX.md), para a IA não inventar marca.

<a id="q-27"></a>
### Q-27 · Programa de pontos/moedas da viajante
Ref.: [blueprint rascunho](../diagrams/2026-11-04-blueprint-rascunho.md) etapas 8–9, D-04, `Q-07`, `Q-17`. No panorama, os descontos funcionam como pontos/moedas trocáveis por serviços e cupons. Falta definir: o que gera pontos (visitar, avaliar, indicar amiga, completar roteiro?); quanto vale cada ação; se expiram; quem financia o desconto (app, parceiro, os dois); se locais e viajantes usam a mesma moeda. Risco: premiar a avaliação pode enviesar notas ou gerar avaliações falsas (`Q-13`). Premiar o ato de avaliar, não a nota?

<a id="q-28"></a>
### Q-28 · Parceiros de benefício
Ref.: blueprint etapa 9. O panorama cita cupons em 99/Uber, restaurantes locais (modelo clube de descontos) e experiências. São um novo ator do ecossistema (`A-8`?). Qual o acordo com cada um (co-marketing, pagamento por resgate)? Isso se mistura com o transporte com motoristas mulheres (`Q-03`)?

<a id="q-29"></a>
### Q-29 · Agente de IA: calendário e notificações
Ref.: `D-07`, `Q-11`, blueprint etapas 4 e 6. No panorama, o agente trabalha com mapa e calendário integrados e manda notificações durante a viagem. O calendário é exportado (.ics) ou sincronizado (Google/Apple)? Quais gatilhos de reajuste ("necessidades multifatoriais": clima, horário, distância, noite/volta, cansaço, orçamento)? O ajuste é automático ou sempre pede confirmação? Qual o limite de notificações por dia?

<a id="q-30"></a>
### Q-30 · Como o app sabe que ela foi ao rolê
Ref.: `Q-04`, `Q-13`, `Q-27`, blueprint etapa 7. Uma prova de visita resolveria três coisas: rastrear a comissão no pagamento no local, validar avaliações e liberar pontos. Opções **(hipótese)**: QR no balcão, código no app validado pelo prestador, cupom usado, geolocalização. Qual é viável no piloto?

<a id="q-31"></a>
### Q-31 · Atendimento e recuperação de falhas
Ref.: blueprint etapa 7. O que acontece quando o rolê está fechado, a reserva não é honrada, o preço é outro ou ela se sente insegura? Quem ela aciona e por qual canal? Quem do grupo atende e em quanto tempo? Liga com `Q-12`.

<a id="q-32"></a>
### Q-32 · Retenção depois da viagem
Ref.: blueprint etapas 8–9, `D-10`. O panorama prevê um catálogo personalizado com base na última visita. Com só Recife/Olinda no piloto, o que ela faz com o app depois de voltar para casa? Pontos e catálogo só têm valor se servirem fora de Recife (ex.: 99/Uber na cidade dela), numa volta, ou para indicar amigas.

<a id="q-33"></a>
### Q-33 · Rolês em grupo só com mulheres
Ref.: D-17, D-11, `P-CAMILA`. Serviço pago e guiado. Quem guia (guia local parceira, prestadora, alguém do grupo)? Quantas pessoas por grupo, como se forma e se confirma? Como se verifica que são só mulheres (`Q-13`)? Encaixa para quem viaja com parceiro(a) (`P-MARINA`)? O guia vira ator do ecossistema.

<a id="q-34"></a>
### Q-34 · Origem e curadoria dos vídeos curtos
Ref.: D-18, D-03, `Q-08`. Quem grava os vídeos do showcase: criadoras locais, o grupo, as próprias viajantes? Com que direitos de uso? Como mostrar que o vídeo não é publi (dor central de `E-04`)? Como manter o vídeo atualizado com o rolê (`F-07`)?

<a id="q-35"></a>
### Q-35 · Limite de mensagens do agente durante a viagem
Ref.: D-17, D-07, [UX.md §5](../UX.md). O agente grátis tem mensagens limitadas, mas o reajuste "durante" (clima, noite, volta) é justamente quando ela mais precisa e quando o UX.md proíbe upsell em momento de tensão. O limite vale igual durante a viagem? Reajustes ligados a segurança ou volta ficam fora do limite? O que ela vê quando o limite acaba na rua?
