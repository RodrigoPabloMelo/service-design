import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';

/// Projeção equiretangular do recorte de Recife/Olinda num canvas fixo.
/// Geometria estilizada (não cartográfica) — sem tiles, sem watermark.
abstract final class RecifeProjection {
  static const north = -7.900;
  static const south = -8.420;
  static const west = -35.020;
  static const east = -34.800;

  // h/w = Δlat / (Δlng · cos 8°) ≈ 2.3875 — sobra ao sul para o sheet
  // cobrir metade da tela sem a borda do canvas aparecer.
  static const width = 1600.0;
  static const height = 3820.0;
  static const size = Size(width, height);

  static Offset of(GeoPoint p) => Offset(
        (p.lng - west) / (east - west) * width,
        (north - p.lat) / (north - south) * height,
      );

  static Offset ll(double lat, double lng) => of(GeoPoint(lat, lng));

  static Rect boundsOf(Iterable<GeoPoint> points) {
    final offs = points.map(of).toList();
    var r = Rect.fromPoints(offs.first, offs.first);
    for (final o in offs.skip(1)) {
      r = r.expandToInclude(Rect.fromPoints(o, o));
    }
    return r;
  }
}

// ── Geometria (lat, lng) ──────────────────────────────────────────────────

const _coast = <List<double>>[
  [-7.900, -34.8260],
  [-7.930, -34.8300],
  [-7.960, -34.8350],
  [-7.995, -34.8395],
  [-8.003, -34.8405],
  [-8.010, -34.8425],
  [-8.017, -34.8445],
  [-8.024, -34.8480],
  [-8.031, -34.8530],
  [-8.038, -34.8590],
  [-8.045, -34.8640],
  [-8.052, -34.8668],
  [-8.058, -34.8680],
  [-8.064, -34.8690],
  [-8.070, -34.8720],
  [-8.077, -34.8752],
  [-8.084, -34.8785],
  [-8.092, -34.8815],
  [-8.100, -34.8845],
  [-8.110, -34.8885],
  [-8.120, -34.8925],
  [-8.130, -34.8965],
  [-8.140, -34.9005],
  [-8.150, -34.9040],
  [-8.170, -34.9100],
  [-8.200, -34.9180],
  [-8.230, -34.9280],
  [-8.260, -34.9400],
  [-8.300, -34.9550],
  [-8.340, -34.9680],
  [-8.380, -34.9800],
  [-8.420, -34.9920],
];

const _capibaribe = <List<double>>[
  [-8.052, -34.965],
  [-8.048, -34.955],
  [-8.043, -34.946],
  [-8.039, -34.938],
  [-8.034, -34.932],
  [-8.0300, -34.9255],
  [-8.0300, -34.9195],
  [-8.0340, -34.9140],
  [-8.0375, -34.9080],
  [-8.0400, -34.9025],
  [-8.0445, -34.8985],
  [-8.0490, -34.8945],
  [-8.0535, -34.8895],
  [-8.0575, -34.8850],
  [-8.0610, -34.8822],
  [-8.0638, -34.8805],
  [-8.0660, -34.8775],
  [-8.0672, -34.8735],
  [-8.0668, -34.8700],
];

const _beberibe = <List<double>>[
  [-7.995, -34.905],
  [-8.003, -34.893],
  [-8.011, -34.882],
  [-8.019, -34.874],
  [-8.027, -34.868],
  [-8.036, -34.8635],
  [-8.044, -34.8625],
  [-8.050, -34.8655],
];

const _jordao = <List<double>>[
  [-8.0930, -34.8905],
  [-8.1000, -34.8990],
  [-8.1060, -34.9080],
  [-8.1120, -34.9180],
  [-8.1180, -34.9300],
  [-8.1220, -34.9450],
];

const _baciaPina = <List<double>>[
  [-8.0695, -34.8790],
  [-8.0740, -34.8850],
  [-8.0805, -34.8905],
  [-8.0880, -34.8930],
  [-8.0950, -34.8915],
  [-8.0935, -34.8860],
  [-8.0870, -34.8830],
  [-8.0800, -34.8800],
  [-8.0740, -34.8770],
];

const _manguezais = <List<double>>[
  [-8.0980, -34.9000],
  [-8.1060, -34.9090],
  [-8.1140, -34.9060],
  [-8.1100, -34.8970],
  [-8.1020, -34.8940],
];

