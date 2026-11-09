import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:studio_app/features/travel_agent/data/travel_agent_mock.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/agent_sheet.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/mare_mark.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';

/// Abertura do começo do zero (nada salvo, nada enviado), sobre o mapa.
///
/// Saudação grande no centro, composer e um chip suave; em volta, a "maré em
/// pixels" — bichos do mar em mosaico nadando pelas bordas (ref. Inspora
/// "shark ascii animation"). Saudação, chip e cena são sorteados a cada
/// visita. O mapa continua arrastável por baixo.
class BlankStartHero extends StatefulWidget {
  const BlankStartHero({required this.used, required this.onSend, super.key});

  final int used;
  final ValueChanged<String> onSend;

  @override
  State<BlankStartHero> createState() => _BlankStartHeroState();
}

class _BlankStartHeroState extends State<BlankStartHero> {
  late final math.Random _rng =
      math.Random(DateTime.now().millisecondsSinceEpoch);
  late final String _greeting =
      TravelMock.blankGreetings[_rng.nextInt(TravelMock.blankGreetings.length)];
  late final String _chip = TravelMock
      .blankSuggestions[_rng.nextInt(TravelMock.blankSuggestions.length)];
  late final TideScene _scene =
      TideScene.values[_rng.nextInt(TideScene.values.length)];
  late final int _seed = _rng.nextInt(1 << 20);

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final name = TravelMock.profile.travelerName;
    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(child: PixelTide(scene: _scene, seed: _seed)),
        // Véu radial: o texto respira sobre o mapa (como o brilho da ref.).
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 0.95,
                colors: [
                  p.s0.withValues(alpha: 0.95),
                  p.s0.withValues(alpha: 0.8),
                  p.s0.withValues(alpha: 0),
                ],
                stops: const [0, 0.45, 1],
              ),
            ),
          ),
        ),
        // Rola se faltar altura (teclado aberto em tela baixa).
        Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            // Mesmo respiro em cima (botões de vidro) e embaixo: continua
            // centralizado.
            padding: EdgeInsets.symmetric(
                vertical:
                    MediaQuery.paddingOf(context).top + TravelSpace.tap + 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MareMark(size: 28),
                  const SizedBox(height: TravelSpace.lg),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: TravelSpace.content),
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: 'Oi, $name.\n',
                          style: TextStyle(color: p.inkMuted),
                        ),
                        TextSpan(text: _greeting),
                      ]),
                      textAlign: TextAlign.center,
                      style: TravelType.title1.copyWith(color: p.ink),
                    ),
                  ),
                  const SizedBox(height: TravelSpace.lg),
                  // Nada embaixo do composer: o chip vem antes.
                  _SoftChip(label: _chip, onTap: () => widget.onSend(_chip)),
                  const SizedBox(height: TravelSpace.xs),
                  AgentInputBar(
                    enabled: true,
                    used: widget.used,
                    hint: 'Pergunte à Maré…',
                    safeBottom: false,
                    onSend: widget.onSend,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Sugestão única, suave: `s1` com texto neutro (sem o azul de contraste).
class _SoftChip extends StatelessWidget {
  const _SoftChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

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
        child: Container(
          height: TravelSpace.tap,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: p.s1,
            borderRadius: BorderRadius.circular(TravelSpace.rPill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(label,
                    style: TravelType.subheadStrong.copyWith(color: p.ink)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Maré em pixels ────────────────────────────────────────────────────────

/// Cena sorteada por visita. Sem tubarão: em Boa Viagem ele é aviso de
/// perigo, e a Maré fala de rolê seguro.
enum TideScene { tartaruga, cardume, arraia, jangada }

enum _Kind { fish, turtle, ray, raft }

/// Um bicho e o trajeto dele (Bézier cúbica em coordenadas 0–1 da tela,
/// começando e terminando fora dela).
class _Swimmer {
  const _Swimmer(this.kind, this.path, this.size,
      {this.laps = 1, this.phase = 0, this.tinted = false});

  final _Kind kind;
  final List<Offset> path;

  /// Comprimento em fração do menor lado da tela.
  final double size;

  /// Travessias por ciclo do controlador (inteiro: o laço não emenda).
  final int laps;
  final double phase;

  /// Toque de tiffany (marca/água) nas células mais densas.
  final bool tinted;
}

/// Bichos do mar em mosaico de pixels (dither Bayer 4×4), cinza do `ink`
/// com toque de `piscina`. Nadam pelas bordas e somem perto do centro, onde
/// fica o texto. Reduce Motion → quadro parado.
class PixelTide extends StatefulWidget {
  const PixelTide({required this.scene, required this.seed, super.key});

  final TideScene scene;
  final int seed;

  @override
  State<PixelTide> createState() => _PixelTideState();
}

class _PixelTideState extends State<PixelTide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 30),
  );
  late final List<_Swimmer> _swimmers =
      _cast(widget.scene, math.Random(widget.seed));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c
        ..stop()
        ..value = 0.5;
    } else if (!_c.isAnimating && _c.value == 0) {
      // Duas passagens e para (sem animação infinita no mapa): os bichos
      // saem de cena e o mapa fica quieto.
      _c.repeat(count: 2);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _PixelTidePainter(
          swimmers: _swimmers,
          clock: _c,
          palette: TravelPalette.of(context),
        ),
      ),
    );
  }

  static List<_Swimmer> _cast(TideScene scene, math.Random rng) {
    // Espelha a cena metade das vezes e desloca um pouco na vertical.
    final flip = rng.nextBool();
    final dy = (rng.nextDouble() - 0.5) * 0.04;
    final base = rng.nextDouble();
    List<Offset> path(List<double> xy) => [
          for (var i = 0; i < 8; i += 2)
            Offset(flip ? 1 - xy[i] : xy[i], xy[i + 1] + dy),
        ];

    List<_Swimmer> school(List<double> xy, int n, double phase,
        {double size = 0.15}) {
      return [
        for (var i = 0; i < n; i++)
          _Swimmer(
            _Kind.fish,
            [
              for (final o in path(xy))
                o +
                    Offset((rng.nextDouble() - 0.5) * 0.12,
                        (rng.nextDouble() - 0.5) * 0.1),
            ],
            size * (0.8 + rng.nextDouble() * 0.4),
            laps: 2,
            phase: (base + phase + i * 0.02 + rng.nextDouble() * 0.015) % 1,
            tinted: rng.nextDouble() < 0.3,
          ),
      ];
    }

    const top = [1.2, 0.17, 0.7, 0.07, 0.3, 0.25, -0.2, 0.12];
    const bottom = [-0.2, 0.88, 0.4, 0.98, 0.6, 0.78, 1.2, 0.9];

    switch (scene) {
      case TideScene.tartaruga:
        return [
          _Swimmer(
            _Kind.turtle,
            path(const [-0.3, 0.95, 0.3, 0.78, 0.7, 0.98, 1.3, 0.82]),
            0.56,
            phase: base,
            tinted: true,
          ),
          ...school(top, 6, 0.4),
        ];
      case TideScene.cardume:
        return [
          ...school(top, 6, 0),
          ...school(bottom, 5, 0.5, size: 0.17),
        ];
      case TideScene.arraia:
        return [
          _Swimmer(
            _Kind.ray,
            path(const [1.3, 0.92, 0.7, 0.76, 0.3, 1.0, -0.3, 0.84]),
            0.56,
            phase: base,
          ),
          ...school(top, 5, 0.3),
        ];
      case TideScene.jangada:
        return [
          _Swimmer(
            _Kind.raft,
            path(const [-0.25, 0.21, 0.3, 0.19, 0.7, 0.23, 1.25, 0.2]),
            0.32,
            phase: base,
            tinted: true,
          ),
          _Swimmer(
            _Kind.turtle,
            path(const [1.3, 0.9, 0.7, 0.8, 0.3, 0.98, -0.3, 0.86]),
            0.4,
            phase: (base + 0.5) % 1,
          ),
        ];
    }
  }
}

