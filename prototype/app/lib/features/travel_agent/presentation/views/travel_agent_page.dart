import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studio_app/core/components/glass/app_glass.dart';
import 'package:studio_app/features/travel_agent/data/travel_agent_mock.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';
import 'package:studio_app/features/travel_agent/presentation/view_models/travel_agent_cubit.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/agent_sheet.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/blank_start.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/calendar_connect_sheet.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/connector_carousel.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/itinerary_view.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/place_detail.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/recife_map.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/short_video_player.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/usage_sheet.dart';

/// Etapa 04 do blueprint — "Organiza locais com o agente".
///
/// Começa como conversa em tela cheia. O mapa só aparece quando a pessoa
/// pede (menu ⋯, "Ver no mapa" ou pedindo ao agente): o sheet desce e revela
/// o mapa. Subir o sheet até o topo (ou voltar) retorna à conversa.
///
/// Começo do zero (nada salvo): abre direto no mapa, sem sheet, com a
/// saudação central ([BlankStartHero]); no primeiro envio o sheet sobe até
/// o detent médio e o mapa fica aberto.
///
/// Camadas (HIG): mapa (conteúdo) → controles em Liquid Glass → sheet sólido
/// com a conversa → menu → overlays (agenda, player).
class TravelAgentPage extends StatelessWidget {
  const TravelAgentPage(
      {this.scenario = TravelAgentScenario.padrao, super.key});

  final TravelAgentScenario scenario;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: travelTheme(context),
      child: BlocProvider(
        create: (_) => TravelAgentCubit(scenario: scenario),
        child: const _TravelAgentView(),
      ),
    );
  }
}

class _TravelAgentView extends StatefulWidget {
  const _TravelAgentView();

  @override
  State<_TravelAgentView> createState() => _TravelAgentViewState();
}

class _TravelAgentViewState extends State<_TravelAgentView> {
  static const _snaps = [0.2, 0.52, 0.92];

  /// Conversa em tela cheia: o sheet ocupa 100% e não arrasta.
  static const _full = 1.0;

  final _sheet = DraggableScrollableController();
  ScrollController? _list;
  late double _extent;
  int _recenter = 0;

  /// Travado na conversa (só depois da transição de volta terminar).
  late bool _chatLocked;

  /// Tamanho com que o sheet nasce (conversa cheia, ou detent médio quando
  /// a tela abre no mapa).
  late final double _initialSize;

  /// Começou no zero: o sheet entra deslizando no primeiro envio.
  late final bool _slideIn;
  int _animations = 0;
  bool _menuOpen = false;

  /// A pessoa está arrastando o sheet (lista ou alça) — só assim chegar ao
  /// topo volta pra conversa; animações programadas não contam.
  bool _userDrag = false;

  /// 0 = sheet sobre o mapa, 1 = conversa em tela cheia (morfa no arraste).
  double get _chatT => _chatTFor(_extent);

  double _chatTFor(double extent) => _chatLocked
      ? 1
      : ((extent - _snaps[2]) / (_full - _snaps[2])).clamp(0.0, 1.0);

  /// Tamanho do sheet quadro a quadro. Só os controles do mapa acompanham
  /// cada quadro (por aqui); a página reconstrói só quando muda algo que a
  /// árvore lê ([_visualKey]) — antes a conversa inteira era refeita a cada
  /// quadro do arraste.
  late final ValueNotifier<double> _extentN = ValueNotifier(_initialSize);

  /// O que a árvore lê do tamanho do sheet: a morfose conversa↔mapa
  /// (`_chatT`, só varia entre 0,92 e 1), a opacidade dos controles do mapa
  /// (> 0,7), o véu do mapa (> 0,8) e o topo (≥ 0,999).
  (double, bool, bool, bool) _visualKey(double extent) => (
        _chatTFor(extent),
        extent > 0.7,
        extent > 0.8,
        extent >= 0.999,
      );

  void _setExtent(double extent) {
    final before = _visualKey(_extent);
    _extent = extent;
    _extentN.value = extent;
    if (_visualKey(extent) != before) setState(() {});
  }

  /// Vídeo aberto: rolê, índice e retângulo do tile (origem da expansão).
  (Role, int, Rect?)? _player;
  final _stackKey = GlobalKey();

  Rect? _originOf(BuildContext tile) {
    final tileBox = tile.findRenderObject() as RenderBox?;
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (tileBox == null || stackBox == null || !tileBox.attached) return null;
    final topLeft = stackBox.globalToLocal(tileBox.localToGlobal(Offset.zero));
    return topLeft & tileBox.size;
  }

  TravelAgentState? _last;

  @override
  void initState() {
    super.initState();
    final s = context.read<TravelAgentCubit>().state;
    _chatLocked = !s.mapOpen;
    _initialSize = s.mapOpen ? _snaps[1] : _full;
    _extent = _initialSize;
    _slideIn = s.isBlankStart;
  }

  @override
  void dispose() {
    _sheet.dispose();
    _extentN.dispose();
    super.dispose();
  }

