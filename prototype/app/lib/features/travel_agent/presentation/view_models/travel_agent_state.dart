part of 'travel_agent_cubit.dart';

enum AgentPhase { idle, thinking, itinerary, error }

enum CalendarStatus { disconnected, verifying, connected }

enum SwapStatus { none, proposed, accepted, declined }

class TravelAgentState extends Equatable {
  const TravelAgentState({
    required this.scenario,
    required this.phase,
    required this.messages,
    required this.savedRoleIds,
    required this.days,
    this.thinkingStep = 0,
    this.thinkingKind = ThinkingKind.quick,
    this.dayIndex = 0,
    this.selectedRoleId,
    this.detailRoleId,
    this.calendarSheetOpen = false,
    this.calendarStatus = CalendarStatus.disconnected,
    this.appConnections = const {},
    this.addedExtras = const {},
    this.extraRides = const {},
    this.swapStatus = SwapStatus.none,
    this.messagesUsed = TravelMock.messagesUsed,
    this.highlightRoleIds = const [],
    this.itineraryOpen = false,
    this.itineraryFocused = false,
    this.itineraryEditing = false,
    this.mapOpen = false,
  });

  final TravelAgentScenario scenario;
  final AgentPhase phase;
  final List<AgentMessage> messages;

  /// Rolês salvos na etapa 04 (vazio no cenário Vazio).
  final List<String> savedRoleIds;
  final List<ItineraryDay> days;
  final int thinkingStep;
  final ThinkingKind thinkingKind;
  final int dayIndex;

  /// Pin/parada em foco (sincroniza mapa ↔ timeline).
  final String? selectedRoleId;

  /// Card do rolê aberto dentro do sheet.
  final String? detailRoleId;
  final bool calendarSheetOpen;
  final CalendarStatus calendarStatus;

  /// Outros apps do sheet de conectores (Maps, Uber, 99). Mesmo ciclo da
  /// agenda: desconectado → verificando → conectado. Ausente = desconectado.
  final Map<ConnectorKind, CalendarStatus> appConnections;
  final Set<String> addedExtras;

  /// Corrida escolhida por extra de transfer (extraId → RideOption.id).
  final Map<String, String> extraRides;
  final SwapStatus swapStatus;
  final int messagesUsed;

  /// Rolês destacados por um filtro de chip ("Só rolê de comida").
  final List<String> highlightRoleIds;

  /// Roteiro completo (calendário) aberto no sheet.
  final bool itineraryOpen;

  /// Roteiro: um dia escolhido → a grade da semana vira o guia do dia.
  final bool itineraryFocused;

  /// Guia do dia em edição (botão Editar do cabeçalho).
  final bool itineraryEditing;

  /// Visão de mapa (sheet sobre o mapa). Fechada = conversa em tela cheia,
  /// que é como a tela começa.
  final bool mapOpen;

  bool get hasItinerary => phase == AgentPhase.itinerary;

  /// Começo do zero: nada salvo e nada enviado — abre no mapa com a
  /// saudação central (sem sheet).
  bool get isBlankStart => savedRoleIds.isEmpty && messages.isEmpty;
  ItineraryDay get currentDay => days[dayIndex];
  int get messagesLeft => TravelMock.messageLimit - messagesUsed;

  TravelAgentState copyWith({
    AgentPhase? phase,
    List<AgentMessage>? messages,
    List<String>? savedRoleIds,
    List<ItineraryDay>? days,
    int? thinkingStep,
    ThinkingKind? thinkingKind,
    int? dayIndex,
    String? selectedRoleId,
    bool clearSelected = false,
    String? detailRoleId,
    bool clearDetail = false,
    bool? calendarSheetOpen,
    CalendarStatus? calendarStatus,
    Map<ConnectorKind, CalendarStatus>? appConnections,
    Set<String>? addedExtras,
    Map<String, String>? extraRides,
    SwapStatus? swapStatus,
    int? messagesUsed,
    List<String>? highlightRoleIds,
    bool? itineraryOpen,
    bool? itineraryFocused,
    bool? itineraryEditing,
    bool? mapOpen,
  }) {
    return TravelAgentState(
      scenario: scenario,
      phase: phase ?? this.phase,
      messages: messages ?? this.messages,
      savedRoleIds: savedRoleIds ?? this.savedRoleIds,
      days: days ?? this.days,
      thinkingStep: thinkingStep ?? this.thinkingStep,
      thinkingKind: thinkingKind ?? this.thinkingKind,
      dayIndex: dayIndex ?? this.dayIndex,
      selectedRoleId:
          clearSelected ? null : (selectedRoleId ?? this.selectedRoleId),
      detailRoleId: clearDetail ? null : (detailRoleId ?? this.detailRoleId),
      calendarSheetOpen: calendarSheetOpen ?? this.calendarSheetOpen,
      calendarStatus: calendarStatus ?? this.calendarStatus,
      appConnections: appConnections ?? this.appConnections,
      addedExtras: addedExtras ?? this.addedExtras,
      extraRides: extraRides ?? this.extraRides,
      swapStatus: swapStatus ?? this.swapStatus,
      messagesUsed: messagesUsed ?? this.messagesUsed,
      highlightRoleIds: highlightRoleIds ?? this.highlightRoleIds,
      itineraryOpen: itineraryOpen ?? this.itineraryOpen,
      itineraryFocused: itineraryFocused ?? this.itineraryFocused,
      itineraryEditing: itineraryEditing ?? this.itineraryEditing,
      mapOpen: mapOpen ?? this.mapOpen,
    );
  }

  @override
  List<Object?> get props => [
        scenario,
        phase,
        messages,
        savedRoleIds,
        days,
        thinkingStep,
        thinkingKind,
        dayIndex,
        selectedRoleId,
        detailRoleId,
        calendarSheetOpen,
        calendarStatus,
        appConnections,
        addedExtras,
        extraRides,
        swapStatus,
        messagesUsed,
        highlightRoleIds,
        itineraryOpen,
        itineraryFocused,
        itineraryEditing,
        mapOpen,
      ];
}
