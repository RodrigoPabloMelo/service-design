import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/features/travel_agent/data/travel_agent_mock.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/connector_carousel.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/mare_mark.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';

/// Cor do uso: neutro → amarelo (≥75%) → vermelho (≥90%).
Color usageColor(TravelPalette p, double ratio) {
  if (ratio >= 0.9) return p.danger;
  if (ratio >= 0.75) return p.sol;
  return p.inkMuted;
}

/// Anel de uso ao lado do enviar (ref. app do Claude). Toque abre o limite.
class UsageRing extends StatelessWidget {
  const UsageRing(
      {required this.used,
      required this.limit,
      required this.onTap,
      super.key});

  final int used;
  final int limit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final ratio = (used / limit).clamp(0.0, 1.0);
    return Semantics(
      button: true,
      label: '${limit - used} de $limit mensagens grátis restantes na semana',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: ratio),
              duration: const Duration(milliseconds: 300),
              curve: const Cubic(0.2, 0, 0, 1),
              builder: (context, r, _) => CustomPaint(
                size: const Size.square(20),
                painter: _RingPainter(
                  ratio: r,
                  track: p.s2,
                  color: usageColor(p, r),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.ratio, required this.track, required this.color});

  final double ratio;
  final Color track;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 3.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    canvas
      ..drawArc(
        rect,
        0,
        math.pi * 2,
        false,
        Paint()
          ..color = track
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke,
      )
      ..drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * ratio,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round,
      );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.ratio != ratio || old.color != color || old.track != track;
}

/// Abre o sheet de limite de mensagens.
Future<void> showUsageSheet(BuildContext context, {required int used}) {
  final p = TravelPalette.of(context);
  return showModalBottomSheet<void>(
    context: context,
    sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
        ? AnimationStyle.noAnimation
        : const AnimationStyle(
            duration: Duration(milliseconds: 420),
            reverseDuration: Duration(milliseconds: 420),
          ),
    useRootNavigator: false,
    clipBehavior: Clip.antiAlias,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: p.s0,
    elevation: 0,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    shape: const RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(TravelSpace.rSheet)),
    ),
    builder: (_) => Theme(
      data: Theme.of(context),
      child: _UsageSheet(used: used),
    ),
  );
}

/// Sheet estilo iOS (ref. Mobbin: "Usage and limits" do ChatGPT,
/// Photoroom): barra com título centralizado e X em círculo à direita,
/// rótulo de seção cinza sobre card branco. Sheet 36 ─(margem 12)→ card 24
/// ─(padding 12)→ conteúdo a 24, alinhado com o rótulo da seção.
class _UsageSheet extends StatelessWidget {
  const _UsageSheet({required this.used});

  final int used;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    const limit = TravelMock.messageLimit;
    final ratio = (used / limit).clamp(0.0, 1.0);
    final color = usageColor(p, ratio);
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            TravelSpace.gutter, TravelSpace.sm, TravelSpace.gutter, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SheetBar(
              title: 'Seus limites',
              onClose: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: TravelSpace.lg),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: TravelSpace.cardPad),
              child: Text('Semanal',
                  style: TravelType.section.copyWith(color: p.inkMuted)),
            ),
            const SizedBox(height: TravelSpace.sm),
            Container(
              padding: const EdgeInsets.all(TravelSpace.cardPad),
              decoration: BoxDecoration(
                color: p.s1,
                borderRadius: BorderRadius.circular(TravelSpace.rCard),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$used de $limit mensagens',
                        style: TravelType.subheadStrong.copyWith(
                          color: p.ink,
                          fontFeatures: TravelType.tabular,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(ratio * 100).round()}%',
                        style: TravelType.footnote.copyWith(
                          color: p.inkMuted,
                          fontFeatures: TravelType.tabular,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TravelSpace.md),
                  // Fundo em contraste na largura toda: dá pra comparar.
                  SizedBox(
                    width: double.infinity,
                    height: 8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(TravelSpace.rPill),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ColoredBox(color: p.ink.withValues(alpha: 0.1)),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: ratio,
                              heightFactor: 1,
                              child: ColoredBox(
                                  color: color == p.inkMuted ? p.ink : color),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: TravelSpace.md),
                  Row(
                    children: [
                      FaIcon(TravelIcons.clock, size: 11, color: p.inkMuted),
                      const SizedBox(width: 6),
                      Text(
                        'Reinicia ${TravelMock.limitResetsAt}',
                        style: TravelType.footnote.copyWith(color: p.inkMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (TravelMock.freePlan) ...[
              const SizedBox(height: TravelSpace.xl),
              _PlanCard(onSubscribe: () => Navigator.of(context).maybePop()),
            ],
          ],
        ),
      ),
    );
  }
}

/// Benefícios do Maré+ escritos numa frase (o preço vai no botão).
const _planPitch = 'Mensagens ilimitadas, roteiros maiores e mais';

/// Card do Maré+: sempre escuro, aurora da marca nascendo do topo, uma
/// frase de valor e o preço no próprio botão. Card 24 / padding 12 → botão
/// 12 (concêntrico). Único botão do sheet: secundário, dentro do card.
class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.onSubscribe});

  final VoidCallback onSubscribe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Força a paleta escura só aqui: SecondaryButton, MareMark e textos
    // resolvem `TravelPalette.dark` sem cor solta.
    return Theme(
      data: theme.copyWith(
        brightness: Brightness.dark,
        colorScheme: theme.colorScheme.copyWith(brightness: Brightness.dark),
      ),
      child: Builder(builder: (context) {
        final p = TravelPalette.of(context);
        return ClipRRect(
          borderRadius: BorderRadius.circular(TravelSpace.rCard),
          child: ColoredBox(
            color: p.s1,
            child: Stack(
              children: [
                // Base fixa: o azul da marca sempre presente no topo, a
                // aurora só mexe por cima.
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0, 0.7],
                        colors: [
                          Color.lerp(p.accent, p.ink, 0.18)!
                              .withValues(alpha: 0.8),
                          p.s1,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: RepaintBoundary(
                    child: Opacity(
                      opacity: 1,
                      child: Transform.flip(
                        flipY: true,
                        child: Aurora(colors: [p.accent, p.piscina]),
                      ),
                    ),
                  ),
                ),
                // Véu de baixo: a frase e o botão ficam sobre fundo escuro.
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.45, 0.95],
                        colors: [p.s1.withValues(alpha: 0), p.s1],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(TravelSpace.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            TravelSpace.xs, TravelSpace.sm, TravelSpace.xs, 0),
                        child: Row(
                          children: [
                            const MareMark(size: 20),
                            const SizedBox(width: TravelSpace.sm),
                            Text(TravelMock.upgradeName,
                                style:
                                    TravelType.headline.copyWith(color: p.ink)),
                          ],
                        ),
                      ),
                      const SizedBox(height: TravelSpace.xxl),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: TravelSpace.xs),
                        child: Text(_planPitch,
                            style: TravelType.title3.copyWith(color: p.ink)),
                      ),
                      const SizedBox(height: TravelSpace.xl),
                      SecondaryButton(
                        label: 'Assinar por ${TravelMock.upgradePrice}',
                        onPressed: onSubscribe,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
