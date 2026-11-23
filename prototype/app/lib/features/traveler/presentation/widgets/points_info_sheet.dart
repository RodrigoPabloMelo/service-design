import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/features/travel_agent/data/travel_agent_mock.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/mare_mark.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';
import 'package:studio_app/features/traveler/data/traveler_mock.dart';
import 'package:studio_app/features/traveler/presentation/widgets/coupon_card.dart';
import 'package:studio_app/features/traveler/presentation/widgets/mare_sheet.dart';

/// "Como funcionam os pontos" (o "i" ao lado do saldo): três páginas com
/// uma arte cada — avaliar, juntar, trocar. Artes feitas com os próprios
/// componentes (card de cupom, selo, símbolo), animadas quando a página
/// entra; Reduce Motion mostra o quadro final. Regras **(hipótese)**, Q-27.
Future<void> showPointsInfoSheet(BuildContext context) => showMareSheet<void>(
      context,
      builder: (_) => const PointsInfoSheet(),
    );

class PointsInfoSheet extends StatefulWidget {
  const PointsInfoSheet({super.key});

  @override
  State<PointsInfoSheet> createState() => _PointsInfoSheetState();
}

class _Step {
  const _Step(this.title, this.line);

  final String title;
  final String line;
}

class _PointsInfoSheetState extends State<PointsInfoSheet> {
  final _pages = PageController();
  int _i = 0;

