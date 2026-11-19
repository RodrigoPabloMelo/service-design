import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:studio_app/core/utils/extensions/cubit_extension.dart';
import 'package:studio_app/features/travel_agent/data/travel_agent_mock.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';
import 'package:studio_app/features/travel_agent/presentation/view_models/travel_agent_cubit.dart';

/// Uma conversa na gaveta: a antiga do mock ([seed]) ou uma feita nesta
/// sessão ([snapshot], o estado em que ela foi deixada).
class ConversationEntry extends Equatable {
  const ConversationEntry({
    required this.id,
    required this.title,
    this.pinned = false,
    this.seed,
    this.snapshot,
  });

  final String id;
  final String title;
  final bool pinned;
  final ConversationSeed? seed;
  final TravelAgentState? snapshot;

  ConversationEntry withSnapshot(TravelAgentState s) => ConversationEntry(
      id: id, title: title, pinned: pinned, seed: seed, snapshot: s);

  @override
  List<Object?> get props => [id, title, pinned, seed, snapshot];
}

class ConversationsState extends Equatable {
  const ConversationsState({
    required this.entries,
    this.activeId,
    this.newChats = 0,
    this.messagesUsed = TravelMock.messagesUsed,
  });

  /// Fixadas e recentes, mais nova primeiro.
  final List<ConversationEntry> entries;

  /// Conversa aberta; `null` = conversa nova (ainda não está na gaveta).
  final String? activeId;

  /// Conta as conversas novas: cada uma ganha uma tela própria (key).
  final int newChats;

  /// Mensagens usadas na semana, somando todas as conversas (o limite é
  /// da semana, não de cada conversa — D-17, Q-35).
  final int messagesUsed;

  List<ConversationEntry> get pinned =>
      entries.where((e) => e.pinned).toList();
  List<ConversationEntry> get recent =>
      entries.where((e) => !e.pinned).toList();

  ConversationEntry? get active =>
      entries.where((e) => e.id == activeId).firstOrNull;

  /// Key da tela da conversa aberta: trocar recria cubit e view.
  String get viewKey => activeId ?? 'nova-$newChats';

  @override
  List<Object?> get props => [entries, activeId, newChats, messagesUsed];
}

/// Gaveta de conversas do agente (☰), ref. ChatGPT.
///
/// No protótipo a lista vive só na sessão: antigas vêm do mock e conversas
/// novas entram em "Recentes" quando a pessoa sai delas (Q-40).
class ConversationsCubit extends Cubit<ConversationsState> {
  /// [activeId]: a tela abre numa conversa da gaveta (a chuva é a
  /// conversa fixada do roteiro; o erro, a que falhou).
  ConversationsCubit({bool seeded = true, String? activeId})
      : super(ConversationsState(activeId: activeId, entries: [
          if (seeded)
            for (final c in TravelMock.conversations)
              ConversationEntry(
                  id: c.id, title: c.title, pinned: c.pinned, seed: c),
        ]));

  int _seq = 0;

  /// Abre uma conversa da gaveta, guardando a atual ([current]).
  void open(String id, {TravelAgentState? current}) {
    if (id == state.activeId) return;
    final entries = _archive(current);
    safeEmit(ConversationsState(
        entries: entries,
        activeId: id,
        newChats: state.newChats,
        messagesUsed: _used(current)));
  }

  /// "Nova conversa": guarda a atual e abre uma em branco.
  void startNew({TravelAgentState? current}) {
    final entries = _archive(current);
    // Já numa conversa nova sem nada enviado: não recria a tela.
    if (state.activeId == null && entries.length == state.entries.length &&
        !_hasUserMessage(current)) {
      return;
    }
    safeEmit(ConversationsState(
        entries: entries,
        activeId: null,
        newChats: state.newChats + 1,
        messagesUsed: _used(current)));
  }

  int _used(TravelAgentState? current) =>
      current == null || current.messagesUsed < state.messagesUsed
          ? state.messagesUsed
          : current.messagesUsed;

  static bool _hasUserMessage(TravelAgentState? s) =>
      s != null && s.messages.any((m) => m.author == MessageAuthor.user);

  /// Conversa nova com mensagem dela vira a primeira de "Recentes" (título =
  /// 1ª mensagem); conversa da gaveta guarda onde parou. Sem mensagem, some.
  List<ConversationEntry> _archive(TravelAgentState? current) {
    final entries = [...state.entries];
    if (current == null) return entries;
    final active = state.activeId;
    if (active != null) {
      final i = entries.indexWhere((e) => e.id == active);
      if (i >= 0) entries[i] = entries[i].withSnapshot(current);
      return entries;
    }
    if (!_hasUserMessage(current)) return entries;
    final first =
        current.messages.firstWhere((m) => m.author == MessageAuthor.user);
    final at = entries.indexWhere((e) => !e.pinned);
    entries.insert(
      at < 0 ? entries.length : at,
      ConversationEntry(
          id: 'sessao-${_seq++}', title: first.text, snapshot: current),
    );
    return entries;
  }
}
