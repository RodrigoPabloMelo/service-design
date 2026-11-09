import 'package:studio_app/features/feature_registry.dart';

/// Descrição e links de uma tela vivem no repositório, em
/// `RegisteredScreen.descricao` / `.links` (feature_registry.dart) — é o que
/// chega no dev pelo handoff.
///
/// O /docs não edita esses campos: rascunho digitado no browser ficava preso
/// no localStorage daquela máquina e nunca virava commit. No lugar disso, a
/// página entrega o comando pronto para pedir a escrita ao Claude, que altera
/// o registry de verdade.

/// Comando para colar no chat do Claude, já apontando para a tela exata.
///
/// Termina em `Descrição:` de propósito — quem cola completa a frase ali.
String claudeNotesPrompt(RegisteredScreen screen) =>
    'Na tela "${screen.title}" (rota ${screen.route}, fluxo ${screen.flow}), '
    'preencha `descricao` e `links` do RegisteredScreen dela em '
    'app/lib/features/feature_registry.dart.\n'
    'Descrição: ';
