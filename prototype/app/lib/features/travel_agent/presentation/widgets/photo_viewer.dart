import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/core/components/glass/app_glass.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';

/// Abre as fotos em tela cheia: fade + escala sutil, deslizar entre fotos,
/// pinça para zoom, arrastar para baixo para fechar. Créditos (licença) aqui.
Future<void> showPhotoViewer(
  BuildContext context, {
  required List<PhotoCredit> photos,
  int initial = 0,
}) {
  final reduce = MediaQuery.disableAnimationsOf(context);
  return Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.transparent,
      transitionDuration: Duration(milliseconds: reduce ? 1 : 320),
      reverseTransitionDuration: Duration(milliseconds: reduce ? 1 : 240),
      // Rota sem Material/Scaffold: sem DefaultTextStyle o Flutter pinta o
      // texto com o sublinhado amarelo de depuração (crédito da foto).
      pageBuilder: (_, __, ___) => DefaultTextStyle(
        style: TravelType.footnote.copyWith(color: Colors.white),
        child: _PhotoViewer(photos: photos, initial: initial),
      ),
      transitionsBuilder: (_, a, __, child) {
        final c = CurvedAnimation(parent: a, curve: const Cubic(0.2, 0, 0, 1));
        return FadeTransition(
          opacity: c,
          child: ScaleTransition(
            scale: Tween(begin: 0.96, end: 1.0).animate(c),
            child: child,
          ),
        );
      },
    ),
  );
}

class _PhotoViewer extends StatefulWidget {
  const _PhotoViewer({required this.photos, required this.initial});

  final List<PhotoCredit> photos;
  final int initial;

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  late final _pc = PageController(initialPage: widget.initial);
  late int _i = widget.initial;
  double _drag = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context).maybePop();

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final ph = widget.photos[_i];
    final fade = (1 - _drag.abs() / 320).clamp(0.3, 1.0);
    return GestureDetector(
      onVerticalDragUpdate: (d) => setState(() => _drag += d.delta.dy),
      onVerticalDragEnd: (d) {
        if (_drag.abs() > 110 || d.velocity.pixelsPerSecond.dy.abs() > 900) {
          _close();
        } else {
          setState(() => _drag = 0);
        }
      },
      child: ColoredBox(
        color: Colors.black.withValues(alpha: fade),
        child: Stack(
          children: [
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(0, _drag),
                child: PageView.builder(
                  controller: _pc,
                  itemCount: widget.photos.length,
                  onPageChanged: (i) => setState(() => _i = i),
                  itemBuilder: (context, i) => InteractiveViewer(
                    maxScale: 4,
                    child: Center(
                      child: Image.asset(widget.photos[i].asset,
                          fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: pad.top + 8,
              right: TravelSpace.gutter,
              child: AppFrostButton(
                icon: const FaIcon(TravelIcons.close),
                semanticLabel: 'Fechar fotos',
                onPressed: _close,
              ),
            ),
            Positioned(
              left: TravelSpace.content,
              right: TravelSpace.content,
              bottom: pad.bottom + 20,
              child: Opacity(
                opacity: fade,
                child: Column(
                  children: [
                    _Dots(count: widget.photos.length, index: _i, light: true),
                    const SizedBox(height: TravelSpace.md),
                    Text(
                      '${ph.author}, ${ph.license}',
                      textAlign: TextAlign.center,
                      style: TravelType.caption.copyWith(
                        color: Colors.white70,
                        fontFeatures: TravelType.tabular,
                      ),
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

/// Bolinhas do carrossel (ativa vira pílula).
class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index, this.light = false});

  final int count;
  final int index;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return PhotoDots(count: count, index: index, light: light);
  }
}

/// Indicador de páginas reutilizável (hero do card e visualizador).
class PhotoDots extends StatelessWidget {
  const PhotoDots(
      {required this.count, required this.index, this.light = true, super.key});

  final int count;
  final int index;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final on = light ? Colors.white : TravelPalette.of(context).ink;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var k = 0; k < count; k++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: const Cubic(0.2, 0, 0, 1),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: k == index ? 16 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: k == index ? on : on.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );
  }
}