  static final _steps = [
    const _Step(
      'Avalie suas saídas',
      '${TravelerMock.pointsPerRating} pontos por avaliação, boa ou ruim. '
          'Contar mais rende ${TravelerMock.pointsPerDetail}.',
    ),
    const _Step(
      'Junte pontos',
      'O saldo fica aqui e no seu perfil.',
    ),
    const _Step(
      'Troque por cupons',
      'Transfer, rolês em grupo e parceiros. Copie o código ou abra no app.',
    ),
  ];

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _next() {
    if (_i == _steps.length - 1) {
      Navigator.of(context).maybePop();
      return;
    }
    _pages.nextPage(
      duration: MediaQuery.disableAnimationsOf(context)
          ? const Duration(milliseconds: 1)
          : const Duration(milliseconds: 360),
      curve: const Cubic(0.2, 0, 0, 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            TravelSpace.gutter, TravelSpace.sm, TravelSpace.gutter, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetBar(
              title: 'Como funcionam os pontos',
              onClose: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: TravelSpace.sm),
            SizedBox(
              height: 384,
              child: PageView.builder(
                controller: _pages,
                itemCount: _steps.length,
                onPageChanged: (i) => setState(() => _i = i),
                itemBuilder: (context, i) => Column(
                  children: [
                    // Arte num card `s1` (raio 24), como os blocos do app.
                    AspectRatio(
                      aspectRatio: 16 / 10,
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: p.s1,
                          borderRadius:
                              BorderRadius.circular(TravelSpace.rCard),
                        ),
                        child: switch (i) {
                          0 => _RateArt(active: _i == 0),
                          1 => _CollectArt(active: _i == 1),
                          _ => _TradeArt(active: _i == 2),
                        },
                      ),
                    ),
                    const SizedBox(height: TravelSpace.xl),
                    // O texto usa o que sobra (nunca estoura a página).
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: TravelSpace.cardPad),
                        child: Column(
                          children: [
                            Text(
                              _steps[i].title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style:
                                  TravelType.title2.copyWith(color: p.ink),
                            ),
                            const SizedBox(height: TravelSpace.sm),
                            Text(
                              _steps[i].line,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TravelType.subhead
                                  .copyWith(color: p.inkMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Pontos da página (pílula cresce na ativa).
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var k = 0; k < _steps.length; k++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: const Cubic(0.2, 0, 0, 1),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: k == _i ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: k == _i ? p.ink : p.ink.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: TravelSpace.xl),
            SecondaryButton(
              label: _i == _steps.length - 1 ? 'Entendi' : 'Próximo',
              onPressed: _next,
            ),
          ],
        ),
      ),
    );
  }
}

/// Base das artes: um controlador que toca uma vez quando a página fica
/// ativa (e vai direto ao fim com Reduce Motion).
abstract class _ArtState<T extends _Art> extends State<T>
    with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.active && c.value == 0) _play();
  }

  @override
  void didUpdateWidget(covariant T old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) _play();
  }

  void _play() {
    if (MediaQuery.disableAnimationsOf(context)) {
      c.value = 1;
    } else {
      c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  /// Fração [a]..[b] do tempo, já com curva.
  double seg(double a, double b, [Curve curve = const Cubic(0.2, 0, 0, 1)]) =>
      curve.transform(((c.value - a) / (b - a)).clamp(0.0, 1.0));
}

abstract class _Art extends StatefulWidget {
  const _Art({required this.active});

  final bool active;
}

/// 1 · Avaliar: o card "Como foi?" com o rolê; as 5 estrelas se acendem
/// uma a uma e sobe um "+20".
class _RateArt extends _Art {
  const _RateArt({required super.active});

  @override
  State<_RateArt> createState() => _RateArtState();
}

class _RateArtState extends _ArtState<_RateArt> {
  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final role = TravelMock.roleById(TravelMock.swapToId);
    return AnimatedBuilder(
      animation: c,
      builder: (context, _) {
        final card = seg(0, 0.35);
        final pick = seg(0.3, 0.55);
        final rise = seg(0.5, 0.95, Curves.easeOutBack);
        return Center(
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: card,
                child: Transform.translate(
                  offset: Offset(0, 16 * (1 - card)),
                  child: Container(
                    width: 264,
                    padding: const EdgeInsets.all(TravelSpace.md),
                    decoration: BoxDecoration(
                      color: p.s0,
                      borderRadius: BorderRadius.circular(TravelSpace.rCard),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(TravelSpace.rInner),
                              child: Image.asset(
                                role.photos.first.asset,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: TravelSpace.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Como foi?',
                                      style: TravelType.footnote
                                          .copyWith(color: p.inkMuted)),
                                  Text(role.shortName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TravelType.subheadStrong
                                          .copyWith(color: p.ink)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: TravelSpace.md),
                        Row(
                          // Esticadas: a quinta fica sob o "+20".
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (var i = 0; i < 5; i++) ...[
                              FaIcon(
                                pick * 5 > i
                                    ? TravelIcons.star
                                    : TravelIcons.starOutline,
                                size: 24,
                                color: pick * 5 > i
                                    ? p.star
                                    : p.ink.withValues(alpha: 0.24),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // "+20" sobe da última estrela.
              Positioned(
                top: -6 - 34 * rise,
                right: -18,
                child: Opacity(
                  opacity: rise.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 0.6 + 0.4 * rise,
                    child:
                        const _PlusPill(points: TravelerMock.pointsPerRating),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 2 · Juntar: três "+20" caem num disco da Maré e o saldo conta até 120.
class _CollectArt extends _Art {
  const _CollectArt({required super.active});

  @override
  State<_CollectArt> createState() => _CollectArtState();
}

class _CollectArtState extends _ArtState<_CollectArt> {
  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return AnimatedBuilder(
      animation: c,
      builder: (context, _) {
        final count = seg(0.2, 0.9, Curves.easeOutCubic);
        return Stack(
          alignment: Alignment.center,
          children: [
            // Ondas da marca abrindo atrás do saldo.
            for (final d in const [0.0, 0.22])
              Builder(builder: (context) {
                final r = seg(d, d + 0.7);
                return Container(
                  width: 96 + 120 * r,
                  height: 96 + 120 * r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: p.piscina.withValues(alpha: 0.5 * (1 - r)),
                      width: 1.5,
                    ),
                  ),
                );
              }),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MareMark(size: 36, mood: MareMood.success),
                const SizedBox(height: TravelSpace.sm),
                Text(
                  '${(120 * count).round()}',
                  style: TravelType.title1
                      .copyWith(color: p.ink, fontFeatures: TravelType.tabular),
                ),
                Text('pontos',
                    style: TravelType.footnote.copyWith(color: p.inkMuted)),
              ],
            ),
            // Três "+20" chegam de fora e ficam em volta do saldo.
            for (final (k, a)
                in const [(0, -0.75), (1, 0.75), (2, 0.0)].indexed)
              Builder(builder: (context) {
                final t =
                    seg(0.1 + k * 0.15, 0.5 + k * 0.15, Curves.easeOutBack);
                final angle = a.$2 * math.pi / 2 - math.pi / 2;
                final dist = 80 * (1 - t) + 104;
                return Transform.translate(
                  offset: Offset(
                      math.cos(angle) * dist, math.sin(angle) * dist * 0.78),
                  child: Opacity(
                    opacity: (t / 0.3).clamp(0.0, 1.0),
                    child: Transform.rotate(
                      angle: a.$2 * 0.12,
                      child:
                          const _PlusPill(points: TravelerMock.pointsPerRating),
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}

/// 3 · Trocar: três cupons (serviço, transporte, rolê) se abrem em leque.
class _TradeArt extends _Art {
  const _TradeArt({required super.active});

  @override
  State<_TradeArt> createState() => _TradeArtState();
}

class _TradeArtState extends _ArtState<_TradeArt> {
  @override
  Widget build(BuildContext context) {
    final coupons = [
      TravelerMock.coupons.firstWhere((c) => c.id == 'casa-astral-drink'),
      TravelerMock.coupons.firstWhere((c) => c.id == 'uber-15'),
      TravelerMock.coupons.firstWhere((c) => c.id == 'transfer-5'),
    ];
    return AnimatedBuilder(
      animation: c,
      builder: (context, _) {
        final fan = seg(0.05, 0.75, Curves.elasticOut);
        return Center(
          child: SizedBox(
            width: 340,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Laterais primeiro; o do meio por cima.
                for (final k in const [0, 2, 1])
                  Transform.translate(
                    offset:
                        Offset((k - 1) * 100.0 * fan, (k == 1 ? -10 : 8) * fan),
                    child: Transform.rotate(
                      angle: (k - 1) * 0.13 * fan,
                      child: SizedBox.square(
                        dimension: 150,
                        child: CouponCard(
                          coupon: coupons[k],
                          status: CouponStatus.available,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Selo "+20" com estrela: pílula `accent`, texto branco.
class _PlusPill extends StatelessWidget {
  const _PlusPill({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: p.accent,
        borderRadius: BorderRadius.circular(TravelSpace.rPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FaIcon(TravelIcons.star, size: 11, color: Colors.white),
          const SizedBox(width: 6),
          Text('+$points',
              style: TravelType.subheadStrong.copyWith(
                  color: Colors.white,
                  height: 1.2,
                  fontFeatures: TravelType.tabular)),
        ],
      ),
    );
  }
}
