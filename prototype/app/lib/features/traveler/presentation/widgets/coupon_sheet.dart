import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';
import 'package:studio_app/features/traveler/domain/traveler_entities.dart';
import 'package:studio_app/features/traveler/presentation/view_models/traveler_cubit.dart';
import 'package:studio_app/features/traveler/presentation/widgets/coupon_card.dart';
import 'package:studio_app/features/traveler/presentation/widgets/mare_sheet.dart';

/// Sheet do cupom: o cartão em destaque, a regra em uma linha, validade e
/// custo. Antes de trocar, um primário "Trocar por N pontos"; depois, o
/// cartão vira e mostra o código, e entra o botão segmentado (copiar o
/// código | usar no app). Tudo **(hipótese)** (Q-27, Q-28).
Future<void> showCouponSheet(BuildContext context, Coupon coupon) =>
    showMareSheet<void>(
      context,
      builder: (_) => CouponSheet(coupon: coupon),
    );

class CouponSheet extends StatefulWidget {
  const CouponSheet({required this.coupon, super.key});

  final Coupon coupon;

  @override
  State<CouponSheet> createState() => _CouponSheetState();
}

class _CouponSheetState extends State<CouponSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flip = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 560),
    value: travelerCubit().state.redeemed.contains(widget.coupon.id) ? 1 : 0,
  );

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  void _redeem() {
    if (!travelerCubit().redeem(widget.coupon)) return;
    HapticFeedback.mediumImpact();
    if (MediaQuery.disableAnimationsOf(context)) {
      _flip.value = 1;
    } else {
      _flip.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final c = widget.coupon;
    return BlocBuilder<TravelerCubit, TravelerState>(
      bloc: travelerCubit(),
      builder: (context, s) {
        final status = couponStatus(c, s.points, s.redeemed);
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                TravelSpace.gutter, TravelSpace.sm, TravelSpace.gutter, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SheetBar(onClose: () => Navigator.of(context).maybePop()),
                const SizedBox(height: TravelSpace.sm),
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: AnimatedBuilder(
                    animation: _flip,
                    builder: (context, _) {
                      final t = Curves.easeInOutCubic.transform(_flip.value);
                      final back = t > 0.5;
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0012)
                          ..rotateY(math.pi * t),
                        child: back
                            ? Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(math.pi),
                                child: _CodeSide(coupon: c),
                              )
                            : CouponCard(
                                coupon: c,
                                status: status,
                                points: s.points,
                                large: true,
                              ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: TravelSpace.xl),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: TravelSpace.cardPad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.fullTitle,
                          style: TravelType.title3.copyWith(color: p.ink)),
                      const SizedBox(height: TravelSpace.xs),
                      Text(c.detail,
                          style:
                              TravelType.subhead.copyWith(color: p.inkMuted)),
                      const SizedBox(height: TravelSpace.md),
                      Row(
                        children: [
                          _Meta(icon: TravelIcons.clock, text: c.validUntil),
                          const SizedBox(width: TravelSpace.lg),
                          _Meta(
                              icon: TravelIcons.ticket,
                              text: '${c.cost} pontos'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TravelSpace.xl),
                AnimatedSwitcher(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 220),
                  child: switch (status) {
                    CouponStatus.redeemed => SplitAction(
                        key: const ValueKey('usar'),
                        code: c.code,
                        secondaryLabel: c.action,
                        secondaryIcon: TravelIcons.arrowUpRight,
                        onSecondary: () {
                          final nav = Navigator.of(context);
                          showMareNotice(
                            context,
                            c.partner != null && c.kind == CouponKind.transporte
                                ? 'Abrindo a ${c.partner} com o código'
                                : 'Cupom pronto pra usar',
                          );
                          nav.maybePop();
                        },
                      ),
                    CouponStatus.available => PrimaryButton(
                        key: const ValueKey('trocar'),
                        label: 'Trocar por ${c.cost} pontos',
                        onPressed: _redeem,
                      ),
                    CouponStatus.locked => PrimaryButton(
                        key: const ValueKey('falta'),
                        label: 'Faltam ${c.cost - s.points} pontos',
                        onPressed: null,
                      ),
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final FaIconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(icon, size: 13, color: p.inkMuted),
        const SizedBox(width: 6),
        Text(text,
            style: TravelType.footnote.copyWith(
                color: p.inkMuted, fontFeatures: TravelType.tabular)),
      ],
    );
  }
}

/// Verso do cartão: o código grande, em `s1`, com o picote de ticket.
class _CodeSide extends StatelessWidget {
  const _CodeSide({required this.coupon});

  final Coupon coupon;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Container(
      decoration: BoxDecoration(
        color: p.s1,
        borderRadius: BorderRadius.circular(TravelSpace.rCard),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Seu código',
              style: TravelType.footnote.copyWith(color: p.inkMuted)),
          const SizedBox(height: TravelSpace.sm),
          SelectableText(
            coupon.code,
            textAlign: TextAlign.center,
            style: TravelType.title1.copyWith(
              color: p.ink,
              letterSpacing: 2,
              fontFeatures: TravelType.tabular,
            ),
          ),
          const SizedBox(height: TravelSpace.md),
          // Picote: furinhos `s0` cruzando o cartão.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: TravelSpace.lg),
            child: LayoutBuilder(builder: (context, box) {
              final n = (box.maxWidth / 10).floor();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < n; i++)
                    Container(
                      width: 4,
                      height: 4,
                      decoration:
                          BoxDecoration(color: p.s2, shape: BoxShape.circle),
                    ),
                ],
              );
            }),
          ),
          const SizedBox(height: TravelSpace.md),
          Text(coupon.validUntil,
              style: TravelType.footnote.copyWith(
                  color: p.inkMuted, fontFeatures: TravelType.tabular)),
        ],
      ),
    );
  }
}