const _doisIrmaos = <List<double>>[
  [-8.000, -34.935],
  [-8.006, -34.950],
  [-8.016, -34.957],
  [-8.024, -34.946],
  [-8.017, -34.932],
  [-8.008, -34.928],
];

const _varzea = <List<double>>[
  [-8.044, -34.952],
  [-8.050, -34.963],
  [-8.060, -34.960],
  [-8.058, -34.948],
];

/// Parques circulares: (lat, lng, raio em px).
const _parks = <List<double>>[
  [-8.0378, -34.9033, 20], // Jaqueira
  [-8.0279, -34.9100, 18], // Sítio da Trindade
  [-8.1290, -34.8985, 10], // Dona Lindu
  [-8.0130, -34.8530, 34], // Olinda (Alto da Sé)
  [-8.0850, -34.9300, 22], // Parque do Caiara
];

const _majorRoads = <List<List<double>>>[
  // Agamenon Magalhães
  [
    [-8.030, -34.8790],
    [-8.040, -34.8875],
    [-8.050, -34.8940],
    [-8.060, -34.8975],
    [-8.070, -34.8990],
    [-8.080, -34.9005]
  ],
  // Conde da Boa Vista
  [
    [-8.0612, -34.8828],
    [-8.0598, -34.8900],
    [-8.0588, -34.8975]
  ],
  // Av. Norte
  [
    [-8.050, -34.8800],
    [-8.040, -34.8900],
    [-8.030, -34.9000],
    [-8.018, -34.9110],
    [-8.005, -34.9250]
  ],
  // Rosa e Silva → Casa Forte
  [
    [-8.0510, -34.8960],
    [-8.0430, -34.9040],
    [-8.0360, -34.9140],
    [-8.0330, -34.9200]
  ],
  // Caxangá
  [
    [-8.0570, -34.8990],
    [-8.0540, -34.9200],
    [-8.0515, -34.9400],
    [-8.0490, -34.9620]
  ],
  // Mascarenhas de Morais
  [
    [-8.0800, -34.9010],
    [-8.1000, -34.9120],
    [-8.1300, -34.9180],
    [-8.1500, -34.9220]
  ],
  // Av. Olinda (beira-mar norte)
  [
    [-8.0330, -34.8600],
    [-8.0200, -34.8500],
    [-8.0050, -34.8440],
    [-7.9950, -34.8425]
  ],
];

const _labels = <(String, double, double)>[
  ('OLINDA', -8.0090, -34.8620),
  ('RECIFE ANTIGO', -8.0600, -34.8735),
  ('BOA VISTA', -8.0560, -34.8915),
  ('SANTO AMARO', -8.0450, -34.8780),
  ('GRAÇAS', -8.0475, -34.9050),
  ('CASA FORTE', -8.0345, -34.9135),
  ('CASA AMARELA', -8.0215, -34.9180),
  ('ENCRUZILHADA', -8.0330, -34.8930),
  ('PINA', -8.0880, -34.8810),
  ('BOA VIAGEM', -8.1230, -34.9060),
  ('IMBIRIBEIRA', -8.1080, -34.9200),
  ('AFOGADOS', -8.0780, -34.9120),
  ('VÁRZEA', -8.0420, -34.9520),
  ('MADALENA', -8.0560, -34.9150),
  ('PAULISTA', -7.9400, -34.8700),
  ('PIEDADE', -8.1750, -34.9250),
  ('JABOATÃO', -8.2250, -34.9600),
  ('CANDEIAS', -8.2050, -34.9330),
];

Path _smooth(List<Offset> pts, {bool closed = false}) {
  final path = Path();
  if (pts.isEmpty) return path;
  final n = pts.length;
  Offset at(int i) => closed ? pts[(i + n) % n] : pts[i.clamp(0, n - 1)];
  path.moveTo(pts[0].dx, pts[0].dy);
  final segs = closed ? n : n - 1;
  for (var i = 0; i < segs; i++) {
    final p0 = at(i - 1), p1 = at(i), p2 = at(i + 1), p3 = at(i + 2);
    final c1 = p1 + (p2 - p0) / 6;
    final c2 = p2 - (p3 - p1) / 6;
    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
  }
  if (closed) path.close();
  return path;
}

