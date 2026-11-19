import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/place_detail.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';
import 'package:studio_app/features/traveler/data/traveler_mock.dart';
import 'package:studio_app/features/traveler/domain/traveler_entities.dart';
import 'package:studio_app/features/traveler/presentation/view_models/traveler_cubit.dart';
import 'package:studio_app/features/traveler/presentation/widgets/mare_sheet.dart';

/// Carteira de pontos (hipótese, Q-27/Q-28): saldo, cupons do próprio
/// serviço e histórico. Valor dos pontos e regras ainda em aberto.
class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final top = MediaQuery.paddingOf(context).top;
    return Theme(
      data: travelTheme(context),
      child: Scaffold(
        backgroundColor: p.s0,
        body: Stack(
          children: [
            ListView(
              controller: _scroll,
              padding: EdgeInsets.fromLTRB(TravelSpace.gutter,
                  top + kDetailHeaderSpace, TravelSpace.gutter, 48),
              children: const [WalletContent(showLabel: false)],
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
                title: 'Carteira',
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

/// Conteúdo da carteira (também usado na aba Perfil).
class WalletContent extends StatelessWidget {
  const WalletContent({this.showLabel = true, super.key});

  /// Rótulo "Carteira" acima do saldo (a página já tem no cabeçalho).
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final cubit = travelerCubit();
    return BlocBuilder<TravelerCubit, TravelerState>(
      bloc: cubit,
      builder: (context, s) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: TravelSpace.cardPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showLabel) ...[
                  Text('Carteira',
                      style: TravelType.section.copyWith(color: p.inkMuted)),
                  const SizedBox(height: TravelSpace.xs),
                ],
                Text(
                  '${s.points} pontos',
                  style: TravelType.title1.copyWith(
                      color: p.ink, fontFeatures: TravelType.tabular),
                ),
                const SizedBox(height: TravelSpace.xs),
                Text(
                  'Você ganha ${TravelerMock.pointsPerRating} pontos por '
                  'avaliação, boa ou ruim.',
                  style: TravelType.footnote.copyWith(color: p.inkMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: TravelSpace.xl),
          const SectionHeader('Trocar por'),
          for (var i = 0; i < TravelerMock.coupons.length; i++) ...[
            if (i > 0) const SizedBox(height: TravelSpace.segmentGap),
            _CouponRow(
              coupon: TravelerMock.coupons[i],
              points: s.points,
              redeemed: s.redeemed.contains(TravelerMock.coupons[i].id),
              radius: _segment(i, TravelerMock.coupons.length),
              onRedeem: () {
                if (cubit.redeem(TravelerMock.coupons[i])) {
                  showMareNotice(context, 'Cupom guardado na carteira');
                }
              },
            ),
          ],
          if (s.history.isNotEmpty) ...[
            const SizedBox(height: TravelSpace.xl),
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
    );
  }
}

BorderRadius _segment(int i, int n) => BorderRadius.vertical(
      top: Radius.circular(i == 0 ? TravelSpace.rCard : TravelSpace.rTight),
      bottom:
          Radius.circular(i == n - 1 ? TravelSpace.rCard : TravelSpace.rTight),
    );

class _CouponRow extends StatelessWidget {
  const _CouponRow({
    required this.coupon,
    required this.points,
    required this.redeemed,
    required this.radius,
    required this.onRedeem,
  });

  final Coupon coupon;
  final int points;
  final bool redeemed;
  final BorderRadius radius;
  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final canRedeem = !redeemed && points >= coupon.cost;
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(
          horizontal: TravelSpace.cardPad, vertical: TravelSpace.sm),
      decoration: BoxDecoration(color: p.s1, borderRadius: radius),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 30,
            child: Center(
                child: FaIcon(TravelIcons.ticket, size: 18, color: p.ink)),
          ),
          const SizedBox(width: TravelSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(coupon.title,
                    style: TravelType.subheadStrong.copyWith(color: p.ink)),
                Text(
                  redeemed ? 'Na carteira' : '${coupon.cost} pontos',
                  style: TravelType.footnote.copyWith(
                      color: p.inkMuted, fontFeatures: TravelType.tabular),
                ),
              ],
            ),
          ),
          SecondaryButton(
            label: redeemed ? 'Trocado' : 'Trocar',
            expand: false,
            onPressed: canRedeem ? onRedeem : null,
          ),
        ],
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
