import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:studio_app/core/utils/extensions/cubit_extension.dart';
import 'package:studio_app/features/travel_agent/data/travel_agent_mock.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';

part 'travel_agent_state.dart';

/// Agente "Maré" — etapa 04 do blueprint (organiza locais com o agente).
///
/// Loop de design: respostas scriptadas com [Timer]s (cancelados no
/// [close]). No loop de dev, troca-se só a injeção (mock → repositório).
class TravelAgentCubit extends Cubit<TravelAgentState> {
  TravelAgentCubit({TravelAgentScenario scenario = TravelAgentScenario.padrao})
      : super(_initial(scenario));

  final List<Timer> _timers = [];
  int _seq = 0;
  String? _pending;

  static const _organize = 'Organizar meus 8 rolês';

  static TravelAgentState _initial(TravelAgentScenario scenario) {
    final saved = TravelMock.savedRoles.map((r) => r.id).toList();
    switch (scenario) {
      case TravelAgentScenario.padrao:
        return TravelAgentState(
          scenario: scenario,
          phase: AgentPhase.idle,
          savedRoleIds: saved,
          days: TravelMock.itinerary,
          // A saudação vive no bloco-resumo; logo abaixo, só as sugestões
          // (os salvos aparecem quando o agente responde).
          messages: const [],
        );
      case TravelAgentScenario.vazio:
        return TravelAgentState(
          scenario: scenario,
          phase: AgentPhase.idle,
          savedRoleIds: const [],
          days: TravelMock.itinerary,
          // Começo do zero: abre no mapa (ideia do lugar), sem bloco-resumo.
          messages: const [],
          mapOpen: true,
        );
      case TravelAgentScenario.erro:
        return TravelAgentState(
          scenario: scenario,
          phase: AgentPhase.error,
          savedRoleIds: saved,
          days: TravelMock.itinerary,
          messages: const [
            AgentMessage(
              id: 'm0',
              author: MessageAuthor.user,
              kind: MessageKind.text,
              text: _organize,
            ),
            AgentMessage(
              id: 'm1',
              author: MessageAuthor.agent,
              kind: MessageKind.error,
              text: 'Não consegui montar o roteiro agora. Seus rolês salvos '
                  'continuam aqui — tenta de novo em instantes.',
            ),
          ],
        );
      case TravelAgentScenario.carregando:
        return TravelAgentState(
          scenario: scenario,
          phase: AgentPhase.thinking,
          savedRoleIds: saved,
          days: TravelMock.itinerary,
          thinkingStep: 1,
          thinkingKind: ThinkingKind.collect,
          messages: const [
            AgentMessage(
              id: 'm0',
              author: MessageAuthor.user,
              kind: MessageKind.text,
              text: _organize,
            ),
          ],
        );
    }
  }

  String _id() => 'x${_seq++}';

  void _after(Duration d, void Function() fn) {
    _timers.add(Timer(d, () {
      if (!isClosed) fn();
    }));
  }

  List<AgentMessage> _with(List<AgentMessage> add) =>
      [...state.messages, ...add];

  /// O pedido vai virar roteiro (processo longo, com a visão de agente)?
  bool _willBuildItinerary(String text) =>
      state.savedRoleIds.isNotEmpty &&
      !state.hasItinerary &&
      !_wantsMap(text.toLowerCase()) &&
      _filterFor(text.toLowerCase()) == null;

  bool _wantsMap(String t) => t.contains('mapa');

  /// Chip de sugestão ou texto digitado.
  void send(String text) {
    if (state.phase == AgentPhase.thinking || text.trim().isEmpty) return;
    if (state.messagesLeft <= 0) return;
    final kind =
        _willBuildItinerary(text) ? ThinkingKind.collect : ThinkingKind.quick;
    _pending = text;
    safeEmit(state.copyWith(
      phase: AgentPhase.thinking,
      thinkingStep: 0,
      thinkingKind: kind,
      messagesUsed: state.messagesUsed + 1,
      clearDetail: true,
      messages: _with([
        AgentMessage(
          id: _id(),
          author: MessageAuthor.user,
          kind: MessageKind.text,
          text: text.trim(),
        ),
      ]),
    ));
    // Doherty: feedback imediato; cada passo entra no seu tempo.
    final marks = kind == ThinkingKind.collect
        ? TravelMock.collectTimeline
        : TravelMock.quickTimeline;
    for (var i = 1; i < marks.length - 1; i++) {
      _after(Duration(milliseconds: marks[i]), () {
        safeEmit(state.copyWith(thinkingStep: i));
      });
    }
    _after(Duration(milliseconds: marks.last), () => _respond(text));
  }