class _PixelTidePainter extends CustomPainter {
  _PixelTidePainter({
    required this.swimmers,
    required this.clock,
    required this.palette,
  }) : super(repaint: clock);

  final List<_Swimmer> swimmers;
  final Animation<double> clock;
  final TravelPalette palette;

  static const _cell = 5.0;
  static const _seconds = 30.0;

  /// Bayer 4×4 normalizado — limiar ordenado do pontilhado.
  static const _bayer = [
    0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5, //
  ];

  static const _inkAlpha = [0.18, 0.3, 0.44, 0.6];
  static const _tintAlpha = [0.3, 0.45, 0.6, 0.78];

  /// A célula avaliada leva o toque de tiffany? (setado pelo shape).
  bool _tint = false;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final t = clock.value;
    final time = t * _seconds;
    final base = math.min(size.width, size.height);
    final ink = List.generate(4, (_) => <Offset>[]);
    final tint = List.generate(4, (_) => <Offset>[]);

    // Centro livre (texto e composer).
    final cx0 = size.width / 2, cy0 = size.height / 2;
    final ex = size.width * 0.46, ey = math.max(size.height * 0.2, 170.0);

    for (final sw in swimmers) {
      final u = (t * sw.laps + sw.phase) % 1.0;
      final pos = _scale(_bezier(sw.path, u), size);
      var dir = _scale(_tangent(sw.path, u), size);
      final len = dir.distance;
      dir = len == 0 ? const Offset(1, 0) : dir / len;
      final raft = sw.kind == _Kind.raft;
      final sign = dir.dx >= 0 ? 1.0 : -1.0;
      final l = sw.size * base;
      final cellL = _cell / l;
      final reach = l * (sw.kind == _Kind.ray ? 1.15 : 0.8);
      final anim = time + sw.phase * 10;

      final gx0 = ((pos.dx - reach) / _cell).floor();
      final gx1 = ((pos.dx + reach) / _cell).ceil();
      final gy0 = ((pos.dy - reach) / _cell).floor();
      final gy1 = ((pos.dy + reach) / _cell).ceil();
      for (var gy = gy0; gy <= gy1; gy++) {
        final cy = gy * _cell + _cell / 2;
        if (cy < 0 || cy > size.height) continue;
        for (var gx = gx0; gx <= gx1; gx++) {
          final cx = gx * _cell + _cell / 2;
          if (cx < 0 || cx > size.width) continue;
          final dx = cx - pos.dx, dy = cy - pos.dy;
          // Jangada não gira: só vira de lado conforme o rumo.
          final lx = raft ? dx * sign / l : (dx * dir.dx + dy * dir.dy) / l;
          final ly = raft ? dy / l : (-dx * dir.dy + dy * dir.dx) / l;
          _tint = false;
          var d = switch (sw.kind) {
            _Kind.fish => _fish(lx, ly, anim),
            _Kind.turtle => _turtle(lx, ly, anim),
            _Kind.ray => _ray(lx, ly, anim, cellL),
            _Kind.raft => _raft(lx, ly, anim, cellL),
          };
          if (d <= 0) continue;
          final rx = (cx - cx0) / ex, ry = (cy - cy0) / ey;
          final r = math.sqrt(rx * rx + ry * ry);
          d *= ((r - 0.85) / 0.45).clamp(0.0, 1.0);
          if (d <= (_bayer[(gy & 3) * 4 + (gx & 3)] + 0.5) / 16) continue;
          final level = (d * 4).floor().clamp(0, 3);
          (sw.tinted && _tint ? tint : ink)[level].add(Offset(cx, cy));
        }
      }
    }