  Future<void> _animateSheet(double to, {bool mode = false}) async {
    if (!_sheet.isAttached || _chatLocked) return;
    _userDrag = false;
    _animations++;
    try {
      await _sheet.animateTo(
        to,
        duration: MediaQuery.disableAnimationsOf(context)
            ? const Duration(milliseconds: 1)
            : Duration(milliseconds: mode ? 520 : 420),
        curve: mode ? const Cubic(0.2, 0, 0, 1) : Curves.easeOutCubic,
      );
    } finally {
      _animations--;
    }
  }

  /// Conversa → mapa: destrava o sheet e desce até o detent médio.
  void _showMap(TravelAgentState s) {
    setState(() => _chatLocked = false);
    // Dois quadros: o sheet aplica os novos detents (e agenda o próprio
    // snap) antes da descida começar.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final open = s.detailRoleId != null || s.itineraryOpen;
        _animateSheet(open ? _snaps[2] : _snaps[1], mode: true);
      });
      // Callback de pós-quadro não agenda quadro sozinho.
      WidgetsBinding.instance.scheduleFrame();
    });
  }

  /// Mapa → conversa: sobe até o topo e só então trava.
  Future<void> _showChat(TravelAgentCubit cubit) async {
    await _animateSheet(_full, mode: true);
    if (mounted && !cubit.state.mapOpen) setState(() => _chatLocked = true);
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = _list;
      if (c == null || !c.hasClients) return;
      c.animateTo(
        c.position.maxScrollExtent,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _onState(
      BuildContext context, TravelAgentState prev, TravelAgentState s) {
    if (prev.mapOpen != s.mapOpen) {
      s.mapOpen ? _showMap(s) : _showChat(context.read<TravelAgentCubit>());
    }
    if (!s.mapOpen) {
      // Conversa em tela cheia: só rola a lista, o sheet não se mexe.
      if (prev.messages.length != s.messages.length ||
          prev.thinkingStep != s.thinkingStep ||
          (prev.phase != s.phase && s.phase == AgentPhase.thinking) ||
          (prev.detailRoleId != s.detailRoleId && s.detailRoleId == null)) {
        if (s.detailRoleId == null && !s.itineraryOpen) _scrollToEnd();
      }
      return;
    }
    if (prev.itineraryOpen != s.itineraryOpen && s.detailRoleId == null) {
      _animateSheet(s.itineraryOpen ? _snaps[2] : _snaps[1]);
    }
    if (prev.detailRoleId != s.detailRoleId) {
      _animateSheet(
        s.detailRoleId != null || s.itineraryOpen ? _snaps[2] : _snaps[1],
      );
      if (s.detailRoleId == null && !s.itineraryOpen) _scrollToEnd();
    }
    if (prev.messages.length != s.messages.length ||
        (prev.phase != s.phase && s.phase == AgentPhase.thinking) ||
        prev.thinkingStep != s.thinkingStep) {
      if (s.detailRoleId == null) _scrollToEnd();
    }
    if (prev.phase != AgentPhase.itinerary && s.phase == AgentPhase.itinerary) {
      if (_extent < _snaps[1]) _animateSheet(_snaps[1]);
    }
  }

  List<Role> _mapRoles(TravelAgentState s) {
    final ids = {
      ...s.savedRoleIds,
      if (s.hasItinerary)
        for (final d in s.days)
          for (final st in d.stops) st.roleId,
    };
    return TravelMock.allRoles.where((r) => ids.contains(r.id)).toList();
  }

  // Cache do mapa: arrastar o sheet reconstrói a página a cada frame, mas o
  // mapa só é recriado quando os dados dele mudam (mesma instância → o
  // Flutter pula o rebuild).
  Widget? _mapCache;
  int? _mapCacheKey;

  Widget _mapFor(
    TravelAgentState s,
    TravelAgentCubit cubit, {
    required MapMode mapMode,
    required double top,
    required double bottom,
  }) {
    final veil = _extent > 0.8 ? 1.0 : 0.0;
    final ghosts =
        s.savedRoleIds.isEmpty ? TravelMock.curationSpots : const <GeoPoint>[];
    final key = Object.hash(s, mapMode, top, bottom, veil, _recenter);
    if (key == _mapCacheKey && _mapCache != null) return _mapCache!;
    _mapCacheKey = key;
    return _mapCache = RepaintBoundary(
      child: RecifeMap(
        roles: _mapRoles(s),
        stay: TravelMock.profile.stayLocation,
        mode: mapMode,
        stops: s.hasItinerary ? s.currentDay.stops : const [],
        selectedId: s.selectedRoleId,
        highlightIds: s.highlightRoleIds,
        focusPadding: EdgeInsets.only(top: top, bottom: bottom),
        fitKey: '$mapMode-${s.dayIndex}-${s.highlightRoleIds.join()}-'
            '$_recenter-${s.swapStatus}-${s.savedRoleIds.length}',
        veil: veil,
        ghostSpots: ghosts,
        onSelect: (id) {
          if (id == null) return cubit.selectRole(null);
          if (!s.hasItinerary || s.selectedRoleId == id) {
            cubit.openRole(id);
          } else {
            cubit.selectRole(id);
          }
        },
      ),
    );
  }

  String _distance(GeoPoint a, GeoPoint b) {
    const r = 6371.0;
    double rad(double d) => d * math.pi / 180;
    final dLat = rad(b.lat - a.lat), dLng = rad(b.lng - a.lng);
    final h = math.pow(math.sin(dLat / 2), 2) +
        math.cos(rad(a.lat)) *
            math.cos(rad(b.lat)) *
            math.pow(math.sin(dLng / 2), 2);
    final km = 2 * r * math.asin(math.sqrt(h));
    return '${km.toStringAsFixed(1).replaceAll('.', ',')} km';
  }

  String? _scheduledAt(TravelAgentState s, String roleId) {
    if (!s.hasItinerary) return null;
    for (final d in s.days) {
      for (final st in d.stops) {
        if (st.roleId == roleId) return '${d.tab} ${st.time}';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final cubit = context.read<TravelAgentCubit>();
    final pad = MediaQuery.paddingOf(context);
    // Base da comparação: sem isso a 1ª mudança (ex.: abrir o mapa) passava
    // batida, porque prev == s.
    _last ??= cubit.state;

    return BlocConsumer<TravelAgentCubit, TravelAgentState>(
      listener: (context, s) {
        final prev = _last ?? s;
        _last = s;
        _onState(context, prev, s);
      },
      builder: (context, s) {
        return Scaffold(
          backgroundColor: p.s0,
          body: LayoutBuilder(
            builder: (context, box) {
              final mapMode =
                  s.hasItinerary ? MapMode.itinerary : MapMode.explore;
              final chatT = _chatT;
              return Stack(
                key: _stackKey,
                children: [
                  Positioned.fill(
                    // Conversa assentada: mapa fora da pintura (custo zero).
                    child: Offstage(
                      offstage: _chatLocked,
                      child: AppGlassScope(
                        background: _mapFor(
                          s,
                          cubit,
                          mapMode: mapMode,
                          top: pad.top + 72,
                          // Começo do zero: sem sheet, a cidade toda.
                          bottom: s.isBlankStart
                              ? pad.bottom + 24
                              : _snaps[1] * box.maxHeight,
                        ),
                        child: Stack(
                          children: [
                            // Começo do zero: saudação, composer e a maré
                            // em pixels sobre o mapa.
                            Positioned.fill(
                              child: AnimatedSwitcher(
                                duration: Duration(
                                    milliseconds:
                                        MediaQuery.disableAnimationsOf(context)
                                            ? 1
                                            : 260),
                                child: s.isBlankStart
                                    ? BlankStartHero(
                                        key: const ValueKey('zero'),
                                        used: s.messagesUsed,
                                        onSend: cubit.send,
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ),
                            // Controles do mapa (vidro, sobre o mapa). Seguem
                            // o sheet quadro a quadro sem reconstruir a página.
                            if (!s.isBlankStart)
                              ValueListenableBuilder<double>(
                                valueListenable: _extentN,
                                builder: (context, extent, child) =>
                                    AnimatedPositioned(
                                  duration: const Duration(milliseconds: 120),
                                  right: 12,
                                  bottom: extent * box.maxHeight + 12,
                                  child: child!,
                                ),
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: _extent > 0.7 ? 0 : 1,
                                  child: Column(
                                    children: [
                                      AppGlassIconButton(
                                        icon:
                                            const FaIcon(TravelIcons.recenter),
                                        semanticLabel: 'Recentrar mapa',
                                        color: p.ink,
                                        onPressed: () =>
                                            setState(() => _recenter++),
                                      ),
                                      const SizedBox(height: 8),
                                      AppGlassIconButton(
                                        icon: const FaIcon(TravelIcons.layers),
                                        semanticLabel: 'Camadas do mapa',
                                        color: p.ink,
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            // Barra do topo (vidro) — só na visão de mapa.
                            Positioned(
                              top: pad.top + 8,
                              left: 12,
                              right: 12,
                              child: IgnorePointer(
                                ignoring: chatT > 0.5,
                                child: Opacity(
                                  opacity: 1 - chatT,
                                  child: _TopBar(
                                    menuOpen: _menuOpen,
                                    // No começo do zero o mapa é a base:
                                    // voltar sai da tela.
                                    backLabel: s.isBlankStart
                                        ? 'Voltar'
                                        : 'Voltar pra conversa',
                                    onBack: s.isBlankStart
                                        ? () => Navigator.of(context).maybePop()
                                        : cubit.closeMap,
                                    onMenu: () =>
                                        setState(() => _menuOpen = true),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Sheet sólido com a conversa (no começo do zero só entra
                  // no primeiro envio, deslizando de baixo).
                  if (!s.isBlankStart)
                    _SlideIn(
                      enabled: _slideIn,
                      child: NotificationListener<ScrollStartNotification>(
                        onNotification: (n) {
                          if (n.dragDetails != null) _userDrag = true;
                          return false;
                        },
                        child: NotificationListener<
                            DraggableScrollableNotification>(
                          onNotification: (n) {
                            _setExtent(n.extent);
                            // Arrastou o sheet até o topo: volta pra conversa.
                            if (cubit.state.mapOpen &&
                                _userDrag &&
                                _animations == 0 &&
                                n.extent >= 0.995) {
                              _userDrag = false;
                              cubit.closeMap();
                            }
                            return false;
                          },
                          // Travado na conversa: mín. 0.999 deixa a lista rolar
                          // normalmente, mas o sheet não desce (só o mapa desce).
                          child: DraggableScrollableSheet(
                            controller: _sheet,
                            initialChildSize: _initialSize,
                            minChildSize: _chatLocked ? 0.999 : _snaps[0],
                            maxChildSize: _full,
                            snap: !_chatLocked,
                            snapSizes: _chatLocked ? null : _snaps,
                            builder: (context, scroll) {
                              _list = scroll;
                              return _SheetBody(
                                state: s,
                                cubit: cubit,
                                scroll: scroll,
                                chatT: chatT,
                                locked: _chatLocked,
                                onBack: () => Navigator.of(context).maybePop(),
                                onMenu: () => setState(() => _menuOpen = true),
                                onDrag: (dy) {
                                  if (!_sheet.isAttached || _chatLocked) return;
                                  _userDrag = true;
                                  final next =
                                      (_sheet.size - dy / box.maxHeight)
                                          .clamp(_snaps[0], _full);
                                  _sheet.jumpTo(next);
                                },
                                onDragEnd: () {
                                  if (!_sheet.isAttached || _chatLocked) return;
                                  final nearest = [..._snaps, _full].reduce(
                                      (a, b) => (a - _sheet.size).abs() <
                                              (b - _sheet.size).abs()
                                          ? a
                                          : b);
                                  _animateSheet(nearest);
                                },
                                onPlay: (role, i, tile) => setState(
                                    () => _player = (role, i, _originOf(tile))),
                                scheduledAt: s.detailRoleId == null
                                    ? null
                                    : _scheduledAt(s, s.detailRoleId!),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                  // Menu ⋯ (popover ancorado no canto).
                  Positioned.fill(
                    child: _Menu(
                      open: _menuOpen,
                      top: pad.top + 8 + TravelSpace.tap + 8,
                      onDismiss: () => setState(() => _menuOpen = false),
                      items: [
                        if (!s.mapOpen)
                          _MenuItem(
                              'Ver no mapa', TravelIcons.map, cubit.openMap),
                        if (s.hasItinerary && !s.itineraryOpen)
                          _MenuItem('Ver roteiro', TravelIcons.calendar,
                              cubit.openItinerary),
                        s.calendarStatus == CalendarStatus.connected
                            ? _MenuItem('Agenda conectada', TravelIcons.check,
                                cubit.openCalendar)
                            : _MenuItem('Conectar agenda', TravelIcons.google,
                                cubit.openCalendar),
                        _MenuItem(
                            'Seus limites',
                            TravelIcons.gauge,
                            () =>
                                showUsageSheet(context, used: s.messagesUsed)),
                      ],
                    ),
                  ),

                  // Agenda (modal).
                  Positioned.fill(
                    child: _Modal(
                      open: s.calendarSheetOpen,
                      onDismiss: cubit.closeCalendar,
                      child: CalendarConnectSheet(
                        status: s.calendarStatus,
                        days: s.days,
                        appConnections: s.appConnections,
                        onConnect: cubit.connectCalendar,
                        onConnectApp: cubit.connectApp,
                        onClose: cubit.closeCalendar,
                      ),
                    ),
                  ),

                  // Player de vídeos curtos.
                  if (_player != null)
                    Positioned.fill(
                      child: ShortVideoPlayer(
                        key: ValueKey('${_player!.$1.id}-${_player!.$2}'),
                        role: _player!.$1,
                        initialIndex: _player!.$2,
                        origin: _player!.$3,
                        distance: _distance(
                          TravelMock.profile.stayLocation,
                          _player!.$1.location,
                        ),
                        onClose: () => setState(() => _player = null),
                        onOpenRole: () {
                          final id = _player!.$1.id;
                          setState(() => _player = null);
                          cubit.openRole(id);
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

/// Entrada do sheet de baixo pra cima (só quando a tela começou no zero).
class _SlideIn extends StatelessWidget {
  const _SlideIn({required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 0),
      duration: Duration(
          milliseconds: MediaQuery.disableAnimationsOf(context) ? 1 : 520),
      curve: const Cubic(0.2, 0, 0, 1),
      child: child,
      builder: (context, v, child) => FractionalTranslation(
        translation: Offset(0, v * 0.6),
        child: child,
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar(
      {required this.menuOpen,
      required this.onBack,
      required this.onMenu,
      this.backLabel = 'Voltar pra conversa'});

  final bool menuOpen;
  final VoidCallback onBack;

  /// No começo do zero o voltar sai da tela (não há conversa atrás).
  final String backLabel;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Row(
      children: [
        AppGlassIconButton(
          icon: const FaIcon(TravelIcons.back),
          semanticLabel: backLabel,
          color: p.ink,
          onPressed: onBack,
        ),
        // Só os controles: o contexto (datas, hotel) vive no bloco-resumo.
        const Spacer(),
        AppGlassIconButton(
          icon: const FaIcon(TravelIcons.more),
          semanticLabel: 'Mais opções',
          color: p.ink,
          onPressed: onMenu,
        ),
      ],
    );
  }
}

/// Botão de ícone neutro direto na superfície (sem fundo), alvo de 44pt.
class _GhostIconButton extends StatelessWidget {
  const _GhostIconButton(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.color});

  final FaIconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: SizedBox.square(
          dimension: TravelSpace.tap,
          child: Center(child: FaIcon(icon, size: 20, color: color ?? p.ink)),
        ),
      ),
    );
  }
}

/// Cabeçalho da conversa em tela cheia: voltar · Maré · ⋯
/// Botões nas mesmas posições dos de vidro do mapa (continuidade).
class _ChatHeader extends StatelessWidget {
  const _ChatHeader(
      {required this.onBack, required this.onMenu, this.onDark = false});

  final VoidCallback onBack;
  final VoidCallback onMenu;

  /// Conteúdo escuro passando por baixo: texto e ícones em claro.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final fg = onDark ? Colors.white : p.ink;
    return SizedBox(
      height: TravelSpace.tap,
      child: Stack(
        children: [
          Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TravelType.headline.copyWith(color: fg),
              child: const Text('Maré'),
            ),
          ),
          Row(
            children: [
              _GhostIconButton(
                  icon: TravelIcons.back,
                  label: 'Voltar',
                  onTap: onBack,
                  color: fg),
              const Spacer(),
              _GhostIconButton(
                  icon: TravelIcons.more,
                  label: 'Mais opções',
                  onTap: onMenu,
                  color: fg),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem(this.label, this.icon, this.onTap);

  final String label;
  final FaIconData icon;
  final VoidCallback onTap;
}

/// Menu ⋯ no padrão iOS: rótulo à esquerda, ícone à direita, sem divisores.
/// Superfície sólida sobre um véu leve (figura-fundo sem sombra).
/// Raio 22 = 16 (linha pressionada) + 6 (padding): concêntrico.
class _Menu extends StatelessWidget {
  const _Menu({
    required this.open,
    required this.top,
    required this.items,
    required this.onDismiss,
  });

  final bool open;
  final double top;
  final List<_MenuItem> items;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final reduce = MediaQuery.disableAnimationsOf(context);
    final d = Duration(milliseconds: reduce ? 1 : (open ? 220 : 160));
    const curve = Cubic(0.2, 0, 0, 1);
    return IgnorePointer(
      ignoring: !open,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onDismiss,
              child: AnimatedOpacity(
                duration: d,
                curve: curve,
                opacity: open ? 1 : 0,
                child: const ColoredBox(color: Color(0x1F000000)),
              ),
            ),
          ),
          Positioned(
            top: top,
            right: TravelSpace.gutter,
            width: 252,
            child: AnimatedOpacity(
              duration: d,
              curve: curve,
              opacity: open ? 1 : 0,
              child: AnimatedScale(
                duration: d,
                curve: curve,
                alignment: Alignment.topRight,
                scale: open ? 1 : 0.9,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: p.s1,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final it in items)
                        _MenuRow(
                          item: it,
                          onTap: () {
                            onDismiss();
                            it.onTap();
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatefulWidget {
  const _MenuRow({required this.item, required this.onTap});

  final _MenuItem item;
  final VoidCallback onTap;

  @override
  State<_MenuRow> createState() => _MenuRowState();
}

class _MenuRowState extends State<_MenuRow> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Semantics(
      button: true,
      label: widget.item.label,
      excludeSemantics: true,
      onTap: widget.onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) {
          setState(() => _down = false);
          widget.onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: _down ? p.s2 : p.s1,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.item.label,
                  overflow: TextOverflow.ellipsis,
                  style: TravelType.callout.copyWith(color: p.ink, height: 1.2),
                ),
              ),
              const SizedBox(width: TravelSpace.md),
              SizedBox(
                width: 20,
                child: Center(
                  child: FaIcon(widget.item.icon, size: 16, color: p.ink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetBody extends StatefulWidget {
  const _SheetBody({
    required this.state,
    required this.cubit,
    required this.scroll,
    required this.onDrag,
    required this.onDragEnd,
    required this.onPlay,
    required this.scheduledAt,
    required this.chatT,
    required this.locked,
    required this.onBack,
    required this.onMenu,
  });

  final TravelAgentState state;
  final TravelAgentCubit cubit;
  final ScrollController scroll;

  /// 0 = sheet sobre o mapa, 1 = conversa em tela cheia.
  final double chatT;
  final bool locked;
  final VoidCallback onBack;
  final VoidCallback onMenu;
  final ValueChanged<double> onDrag;
  final VoidCallback onDragEnd;
  final void Function(Role role, int index, BuildContext tile) onPlay;
  final String? scheduledAt;

  @override
  State<_SheetBody> createState() => _SheetBodyState();
}

class _SheetBodyState extends State<_SheetBody> {
  /// Altura medida do rodapé fixo (composer ou CTA) — cresce com o texto.
  double _footer = 150;

  /// Aurora de abertura já se esvaiu: desliga o ticker (sem animação
  /// infinita escondida).
  bool _auroraIdle = false;
  bool _fresh = true;

  /// Roteiro: composer aberto pelo "Pedir ajuste".
  bool _askOpen = false;

  @override
  void didUpdateWidget(covariant _SheetBody old) {
    super.didUpdateWidget(old);
    if (!widget.state.itineraryOpen) _askOpen = false;
  }

  static const _bottomFade = 80.0;

  /// Rampa muito suave: seno em 16 passos (sem degraus nem "borda").
  static const _rampSteps = 16;
  static double _smooth(double t) => 0.5 - 0.5 * math.cos(math.pi * t);

  static const _auroraHeight = 300.0;

  /// A aurora só aparece onde o véu do rodapé cobre a lista, e na mesma
  /// proporção (mesma rampa): fica "por baixo de tudo" como antes de o fade
  /// virar véu. Na abertura ela cabe inteira sob o véu (sugestões + composer)
  /// e nada muda; depois do 1º envio o rodapé encolhe e, enquanto ela se
  /// esvai, o topo dela é recortado na rampa — sem tingir as mensagens.
  Widget _underVeil(Widget aurora) {
    // Altura, contada do fundo, em que a rampa do véu começa (alfa 0).
    final rampTop = _footer - 16 + _bottomFade;
    if (rampTop >= _auroraHeight) return aurora;
    final start = (_auroraHeight - rampTop) / _auroraHeight;
    const span = _bottomFade / _auroraHeight;
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          for (var i = 0; i <= _rampSteps; i++)
            Colors.black.withValues(alpha: _smooth(i / _rampSteps)),
        ],
        stops: [
          for (var i = 0; i <= _rampSteps; i++)
            (start + span * i / _rampSteps).clamp(0.0, 1.0),
        ],
      ).createShader(rect),
      child: aurora,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final s = widget.state;
    final cubit = widget.cubit;
    final detail =
        s.detailRoleId == null ? null : TravelMock.roleById(s.detailRoleId!);
    final hasHeader = detail != null || s.itineraryOpen;
    final t = widget.chatT;
    final safeTop = MediaQuery.paddingOf(context).top;
    // Em tela cheia o conteúdo desce a área segura (+ cabeçalho na conversa).
    final inset = t * (safeTop + (hasHeader ? 0 : TravelSpace.tap + 8));
    // Abertura (nada enviado ainda): aurora sob o composer. Na primeira
    // mensagem ela se esvai devagar.
    _fresh =
        !s.messages.any((m) => m.author == MessageAuthor.user) && !hasHeader;
    return Container(
      clipBehavior: Clip.antiAlias,
      // Flat: sem sombra nem borda — o sheet se separa do mapa só pela cor.
      // Raio some conforme vira tela cheia.
      decoration: BoxDecoration(
        color: p.s0,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(TravelSpace.rSheet * (1 - t))),
      ),
      child: Stack(
        children: [
          // Conteúdo rolável. A lista começa no topo do sheet (por baixo da
          // status bar) e o recuo vira padding ([SheetTopInset]): rola por
          // baixo do cabeçalho e some num fade curto que nasce na status
          // bar — sem borda dura onde a lista começava (era a "linha de
          // pixel").
          Positioned.fill(
            child: SheetTopInset(
              value: 8 + inset,
              child: _FadeIn(
                key: ValueKey(
                    detail?.id ?? (s.itineraryOpen ? 'roteiro' : 'chat')),
                child: detail == null
                    ? (s.itineraryOpen
                        ? ItineraryView(
                            state: s,
                            cubit: cubit,
                            scrollController: widget.scroll,
                            onPlay: widget.onPlay,
                          )
                        : AgentConversation(
                            state: s,
                            cubit: cubit,
                            scrollController: widget.scroll))
                    : PlaceDetail(
                        role: detail,
                        scrollController: widget.scroll,
                        onPlayVideo: (i, tile) =>
                            widget.onPlay(detail, i, tile),
                      ),
              ),
            ),
          ),
          // Fade das bordas fixas: véus `s0` por cima da lista (o fundo do
          // sheet é `s0` sólido, então dá o mesmo desenho de uma máscara,
          // sem o saveLayer de tela cheia a cada quadro).
          // Sobre o mapa (t=0): fade sob a alça (e sob o cabeçalho do
          // card/roteiro). Em tela cheia quem cuida do topo é o desfoque
          // progressivo (abaixo).
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _EdgeVeilPainter(
                  color: p.s0,
                  topEnd: (1 - t) * (hasHeader ? 62 : 24),
                  footer: _footer,
                ),
              ),
            ),
          ),
          // Aurora presa ao rodapé: por cima do véu (que esconde a lista sob
          // o composer) e embaixo do composer — nunca por cima da lista
          // ([_underVeil]).
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _auroraHeight,
            child: IgnorePointer(
              child: Opacity(
                opacity: t,
                child: AnimatedOpacity(
                  opacity: _fresh ? 1 : 0,
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? const Duration(milliseconds: 1)
                      : const Duration(milliseconds: 1800),
                  curve: Curves.easeInOut,
                  onEnd: () => setState(() => _auroraIdle = !_fresh),
                  child: TickerMode(
                    // Sobre o mapa (t = 0) ela não aparece: nada de animar
                    // escondida.
                    enabled: t > 0 && (_fresh || !_auroraIdle),
                    child: _underVeil(
                      Aurora(
                        colors: [p.accent, p.piscina, p.accent],
                        intensity: p.isDark ? 0.8 : 0.6,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Desfoque progressivo (iOS) + véu sob a status bar e o
          // cabeçalho: o conteúdo rola por baixo, desfocado e legível.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ProgressiveBlurTop(
              // Só perto da tela cheia (na transição leria o mapa) e sem
              // encostar no topo da foto do card (que começa em +70).
              height: t > 0.98 ? safeTop + (hasHeader ? 64 : 72) : 0,
            ),
          ),
          // Cabeçalho do card do rolê: fora da máscara, flutua sobre o fade.
          // Cabeçalho da conversa (tela cheia).
          if (!hasHeader && t > 0)
            Positioned(
              top: safeTop + 8,
              left: TravelSpace.gutter,
              right: TravelSpace.gutter,
              child: IgnorePointer(
                ignoring: t < 0.5,
                child: Opacity(
                  opacity: t,
                  child: OnDarkBuilder(
                    scroll: widget.scroll,
                    builder: (context, onDark) => _ChatHeader(
                      onBack: widget.onBack,
                      onMenu: widget.onMenu,
                      onDark: onDark,
                    ),
                  ),
                ),
              ),
            ),
          if (detail != null)
            Positioned(
              top: 18 + t * (safeTop - 10),
              left: TravelSpace.gutter,
              right: TravelSpace.gutter,
              child: DetailHeader(
                key: const ValueKey('h-rolê'),
                scroll: widget.scroll,
                title: 'Rolê de local',
                onBack: cubit.closeRole,
              ),
            )
          else if (s.itineraryOpen)
            Positioned(
              top: 18 + t * (safeTop - 10),
              left: TravelSpace.gutter,
              right: TravelSpace.gutter,
              child: OnDarkBuilder(
                scroll: widget.scroll,
                builder: (context, onDark) => ItineraryHeader(
                  key: const ValueKey('h-roteiro'),
                  state: s,
                  cubit: cubit,
                  onDark: onDark,
                ),
              ),
            ),
          // Alça arrastável (só sobre o mapa).
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 24,
            child: IgnorePointer(
              ignoring: widget.locked,
              child: Opacity(
                opacity: 1 - t,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragUpdate: (d) => widget.onDrag(d.delta.dy),
                  onVerticalDragEnd: (_) => widget.onDragEnd(),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: p.inkMuted.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _MeasureSize(
              onChange: (size) {
                if (mounted && (size.height - _footer).abs() > 0.5) {
                  setState(() => _footer = size.height);
                }
              },
              child: detail == null
                  ? AnimatedSwitcher(
                      duration: Duration(
                          milliseconds: MediaQuery.disableAnimationsOf(context)
                              ? 1
                              : 260),
                      switchInCurve: const Cubic(0.2, 0, 0, 1),
                      transitionBuilder: (child, a) => FadeTransition(
                        opacity: a,
                        child: SizeTransition(
                          sizeFactor: a,
                          alignment: Alignment.bottomCenter,
                          child: child,
                        ),
                      ),
                      // No roteiro o composer só aparece quando a pessoa
                      // pede um ajuste.
                      child: s.itineraryOpen && !_askOpen
                          ? ItineraryAskButton(
                              key: const ValueKey('pedir'),
                              onTap: () => setState(() => _askOpen = true),
                            )
                          : AgentInputBar(
                              key: const ValueKey('composer'),
                              enabled: s.phase != AgentPhase.thinking &&
                                  s.phase != AgentPhase.error,
                              used: s.messagesUsed,
                              autofocus: s.itineraryOpen,
                              above: s.phase == AgentPhase.idle &&
                                      !s.itineraryOpen
                                  ? AgentSuggestions(onTap: cubit.send)
                                  : null,
                              onSend: (text) {
                                if (_askOpen) setState(() => _askOpen = false);
                                cubit.send(text);
                              },
                            ),
                    )
                  : _DetailCta(
                      scheduledAt: widget.scheduledAt,
                      onAdd: () => cubit.closeRole(),
                      onMap: () {
                        cubit
                          ..selectRole(detail.id)
                          ..closeRole()
                          ..openMap();
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Véus na cor do fundo nas bordas fixas do sheet: topo (sob a alça ou o
/// cabeçalho, só sobre o mapa) e rodapé (sob o composer). Mesmas rampas
/// senoidais da antiga máscara `ShaderMask` + `dstIn`, invertidas: onde a
/// máscara apagava o conteúdo, o véu pinta `s0` por cima.
class _EdgeVeilPainter extends CustomPainter {
  _EdgeVeilPainter({
    required this.color,
    required this.topEnd,
    required this.footer,
  });

  final Color color;

  /// Altura do fade do topo (menos de 1 px = sem fade).
  final double topEnd;

  /// Altura medida do rodapé fixo (composer ou CTA).
  final double footer;

  static final _ks = [
    for (var i = 0; i <= _SheetBodyState._rampSteps; i++)
      i / _SheetBodyState._rampSteps,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    if (h <= 0) return;
    // Topo: `s0` opaco → transparente, em curva.
    final top = topEnd.clamp(0.0, h);
    if (top >= 1) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, top),
        Paint()
          ..shader = ui.Gradient.linear(
            Offset.zero,
            Offset(0, top),
            [
              for (final k in _ks)
                color.withValues(
                    alpha: color.a * (1 - _SheetBodyState._smooth(k))),
            ],
            _ks,
          ),
      );
    }
    // Rodapé: transparente → `s0` em curva; opaco daí até o fim. O fim da
    // rampa cai dentro do respiro do composer.
    const fade = _SheetBodyState._bottomFade;
    final edge = (h - footer + 16).clamp(0.0, h);
    final start = (edge - fade).clamp(0.0, h);
    if (start < h) {
      canvas.drawRect(
        Rect.fromLTRB(0, start, size.width, h),
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, start),
            Offset(0, start + fade),
            [
              for (final k in _ks)
                color.withValues(alpha: color.a * _SheetBodyState._smooth(k)),
            ],
            _ks,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(_EdgeVeilPainter old) =>
      old.color != color || old.topEnd != topEnd || old.footer != footer;
}

/// Informa o tamanho do filho depois do layout (para o véu do rodapé).
class _MeasureSize extends SingleChildRenderObjectWidget {
  const _MeasureSize({required this.onChange, required super.child});

  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMeasureSize(onChange);

  @override
  void updateRenderObject(
      BuildContext context, _RenderMeasureSize renderObject) {
    renderObject.onChange = onChange;
  }
}

class _RenderMeasureSize extends RenderProxyBox {
  _RenderMeasureSize(this.onChange);

  ValueChanged<Size> onChange;
  Size? _last;

  @override
  void performLayout() {
    super.performLayout();
    final s = size;
    if (s == _last) return;
    _last = s;
    WidgetsBinding.instance.addPostFrameCallback((_) => onChange(s));
  }
}

class _DetailCta extends StatelessWidget {
  const _DetailCta(
      {required this.scheduledAt, required this.onAdd, required this.onMap});

  final String? scheduledAt;
  final VoidCallback onAdd;
  final VoidCallback onMap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        TravelSpace.gutter,
        10,
        TravelSpace.gutter,
        10 + MediaQuery.paddingOf(context).bottom,
      ),
      // Dois botões: sempre empilhados, primário embaixo.
      child: scheduledAt != null
          ? SecondaryButton(
              label: 'Ver no mapa',
              icon: TravelIcons.mapPin,
              onPressed: onMap,
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SecondaryButton(
                  label: 'Ver no mapa',
                  icon: TravelIcons.mapPin,
                  onPressed: onMap,
                ),
                const SizedBox(height: TravelSpace.sm),
                PrimaryButton(
                  label: 'Adicionar ao roteiro',
                  icon: TravelIcons.calendar,
                  onPressed: onAdd,
                ),
              ],
            ),
    );
  }
}

/// Modal com scrim: desliza de baixo, fecha tocando fora.
///
/// Fechado (depois da saída), o sheet fica montado — com estado, pra abrir
/// na hora — mas fora da pintura e sem animar: deslizado pra fora da tela
/// ele ainda era desenhado a cada quadro, carrossel com blur incluso.
class _Modal extends StatefulWidget {
  const _Modal(
      {required this.open, required this.onDismiss, required this.child});

  final bool open;
  final VoidCallback onDismiss;
  final Widget child;

  @override
  State<_Modal> createState() => _ModalState();
}

class _ModalState extends State<_Modal> {
  /// Fechado e com a saída concluída.
  late bool _parked = !widget.open;

  @override
  void didUpdateWidget(_Modal old) {
    super.didUpdateWidget(old);
    if (widget.open) _parked = false;
  }

  @override
  Widget build(BuildContext context) {
    final open = widget.open;
    final reduce = MediaQuery.disableAnimationsOf(context);
    final d = Duration(milliseconds: reduce ? 1 : 360);
    return IgnorePointer(
      ignoring: !open,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.onDismiss,
              child: AnimatedOpacity(
                duration: d,
                opacity: open ? 1 : 0,
                child: const ColoredBox(color: Color(0x73000000)),
              ),
            ),
          ),
          Visibility(
            visible: !_parked,
            maintainState: true,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedSlide(
                duration: d,
                curve: Curves.easeOutCubic,
                offset: open ? Offset.zero : const Offset(0, 1.05),
                onEnd: () {
                  if (mounted && !widget.open) setState(() => _parked = true);
                },
                child: open || reduce
                    ? widget.child
                    : _KeepAlive(child: widget.child),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mantém o sheet montado durante a saída, mas sem animações rodando.
class _KeepAlive extends StatelessWidget {
  const _KeepAlive({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      TickerMode(enabled: false, child: child);
}

class _FadeIn extends StatefulWidget {
  const _FadeIn({required this.child, super.key});

  final Widget child;

  @override
  State<_FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<_FadeIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _c, child: widget.child);
}