  /// "Pular": encerra o processo e responde na hora.
  void skipThinking() {
    if (state.phase != AgentPhase.thinking) return;
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
    _respond(_pending ?? 'Organizar meus 8 rolês');
  }

  (List<String>, String)? _filterFor(String t) {
    if (t.contains('comida')) {
      return (
        _idsWhere((r) => r.category == RoleCategory.comida),
        'Dos seus salvos, esses são de comer bem:',
      );
    }
    if (t.contains('noite') || t.contains('amigas')) {
      return (
        _idsWhere((r) => r.category == RoleCategory.noite),
        'Pra noite com as amigas, os dois mais elogiados por quem mora '
            'aqui. Os dois têm transfer com motorista mulher na volta.',
      );
    }
    if (t.contains('graça')) {
      return (_idsWhere((r) => r.price == 'Grátis'), 'Esses não custam nada:');
    }
    if (t.contains('hotel') || t.contains('perto')) {
      return (['dona-lindu'], 'O mais perto do seu hotel fica a 15 min a pé:');
    }
    return null;
  }

  void _respond(String text) {
    final t = text.toLowerCase();
    _pending = null;
    final process = AgentMessage(
      id: _id(),
      author: MessageAuthor.agent,
      kind: MessageKind.process,
      text: state.thinkingKind.name,
    );
    if (state.savedRoleIds.isEmpty) {
      safeEmit(state.copyWith(
        phase: AgentPhase.idle,
        savedRoleIds: TravelMock.savedRoles.map((r) => r.id).toList(),
        messages: _with([
          process,
          AgentMessage(
            id: _id(),
            author: MessageAuthor.agent,
            kind: MessageKind.text,
            text: 'Separei 8 rolês de gente daqui. Toca num pin ou num '
                'card pra ver fotos e vídeos.',
          ),
          AgentMessage(
            id: _id(),
            author: MessageAuthor.agent,
            kind: MessageKind.savedRoles,
          ),
        ]),
      ));
      return;
    }

    // "Me mostra no mapa": a conversa dá lugar à visão de mapa.
    if (_wantsMap(t)) {
      safeEmit(state.copyWith(
        phase: _restingPhase,
        mapOpen: true,
        messages: _with([
          process,
          AgentMessage(
            id: _id(),
            author: MessageAuthor.agent,
            kind: MessageKind.text,
            text: state.messages.any((m) => m.kind == MessageKind.itinerary)
                ? 'Abri o roteiro no mapa, dia a dia.'
                : 'Abri o mapa com os seus rolês salvos.',
          ),
        ]),
      ));
      return;
    }

    final filtered = _filterFor(t);
    final filter = filtered?.$1;
    final intro = filtered?.$2;

    if (filter != null) {
      safeEmit(state.copyWith(
        phase: _restingPhase,
        highlightRoleIds: filter,
        messages: _with([
          process,
          AgentMessage(
            id: _id(),
            author: MessageAuthor.agent,
            kind: MessageKind.text,
            text: intro!,
          ),
          AgentMessage(
            id: _id(),
            author: MessageAuthor.agent,
            kind: MessageKind.savedRoles,
            text: filter.join(','),
          ),
        ]),
      ));
      return;
    }

    if (state.hasItinerary) {
      safeEmit(state.copyWith(
        phase: AgentPhase.itinerary,
        messages: _with([
          process,
          AgentMessage(
            id: _id(),
            author: MessageAuthor.agent,
            kind: MessageKind.text,
            text: 'Anotado! Mantive o roteiro e só sugiro rolês da '
                'curadoria local. Quer trocar alguma parada?',
          ),
        ]),
      ));
      return;
    }

    safeEmit(state.copyWith(
      phase: AgentPhase.itinerary,
      dayIndex: 0,
      highlightRoleIds: const [],
      clearSelected: true,
      messages: _with([
        process,
        AgentMessage(
          id: _id(),
          author: MessageAuthor.agent,
          kind: MessageKind.text,
          text: 'Pronto! Agrupei seus 8 rolês em 3 dias, por bairro. '
              'Nenhuma parada fica a mais de 25 min da anterior.',
        ),
        AgentMessage(
          id: _id(),
          author: MessageAuthor.agent,
          kind: MessageKind.itinerary,
        ),
        AgentMessage(
          id: _id(),
          author: MessageAuthor.agent,
          kind: MessageKind.extras,
          text: 'Extras pra sábado',
        ),
        AgentMessage(
          id: _id(),
          author: MessageAuthor.agent,
          kind: MessageKind.calendarCta,
        ),
      ]),
    ));
  }