    final paint = Paint()
      ..strokeWidth = _cell - 1.5
      ..strokeCap = StrokeCap.square;
    for (var i = 0; i < 4; i++) {
      if (ink[i].isNotEmpty) {
        paint.color = palette.ink.withValues(alpha: _inkAlpha[i]);
        canvas.drawPoints(ui.PointMode.points, ink[i], paint);
      }
      if (tint[i].isNotEmpty) {
        paint.color = palette.piscina.withValues(alpha: _tintAlpha[i]);
        canvas.drawPoints(ui.PointMode.points, tint[i], paint);
      }
    }
  }

  // ── Formas (x = frente, y = lado, em unidades do comprimento) ──────────

  /// Positivo dentro da elipse, ~distância normalizada até a borda.
  static double _ell(double x, double y, double a, double b) =>
      1 - math.sqrt((x / a) * (x / a) + (y / b) * (y / b));

  static double _rotEll(double x, double y, double cx, double cy, double a,
      double b, double angle) {
    final c = math.cos(angle), s = math.sin(angle);
    final px = x - cx, py = y - cy;
    return _ell(px * c + py * s, -px * s + py * c, a, b);
  }

  static double _fill(double v) => (v * 3).clamp(0.0, 1.0);

  double _fish(double x, double y, double time) {
    final yy = y + math.sin(x * 7 - time * 9) * 0.04;
    final body = _fill(_ell(x - 0.05, yy, 0.42, 0.17));
    var tail = 0.0;
    if (x < -0.3 && x > -0.64) {
      tail = _fill(((-0.3 - x) * 0.75 - yy.abs()) * 4) * 0.8;
    }
    final d = math.max(body, tail) * 0.85;
    _tint = body > 0.6 && yy < 0;
    return d;
  }

  double _turtle(double x, double y, double time) {
    final flap = math.sin(time * 2.4) * 0.35;
    final shellV = _ell(x, y, 0.42, 0.33);
    var shell = _fill(shellV) * 0.95;
    if (shell > 0 && math.sin(x * 22) * math.sin(y * 22) > 0.3) shell *= 0.7;
    final head = _fill(_ell(x - 0.52, y, 0.13, 0.1)) * 0.8;
    var limbs = 0.0;
    for (final side in const [-1.0, 1.0]) {
      limbs = math.max(
          limbs,
          _fill(_rotEll(
              x, y, 0.16, side * 0.36, 0.28, 0.08, side * (0.6 + flap))));
      limbs = math.max(
          limbs,
          _fill(_rotEll(
              x, y, -0.32, side * 0.24, 0.14, 0.07, side * (2.4 - flap / 2))));
    }
    _tint = shellV > 0.25;
    return math.max(shell, math.max(head, limbs * 0.75));
  }

  double _ray(double x, double y, double time, double cellL) {
    final wing = 1 + 0.18 * math.sin(time * 2.2);
    final v = 1 - ((x - 0.05).abs() / 0.38 + y.abs() / (0.62 * wing));
    final body = _fill(v) * 0.9;
    var tail = 0.0;
    if (x < -0.3 && x > -1.1) {
      final wave = math.sin(x * 8 - time * 4) * 0.03;
      if ((y - wave).abs() < cellL * 0.6) tail = 0.6;
    }
    _tint = v > 0.5;
    return math.max(body, tail);
  }

  double _raft(double x, double y, double time, double cellL) {
    final yy = y - math.sin(time * 1.6) * 0.03;
    // Casco com pontas arredondadas.
    if (yy > 0.18 && yy < 0.28 && x.abs() < 0.48 - (yy - 0.18) * 0.8) {
      _tint = false;
      return 0.9;
    }
    // Mastro.
    if ((x - 0.04).abs() < cellL * 0.5 && yy > -0.62 && yy <= 0.18) {
      _tint = false;
      return 0.75;
    }
    // Vela triangular da jangada.
    if (x <= 0.04 && yy <= 0.14 && yy >= -0.6) {
      final left = 0.04 - (yy + 0.6) / 0.74 * 0.46;
      if (x >= left) {
        _tint = true;
        return 0.45 + 0.4 * ((x - left) / (0.04 - left + 1e-6));
      }
    }
    // Marolas sob o casco.
    if (yy > 0.3 && yy < 0.36 && math.sin(x * 20 + time * 3) > 0.3) {
      _tint = true;
      return 0.4;
    }
    return 0;
  }

  // ── Trajeto ────────────────────────────────────────────────────────────

  static Offset _scale(Offset o, Size s) =>
      Offset(o.dx * s.width, o.dy * s.height);

  static Offset _bezier(List<Offset> p, double u) {
    final v = 1 - u;
    return p[0] * (v * v * v) +
        p[1] * (3 * v * v * u) +
        p[2] * (3 * v * u * u) +
        p[3] * (u * u * u);
  }

  static Offset _tangent(List<Offset> p, double u) {
    final v = 1 - u;
    return (p[1] - p[0]) * (3 * v * v) +
        (p[2] - p[1]) * (6 * v * u) +
        (p[3] - p[2]) * (3 * u * u);
  }

  @override
  bool shouldRepaint(_PixelTidePainter old) =>
      old.palette != palette || old.swimmers != swimmers;
}
