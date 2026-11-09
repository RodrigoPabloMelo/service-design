import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/core/components/glass/app_glass.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';

/// Player vertical de vídeos curtos (layout de Reels).
///
/// Transição: expande a partir do tile tocado ([origin]) até a tela cheia e
/// encolhe de volta ao fechar (botão, arrastar para baixo ou fim da fila).
///
/// Placeholder de design: o "vídeo" é a foto do lugar com Ken Burns +
/// progresso segmentado. Toque esquerda/direita = anterior/próximo,
/// segurar = pausar. Controles explícitos de pausa e som (HIG).
class ShortVideoPlayer extends StatefulWidget {
  const ShortVideoPlayer({
    required this.role,
    required this.initialIndex,
    required this.onClose,
    required this.onOpenRole,
    required this.distance,
    this.origin,
    super.key,
  });

  final Role role;
  final int initialIndex;
  final VoidCallback onClose;
  final VoidCallback onOpenRole;

  /// "2,1 km" do hotel.
  final String distance;

  /// Retângulo do tile de origem (coordenadas do Stack da página).
  final Rect? origin;

  @override
  State<ShortVideoPlayer> createState() => _ShortVideoPlayerState();
}

class _ShortVideoPlayerState extends State<ShortVideoPlayer>
    with TickerProviderStateMixin {
  late int _i = widget.initialIndex;
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..addStatusListener((s) {
      if (s == AnimationStatus.completed) _next();
    });
  late final AnimationController _open = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
    reverseDuration: const Duration(milliseconds: 340),
  );
  bool _paused = false;
  bool _muted = true;
  bool _expanded = false;
  bool _closing = false;
  double _drag = 0;

  List<ShortVideo> get _videos => widget.role.videos;

  @override
  void initState() {
    super.initState();
    _open.forward().then((_) {
      if (mounted && !_paused) _c.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _open
        ..duration = const Duration(milliseconds: 1)
        ..reverseDuration = const Duration(milliseconds: 1);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    _open.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    if (_closing) return;
    _closing = true;
    _c.stop();
    setState(() => _drag = 0);
    await _open.reverse();
    if (mounted) widget.onClose();
  }

  void _go(int i) {
    if (i < 0) {
      _c.forward(from: 0);
      return;
    }
    if (i >= _videos.length) {
      _close();
      return;
    }
    setState(() {
      _i = i;
      _expanded = false;
    });
    _c.forward(from: 0);
    if (_paused) _c.stop();
  }

  void _next() => _go(_i + 1);

  void _setPaused(bool v) {
    setState(() => _paused = v);
    v ? _c.stop() : _c.forward();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final full = Offset.zero & box.biggest;
        return AnimatedBuilder(
          animation: _open,
          builder: (context, _) {
            final t = const Cubic(0.2, 0, 0, 1).transform(_open.value);
            final from = widget.origin ?? full.deflate(full.shortestSide * 0.2);
            final rect = Rect.lerp(from, full, t)!.translate(0, _drag * t);
            final radius =
                ui.lerpDouble(TravelSpace.rInner, _drag > 0 ? 28 : 0, t)!;
            final chrome = ((t - 0.6) / 0.4).clamp(0.0, 1.0) *
                (1 - (_drag / 400).clamp(0.0, 0.6));
            return Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: ColoredBox(
                      color: Colors.black.withValues(
                          alpha: 0.9 * t * (1 - (_drag / 500).clamp(0.0, 0.7))),
                    ),
                  ),
                ),
                Positioned.fromRect(
                  rect: rect,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius),
                    // O conteúdo é diagramado em tela cheia e escalado no
                    // retângulo animado — sem "pular" de layout.
                    child: FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox.fromSize(
                        size: full.size,
                        child: _content(context, chrome),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _content(BuildContext context, double chrome) {
    final v = _videos[_i];
    final pad = MediaQuery.paddingOf(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return GestureDetector(
      onVerticalDragUpdate: (d) =>
          setState(() => _drag = (_drag + d.delta.dy).clamp(0, 600)),
      onVerticalDragEnd: (d) {
        if (_drag > 120 || d.velocity.pixelsPerSecond.dy > 800) {
          _close();
        } else {
          setState(() => _drag = 0);
        }
      },
      onLongPressStart: (_) => _setPaused(true),
      onLongPressEnd: (_) => _setPaused(false),
      onTapUp: (d) {
        final w = MediaQuery.sizeOf(context).width;
        d.localPosition.dx < w * 0.33 ? _go(_i - 1) : _go(_i + 1);
      },
      child: ColoredBox(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // "Vídeo" (Ken Burns).
            AnimatedBuilder(
              animation: _c,
              builder: (context, child) {
                final k =
                    reduceMotion ? 0.0 : Curves.easeInOut.transform(_c.value);
                return Transform.scale(
                  scale: 1.08 + 0.12 * k,
                  alignment: Alignment(-0.4 + 0.8 * k, _i.isEven ? -0.2 : 0.2),
                  child: child,
                );
              },
              child: Image.asset(v.poster, fit: BoxFit.cover),
            ),
            IgnorePointer(
              child: Opacity(
                opacity: chrome,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x80000000),
                        Color(0x00000000),
                        Color(0x00000000),
                        Color(0xCC000000)
                      ],
                      stops: [0, 0.2, 0.55, 1],
                    ),
                  ),
                ),
              ),
            ),
            if (_paused)
              const Center(
                  child: FaIcon(TravelIcons.circlePause,
                      size: 64, color: Colors.white70)),

            // Topo: só progresso + controles.
            Positioned(
              top: pad.top + 8,
              left: TravelSpace.gutter,
              right: TravelSpace.gutter,
              child: Opacity(
                opacity: chrome,
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _c,
                      builder: (context, _) => Row(
                        children: [
                          for (var k = 0; k < _videos.length; k++) ...[
                            if (k > 0) const SizedBox(width: 4),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  minHeight: 3,
                                  value: k < _i ? 1 : (k == _i ? _c.value : 0),
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.3),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: TravelSpace.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppFrostButton(
                          icon: FaIcon(
                              _paused ? TravelIcons.play : TravelIcons.pause),
                          semanticLabel: _paused ? 'Continuar' : 'Pausar',
                          onPressed: () => _setPaused(!_paused),
                        ),
                        const SizedBox(width: TravelSpace.sm),
                        AppFrostButton(
                          icon: FaIcon(
                              _muted ? TravelIcons.muted : TravelIcons.sound),
                          semanticLabel: _muted ? 'Ativar som' : 'Silenciar',
                          onPressed: () => setState(() => _muted = !_muted),
                        ),
                        const SizedBox(width: TravelSpace.sm),
                        AppFrostButton(
                          icon: const FaIcon(TravelIcons.close),
                          semanticLabel: 'Fechar vídeo',
                          onPressed: _close,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Rodapé (Reels): autor + origem + legenda à esquerda, ações à direita.
            Positioned(
              left: TravelSpace.lg,
              right: TravelSpace.gutter,
              bottom: pad.bottom + 20,
              child: Opacity(
                opacity: chrome,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 20,
                                child: FaIcon(videoSourceIcon(v.source),
                                    size: 15, color: Colors.white),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  v.handle,
                                  overflow: TextOverflow.ellipsis,
                                  style: TravelType.subheadStrong
                                      .copyWith(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: TravelSpace.sm),
                              Text(
                                videoSourceLabel(v.source),
                                style: TravelType.footnote
                                    .copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                          const SizedBox(height: TravelSpace.sm),
                          GestureDetector(
                            onTap: () => setState(() => _expanded = !_expanded),
                            child: Text(
                              v.caption,
                              maxLines: _expanded ? 6 : 2,
                              overflow: TextOverflow.ellipsis,
                              style: TravelType.callout
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: TravelSpace.md),
                          AppFrostButton(
                            icon: FaIcon(categoryIcon(widget.role.category)),
                            label:
                                '${widget.role.shortName} a ${widget.distance}',
                            semanticLabel: 'Ver rolê ${widget.role.shortName}',
                            onPressed: widget.onOpenRole,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: TravelSpace.md),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppFrostButton(
                          icon: const FaIcon(TravelIcons.bookmark),
                          semanticLabel: 'Salvar rolê',
                          onPressed: () {},
                        ),
                        const SizedBox(height: TravelSpace.sm),
                        AppFrostButton(
                          icon: const FaIcon(TravelIcons.share),
                          semanticLabel: 'Compartilhar',
                          onPressed: () {},
                        ),
                        const SizedBox(height: TravelSpace.sm),
                        AppFrostButton(
                          icon: FaIcon(videoSourceIcon(v.source)),
                          semanticLabel:
                              'Abrir no ${videoSourceLabel(v.source)}',
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
