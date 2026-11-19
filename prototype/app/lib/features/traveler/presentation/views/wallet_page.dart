import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/place_detail.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';
import 'package:studio_app/features/traveler/data/traveler_mock.dart';
import 'package:studio_app/features/traveler/domain/traveler_entities.dart';
import 'package:studio_app/features/traveler/presentation/view_models/traveler_cubit.dart';
import 'package:studio_app/features/traveler/presentation/widgets/coupon_card.dart';
import 'package:studio_app/features/traveler/presentation/widgets/coupon_sheet.dart';

/// Pontos e recompensas (ref. recompensas do Google Pay; hipótese,
/// Q-27/Q-28): saldo grande no topo, cupons em grade (bloqueado cinza,
/// trocado com selo) e histórico. Tocar num cupom abre o sheet dele.
class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // Aberta direto pela rota (/carteira): começa no momento "já em Recife".
    final traveler = travelerCubit();
    if (!traveler.hasAccount) traveler.ensureMoment();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Theme(
      data: travelTheme(context),
      child: Scaffold(
        backgroundColor: p.s0,
        body: Stack(
          children: [
            BlocBuilder<TravelerCubit, TravelerState>(
              bloc: travelerCubit(),
              builder: (context, s) => ListView(
                controller: _scroll,
                padding: EdgeInsets.fromLTRB(TravelSpace.gutter,
                    top + kDetailHeaderSpace, TravelSpace.gutter, 48 + bottom),
                children: [
                  _Balance(points: s.points),
                  const SizedBox(height: TravelSpace.xxl),
                  const SectionHeader('Trocar por'),
                  LayoutBuilder(builder: (context, box) {
                    const gap = TravelSpace.md;
                    final w = (box.maxWidth - gap) / 2;
                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        for (final c in TravelerMock.coupons)
                          SizedBox.square(
                            dimension: w,
                            child: _CouponTile(
                              coupon: c,
                              status: couponStatus(c, s.points, s.redeemed),
                              points: s.points,
                            ),
                          ),
                      ],
                    );
                  }),
                  if (s.history.isNotEmpty) ...[
                    const SizedBox(height: TravelSpace.xxl),
                    const SectionHeader('Histórico'),
                    SolidBlock(
                      child: Column(
                        children: [
                          for (final (i, e) in s.history.indexed) ...[
                            if (i > 0) const SizedBox(height: TravelSpace.md),
                            _HistoryRow(entry: e),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Topo fixo: desfoque progressivo + voltar (regras 10 e 11).
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ProgressiveBlurTop(height: top + 64),
            ),
            Positioned(
              top: top + 8,
              left: TravelSpace.gutter,
              right: TravelSpace.gutter,
              child: DetailHeader(
                scroll: _scroll,
                title: 'Pontos',
                backLabel: 'Voltar',
                onBack: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Saldo grande (ref. "Total rewards"): número em display, rótulo embaixo.
class _Balance extends StatelessWidget {
  const _Balance({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TravelSpace.cardPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(end: points.toDouble()),
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => Text(
              '${v.round()}',
              style: TravelType.display.copyWith(
                color: p.ink,
                fontFeatures: TravelType.tabular,
              ),
            ),
          ),
          Text('pontos', style: TravelType.title3.copyWith(color: p.ink)),
          const SizedBox(height: TravelSpace.sm),
          Text(
            'Você ganha ${TravelerMock.pointsPerRating} por avaliação, boa '
            'ou ruim.',
            style: TravelType.footnote.copyWith(color: p.inkMuted),
          ),
        ],
      ),
    );
  }
}

class _CouponTile extends StatelessWidget {
  const _CouponTile({
    required this.coupon,
    required this.status,
    required this.points,
  });

  final Coupon coupon;
  final CouponStatus status;
  final int points;

  @override
  Widget build(BuildContext context) {
    void onTap() => showCouponSheet(context, coupon);
    final state = switch (status) {
      CouponStatus.locked => 'faltam ${coupon.cost - points} pontos',
      CouponStatus.redeemed => 'trocado',
      CouponStatus.available => '${coupon.cost} pontos',
    };
    return Semantics(
      button: true,
      label: '${coupon.fullTitle}, $state',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: CouponCard(coupon: coupon, status: status, points: points),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry});

  final PointsEntry entry;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.label,
                  style: TravelType.subhead.copyWith(color: p.ink)),
              Text(entry.date,
                  style: TravelType.footnote.copyWith(color: p.inkMuted)),
            ],
          ),
        ),
        Text(
          entry.points > 0 ? '+${entry.points}' : '${entry.points}',
          style: TravelType.subheadStrong
              .copyWith(color: p.ink, fontFeatures: TravelType.tabular),
        ),
      ],
    );
  }
}
