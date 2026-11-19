import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/features/travel_agent/data/travel_agent_mock.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/connector_carousel.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/mare_mark.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';
import 'package:studio_app/features/traveler/domain/traveler_entities.dart';

/// Estado do cupom pra ela: falta ponto, dá pra trocar ou já trocou.
enum CouponStatus { locked, available, redeemed }

CouponStatus couponStatus(Coupon c, int points, Set<String> redeemed) {
  if (redeemed.contains(c.id)) return CouponStatus.redeemed;
  return points >= c.cost ? CouponStatus.available : CouponStatus.locked;
}

/// Cartão do cupom (ref. recompensas do Google Pay, no nosso sistema).
/// Exceção de cor (regra 2): serviço = `accent` com as ondas da marca;
/// transporte = superfície escura com o ícone do app; rolê = foto do lugar
/// com véu escuro. Bloqueado fica cinza (sem cor) com cadeado; trocado
/// ganha o selo "Trocado".
class CouponCard extends StatelessWidget {
  const CouponCard({
    required this.coupon,
    required this.status,
    this.points = 0,
    this.large = false,
    super.key,
  });

  final Coupon coupon;
  final CouponStatus status;

  /// Saldo atual (pra dizer quanto falta).
  final int points;

  /// Versão grande do sheet (valor maior, regra visível).
  final bool large;

  static const _transportBg = Color(0xFF1C1C1F);

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final c = coupon;
    final locked = status == CouponStatus.locked;
    final pad = large ? 20.0 : 16.0;

    final Widget background = switch (c.kind) {
      CouponKind.servico => ColoredBox(
          color: p.accent,
          child: CustomPaint(painter: _WavesPainter(p.piscina)),
        ),
      CouponKind.transporte => const ColoredBox(color: _transportBg),
      CouponKind.role => Stack(
          fit: StackFit.expand,
          children: [
            if (c.roleId != null)
              Image.asset(
                TravelMock.roleById(c.roleId!).photos.first.asset,
                fit: BoxFit.cover,
              ),
            const ColoredBox(color: Color(0x8C000000)),
          ],
        ),
    };

    final Widget mark = switch (c.kind) {
      CouponKind.servico => const MareMark(size: 28, inverted: true),
      CouponKind.transporte => ConnectorTile(
          kind: c.partner == 'Uber' ? ConnectorKind.uber : ConnectorKind.noveNove,
          size: 32,
        ),
      CouponKind.role => Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: const FaIcon(TravelIcons.drink, size: 14, color: Colors.white),
        ),
    };

    final card = ClipRRect(
      borderRadius: BorderRadius.circular(TravelSpace.rCard),
      child: Stack(
        fit: StackFit.expand,
        children: [
          background,
          Padding(
            padding: EdgeInsets.all(pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    mark,
                    const SizedBox(width: TravelSpace.sm),
                    Expanded(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: _Badge(
                            coupon: c, status: status, points: points),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  c.value,
                  style: (large ? TravelType.title1 : TravelType.title2)
                      .copyWith(
                          color: Colors.white,
                          fontFeatures: TravelType.tabular,
                          height: 1.1),
                ),
                const SizedBox(height: 2),
                Text(
                  c.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: (large ? TravelType.subhead : TravelType.footnote)
                      .copyWith(color: Colors.white.withValues(alpha: 0.86)),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!locked) return card;
    // Bloqueado: sem cor (cinza) — o selo com cadeado continua legível.
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        0.2126, 0.7152, 0.0722, 0, 0, //
        0.2126, 0.7152, 0.0722, 0, 0, //
        0.2126, 0.7152, 0.0722, 0, 0, //
        0, 0, 0, 0.55, 0, //
      ]),
      child: card,
    );
  }
}

/// Selo pílula no canto: "Novo", "Faltam N" (cadeado) ou "Trocado" (check).
class _Badge extends StatelessWidget {
  const _Badge({
    required this.coupon,
    required this.status,
    required this.points,
  });

  final Coupon coupon;
  final CouponStatus status;
  final int points;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final (FaIconData? icon, String? label) = switch (status) {
      CouponStatus.locked => (
          TravelIcons.lock,
          'Faltam ${coupon.cost - points}'
        ),
      CouponStatus.redeemed => (TravelIcons.check, 'Trocado'),
      CouponStatus.available => coupon.isNew ? (null, 'Novo') : (null, null),
    };
    if (label == null) return const SizedBox.shrink();
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: p.s1,
        borderRadius: BorderRadius.circular(TravelSpace.rPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            FaIcon(icon, size: 10, color: p.ink),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TravelType.caption
                  .weight(FontWeight.w500)
                  .copyWith(
                      color: p.ink,
                      height: 1.2,
                      fontFeatures: TravelType.tabular)),
          ),
        ],
      ),
    );
  }
}

/// Ondas da marca (as do símbolo) atravessando o card do serviço.
class _WavesPainter extends CustomPainter {
  _WavesPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final amp = size.height * 0.035;
    final wave = size.width / 2.2;
    for (var k = 0; k < 4; k++) {
      final y0 = size.height * (0.18 + k * 0.13);
      final path = Path()..moveTo(size.width * 0.35, y0);
      for (var x = size.width * 0.35; x <= size.width + 4; x += 4) {
        path.lineTo(
            x, y0 + amp * math.sin((x / wave) * 2 * math.pi + k * 0.9));
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavesPainter old) => old.color != color;
}