List<Offset> _pts(List<List<double>> ll) =>
    [for (final p in ll) RecifeProjection.ll(p[0], p[1])];

/// Base do mapa — estática (pinta uma vez; `shouldRepaint` só muda com tema).
class RecifeMapPainter extends CustomPainter {
  RecifeMapPainter(this.p);

  final TravelPalette p;

  @override
  void paint(Canvas canvas, Size size) {
    const h = RecifeProjection.height;
    final full = Offset.zero & RecifeProjection.size;

    // 1. Mar chapado (monocromático, sem textura).
    canvas.drawRect(full, Paint()..color = p.ocean);

    // 2. Terra.
    final coast = _pts(_coast);
    final land = _smooth(coast)
      ..lineTo(0, h)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(
      land,
      Paint()
        ..color = p.landEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );
    canvas.drawPath(land, Paint()..color = p.land);

    // 3. Textura de quadras (só sobre a terra).
    canvas
      ..save()
      ..clipPath(land);
    _streetGrid(canvas);
    canvas.restore();

    // 4. Verde: matas, mangue, parques.
    final green = Paint()..color = p.park;
    for (final poly in [_doisIrmaos, _varzea, _manguezais]) {
      canvas.drawPath(_smooth(_pts(poly), closed: true), green);
    }
    for (final c in _parks) {
      canvas.drawCircle(RecifeProjection.ll(c[0], c[1]), c[2], green);
    }

    // 5. Água interior: bacia do Pina e rios.
    final water = Paint()..color = p.river;
    canvas.drawPath(_smooth(_pts(_baciaPina), closed: true), water);
    final riverStroke = Paint()
      ..color = p.river
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas
      ..drawPath(_smooth(_pts(_capibaribe)), riverStroke..strokeWidth = 16)
      ..drawPath(_smooth(_pts(_beberibe)), riverStroke..strokeWidth = 11)
      ..drawPath(_smooth(_pts(_jordao)), riverStroke..strokeWidth = 8);

    // 6. Avenidas (por cima dos rios = pontes).
    final roadCasing = Paint()
      ..color = p.landEdge
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 9;
    final road = Paint()
      ..color = p.roadMajor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6;
    final roads = [
      for (final r in _majorRoads) _smooth(_pts(r)),
      _offsetCoast(-0.0012, from: -8.084), // Av. Boa Viagem
      _offsetCoast(-0.0048, from: -8.090), // Domingos Ferreira
    ];
    for (final r in roads) {
      canvas.drawPath(r, roadCasing);
    }
    for (final r in roads) {
      canvas.drawPath(r, road);
    }

    // 7. Arrecifes — o que dá nome à cidade.
    _reef(canvas);

    // 8. Rótulos de bairro.
    for (final (name, lat, lng) in _labels) {
      _label(canvas, name, RecifeProjection.ll(lat, lng), 13, p.mapLabel);
    }
    _label(
      canvas,
      'OCEANO ATLÂNTICO',
      RecifeProjection.ll(-8.098, -34.852),
      15,
      p.mapLabel,
      angle: -1.2,
      spacing: 4,
    );
    _label(
      canvas,
      'Capibaribe',
      RecifeProjection.ll(-8.0418, -34.9335),
      12,
      p.mapLabel,
      angle: -0.75,
      italic: true,
    );
  }

  Path _offsetCoast(double dLng, {required double from}) {
    final pts = [
      for (final c in _coast)
        if (c[0] <= from) RecifeProjection.ll(c[0], c[1] + dLng),
    ];
    return _smooth(pts);
  }

