import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/features/explore/domain/explore_entities.dart';
import 'package:studio_app/features/explore/presentation/widgets/explore_ui.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';

String _brl(int v, {bool plus = false}) => 'R\$ $v${plus ? '+' : ''}';

// ── Preço: histograma + faixa (ref. Airbnb) ───────────────────────────────

/// Faixa de preço por pessoa: histograma dos rolês curados por preço e um
/// range slider na base das barras. Barras dentro da faixa em `accent`, fora
/// em cinza. Mínimo e máximo embaixo, em pílulas `s1`.
class PriceRangePicker extends StatelessWidget {
  const PriceRangePicker({
    required this.prices,
    required this.min,
    required this.max,
    required this.onChanged,
    super.key,
  });

  /// Preço estimado por pessoa de cada rolê (alimenta o histograma).
  final List<int> prices;
  final int min;
  final int max;
  final void Function(int min, int max) onChanged;

  static const _thumb = 14.0;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    const bins = kPriceCap ~/ kPriceStep + 1;
    final counts = List<int>.filled(bins, 0);
    for (final v in prices) {
      counts[(v.clamp(0, kPriceCap) / kPriceStep).floor()]++;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 96,
          child: Stack(
            children: [
              // Barras alinhadas ao trilho (recuo = raio do polegar).
              Positioned(
                left: _thumb,
                right: _thumb,
                top: 0,
                bottom: 24,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: 1),
                  duration: exploreMotion(context, 520),
                  curve: kExploreEase,
                  builder: (context, grow, _) => CustomPaint(
                    painter: _HistogramPainter(
                      counts: counts,
                      min: min,
                      max: max,
                      on: p.accent,
                      off: p.ink.withValues(alpha: 0.12),
                      grow: grow,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 48,
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2,
                    activeTrackColor: p.accent,
                    inactiveTrackColor: p.ink.withValues(alpha: 0.12),
                    overlayShape: SliderComponentShape.noOverlay,
                    rangeThumbShape: _ThumbShape(
                      fill: p.s1,
                      ring: p.ink.withValues(alpha: 0.14),
                    ),
                    rangeTickMarkShape:
                        const RoundRangeSliderTickMarkShape(tickMarkRadius: 0),
                    showValueIndicator: ShowValueIndicator.never,
                  ),
                  child: RangeSlider(
                    values: RangeValues(min.toDouble(), max.toDouble()),
                    max: kPriceCap.toDouble(),
                    divisions: kPriceCap ~/ kPriceStep,
                    semanticFormatterCallback: (v) =>
                        _brl(v.round(), plus: v.round() >= kPriceCap),
                    onChanged: (v) {
                      final a = v.start.round();
                      final b = v.end.round();
                      if (a != min || b != max) {
                        HapticFeedback.selectionClick();
                        onChanged(a, b);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: TravelSpace.md),
        Row(
          children: [
            _Bound(label: 'Mínimo', value: _brl(min)),
            const Spacer(),
            _Bound(
                label: 'Máximo',
                value: _brl(max, plus: max >= kPriceCap),
                end: true),
          ],
        ),
      ],
    );
  }
}

class _Bound extends StatelessWidget {
  const _Bound({required this.label, required this.value, this.end = false});

  final String label;
  final String value;
  final bool end;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Column(
      crossAxisAlignment:
          end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(label,
              style: TravelType.caption.copyWith(color: p.inkMuted)),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          constraints: const BoxConstraints(minWidth: 96),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: p.s1,
            borderRadius: BorderRadius.circular(TravelSpace.rPill),
          ),
          child: AnimatedSwitcher(
            duration: exploreMotion(context, 150),
            child: Text(
              value,
              key: ValueKey(value),
              style: TravelType.subheadStrong
                  .copyWith(color: p.ink, fontFeatures: TravelType.tabular),
            ),
          ),
        ),
      ],
    );
  }
}

