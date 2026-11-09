import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';

enum MareMood { idle, thinking, success }

/// Símbolo flat da Maré: disco sólido com duas ondas (maré). Sem gradiente,
/// brilho nem volume. `thinking` faz as ondas correrem; Reduce Motion → parado.
/// [inverted] = disco branco com ondas azuis, para usar sobre o azul.
class MareMark extends StatefulWidget {
  const MareMark({
    this.size = 32,
    this.mood = MareMood.idle,
    this.inverted = false,
    super.key,
  });

  final double size;
  final MareMood mood;
  final bool inverted;

  @override
  State<MareMark> createState() => _MareMarkState();
}

class _MareMarkState extends State<MareMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(MareMark old) {
    super.didUpdateWidget(old);
    if (old.mood != widget.mood) _sync();
  }

  void _sync() {
    final animate = widget.mood == MareMood.thinking &&
        !MediaQuery.disableAnimationsOf(context);
    if (animate && !_c.isAnimating) {
      _c.repeat();
    } else if (!animate && _c.isAnimating) {
      _c
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final disc = widget.inverted ? p.onAccent : p.accent;
    final wave = widget.inverted ? p.accent : p.onAccent;
    return Semantics(
      label: switch (widget.mood) {
        MareMood.idle => 'Maré',
        MareMood.thinking => 'Maré pensando',
        MareMood.success => 'Maré concluiu',
      },
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(
            painter: _MarkPainter(
              phase: _c.value * math.pi * 2,
              disc: disc,
              wave: wave,
            ),
          ),
        ),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  _MarkPainter({required this.phase, required this.disc, required this.wave});

  final double phase;
  final Color disc;
  final Color wave;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final c = size.center(Offset.zero);
    canvas.drawCircle(c, s / 2, Paint()..color = disc);

    final stroke = Paint()
      ..color = wave
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.4, s * 0.09)
      ..strokeCap = StrokeCap.round;
    final w = s * 0.52;
    final amp = s * 0.065;
    for (final (i, dy) in [-0.11, 0.11].indexed) {
      final path = Path();
      const steps = 24;
      for (var k = 0; k <= steps; k++) {
        final t = k / steps;
        final x = c.dx - w / 2 + w * t;
        final y =
            c.dy + dy * s + math.sin(t * math.pi * 3 - phase + i * 0.9) * amp;
        k == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      canvas.drawPath(path, stroke);
    }
  }

  @override
  bool shouldRepaint(_MarkPainter old) =>
      old.phase != phase || old.disc != disc || old.wave != wave;
}