/// Botão segmentado (ref. button group do M3, no nosso sistema): dois
/// segmentos colados, 2 px de fundo entre eles, cantos de fora 24 e de
/// dentro 8 — a mesma linguagem da lista segmentada. Esquerda = copiar o
/// código (primário `accent`, vira "Copiado" com check por 1,6 s); direita
/// = usar no app (secundário `s2`, texto neutro). Exceção à regra 5
/// (pedido do designer).
class SplitAction extends StatefulWidget {
  const SplitAction({
    required this.code,
    required this.secondaryLabel,
    required this.secondaryIcon,
    required this.onSecondary,
    super.key,
  });

  final String code;
  final String secondaryLabel;
  final FaIconData secondaryIcon;
  final VoidCallback onSecondary;

  @override
  State<SplitAction> createState() => _SplitActionState();
}

class _SplitActionState extends State<SplitAction> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    await HapticFeedback.selectionClick();
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    const outer = Radius.circular(TravelSpace.rCard);
    const inner = Radius.circular(TravelSpace.rTight);
    Widget segment({
      required String label,
      required FaIconData icon,
      required Color fill,
      required Color fg,
      required BorderRadius radius,
      required VoidCallback onTap,
    }) =>
        Expanded(
          child: Semantics(
            button: true,
            label: label,
            excludeSemantics: true,
            onTap: onTap,
            child: Pressable(
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 56,
                decoration: BoxDecoration(color: fill, borderRadius: radius),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      transitionBuilder: (child, a) =>
                          ScaleTransition(scale: a, child: child),
                      child: FaIcon(icon,
                          key: ValueKey(icon), size: 15, color: fg),
                    ),
                    const SizedBox(width: TravelSpace.sm),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TravelType.calloutStrong
                            .copyWith(color: fg, height: 1.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
    return Row(
      children: [
        segment(
          label: _copied ? 'Copiado' : 'Copiar código',
          icon: _copied ? TravelIcons.check : TravelIcons.copy,
          fill: p.accent,
          fg: Colors.white,
          radius: const BorderRadius.horizontal(left: outer, right: inner),
          onTap: _copy,
        ),
        const SizedBox(width: TravelSpace.segmentGap),
        segment(
          label: widget.secondaryLabel,
          icon: widget.secondaryIcon,
          fill: p.s2,
          fg: p.ink,
          radius: const BorderRadius.horizontal(left: inner, right: outer),
          onTap: widget.onSecondary,
        ),
      ],
    );
  }
}
