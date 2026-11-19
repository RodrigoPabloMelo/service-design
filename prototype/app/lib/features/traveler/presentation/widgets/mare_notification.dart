import 'dart:async';

import 'package:flutter/material.dart';
import 'package:studio_app/features/explore/presentation/widgets/explore_ui.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/mare_mark.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';

/// Notificação push simulada (estilo banner do iOS) por cima da tela.
/// Push é **(hipótese)**: gatilhos e limite diário seguem em Q-29.
///
/// Entra pelo topo depois de [delay]; tocar chama [onTap] e some. Sem
/// sombra: camada sólida `s1` sobre a tela.
class MareNotificationOverlay extends StatefulWidget {
  const MareNotificationOverlay({
    required this.title,
    required this.body,
    required this.onTap,
    required this.child,
    this.delay = const Duration(milliseconds: 900),
    super.key,
  });

  final String title;
  final String body;
  final VoidCallback onTap;
  final Widget child;
  final Duration delay;

  @override
  State<MareNotificationOverlay> createState() =>
      _MareNotificationOverlayState();
}

class _MareNotificationOverlayState extends State<MareNotificationOverlay> {
  bool _visible = false;
  Timer? _show;

  @override
  void initState() {
    super.initState();
    _show = Timer(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _show?.cancel();
    super.dispose();
  }

  void _tap() {
    _show?.cancel();
    setState(() => _visible = false);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Stack(
      children: [
        Positioned.fill(child: widget.child),
        Positioned(
          top: top + TravelSpace.sm,
          left: TravelSpace.gutter,
          right: TravelSpace.gutter,
          child: IgnorePointer(
            ignoring: !_visible,
            child: AnimatedSlide(
              offset: _visible ? Offset.zero : const Offset(0, -1.6),
              duration: exploreMotion(context, 420),
              curve: kExploreEase,
              child: AnimatedOpacity(
                opacity: _visible ? 1 : 0,
                duration: exploreMotion(context, 260),
                // Fora do Scaffold da tela: sem Material, o texto ganha o
                // sublinhado amarelo de debug.
                child: Material(
                  type: MaterialType.transparency,
                  child: MareNotificationBanner(
                    title: widget.title,
                    body: widget.body,
                    onTap: _tap,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MareNotificationBanner extends StatelessWidget {
  const MareNotificationBanner({
    required this.title,
    required this.body,
    required this.onTap,
    super.key,
  });

  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Semantics(
      button: true,
      label: 'Notificação da Maré. $title. $body',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(TravelSpace.md),
          decoration: BoxDecoration(
            color: p.s1,
            borderRadius: BorderRadius.circular(TravelSpace.rCard),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MareMark(size: 36),
              const SizedBox(width: TravelSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TravelType.subheadStrong
                                  .copyWith(color: p.ink)),
                        ),
                        Text('agora',
                            style: TravelType.caption
                                .copyWith(color: p.inkMuted)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(body,
                        style: TravelType.subhead.copyWith(color: p.ink)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
