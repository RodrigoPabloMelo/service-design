import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/features/travel_agent/data/travel_agent_mock.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/recife_map_painter.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';

enum MapMode { explore, itinerary }

/// Mapa próprio de Recife: pan/zoom, pins estilo Google, rota do dia.
///
/// [focusPadding] = áreas cobertas pela UI (barra do topo, sheet); o
/// enquadramento da câmera acontece só na área visível.
class RecifeMap extends StatefulWidget {
  const RecifeMap({
    required this.roles,
    required this.stay,
    required this.mode,
    required this.stops,
    required this.selectedId,
    required this.highlightIds,
    required this.onSelect,
    required this.focusPadding,
    required this.fitKey,
    this.veil = 0,
    this.ghostSpots = const [],
    super.key,
  });

  final List<Role> roles;
  final GeoPoint stay;
  final MapMode mode;
  final List<ItineraryStop> stops;
  final String? selectedId;
  final List<String> highlightIds;
  final ValueChanged<String?> onSelect;
  final EdgeInsets focusPadding;

  /// Muda → reenquadra a câmera (dia trocado, modo trocado, recentrar).
  final Object fitKey;

  /// Véu sólido (figura-fundo) quando o sheet cobre quase tudo.
  final double veil;

  /// Pontos apagados da curadoria (começo do zero, antes de haver pins).
  final List<GeoPoint> ghostSpots;

  @override
  State<RecifeMap> createState() => _RecifeMapState();
}