  AgentPhase get _restingPhase =>
      state.messages.any((m) => m.kind == MessageKind.itinerary)
          ? AgentPhase.itinerary
          : AgentPhase.idle;

  List<String> _idsWhere(bool Function(Role) test) => TravelMock.savedRoles
      .where((r) => state.savedRoleIds.contains(r.id) && test(r))
      .map((r) => r.id)
      .toList();

  void selectDay(int index) {
    if (index == state.dayIndex) return;
    safeEmit(state.copyWith(dayIndex: index, clearSelected: true));
  }

  /// Toque no pin ou na parada — destaca nos dois (conectividade).
  void selectRole(String? id) {
    if (id == null) {
      safeEmit(state.copyWith(clearSelected: true));
      return;
    }
    // Se a parada é de outro dia, pula pra ele.
    final day = state.days.indexWhere(
      (d) => d.stops.any((s) => s.roleId == id),
    );
    safeEmit(state.copyWith(
      selectedRoleId: id,
      dayIndex: state.hasItinerary && day >= 0 ? day : state.dayIndex,
    ));
  }

  void openRole(String id) {
    safeEmit(state.copyWith(detailRoleId: id, selectedRoleId: id));
  }

  void closeRole() => safeEmit(state.copyWith(clearDetail: true));

  void openItinerary() => safeEmit(state.copyWith(
      itineraryOpen: true, itineraryFocused: false, itineraryEditing: false));

  void closeItinerary() => safeEmit(state.copyWith(
      itineraryOpen: false, itineraryFocused: false, itineraryEditing: false));

  /// Roteiro: abre o guia do [index]. Tocar no dia já aberto volta pra
  /// semana.
  void focusDay(int index) {
    if (state.itineraryFocused && state.dayIndex == index) {
      unfocusDay();
      return;
    }
    safeEmit(state.copyWith(
      dayIndex: index,
      itineraryFocused: true,
      clearSelected: true,
    ));
  }

  void unfocusDay() => safeEmit(
      state.copyWith(itineraryFocused: false, itineraryEditing: false));

  void toggleItineraryEdit() =>
      safeEmit(state.copyWith(itineraryEditing: !state.itineraryEditing));

  /// Edição do guia: tira o rolê do dia aberto.
  void removeStop(String roleId) {
    final days = [...state.days];
    final d = days[state.dayIndex];
    days[state.dayIndex] = d.copyWith(
      stops: [
        for (final s in d.stops)
          if (s.roleId != roleId) s
      ],
    );
    safeEmit(state.copyWith(days: days));
  }

  void openMap() => safeEmit(state.copyWith(mapOpen: true));

  void closeMap() => safeEmit(state.copyWith(mapOpen: false));

  void toggleExtra(String id) {
    final next = {...state.addedExtras};
    final removed = next.remove(id);
    if (!removed) next.add(id);
    safeEmit(state.copyWith(
      addedExtras: next,
      extraRides: removed ? ({...state.extraRides}..remove(id)) : null,
    ));
  }

