import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:studio_app/core/components/glass/app_glass.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';

/// Carrossel infinito de conectores (ref. vídeo): o do centro cresce num
/// tile claro; os vizinhos encolhem, apagam e desfocam nas bordas.
/// Avança sozinho com curva elástica. Reduce Motion → parado.
class ConnectorCarousel extends StatefulWidget {
  const ConnectorCarousel({required this.connectors, super.key});

  final List<Connector> connectors;

  @override
  State<ConnectorCarousel> createState() => _ConnectorCarouselState();
}

class _ConnectorCarouselState extends State<ConnectorCarousel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  );
  int _step = 0;
  double _prev = 0;

  @override
  void initState() {
    super.initState();
    _c.addListener(() {
      if (_c.value < _prev) _step++;
      _prev = _c.value;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double get _frac {
    // 45% do ciclo anda (com overshoot), o resto segura no lugar.
    final v = (_c.value / 0.45).clamp(0.0, 1.0);
    return Curves.easeInOutBack.transform(v);
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.connectors.length;
    return SizedBox(
      width: double.infinity,
      height: 112,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final frac = _frac;
          final items = <(double, Widget)>[];
          for (var k = -3; k <= 4; k++) {
            final d = k - frac;
            final idx = ((_step + k) % n + n) % n;
            final ad = d.abs();
            final scale = ad < 1
                ? ui.lerpDouble(1.3, 0.86, ad)!
                : math.max(0.6, 0.86 - (ad - 1) * 0.1);
            final opacity = (1 - 0.32 * math.min(ad, 2.5)).clamp(0.0, 1.0);
            items.add((
              ad,
              Transform.translate(
                offset: Offset(d * 80, 0),
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: AppBlur(
                      sigma: math.max(0, ad - 1.2) * 2.4,
                      child: ConnectorTile(
                        kind: widget.connectors[idx].kind,
                        size: 60,
                        lifted: ad < 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ));
          }
          items.sort((a, b) => b.$1.compareTo(a.$1));
          return ExcludeSemantics(
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [for (final i in items) i.$2],
            ),
          );
        },
      ),
    );
  }
}

/// Ícone oficial de cada app (App Store), com máscara iOS (raio 22,37%).
class ConnectorTile extends StatelessWidget {
  const ConnectorTile({
    required this.kind,
    this.size = 44,
    this.lifted = false,
    super.key,
  });

  final ConnectorKind kind;
  final double size;
  final bool lifted;

  static String assetOf(ConnectorKind k) =>
      'assets/images/connectors/${switch (k) {
        ConnectorKind.googleCalendar => 'google_calendar',
        ConnectorKind.googleMaps => 'google_maps',
        ConnectorKind.gmail => 'gmail',
        ConnectorKind.uber => 'uber',
        ConnectorKind.noveNove => 'noventa_e_nove',
      }}.png';

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.2237);
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: radius),
      foregroundDecoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
      ),
      child: Image.asset(assetOf(kind), fit: BoxFit.cover),
    );
  }
}

/// Aurora: brilho que desliza e pulsa no rodapé do sheet.
/// [intensity] escala o alfa (fundo claro pede menos que o escuro).
class Aurora extends StatefulWidget {
  const Aurora({required this.colors, this.intensity = 1, super.key});

  final List<Color> colors;
  final double intensity;

  @override
  State<Aurora> createState() => _AuroraState();
}

class _AuroraState extends State<Aurora> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _AuroraPainter(
              _c.value * math.pi * 2, widget.colors, widget.intensity),
        ),
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter(this.t, this.colors, this.intensity);

  final double t;
  final List<Color> colors;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < colors.length; i++) {
      final ph = t + i * 2.1;
      final center = Offset(
        size.width * (0.5 + 0.38 * math.sin(ph * (i.isEven ? 1 : -1))),
        size.height * (0.95 - 0.12 * math.cos(ph * 0.7)),
      );
      final r = size.width * (0.55 + 0.1 * math.sin(ph * 1.3));
      final pulse = (0.55 + 0.25 * math.sin(ph * 0.9)) * intensity;
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..shader = ui.Gradient.radial(center, r, [
            colors[i].withValues(alpha: pulse),
            colors[i].withValues(alpha: 0),
          ]),
      );
    }
  }

  @override
  bool shouldRepaint(_AuroraPainter old) =>
      old.t != t || old.intensity != intensity;
}
