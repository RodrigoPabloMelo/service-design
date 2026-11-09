# Protótipo — Maré (Flutter web)

Protótipo navegável do serviço de rolês locais para mulheres viajantes (piloto Recife/Olinda). **Maré** é nome de trabalho ([Q-01](../../docs/questoes-em-aberto.md#q-01)).

- O que o serviço é e por que cada tela existe: [docs/README.md](../../docs/README.md)
- O que este protótipo cobre (telas ↔ jornada, personas, decisões): [docs/prototipo.md](../../docs/prototipo.md)
- Restrições de UX para gerar telas e textos: [UX.md](../../UX.md)
- Sistema visual: [.claude/skills/mare-design](../../.claude/skills/mare-design/SKILL.md)

Dados são mock (`lib/features/travel_agent/data/travel_agent_mock.dart`); não há backend.

## Rodar

Flutter **3.47.9** (fixado em `.fvmrc`, instalado via [fvm](https://fvm.app)).

```bash
fvm install
fvm flutter pub get
fvm flutter run -d chrome -t lib/main_design.dart
```

Abra `/agente`. Build de produção web:

```bash
fvm flutter build web --release -t lib/main_design.dart
tool/check_icons.sh   # confere se nenhum ícone foi cortado no build
```

## Estrutura

```
lib/
├── main_design.dart          # entry do protótipo (sem dart:io)
├── core/                     # DI, tema, componentes compartilhados (vidro, etc.)
└── features/
    ├── feature_registry.dart # telas que aparecem no protótipo
    └── travel_agent/         # agente de roteiros (/agente)
        ├── data/             # mock e cenários (padrao, vazio, erro, carregando)
        ├── domain/           # entidades (Role, Recommender, ItineraryDay...)
        └── presentation/     # Cubit + State, página e widgets
assets/images/roles/CREDITS.md  # créditos das fotos (Wikimedia Commons)
```

Regras de código e de design: [CLAUDE.md](../../CLAUDE.md).