  /// Transfer: adiciona o extra com a corrida (app + categoria) escolhida.
  void chooseRide(String extraId, String rideId) {
    safeEmit(state.copyWith(
      addedExtras: {...state.addedExtras, extraId},
      extraRides: {...state.extraRides, extraId: rideId},
    ));
  }

  void openCalendar() => safeEmit(state.copyWith(calendarSheetOpen: true));

  void closeCalendar() => safeEmit(state.copyWith(calendarSheetOpen: false));

  int get eventsCount => state.days.fold(0, (n, d) => n + d.stops.length);

  /// Conecta Maps, Uber ou 99 direto na linha do sheet (mock OAuth curto).
  /// A agenda segue no fluxo próprio ([connectCalendar]).
  void connectApp(ConnectorKind kind) {
    final current = state.appConnections[kind] ?? CalendarStatus.disconnected;
    if (current != CalendarStatus.disconnected) return;
    safeEmit(state.copyWith(appConnections: {
      ...state.appConnections,
      kind: CalendarStatus.verifying,
    }));
    _after(const Duration(milliseconds: 1200), () {
      safeEmit(state.copyWith(appConnections: {
        ...state.appConnections,
        kind: CalendarStatus.connected,
      }));
    });
  }

  void connectCalendar() {
    if (state.calendarStatus != CalendarStatus.disconnected) return;
    safeEmit(state.copyWith(calendarStatus: CalendarStatus.verifying));
    _after(const Duration(milliseconds: 1800), () {
      // O bloco do CTA vira a confirmação (sem mensagem duplicada).
      safeEmit(state.copyWith(calendarStatus: CalendarStatus.connected));
      // Etapa 06: agente monitora clima e propõe 1 troca perto.
      _after(const Duration(milliseconds: 2600), () {
        if (!state.hasItinerary || state.swapStatus != SwapStatus.none) return;
        safeEmit(state.copyWith(
          swapStatus: SwapStatus.proposed,
          messages: _with([
            AgentMessage(
              id: _id(),
              author: MessageAuthor.agent,
              kind: MessageKind.swapProposal,
              text: 'Chuva prevista sábado às 15h. Troco o Sítio da '
                  'Trindade pelo Mercado de Casa Amarela? É coberto e fica '
                  'a 900 m.',
            ),
          ]),
        ));
      });
    });
  }

  void acceptSwap() {
    if (state.swapStatus != SwapStatus.proposed) return;
    final days = [
      for (final d in state.days)
        d.id == TravelMock.swapDayId
            ? d.copyWith(stops: [
                for (final s in d.stops)
                  s.roleId == TravelMock.swapFromId
                      ? s.copyWith(roleId: TravelMock.swapToId)
                      : s,
              ])
            : d,
    ];
    final dayIndex = days.indexWhere((d) => d.id == TravelMock.swapDayId);
    safeEmit(state.copyWith(
      days: days,
      dayIndex: dayIndex,
      selectedRoleId: TravelMock.swapToId,
      swapStatus: SwapStatus.accepted,
      messages: _with([
        AgentMessage(
          id: _id(),
          author: MessageAuthor.agent,
          kind: MessageKind.swapDone,
          text: 'Troquei. Sábado 15h: Mercado de Casa Amarela. '
              'Calendário atualizado.',
        ),
      ]),
    ));
  }

  void declineSwap() {
    if (state.swapStatus != SwapStatus.proposed) return;
    safeEmit(state.copyWith(
      swapStatus: SwapStatus.declined,
      messages: _with([
        AgentMessage(
          id: _id(),
          author: MessageAuthor.agent,
          kind: MessageKind.text,
          text: 'Mantive o Sítio da Trindade. Te aviso se a previsão '
              'piorar até sábado.',
        ),
      ]),
    ));
  }

  void retry() {
    if (state.phase != AgentPhase.error) return;
    safeEmit(state.copyWith(
      phase: AgentPhase.idle,
      messages:
          state.messages.where((m) => m.kind != MessageKind.error).toList()
            ..removeWhere((m) => m.author == MessageAuthor.user),
    ));
    send(_organize);
  }

  @override
  Future<void> close() {
    for (final t in _timers) {
      t.cancel();
    }
    return super.close();
  }
}
