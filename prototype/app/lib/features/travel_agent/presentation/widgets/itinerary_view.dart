import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/core/components/glass/app_glass.dart';
import 'package:studio_app/features/travel_agent/data/travel_agent_mock.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';
import 'package:studio_app/features/travel_agent/presentation/view_models/travel_agent_cubit.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/mare_mark.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/place_detail.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';

const _ease = Cubic(0.2, 0, 0, 1);

Duration _d(BuildContext context, int ms) =>
    MediaQuery.disableAnimationsOf(context)
        ? const Duration(milliseconds: 1)
        : Duration(milliseconds: ms);

/// "Sexta, 14 nov" → "14".
String _dayNumber(ItineraryDay d) =>
    RegExp(r'\d+').firstMatch(d.title)?.group(0) ?? '';

/// "16h30" → 16.5.
double _hourOf(String t) {
  final m = RegExp(r'(\d+)h(\d+)?').firstMatch(t);
  if (m == null) return 12;
  return int.parse(m.group(1)!) + int.parse(m.group(2) ?? '0') / 60;
}

/// Roteiro. Ao entrar: semana em grade (pinça dá zoom, como no Google
/// Agenda; eventos com a cor do tipo). Tocar num dia: a grade recolhe e
/// entra o guia do dia — rolês com dica curta e vídeos curtos (ref.
/// Inspora "travel app": nome grande + foto em selo). Os dias ficam num
/// segmented do iPhone no topo do conteúdo (sem vidro, sem flutuar) e o guia
/// arrasta de lado: sexta, sábado, domingo ([_DayPager]); Editar em vidro.
class ItineraryView extends StatelessWidget {
  const ItineraryView({
    required this.state,
    required this.cubit,
    required this.scrollController,
    required this.onPlay,
    super.key,
  });

  final TravelAgentState state;
  final TravelAgentCubit cubit;
  final ScrollController scrollController;
  final void Function(Role role, int index, BuildContext tile) onPlay;