  void _streetGrid(Canvas canvas) {
    final paint = Paint()
      ..color = p.road.withValues(alpha: p.isDark ? 0.5 : 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    // Malhas com ângulos diferentes por região dão textura de cidade.
    // Um path por direção em vez de ~860 drawLine (no navegador a pintura
    // do mapa é refeita a cada quadro). Mesmo desenho: dentro de um path as
    // paralelas não se tocam, e o cruzamento das duas direções continua
    // somando alfa como antes.
    void grid(Rect area, double angle, double gap) {
      final r = area.longestSide;
      final across = Path(), down = Path();
      for (var d = -r; d < r; d += gap) {
        across
          ..moveTo(-r, d)
          ..lineTo(r, d);
        down
          ..moveTo(d, -r)
          ..lineTo(d, r);
      }
      canvas
        ..save()
        ..clipRect(area)
        ..translate(area.center.dx, area.center.dy)
        ..rotate(angle)
        ..drawPath(across, paint)
        ..drawPath(down, paint)
        ..restore();
    }

    const w = RecifeProjection.width, h = RecifeProjection.height;
    grid(const Rect.fromLTWH(0, 0, w, h * 0.36), 0.35, 26);
    grid(const Rect.fromLTWH(0, h * 0.36, w, h * 0.14), -0.2, 22);
    grid(const Rect.fromLTWH(0, h * 0.50, w, h * 0.50), 0.42, 24);
  }

  void _reef(Canvas canvas) {
    final pts = [
      for (final c in _coast)
        if (c[0] <= -8.040) RecifeProjection.ll(c[0], c[1] + 0.0042),
    ];
    final path = _smooth(pts);
    final paint = Paint()
      ..color = p.reef
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    // Traços num path só (um desenho em vez de centenas); eles não se
    // tocam, então o resultado é o mesmo.
    final dashes = Path();
    for (final m in path.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        dashes.addPath(m.extractPath(d, d + 14), Offset.zero);
        d += 22;
      }
    }
    canvas.drawPath(dashes, paint);
  }

  void _label(
    Canvas canvas,
    String text,
    Offset at,
    double size,
    Color color, {
    double angle = 0,
    double spacing = 1.6,
    bool italic = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: size,
          fontWeight: FontWeight.w500,
          fontVariations: const [FontVariation('wght', 500)],
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          letterSpacing: spacing,
          color: color,
          shadows: [
            Shadow(color: p.land.withValues(alpha: 0.9), blurRadius: 4),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas
      ..save()
      ..translate(at.dx, at.dy)
      ..rotate(angle);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(RecifeMapPainter old) => old.p != p;
}

/// Rota do dia: curvas suaves entre paradas; tracejado = a pé.
class RoutePainter extends CustomPainter {
  RoutePainter({
    required this.points,
    required this.walking,
    required this.progress,
    required this.zoom,
    required this.color,
    required this.glow,
  });

  /// Pontos em coordenadas do canvas (hotel → paradas).
  final List<Offset> points;

  /// `walking[i]` = trecho i → i+1 é a pé.
  final List<bool> walking;
  final double progress;
  final double zoom;
  final Color color;
  final Color glow;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final segs = <(Path, bool)>[];
    for (var i = 0; i < points.length - 1; i++) {
      final a = points[i], b = points[i + 1];
      final mid = Offset.lerp(a, b, 0.5)!;
      final normal = Offset(-(b - a).dy, (b - a).dx);
      final bend = normal /
          (normal.distance == 0 ? 1 : normal.distance) *
          math.min(60, (b - a).distance * 0.18);
      final c = mid + bend;
      segs.add((
        Path()
          ..moveTo(a.dx, a.dy)
          ..quadraticBezierTo(c.dx, c.dy, b.dx, b.dy),
        walking[i],
      ));
    }
    final total = segs.fold<double>(
      0,
      (s, e) => s + e.$1.computeMetrics().fold(0, (a, m) => a + m.length),
    );
    var budget = total * progress.clamp(0, 1);
    final sw = 5 / zoom;
    final glowPaint = Paint()
      ..color = glow.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw * 2.6
      ..strokeCap = StrokeCap.round;
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round;

    for (final (path, walk) in segs) {
      for (final m in path.computeMetrics()) {
        if (budget <= 0) return;
        final len = math.min(budget, m.length);
        budget -= len;
        if (walk) {
          final dash = 10 / zoom, gap = 8 / zoom;
          var d = 0.0;
          while (d < len) {
            final seg = m.extractPath(d, math.min(d + dash, len));
            canvas
              ..drawPath(seg, glowPaint)
              ..drawPath(seg, line);
            d += dash + gap;
          }
        } else {
          final seg = m.extractPath(0, len);
          canvas
            ..drawPath(seg, glowPaint)
            ..drawPath(seg, line);
        }
      }
    }
  }

  @override
  bool shouldRepaint(RoutePainter old) =>
      old.progress != progress ||
      old.zoom != zoom ||
      old.points != points ||
      old.color != color;
}