class _HistogramPainter extends CustomPainter {
  _HistogramPainter({
    required this.counts,
    required this.min,
    required this.max,
    required this.on,
    required this.off,
    required this.grow,
  });

  final List<int> counts;
  final int min;
  final int max;
  final Color on;
  final Color off;
  final double grow;

  @override
  void paint(Canvas canvas, Size size) {
    final peak = counts.fold<int>(1, math.max);
    final n = counts.length;
    // Cada barra centrada no valor que ela representa (0, 5, …, 60).
    final step = size.width / (n - 1);
    final barW = math.min(10.0, step * 0.62);
    for (var i = 0; i < n; i++) {
      if (counts[i] == 0) continue;
      final value = i * kPriceStep;
      final inside = value >= min && (max >= kPriceCap || value <= max);
      final h = (size.height - 4) * counts[i] / peak * grow;
      final x = (i * step).clamp(barW / 2, size.width - barW / 2);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x - barW / 2, size.height - h, barW, h),
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
        ),
        Paint()..color = inside ? on : off,
      );
    }
  }

  @override
  bool shouldRepaint(_HistogramPainter old) =>
      old.min != min || old.max != max || old.grow != grow || old.on != on;
}

/// Polegar flat: disco `s1` com anel fino (sem sombra — regra 1).
class _ThumbShape extends RangeSliderThumbShape {
  const _ThumbShape({required this.fill, required this.ring});

  final Color fill;
  final Color ring;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(PriceRangePicker._thumb);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool? isOnTop,
    TextDirection? textDirection,
    required SliderThemeData sliderTheme,
    Thumb? thumb,
    bool? isPressed,
  }) {
    final r = PriceRangePicker._thumb * (1 + 0.12 * activationAnimation.value);
    final c = context.canvas;
    c.drawCircle(center, r, Paint()..color = fill);
    c.drawCircle(
      center,
      r - 0.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = ring,
    );
  }
}

// ── Período: arco do dia (ref. card de nascer/pôr do sol) ─────────────────

/// Card do período: arraste o sol pelo arco. Manhã à esquerda, tarde no
/// alto, noite à direita — indo pra noite o card escurece, o sol vira lua e
/// o brilho fica azul. Ao soltar encaixa no período mais perto (mola do
/// segmented). Tocar num rótulo também escolhe; "Qualquer" limpa.
class DayArcPicker extends StatefulWidget {
  const DayArcPicker({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final StopPeriod? value;
  final ValueChanged<StopPeriod?> onChanged;

  @override
  State<DayArcPicker> createState() => _DayArcPickerState();
}

class _DayArcPickerState extends State<DayArcPicker>
    with SingleTickerProviderStateMixin {
  static const _h = 208.0;
  static const _spring =
      SpringDescription(mass: 1, stiffness: 420, damping: 32);

  /// Posição no arco (0 = horizonte da esquerda, 1 = da direita).
  static const _stops = {
    StopPeriod.manha: 0.16,
    StopPeriod.tarde: 0.5,
    StopPeriod.noite: 0.86,
  };

  static const _night = DayArcTones.night;
  static const _nightGround = DayArcTones.nightGround;
  static const _warm = DayArcTones.warmGlow;
  static const _noon = DayArcTones.noonGlow;
  static const _nightGlow = DayArcTones.nightGlow;

  late final AnimationController _t = AnimationController.unbounded(
      vsync: this, value: _stops[widget.value] ?? 0.5);
  bool _held = false;
  StopPeriod? _zone;

  @override
  void didUpdateWidget(DayArcPicker old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && !_held) {
      _animateTo(_stops[widget.value] ?? 0.5);
    }
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  void _animateTo(double target, {double velocity = 0}) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _t.value = target;
      return;
    }
    _t.animateWith(SpringSimulation(_spring, _t.value, target, velocity));
  }

