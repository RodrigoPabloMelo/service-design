---
name: design-feedback
description: Registra feedback visual do designer como regra durável do sistema da Maré (skill mare-design + lint). Use sempre que o designer corrigir ou definir algo visual da interface — cor, peso de fonte, espaçamento, raio, botão, ícone, animação, texto de UI, fluxo de tela — mesmo que ele não peça para registrar.
when_to_use: "não use sombra", "tira esse separador", "isso tá muito Material", "botão deve ficar…", "prefiro…", "sempre/nunca faça…" sobre a UI do app.
---

# Registrar feedback de design

Aplique a mudança pedida no código primeiro. Depois, na mesma resposta:

1. **Generalize.** Transforme o caso em regra reutilizável (o quê + onde
   vale). Ex.: "o botão Assinar não pode ter brilhinho" → "sem ícone de
   brilho/varinha pra significar IA, em qualquer botão".
2. **Ache o lugar certo** em `.claude/skills/mare-design/`:
   - regra transversal curta e que já quebrou mais de uma vez → lista
     "Regras que mais quebram" do `SKILL.md` (máx. ~12 itens);
   - valor (cor, tamanho, raio, duração) → `tokens.md` e o token no código
     (`travel_tokens.dart`);
   - comportamento de componente ou fluxo → `patterns.md`;
   - texto → `writing.md`.
   Atualize a regra existente em vez de duplicar; se contradiz uma antiga,
   troque a antiga.
3. **Automatize se der.** Se a regra é detectável por padrão de código com
   poucos falsos positivos, adicione uma entrada em `RULES` de
   `.claude/skills/mare-design/scripts/design_lint.py` (próximo id `Dxx`,
   severidade `erro` ou `aviso`) e rode o lint no feature inteiro:
   `/usr/bin/python3 -I .claude/skills/mare-design/scripts/design_lint.py`.
   Corrija o que ele achar ou anote exceção legítima com
   `// design-lint: ignore Dxx`.
4. **Conte em uma linha** ao designer qual regra entrou e onde.

Não registre preferência de uma tela só que o designer disse ser exceção.