class _RecifeMapState extends State<RecifeMap> with TickerProviderStateMixin {
  final _tc = TransformationController();
  late final AnimationController _cam = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );
  late final AnimationController _route = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  late final AnimationController _drop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  Animation<Matrix4>? _camAnim;
  Size _viewport = Size.zero;
  bool _didInitialFit = false;

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  @override
  void initState() {
    super.initState();
    _cam.addListener(() {
      if (_camAnim != null) _tc.value = _camAnim!.value;
    });
    _route.value = 1;
    _drop.value = 1;
  }

  @override
  void didUpdateWidget(RecifeMap old) {
    super.didUpdateWidget(old);
    final refit = old.fitKey != widget.fitKey || old.mode != widget.mode;
    // Começo do zero: os rolês sugeridos chegam de uma vez e caem no mapa.
    final arrived = widget.roles.length > old.roles.length;
    if (refit || arrived) {
      _fit(animate: true);
      if (widget.mode == MapMode.itinerary) _replay(_route);
      if (old.mode != widget.mode || arrived) _replay(_drop);
    } else if (widget.selectedId != null &&
        widget.selectedId != old.selectedId) {
      _focusOn(widget.selectedId!);
    }
  }

  void _replay(AnimationController c) {
    if (_reduceMotion) {
      c.value = 1;
    } else {
      c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _tc.dispose();
    _cam.dispose();
    _route.dispose();
    _drop.dispose();
    super.dispose();
  }

  double get _minScale => math.max(
        _viewport.width / RecifeProjection.width,
        _viewport.height / RecifeProjection.height,
      );

  Rect get _visibleArea {
    final pad = widget.focusPadding;
    return Rect.fromLTRB(
      pad.left + 28,
      pad.top + 28,
      _viewport.width - pad.right - 28,
      // +36: rótulos ficam abaixo dos pins.
      math.max(pad.top + 120, _viewport.height - pad.bottom - 64),
    );
  }

  Matrix4 _matrixFor(Rect bounds, {double? atLeast}) {
    final area = _visibleArea;
    var s = math.min(
      area.width / math.max(bounds.width, 1),
      area.height / math.max(bounds.height, 1),
    );
    s = s.clamp(_minScale, 3.0);
    if (atLeast != null) s = math.max(s, atLeast);
    final tx = area.center.dx - bounds.center.dx * s;
    final ty = area.center.dy - bounds.center.dy * s;
    return _clamp(Matrix4(s, 0, 0, 0, 0, s, 0, 0, 0, 0, 1, 0, tx, ty, 0, 1));
  }

  /// Mantém o canvas cobrindo a viewport (a faixa sob o sheet pode sobrar).
  Matrix4 _clamp(Matrix4 m) {
    final s = m.storage[0];
    final minTx = _viewport.width - RecifeProjection.width * s;
    final minTy = _viewport.height -
        RecifeProjection.height * s -
        widget.focusPadding.bottom * 0.8;
    final tx = m.storage[12].clamp(minTx, 0.0);
    final ty = m.storage[13].clamp(minTy, 0.0);
    return Matrix4(s, 0, 0, 0, 0, s, 0, 0, 0, 0, 1, 0, tx, ty, 0, 1);
  }

  Iterable<GeoPoint> get _fitPoints sync* {
    yield widget.stay;
    if (widget.mode == MapMode.itinerary && widget.stops.isNotEmpty) {
      for (final s in widget.stops) {
        yield _role(s.roleId).location;
      }
    } else if (widget.highlightIds.isNotEmpty) {
      for (final id in widget.highlightIds) {
        yield _role(id).location;
      }
    } else if (widget.roles.isEmpty) {
      // Começo do zero: enquadra a cidade pelos pontos da curadoria.
      yield* widget.ghostSpots;
    } else {
      for (final r in widget.roles) {
        yield r.location;
      }
    }
  }

  Role _role(String id) => widget.roles.firstWhere(
        (r) => r.id == id,
        orElse: () =>
            widget.roles.isEmpty ? TravelMock.roleById(id) : widget.roles.first,
      );

  void _fit({required bool animate}) {
    if (_viewport == Size.zero) return;
    var b = RecifeProjection.boundsOf(_fitPoints);
    // Poucos pontos (ex.: só o hotel): enquadra um bairro, não zoom máximo.
    if (b.width < 500 && b.height < 500) {
      b = Rect.fromCenter(center: b.center, width: 500, height: 500);
    }
    _animateTo(_matrixFor(b), animate);
  }

  void _focusOn(String id) {
    if (_viewport == Size.zero) return;
    final o = RecifeProjection.of(_role(id).location);
    final s = math.max(_tc.value.storage[0], 0.9).clamp(_minScale, 1.6);
    final area = _visibleArea;
    _animateTo(
      _clamp(Matrix4(
        s, 0, 0, 0, 0, s, 0, 0, 0, 0, 1, 0, //
        area.center.dx - o.dx * s, area.center.dy - o.dy * s, 0, 1,
      )),
      true,
    );
  }

  void _animateTo(Matrix4 target, bool animate) {
    if (!animate || _reduceMotion) {
      _tc.value = target;
      return;
    }
    _camAnim = Matrix4Tween(begin: _tc.value, end: target).animate(
      CurvedAnimation(parent: _cam, curve: Curves.easeInOutCubic),
    );
    _cam.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return LayoutBuilder(
      builder: (context, c) {
        final size = c.biggest;
        if (size != _viewport) {
          _viewport = size;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _fit(animate: _didInitialFit);
            _didInitialFit = true;
          });
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: p.land),
            InteractiveViewer(
              transformationController: _tc,
              constrained: false,
              minScale: math.max(_minScale, 0.05),
              maxScale: 4,
              boundaryMargin: const EdgeInsets.only(bottom: 900),
              onInteractionStart: (_) => _cam.stop(),
              child: SizedBox.fromSize(
                size: RecifeProjection.size,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => widget.onSelect(null),
                  child: AnimatedBuilder(
                    // Sem animação infinita: o mapa parado não repinta (nem recaptura o
                    // fundo do vidro) a cada frame.
                    animation: Listenable.merge([_tc, _route, _drop]),
                    builder: (context, _) => _layers(p),
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: widget.veil,
                duration: const Duration(milliseconds: 200),
                child: ColoredBox(color: p.s0.withValues(alpha: 0.35)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _layers(TravelPalette p) {
    final zoom = _tc.value.storage[0].clamp(0.05, 10.0);
    final inv = 1 / zoom;
    final itinerary =
        widget.mode == MapMode.itinerary && widget.stops.isNotEmpty;
    final stopIds = [for (final s in widget.stops) s.roleId];
    final stay = RecifeProjection.of(widget.stay);

    final children = <Widget>[
      const Positioned.fill(child: _BaseMap()),
    ];

    if (itinerary) {
      final pts = [
        stay,
        for (final id in stopIds) RecifeProjection.of(_role(id).location)
      ];
      final walking = [
        for (final s in widget.stops) s.mode == TravelMode.aPe,
      ];
      children.add(
        Positioned.fill(
          child: CustomPaint(
            painter: RoutePainter(
              points: pts,
              walking: walking,
              progress: Curves.easeInOutCubic.transform(_route.value),
              zoom: zoom,
              color: p.accent,
              glow: p.s1,
            ),
          ),
        ),
      );
    }

    // Curadoria apagada: só enquanto não há pins (dá ideia do lugar).
    if (widget.roles.isEmpty) {
      for (final g in widget.ghostSpots) {
        children.add(_anchored(
          RecifeProjection.of(g),
          inv,
          const Size(8, 8),
          Alignment.center,
          DecoratedBox(
            decoration: BoxDecoration(
              color: p.inkMuted.withValues(alpha: 0.55),
              shape: BoxShape.circle,
            ),
          ),
        ));
      }
    }

    // Hotel (com pulso de localização).
    children.add(_anchored(
      stay,
      inv,
      const Size(64, 64),
      Alignment.center,
      _StayMarker(pulse: 0.55, palette: p),
    ));

    // Pins.
    final ordered = [...widget.roles]..sort((a, b) =>
        a.id == widget.selectedId ? 1 : (b.id == widget.selectedId ? -1 : 0));
    var dropIndex = 0;
    for (final role in ordered) {
      final at = RecifeProjection.of(role.location);
      final selected = role.id == widget.selectedId;
      final stopIndex = stopIds.indexOf(role.id);
      final t = _stagger(dropIndex++, ordered.length);

      if (itinerary) {
        if (stopIndex < 0) {
          children.add(_anchored(
            at,
            inv,
            const Size(14, 14),
            Alignment.center,
            _Dot(color: p.inkMuted),
          ));
          continue;
        }
        children.add(_anchored(
          at,
          inv,
          const Size(160, 76),
          const Alignment(0, -0.05),
          _NumberPin(
            number: stopIndex + 1,
            label: role.shortName,
            showLabel: selected || zoom >= 0.9,
            selected: selected,
            appear: t,
            palette: p,
            onTap: () => widget.onSelect(role.id),
          ),
        ));
        continue;
      }

      final dim = widget.highlightIds.isNotEmpty &&
          !widget.highlightIds.contains(role.id);
      children.add(_anchored(
        at,
        inv,
        const Size(160, 84),
        const Alignment(0, 0.05),
        _DropPin(
          role: role,
          selected: selected,
          dim: dim,
          appear: t,
          palette: p,
          onTap: () => widget.onSelect(role.id),
        ),
      ));
    }

    return Stack(clipBehavior: Clip.none, children: children);
  }

  double _stagger(int i, int n) {
    final start = (i / math.max(n, 1)) * 0.5;
    final v = ((_drop.value - start) / 0.5).clamp(0.0, 1.0);
    return Curves.easeOutBack.transform(v);
  }

  /// Posiciona [child] com o ponto [alignAt] do box sobre [at] e contra-escala
  /// pelo zoom — pins mantêm tamanho na tela.
  Widget _anchored(
    Offset at,
    double inv,
    Size box,
    Alignment alignAt,
    Widget child,
  ) {
    final ax = (alignAt.x + 1) / 2 * box.width;
    final ay = (alignAt.y + 1) / 2 * box.height;
    return Positioned(
      left: at.dx - ax,
      top: at.dy - ay,
      width: box.width,
      height: box.height,
      child: Transform.scale(
        scale: inv,
        alignment: alignAt,
        child: child,
      ),
    );
  }
}

class _BaseMap extends StatelessWidget {
  const _BaseMap();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        isComplex: true,
        painter: RecifeMapPainter(TravelPalette.of(context)),
        size: RecifeProjection.size,
      ),
    );
  }
}

/// Pin em gota estilo Google: cor + glifo da categoria. A ponta fica em
/// (0, 0.05) do box — o ponto geográfico.
class _DropPin extends StatelessWidget {
  const _DropPin({
    required this.role,
    required this.selected,
    required this.dim,
    required this.appear,
    required this.palette,
    required this.onTap,
  });

  final Role role;
  final bool selected;
  final bool dim;
  final double appear;
  final TravelPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    // Monocromático: pin em tinta; azul de contraste só no selecionado.
    // A categoria vem do glifo.
    final color = selected ? p.accent : p.inverse;
    final scale = (selected ? 1.18 : (dim ? 0.78 : 1.0)) * appear;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Gota: ponta no centro vertical do box (y = 0.05 → 44px).
        Positioned(
          left: 80 - 22,
          top: 0,
          width: 44,
          height: 46,
          child: Opacity(
            opacity: dim ? 0.45 : 1,
            child: Transform.scale(
              scale: scale.clamp(0.0, 2.0),
              alignment: Alignment.bottomCenter,
              child: Semantics(
                button: true,
                label: '${role.shortName}, ${categoryLabel(role.category)}',
                child: GestureDetector(
                  onTap: onTap,
                  child: CustomPaint(
                    painter: _DropPainter(
                      color: color,
                      ring: p.s1,
                      shadow: p.ink,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Center(
                        child: FaIcon(
                          categoryIcon(role.category),
                          size: 14,
                          color: selected ? p.onAccent : p.onInverse,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (selected)
          Positioned(
            left: 0,
            right: 0,
            top: 50,
            child: Center(child: _PinLabel(role.shortName, p)),
          ),
      ],
    );
  }
}

class _DropPainter extends CustomPainter {
  _DropPainter({required this.color, required this.ring, required this.shadow});

  final Color color;
  final Color ring;
  final Color shadow;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final r = w / 2 - 3;
    final c = Offset(w / 2, r + 3);
    final tip = Offset(w / 2, h - 2);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..cubicTo(
          c.dx - r * 0.55, h - 12, c.dx - r, c.dy + r * 0.75, c.dx - r, c.dy)
      ..arcToPoint(Offset(c.dx + r, c.dy), radius: Radius.circular(r))
      ..cubicTo(
          c.dx + r, c.dy + r * 0.75, c.dx + r * 0.55, h - 12, tip.dx, tip.dy)
      ..close();
    // Flat: anel sólido + preenchimento, sem sombra.
    canvas
      ..drawPath(path, Paint()..color = ring)
      ..save()
      ..translate(c.dx, c.dy)
      ..scale(0.86)
      ..translate(-c.dx, -c.dy)
      ..drawPath(path, Paint()..color = color)
      ..restore();
  }

  @override
  bool shouldRepaint(_DropPainter old) =>
      old.color != color || old.ring != ring;
}

/// Parada numerada do roteiro. O centro do círculo é o ponto geográfico.
class _NumberPin extends StatelessWidget {
  const _NumberPin({
    required this.number,
    required this.label,
    required this.showLabel,
    required this.selected,
    required this.appear,
    required this.palette,
    required this.onTap,
  });

  final int number;
  final String label;
  final bool showLabel;
  final bool selected;
  final double appear;
  final TravelPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final d = selected ? 40.0 : 34.0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 80 - d / 2,
          top: 36 - d / 2,
          width: d,
          height: d,
          child: Transform.scale(
            scale: appear.clamp(0.0, 2.0),
            child: Semantics(
              button: true,
              label: 'Parada $number, $label',
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? p.accent : p.inverse,
                    shape: BoxShape.circle,
                    border: Border.all(color: p.s1, width: 3),
                  ),
                  child: Text(
                    '$number',
                    style: TravelType.title3.copyWith(
                      fontSize: selected ? 20 : 17,
                      height: 1,
                      color: selected ? p.onAccent : p.onInverse,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (showLabel)
          Positioned(
            left: 0,
            right: 0,
            top: 36 + d / 2 + 4,
            child: Center(child: _PinLabel(label, p, strong: selected)),
          ),
      ],
    );
  }
}

class _PinLabel extends StatelessWidget {
  const _PinLabel(this.text, this.p, {this.strong = true});

  final String text;
  final TravelPalette p;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: p.s1.withValues(alpha: strong ? 1 : 0.85),
        borderRadius: BorderRadius.circular(TravelSpace.rPill),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TravelType.caption
            .weight(strong ? FontWeight.w500 : FontWeight.w400)
            .copyWith(color: p.ink),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.55),
        shape: BoxShape.circle,
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
      ),
    );
  }
}

class _StayMarker extends StatelessWidget {
  const _StayMarker({required this.pulse, required this.palette});

  final double pulse;
  final TravelPalette palette;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return Semantics(
      label: 'Seu hotel',
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 24 + 40 * pulse,
            height: 24 + 40 * pulse,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: p.accent.withValues(alpha: 0.3 * (1 - pulse)),
            ),
          ),
          Container(
            alignment: Alignment.center,
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: p.inverse,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: p.s1, width: 2.5),
            ),
            child: FaIcon(TravelIcons.home, size: 13, color: p.onInverse),
          ),
        ],
      ),
    );
  }
}