  static StopPeriod _nearest(double t) => _stops.entries
      .reduce((a, b) => (a.value - t).abs() <= (b.value - t).abs() ? a : b)
      .key;

  void _pick(StopPeriod? period) {
    _animateTo(_stops[period] ?? 0.5);
    if (period != widget.value) {
      HapticFeedback.selectionClick();
      widget.onChanged(period);
    }
  }

  double _tAt(double x, double w) => ((x - w * _ArcGeometry.left) /
          (w * (_ArcGeometry.right - _ArcGeometry.left)))
      .clamp(0.0, 1.0);

  static double _smooth(double a, double b, double x) {
    final t = ((x - a) / (b - a)).clamp(0.0, 1.0);
    return t * t * (3 - 2 * t);
  }

  static String _title(StopPeriod? p) => switch (p) {
        null => 'Qualquer horário',
        StopPeriod.manha => 'De manhã',
        StopPeriod.tarde => 'À tarde',
        StopPeriod.noite => 'À noite',
      };

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) => _pick(_nearest(_tAt(d.localPosition.dx, w))),
          onHorizontalDragStart: (d) {
            _t.stop();
            _zone = widget.value;
            setState(() => _held = true);
          },
          onHorizontalDragUpdate: (d) {
            _t.value = _tAt(d.localPosition.dx, w);
            final z = _nearest(_t.value);
            if (z != _zone) {
              _zone = z;
              HapticFeedback.selectionClick();
            }
          },
          onHorizontalDragEnd: (d) {
            setState(() => _held = false);
            final v = d.velocity.pixelsPerSecond.dx / w;
            final target = _nearest(_t.value + v * 0.08);
            _animateTo(_stops[target]!, velocity: v);
            if (target != widget.value) widget.onChanged(target);
          },
          child: AnimatedBuilder(
            animation: _t,
            builder: (context, _) {
              final t = _t.value;
              final night = _smooth(0.6, 0.86, t);
              final morning = 1 - _smooth(0.16, 0.42, t);
              final bg = Color.lerp(p.s1, _night, night)!;
              final fg = Color.lerp(p.ink, Colors.white, night)!;
              final muted = Color.lerp(p.inkMuted, Colors.white70, night)!;
              final glow = Color.lerp(
                  Color.lerp(_noon, _warm, morning)!, _nightGlow, night)!;
              final active = widget.value;
              return ClipRRect(
                borderRadius: BorderRadius.circular(TravelSpace.rCard),
                child: SizedBox(
                  height: _h,
                  child: Stack(
                    children: [
                      Positioned.fill(child: ColoredBox(color: bg)),
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _ArcPainter(
                            t: t,
                            glow: glow,
                            night: night,
                            ground: Color.lerp(p.ink.withValues(alpha: 0.035),
                                _nightGround, night)!,
                            stroke: Color.lerp(p.ink.withValues(alpha: 0.14),
                                Colors.white.withValues(alpha: 0.32), night)!,
                          ),
                        ),
                      ),
                      // Sol → lua, sobre o arco.
                      Builder(builder: (context) {
                        final c = _ArcGeometry.point(t, Size(w, _h));
                        return Positioned(
                          left: c.dx - 22,
                          top: c.dy - 22,
                          child: IgnorePointer(
                            child: AnimatedScale(
                              scale: _held ? 1.12 : 1,
                              duration: const Duration(milliseconds: 160),
                              curve: kExploreEase,
                              child: SizedBox.square(
                                dimension: 44,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Opacity(
                                      opacity: 1 - night,
                                      child: FaIcon(TravelIcons.sun,
                                          size: 26, color: p.sol),
                                    ),
                                    Opacity(
                                      opacity: night,
                                      child: const FaIcon(TravelIcons.moon,
                                          size: 24, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      // Cabeçalho: o que está valendo + "Qualquer".
                      Positioned(
                        left: TravelSpace.lg,
                        right: TravelSpace.sm,
                        top: TravelSpace.md,
                        child: Row(
                          children: [
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: exploreMotion(context, 160),
                                layoutBuilder: (cur, prev) => Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [...prev, if (cur != null) cur],
                                ),
                                child: Text(
                                  _title(_held ? _nearest(t) : active),
                                  key: ValueKey(_held ? _nearest(t) : active),
                                  style: TravelType.title3.copyWith(color: fg),
                                ),
                              ),
                            ),
                            AnimatedOpacity(
                              opacity: active == null ? 0 : 1,
                              duration: exploreMotion(context, 150),
                              child: IgnorePointer(
                                ignoring: active == null,
                                child: Semantics(
                                  button: true,
                                  label: 'Qualquer horário',
                                  excludeSemantics: true,
                                  onTap: () => _pick(null),
                                  child: Pressable(
                                    onTap: () => _pick(null),
                                    child: SizedBox(
                                      height: TravelSpace.tap,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: TravelSpace.sm),
                                        child: Center(
                                          widthFactor: 1,
                                          child: Text('Qualquer',
                                              style: TravelType.subheadStrong
                                                  .copyWith(color: fg)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Rótulos no chão (também tocáveis).
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: TravelSpace.xs,
                        child: Row(
                          children: [
                            for (final e in _stops.entries)
                              Expanded(
                                child: Semantics(
                                  button: true,
                                  selected: active == e.key,
                                  label: periodLabel(e.key),
                                  excludeSemantics: true,
                                  onTap: () => _pick(e.key),
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => _pick(e.key),
                                    child: SizedBox(
                                      height: TravelSpace.tap,
                                      child: Center(
                                        child: Text(
                                          periodLabel(e.key),
                                          style: (active == e.key
                                                  ? TravelType.footnoteStrong
                                                  : TravelType.footnote)
                                              .copyWith(
                                            color: active == e.key ? fg : muted,
                                            fontFeatures: TravelType.tabular,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Geometria do arco: um círculo grande cujo topo fica a ~55% da altura,
/// largo além das bordas (a cúpula da referência).
abstract final class _ArcGeometry {
  static const left = 0.14;
  static const right = 0.86;

  static ({Offset center, double radius}) circle(Size s) {
    final r = s.width * 0.78;
    return (center: Offset(s.width / 2, s.height * 0.56 + r), radius: r);
  }

  static Offset point(double t, Size s) {
    final c = circle(s);
    final x = s.width * (left + (right - left) * t);
    final dx = x - c.center.dx;
    final y =
        c.center.dy - math.sqrt(math.max(0, c.radius * c.radius - dx * dx));
    return Offset(x, y);
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter({
    required this.t,
    required this.glow,
    required this.night,
    required this.ground,
    required this.stroke,
  });

  final double t;
  final Color glow;
  final double night;
  final Color ground;
  final Color stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final c = _ArcGeometry.circle(size);
    final body = _ArcGeometry.point(t, size);

    // Brilho atrás do sol/lua (mais forte à noite, como na referência).
    canvas.drawCircle(
      body,
      size.width * 0.42,
      Paint()
        ..shader = ui.Gradient.radial(body, size.width * 0.42, [
          glow.withValues(alpha: 0.30 + 0.25 * night),
          glow.withValues(alpha: 0),
        ]),
    );

    // Cúpula (chão) e a linha do horizonte.
    final dome = Path()
      ..addOval(Rect.fromCircle(center: c.center, radius: c.radius));
    canvas.drawPath(dome, Paint()..color = ground);
    canvas.drawCircle(
      c.center,
      c.radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = stroke,
    );

    // Marcas dos três períodos no arco.
    for (final s in const [0.16, 0.5, 0.86]) {
      canvas.drawCircle(
          _ArcGeometry.point(s, size), 2.5, Paint()..color = stroke);
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.t != t || old.glow != glow || old.ground != ground;
}