  @override
  Widget build(BuildContext context) {
    final focused = state.itineraryFocused;
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.fromLTRB(
        TravelSpace.gutter,
        kDetailHeaderSpace - 8 + SheetTopInset.of(context),
        TravelSpace.gutter,
        200,
      ),
      children: [
        AnimatedSwitcher(
          duration: _d(context, 380),
          reverseDuration: _d(context, 200),
          switchInCurve: _ease,
          switchOutCurve: Curves.easeIn,
          layoutBuilder: (current, previous) => Stack(
            alignment: Alignment.topCenter,
            children: [...previous, if (current != null) current],
          ),
          transitionBuilder: (child, a) => FadeTransition(
            opacity: a,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, 0.03), end: Offset.zero)
                  .animate(a),
              child: child,
            ),
          ),
          child: focused
              ? _DayPager(
                  key: const ValueKey('guia'),
                  state: state,
                  cubit: cubit,
                  onPlay: onPlay,
                )
              : _WeekGrid(
                  key: const ValueKey('semana'),
                  days: state.days,
                  onFocus: cubit.focusDay,
                  onOpen: cubit.openRole,
                ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Cabeçalho fixo do roteiro
// ═══════════════════════════════════════════════════════════════════════════

/// Voltar à esquerda, título no centro e Editar em vidro à direita só no
/// guia do dia. A troca de dias vive no conteúdo ([_DayPager]).
class ItineraryHeader extends StatelessWidget {
  const ItineraryHeader({
    required this.state,
    required this.cubit,
    this.onDark = false,
    super.key,
  });

  final TravelAgentState state;
  final TravelAgentCubit cubit;

  /// Fundo escuro passando sob o cabeçalho: título em claro (como no iOS).
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final focused = state.itineraryFocused;
    final back = focused ? cubit.unfocusDay : cubit.closeItinerary;
    // Em linha: voltar | dias (ou título) centrados no espaço livre |
    // editar. Assim "Concluir", mais largo, nunca cobre os dias.
    return SizedBox(
      height: TravelSpace.tap,
      child: Row(
        children: [
          Semantics(
            button: true,
            label: focused ? 'Voltar pra semana' : 'Voltar pra conversa',
            excludeSemantics: true,
            onTap: back,
            child: Pressable(
              onTap: back,
              child: const _Glass(
                radius: TravelSpace.tap / 2,
                child: SizedBox.square(
                  dimension: TravelSpace.tap,
                  child: Center(child: _Icon(TravelIcons.back, size: 16)),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: _d(context, 200),
                style: TravelType.subheadStrong.copyWith(
                  color: onDark ? Colors.white : p.ink,
                ),
                child: const Text('Roteiro'),
              ),
            ),
          ),
          AnimatedSize(
            duration: _d(context, 260),
            curve: _ease,
            clipBehavior: Clip.none,
            child: AnimatedSwitcher(
              duration: _d(context, 260),
              switchInCurve: Curves.easeOutBack,
              transitionBuilder: (child, a) => FadeTransition(
                opacity: a,
                child: ScaleTransition(scale: a, child: child),
              ),
              child: focused
                  ? _EditButton(
                      key: const ValueKey('editar'),
                      editing: state.itineraryEditing,
                      onTap: cubit.toggleItineraryEdit,
                    )
                  // Equilibra o voltar: título fica no centro da tela.
                  : const SizedBox(
                      key: ValueKey('nada'), width: TravelSpace.tap),
            ),
          ),
        ],
      ),
    );
  }
}

/// Vidro (estilo Liquid Glass): desfoque do que está atrás + véu `s1` e
/// brilho fino na borda. Sem sombra. No modo leve (celular no navegador),
/// sem desfoque e com véu mais denso.
class _Glass extends StatelessWidget {
  const _Glass({required this.child, this.radius = TravelSpace.rPill});

  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final r = BorderRadius.circular(radius);
    return AppBackdropBlur(
      sigma: 14,
      borderRadius: r,
      liteColor: p.s1.withValues(alpha: 0.6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: r,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              p.s1.withValues(alpha: p.isDark ? 0.62 : 0.78),
              p.s1.withValues(alpha: p.isDark ? 0.42 : 0.58),
            ],
          ),
        ),
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            borderRadius: r,
            border: Border.all(
              color: Colors.white.withValues(alpha: p.isDark ? 0.14 : 0.7),
              width: 0.8,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  const _Icon(this.icon, {this.size = 14});

  final FaIconData icon;
  final double size;

  @override
  Widget build(BuildContext context) =>
      FaIcon(icon, size: size, color: TravelPalette.of(context).ink);
}

/// Editar ↔ Concluir: o ícone gira na troca e a pílula muda de largura.
class _EditButton extends StatelessWidget {
  const _EditButton({required this.editing, required this.onTap, super.key});

  final bool editing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Semantics(
      button: true,
      label: editing ? 'Concluir edição' : 'Editar dia',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: _Glass(
          child: AnimatedSize(
            duration: _d(context, 240),
            curve: _ease,
            clipBehavior: Clip.none,
            child: SizedBox(
              height: TravelSpace.tap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: _d(context, 240),
                      transitionBuilder: (child, a) => RotationTransition(
                        turns: Tween(begin: -0.25, end: 0.0).animate(a),
                        child: FadeTransition(opacity: a, child: child),
                      ),
                      child: FaIcon(
                        editing ? TravelIcons.check : TravelIcons.pen,
                        key: ValueKey(editing),
                        size: 13,
                        color: p.ink,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      editing ? 'Concluir' : 'Editar',
                      style: TravelType.subheadStrong
                          .copyWith(color: p.ink, height: 1.2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rodapé do roteiro: o composer só aparece se a pessoa quiser pedir um
/// ajuste. Pílula de vidro "Pedir ajuste" com o símbolo da Maré.
class ItineraryAskButton extends StatelessWidget {
  const ItineraryAskButton({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        TravelSpace.gutter,
        TravelSpace.sm,
        TravelSpace.gutter,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Center(
        child: Semantics(
          button: true,
          label: 'Pedir um ajuste à Maré',
          excludeSemantics: true,
          onTap: onTap,
          child: Pressable(
            onTap: onTap,
            child: _Glass(
              child: SizedBox(
                height: TravelSpace.tap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const MareMark(size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Pedir ajuste',
                        style: TravelType.subheadStrong
                            .copyWith(color: p.ink, height: 1.2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Semana em grade (zoom de pinça)
// ═══════════════════════════════════════════════════════════════════════════

/// Grade de 9h às 24h. Pinça (toque ou trackpad) e ctrl+rolagem mudam a
/// altura da hora, como no Google Agenda; os blocos mostram mais conforme
/// crescem. Tocar no dia (cabeçalho da coluna) abre o guia do dia.
class _WeekGrid extends StatefulWidget {
  const _WeekGrid({
    required this.days,
    required this.onFocus,
    required this.onOpen,
    super.key,
  });

  final List<ItineraryDay> days;
  final ValueChanged<int> onFocus;
  final ValueChanged<String> onOpen;

  @override
  State<_WeekGrid> createState() => _WeekGridState();
}

class _WeekGridState extends State<_WeekGrid> {
  static const _start = 9.0;
  static const _end = 24.0;
  static const _axisW = 32.0;
  static const _headH = 36.0;
  static const _minH = 22.0;
  static const _maxH = 84.0;

  /// Altura de 1h. Padrão compacto: a semana cabe inteira na tela.
  double _hourH = 30;
  double _pinchStartH = 30;
  double? _pinchStartDist;
  final _pointers = <int, Offset>{};

  void _setH(double h) {
    final v = h.clamp(_minH, _maxH);
    if ((v - _hourH).abs() > 0.1) setState(() => _hourH = v);
  }

  double get _dist {
    final ps = _pointers.values.take(2).toList();
    return (ps[0] - ps[1]).distance;
  }

  static double _duration(ItineraryStop s) =>
      s.period == StopPeriod.noite ? 2.5 : 1.5;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final height = (_end - _start) * _hourH;
    return Listener(
      onPointerDown: (e) {
        _pointers[e.pointer] = e.position;
        if (_pointers.length == 2) {
          _pinchStartDist = _dist;
          _pinchStartH = _hourH;
        }
      },
      onPointerMove: (e) {
        if (!_pointers.containsKey(e.pointer)) return;
        _pointers[e.pointer] = e.position;
        final start = _pinchStartDist;
        if (_pointers.length >= 2 && start != null && start > 8) {
          _setH(_pinchStartH * (_dist / start));
        }
      },
      onPointerUp: (e) {
        _pointers.remove(e.pointer);
        if (_pointers.length < 2) _pinchStartDist = null;
      },
      onPointerCancel: (e) {
        _pointers.remove(e.pointer);
        if (_pointers.length < 2) _pinchStartDist = null;
      },
      onPointerPanZoomStart: (_) => _pinchStartH = _hourH,
      onPointerPanZoomUpdate: (e) => _setH(_pinchStartH * e.scale),
      onPointerSignal: (e) {
        if (e is PointerScaleEvent) _setH(_hourH * e.scale);
      },
      child: SolidBlock(
        padding: const EdgeInsets.fromLTRB(
            TravelSpace.sm, TravelSpace.xs, TravelSpace.sm, TravelSpace.lg),
        child: LayoutBuilder(
          builder: (context, box) {
            final colW = (box.maxWidth - _axisW) / widget.days.length;
            return Column(
              children: [
                // Dias: tocar abre o guia.
                SizedBox(
                  height: _headH,
                  child: Row(
                    children: [
                      const SizedBox(width: _axisW),
                      for (final (i, d) in widget.days.indexed)
                        SizedBox(
                          width: colW,
                          child: Semantics(
                            button: true,
                            label: 'Abrir ${d.title}',
                            excludeSemantics: true,
                            onTap: () => widget.onFocus(i),
                            child: Pressable(
                              onTap: () => widget.onFocus(i),
                              child: Center(
                                child: Text(
                                  '${d.tab} ${_dayNumber(d)}',
                                  style: TravelType.footnoteStrong.copyWith(
                                    color: p.ink,
                                    fontFeatures: TravelType.tabular,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: height,
                  child: Stack(
                    // Rótulos das horas nas pontas não são cortados.
                    clipBehavior: Clip.none,
                    children: [
                      for (var h = _start; h <= _end; h++)
                        Positioned(
                          left: _axisW,
                          right: 0,
                          top: (h - _start) * _hourH,
                          child: Container(
                            height: 0.5,
                            color: p.ink.withValues(alpha: 0.08),
                          ),
                        ),
                      // De 2 em 2h (de hora em hora com zoom alto),
                      // centradas na linha.
                      for (var h = _start + 1; h <= _end; h++)
                        if (h % 2 == 0 || _hourH >= 48)
                          Positioned(
                            left: 0,
                            width: _axisW - 4,
                            top: (h - _start) * _hourH - 8,
                            child: Text(
                              '${h.toInt() % 24}h',
                              style: TravelType.caption.copyWith(
                                color: p.inkMuted,
                                fontFeatures: TravelType.tabular,
                                height: 1.2,
                              ),
                            ),
                          ),
                      for (final (di, d) in widget.days.indexed)
                        for (final st in d.stops)
                          Positioned(
                            left: _axisW + di * colW + 2,
                            width: colW - 4,
                            top: (_hourOf(st.time) - _start) * _hourH + 1,
                            height: _duration(st) * _hourH - 2,
                            child: _EventBlock(
                              stop: st,
                              role: TravelMock.roleById(st.roleId),
                              height: _duration(st) * _hourH - 2,
                              onTap: () => widget.onOpen(st.roleId),
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Bloco do evento com a cor do tipo (música roxo, arte amarelo…): fundo
/// suave e texto no tom escuro da mesma cor. Mostra mais conforme cresce.
class _EventBlock extends StatelessWidget {
  const _EventBlock({
    required this.stop,
    required this.role,
    required this.height,
    required this.onTap,
  });

  final ItineraryStop stop;
  final Role role;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tone = TravelCategoryTones.of(context, role.category);
    final name = TravelType.caption
        .weight(FontWeight.w500)
        .copyWith(color: tone.ink, height: 1.2);
    final roomy = height >= 46;
    // Linhas que cabem de verdade (sem a 2ª sair fatiada).
    final lines = math.max(1, ((height - 8 - (roomy ? 18 : 0)) / 14.4).floor());
    return Semantics(
      button: true,
      label: '${stop.time}, ${role.shortName}',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 4, 4, 4),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: tone.fill,
            borderRadius: BorderRadius.circular(TravelSpace.rTight),
          ),
          child: roomy
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        FaIcon(categoryIcon(role.category),
                            size: 9, color: tone.ink),
                        const SizedBox(width: 4),
                        Text(
                          stop.time,
                          style: TravelType.caption.copyWith(
                            color: tone.ink.withValues(alpha: 0.8),
                            fontFeatures: TravelType.tabular,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Flexible(
                      child: Text(
                        role.shortName,
                        maxLines: lines,
                        overflow: TextOverflow.ellipsis,
                        style: name,
                      ),
                    ),
                  ],
                )
              : Text(
                  role.shortName,
                  maxLines: lines,
                  overflow: TextOverflow.ellipsis,
                  style: name,
                ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Guia do dia
// ═══════════════════════════════════════════════════════════════════════════

/// Dias em páginas: segmented do iPhone no topo do conteúdo (sólido, sem
/// vidro) e o guia embaixo, arrastável de lado — sexta, sábado, domingo.
/// O indicador do segmented acompanha o dedo; tocar num dia desliza o guia
/// do lado certo. Nas pontas o arraste resiste.
class _DayPager extends StatefulWidget {
  const _DayPager({
    required this.state,
    required this.cubit,
    required this.onPlay,
    super.key,
  });

  final TravelAgentState state;
  final TravelAgentCubit cubit;
  final void Function(Role role, int index, BuildContext tile) onPlay;

  @override
  State<_DayPager> createState() => _DayPagerState();
}

class _DayPagerState extends State<_DayPager>
    with SingleTickerProviderStateMixin {
  late int _index = widget.state.dayIndex;

  /// Deslocamento horizontal da página atual (px).
  double _dx = 0;
  double _w = 1;

  late final AnimationController _settle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 340),
  )..addListener(() {
      final a = _anim;
      if (a != null) setState(() => _dx = a.value);
    });
  Animation<double>? _anim;

  List<ItineraryDay> get _days => widget.state.days;

  @override
  void didUpdateWidget(_DayPager old) {
    super.didUpdateWidget(old);
    final next = widget.state.dayIndex;
    if (next != _index) {
      // Dia trocado no segmented: o guia entra do lado certo.
      _dx += (next - _index) * _w;
      _index = next;
      _slideHome();
    }
  }

  @override
  void dispose() {
    _settle.dispose();
    super.dispose();
  }

  void _slideHome() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _settle.stop();
      _anim = null;
      setState(() => _dx = 0);
      return;
    }
    _anim = Tween(begin: _dx, end: 0.0)
        .animate(CurvedAnimation(parent: _settle, curve: _ease));
    _settle.forward(from: 0);
  }

  void _onDrag(DragUpdateDetails d) {
    _settle.stop();
    _anim = null;
    var delta = d.delta.dx;
    final next = _dx + delta;
    if ((_index == 0 && next > 0) || (_index == _days.length - 1 && next < 0)) {
      delta *= 0.35;
    }
    setState(() => _dx += delta);
  }

  void _onDragEnd(DragEndDetails d) {
    final v = d.velocity.pixelsPerSecond.dx;
    var target = _index;
    if ((_dx < -_w * 0.25 || v < -500) && _index < _days.length - 1) {
      target++;
    } else if ((_dx > _w * 0.25 || v > 500) && _index > 0) {
      target--;
    }
    if (target != _index) {
      // Mesma posição na tela, agora relativa ao novo dia.
      _dx += (target - _index) * _w;
      _index = target;
      widget.cubit.focusDay(target);
    }
    _slideHome();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    return LayoutBuilder(
      builder: (context, box) {
        _w = box.maxWidth;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PillSegmented(
              labels: [for (final d in _days) '${d.tab} ${_dayNumber(d)}'],
              semanticLabels: [for (final d in _days) d.title],
              index: _index,
              position: _index - _dx / _w,
              onChanged: (i) {
                if (i != _index) widget.cubit.focusDay(i);
              },
            ),
            const SizedBox(height: TravelSpace.xl),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: _onDrag,
              onHorizontalDragEnd: _onDragEnd,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (final (i, d) in _days.indexed)
                    if (((i - _index) * _w + _dx).abs() < _w)
                      Transform.translate(
                        key: ValueKey(d.id),
                        offset: Offset((i - _index) * _w + _dx, 0),
                        child: _DayGuide(
                          day: d,
                          editing: s.itineraryEditing && i == _index,
                          onOpen: widget.cubit.openRole,
                          onRemove: widget.cubit.removeStop,
                          onPlay: widget.onPlay,
                        ),
                      ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DayGuide extends StatelessWidget {
  const _DayGuide({
    required this.day,
    required this.editing,
    required this.onOpen,
    required this.onRemove,
    required this.onPlay,
  });

  final ItineraryDay day;
  final bool editing;
  final ValueChanged<String> onOpen;
  final ValueChanged<String> onRemove;
  final void Function(Role role, int index, BuildContext tile) onPlay;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final n = day.stops.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TravelSpace.cardPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(day.title, style: TravelType.title2.copyWith(color: p.ink)),
              const SizedBox(height: 2),
              Text(
                n == 0
                    ? day.area
                    : '${day.area}, $n ${n == 1 ? 'rolê' : 'rolês'}',
                style: TravelType.footnote.copyWith(color: p.inkMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: TravelSpace.lg),
        if (n == 0)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: TravelSpace.cardPad),
            child: Text(
              'Dia livre. Peça um ajuste se quiser encaixar algo.',
              style: TravelType.subhead.copyWith(color: p.inkMuted),
            ),
          ),
        for (final (i, st) in day.stops.indexed) ...[
          if (i > 0) _Leg(stop: st),
          _Staggered(
            index: i,
            child: _GuideStop(
              key: ValueKey(st.roleId),
              index: i,
              stop: st,
              role: TravelMock.roleById(st.roleId),
              editing: editing,
              onOpen: () => onOpen(st.roleId),
              onRemove: () => onRemove(st.roleId),
              onPlay: onPlay,
            ),
          ),
        ],
      ],
    );
  }
}

/// Trajeto entre dois rolês: modo + tempo, recuado e discreto.
class _Leg extends StatelessWidget {
  const _Leg({required this.stop});

  final ItineraryStop stop;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final text = stop.fromPrevious;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          TravelSpace.content, TravelSpace.sm, 0, TravelSpace.sm),
      child: text == null
          ? const SizedBox(height: TravelSpace.xs)
          : Row(
              children: [
                FaIcon(
                  stop.mode == TravelMode.carro
                      ? TravelIcons.car
                      : TravelIcons.walk,
                  size: 11,
                  color: p.inkMuted,
                ),
                const SizedBox(width: 6),
                Text(text,
                    style: TravelType.footnote.copyWith(color: p.inkMuted)),
              ],
            ),
    );
  }
}

/// Entrada em cascata dos cards do guia (sobe 12pt e acende).
class _Staggered extends StatelessWidget {
  const _Staggered({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final delay = index * 70;
    final total = 340 + delay;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(delay / total, 1, curve: _ease),
      builder: (context, v, child) => Opacity(
        opacity: v,
        child:
            Transform.translate(offset: Offset(0, 12 * (1 - v)), child: child),
      ),
      child: child,
    );
  }
}

/// Card do rolê no guia: foto em selo, hora na cor do tipo, nome em
/// Oswald, dica curta e vídeos curtos. Editando: botão de tirar.
class _GuideStop extends StatefulWidget {
  const _GuideStop({
    required this.index,
    required this.stop,
    required this.role,
    required this.editing,
    required this.onOpen,
    required this.onRemove,
    required this.onPlay,
    super.key,
  });

  final int index;
  final ItineraryStop stop;
  final Role role;
  final bool editing;
  final VoidCallback onOpen;
  final VoidCallback onRemove;
  final void Function(Role role, int index, BuildContext tile) onPlay;

  @override
  State<_GuideStop> createState() => _GuideStopState();
}

class _GuideStopState extends State<_GuideStop> {
  bool _leaving = false;

  void _remove() => setState(() => _leaving = true);

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final role = widget.role;
    final tone = TravelCategoryTones.of(context, role.category);
    final videos = role.videos.take(3).toList();
    return TweenAnimationBuilder<double>(
      tween: Tween(end: _leaving ? 0 : 1),
      duration: _d(context, 260),
      curve: _ease,
      onEnd: () {
        if (_leaving) widget.onRemove();
      },
      builder: (context, v, child) => ClipRRect(
        borderRadius: BorderRadius.circular(TravelSpace.rCard),
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: v,
          child: Opacity(opacity: v, child: child),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(TravelSpace.cardPad),
        decoration: BoxDecoration(
          color: p.s1,
          borderRadius: BorderRadius.circular(TravelSpace.rCard),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Semantics(
                    button: true,
                    label: '${widget.stop.time}, ${role.shortName}. Abrir rolê',
                    excludeSemantics: true,
                    onTap: widget.onOpen,
                    child: Pressable(
                      onTap: widget.onOpen,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Stamp(
                            asset: role.photos.first.asset,
                            angle: widget.index.isEven ? -0.035 : 0.03,
                          ),
                          const SizedBox(width: TravelSpace.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: tone.fill,
                                    borderRadius: BorderRadius.circular(
                                        TravelSpace.rPill),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      FaIcon(categoryIcon(role.category),
                                          size: 10, color: tone.ink),
                                      const SizedBox(width: 5),
                                      Text(
                                        widget.stop.time,
                                        style: TravelType.caption
                                            .weight(FontWeight.w500)
                                            .copyWith(
                                              color: tone.ink,
                                              fontFeatures: TravelType.tabular,
                                              height: 1.2,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: TravelSpace.sm),
                                Text(
                                  role.shortName.toUpperCase(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TravelType.cardTitle
                                      .copyWith(color: p.ink),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  role.neighborhood,
                                  style: TravelType.footnote
                                      .copyWith(color: p.inkMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Editando: botão de tirar entra crescendo.
                AnimatedSwitcher(
                  duration: _d(context, 220),
                  switchInCurve: Curves.easeOutBack,
                  transitionBuilder: (child, a) =>
                      ScaleTransition(scale: a, child: child),
                  child: widget.editing
                      ? Semantics(
                          key: const ValueKey('tirar'),
                          button: true,
                          label: 'Tirar ${role.shortName} do dia',
                          excludeSemantics: true,
                          onTap: _remove,
                          child: Pressable(
                            onTap: _remove,
                            child: SizedBox.square(
                              dimension: TravelSpace.tap,
                              child: Center(
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: p.danger,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const FaIcon(TravelIcons.minus,
                                      size: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('vazio')),
                ),
              ],
            ),
            const SizedBox(height: TravelSpace.md),
            Text(
              role.whatToDo,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TravelType.subhead.copyWith(color: p.ink),
            ),
            const SizedBox(height: TravelSpace.xs),
            Row(
              children: [
                FaIcon(TravelIcons.clock, size: 11, color: p.inkMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    role.bestTime,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TravelType.footnote.copyWith(color: p.inkMuted),
                  ),
                ),
              ],
            ),
            if (videos.isNotEmpty) ...[
              const SizedBox(height: TravelSpace.md),
              SizedBox(
                height: 112,
                child: Row(
                  children: [
                    for (final (i, v) in videos.indexed) ...[
                      if (i > 0) const SizedBox(width: TravelSpace.sm),
                      ShortTile(
                        video: v,
                        width: 63,
                        compact: true,
                        onTap: (tile) => widget.onPlay(role, i, tile),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Foto em selo postal (skeuomórfico): papel com picote nas bordas e a
/// foto dentro, levemente girado.
class _Stamp extends StatelessWidget {
  const _Stamp({required this.asset, this.angle = 0});

  final String asset;
  final double angle;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final paper =
        p.isDark ? Colors.white : Color.lerp(p.s2, Colors.white, 0.35)!;
    return Transform.rotate(
      angle: angle,
      child: ClipPath(
        clipper: const _StampClipper(),
        child: Container(
          width: 76,
          height: 92,
          color: paper,
          padding: const EdgeInsets.all(6),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(1),
            child: Image.asset(asset, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

/// Picote: semicírculos recortados ao longo das quatro bordas.
class _StampClipper extends CustomClipper<Path> {
  const _StampClipper();

  @override
  Path getClip(Size size) {
    const r = 2.4;
    const step = 7.5;
    final holes = Path();
    final nx = math.max(1, (size.width / step).round());
    final ny = math.max(1, (size.height / step).round());
    for (var i = 0; i < nx; i++) {
      final x = size.width / nx * (i + 0.5);
      holes
        ..addOval(Rect.fromCircle(center: Offset(x, 0), radius: r))
        ..addOval(Rect.fromCircle(center: Offset(x, size.height), radius: r));
    }
    for (var j = 0; j < ny; j++) {
      final y = size.height / ny * (j + 0.5);
      holes
        ..addOval(Rect.fromCircle(center: Offset(0, y), radius: r))
        ..addOval(Rect.fromCircle(center: Offset(size.width, y), radius: r));
    }
    return Path.combine(
        PathOperation.difference, Path()..addRect(Offset.zero & size), holes);
  }

  @override
  bool shouldReclip(_StampClipper oldClipper) => false;
}
