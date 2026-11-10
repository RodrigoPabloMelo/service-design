# Log de decisões

> **Atualizado:** 2026-11-09
> Uma linha por decisão. Para mudar uma decisão, não apague: marque como `substituída por D-xx` e crie a nova.

| ID | Data | Área | Decisão | Origem |
| --- | --- | --- | --- | --- |
| D-01 | 2026-10-16 | Receita | Haverá **planos/pacotes** com mais benefícios para a viajante (ex.: transporte com motoristas mulheres, reservas pré-feitas, pratos específicos em restaurantes selecionados) | Conversa Rodrigo |
| D-02 | 2026-10-16 | Receita | O serviço cobra **comissão do prestador** sobre os rolês | Conversa Rodrigo |
| D-03 | 2026-10-16 | Recomendação | Quem recomenda: **moradoras/es comuns** e **criadoras de conteúdo** locais | Conversa Rodrigo |
| D-04 | 2026-10-16 | Recomendação | Incentivo a quem recomenda: **créditos/descontos em rolês do app** | Conversa Rodrigo + esboço ecossistema |
| D-05 | 2026-10-16 | Curadoria | Curadoria por **critérios definidos pelo grupo + comunidade** (avaliações mantêm/derrubam) | Conversa Rodrigo |
| D-06 | 2026-10-16 | Segurança | Recursos de segurança do conceito: **contexto do entorno** e **selo/avaliação de segurança**. Compartilhar localização e check-in/SOS ficaram de fora por ora | Conversa Rodrigo |
| D-07 | 2026-10-16 | IA | O app **monta/ajusta roteiros com IA usando só a base curada** + clima/localização | Conversa Rodrigo |
| D-08 | 2026-10-16 | Pagamento | Pagamento em **dois caminhos**: pacotes/reservas no app; rolês avulsos direto no local. **Parte "reservas no app" substituída por D-13** | Conversa Rodrigo |
| D-09 | 2026-10-16 | Avaliações | **Qualquer usuária do app** pode avaliar e recomendar (sem verificação forte por ora) | Conversa Rodrigo |
| D-10 | 2026-10-16 | Escopo | **Recife/Olinda como piloto**, com intenção de expandir | Conversa Rodrigo |
| D-11 | ciclo 1 | Público | Mulheres viajantes **sozinhas ou acompanhadas de 1 pessoa** (amiga ou parceiro(a)) | PDF ciclo 1 |
| D-12 | 2026-10-16 | Próximas etapas | Próximas entregas: **jornadas das outras personas**, **ideação do serviço**, **blueprint/refinamento do ecossistema** | Conversa Rodrigo |
| D-13 | 2026-11-04 | Pagamento | **Não há reserva integrada no app.** Substitui a parte "reservas no app" de D-08. O que ainda se paga no app segue em `Q-05` | Conversa Rodrigo (blueprint) |
| D-14 | 2026-11-04 | Recomendação | Retorno ao local: o local **ganha pontos quando uma viajante usa o rolê que ele indicou** (não ao enviar nem ao ser aprovado). Responde em parte `Q-07`; depende de saber que ela foi (`Q-30`) | Conversa Rodrigo (blueprint) |
| D-15 | 2026-11-04 | Aquisição | A viajante chega ao serviço **principalmente por buscadores** (Google, Safari etc.), abrindo o site pelo link; indicação de alguém é secundária | Conversa Rodrigo (blueprint) |
| D-16 | 2026-11-04 | Acesso | **Rolês visíveis sem login.** A conta é pedida para salvar | Conversa Rodrigo (blueprint) |
| D-17 | 2026-11-04 | Receita | **Freemium.** Grátis: rolês curados + agente de IA com **mensagens limitadas** (como assistentes de IA comerciais). Pagos (serviços adicionais, a parte mais monetizável): **transfer com motoristas mulheres** e **rolês em grupo só com mulheres, guiados**. Detalha D-01; estrutura e preço seguem em `Q-02` | Conversa Rodrigo (blueprint) |
| D-18 | 2026-11-04 | Conteúdo/UX | Exibição dos rolês: **cards no estilo de sites de avaliação de viagem** (foto, nota, avaliações) **+ vídeos curtos** no formato que ela já usa nas redes, **curados pelo grupo** | Conversa Rodrigo (blueprint) |
| D-19 | 2026-11-09 | Protótipo | Protótipo navegável em **Flutter web** em `prototype/app/`, com **dados mockados** (sem backend nem IA real). Mapa ligando telas aos docs: [prototipo.md](prototipo.md) | Conversa Rodrigo (união do app ao repo) |
| D-20 | 2026-11-04 | Protótipo | Primeira tela prototipada = **etapa 05 do blueprint, "Organiza locais com o agente"**: conversa com o agente + mapa + roteiro por dia (aplica D-07) | Blueprint (PDF 2026-11-04) + protótipo |
| D-21 | 2026-11-07 | Confiança | No card do rolê, a prova de confiança vem junto: **quem indicou** (nome, vínculo com o lugar, citação), **fotos reais**, **vídeos curtos** e **entorno** com data de verificação (aplica D-03, D-06, D-18) | Protótipo, com Rodrigo |
| D-22 | 2026-11-07 | Visual | Identidade visual **de trabalho** "Maré" (flat, iOS, neutros cinza + azul de contraste) documentada na skill `.claude/skills/mare-design/`. Provisória: ver [Q-26](questoes-em-aberto.md#q-26); o nome segue em aberto ([Q-01](questoes-em-aberto.md#q-01)) | Protótipo, com Rodrigo |
| D-23 | 2026-11-09 | Blueprint | Blueprint v2: a **curadoria vira processo contínuo** numa coluna 00 "Base curada", antes da jornada (indicação dos locais, análise pelos critérios, publicação, vídeos, manutenção). O bastidor de cada etapa mostra só o que acontece naquele momento. **Selecionar e salvar viram uma etapa só (03)**: tocar em salvar pede a conta na hora (aplica D-16). Datas e hospedagem passam para a etapa do agente. "Organiza locais com o agente" passa de 05 para **04** (D-20 usa a numeração da v1) | Feedback do grupo sobre o blueprint v1 |
