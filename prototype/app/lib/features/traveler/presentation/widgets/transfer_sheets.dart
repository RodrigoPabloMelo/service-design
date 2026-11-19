import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/features/travel_agent/data/travel_agent_mock.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';
import 'package:studio_app/features/traveler/data/traveler_mock.dart';
import 'package:studio_app/features/traveler/domain/traveler_entities.dart';
import 'package:studio_app/features/traveler/presentation/view_models/traveler_cubit.dart';
import 'package:studio_app/features/traveler/presentation/widgets/mare_sheet.dart';

// Transfer com motorista parceira (D-26): contrata e paga no app; o
// acompanhamento da corrida fica no app da parceira. Preço e meio de
// pagamento são mock (Q-02, Q-03, Q-05).

/// "Sáb, 17h30" → "17h30".
String _hour(String v) => v.split(', ').last;

/// Oferta no chat, depois da troca por chuva. Opcional: só um secundário.
class TransferOfferCard extends StatelessWidget {
  const TransferOfferCard({required this.roleId, this.onBooked, super.key});

  final String roleId;
  final VoidCallback? onBooked;

  Future<void> _hire(BuildContext context) async {
    final booking = TravelerMock.transferTo(roleId);
    final paid = await showMareSheet<bool>(
      context,
      builder: (_) => TransferCheckoutSheet(booking: booking),
    );
    if (paid != true) return;
    travelerCubit().bookTransfer(booking);
    onBooked?.call();
  }

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return BlocBuilder<TravelerCubit, TravelerState>(
      bloc: travelerCubit(),
      buildWhen: (a, b) => a.transfer != b.transfer,
      builder: (context, s) {
        if (s.transfer != null) return const SizedBox.shrink();
        return SolidBlock(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FaIcon(TravelIcons.car, size: 15, color: p.ink),
                  const SizedBox(width: TravelSpace.sm),
                  Expanded(
                    child: Text('Ida e volta com motorista mulher',
                        style: TravelType.headline.copyWith(color: p.ink)),
                  ),
                ],
              ),
              const SizedBox(height: TravelSpace.xs),
              Text(
                'Saída do hotel às '
                '${_hour(TravelerMock.transferPickup)}, volta às '
                '${_hour(TravelerMock.transferBack)}. Pago no app, '
                '${TravelerMock.transferPrice}.',
                style: TravelType.subhead.copyWith(color: p.ink),
              ),
              const SizedBox(height: TravelSpace.md),
              SecondaryButton(
                label: 'Ver transfer',
                onPressed: () => _hire(context),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Checkout: motorista, horários, preço e pagamento. Um primário: pagar.
class TransferCheckoutSheet extends StatefulWidget {
  const TransferCheckoutSheet({required this.booking, super.key});

  final TransferBooking booking;

  @override
  State<TransferCheckoutSheet> createState() => _TransferCheckoutSheetState();
}

class _TransferCheckoutSheetState extends State<TransferCheckoutSheet> {
  bool _paying = false;

  Future<void> _pay() async {
    setState(() => _paying = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final b = widget.booking;
    final role = TravelMock.roleById(b.roleId);
    final rows = <(FaIconData, String, String)>[
      (TravelIcons.user, b.driverName, 'Motorista parceira, ${b.car}'),
      (TravelIcons.clock, 'Ida ${b.pickup}', 'Do hotel ao ${role.shortName}'),
      (TravelIcons.home, 'Volta ${b.back}', 'Do ${role.shortName} ao hotel'),
      (TravelIcons.creditCard, b.paidWith, 'Pagamento no app'),
    ];
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
              title: 'Transfer',
              onClose: () => Navigator.of(context).maybePop(false),
            ),
            const SizedBox(height: TravelSpace.sm),
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) const SizedBox(height: TravelSpace.segmentGap),
              _Row(
                icon: rows[i].$1,
                title: rows[i].$2,
                detail: rows[i].$3,
                radius: BorderRadius.vertical(
                  top: Radius.circular(
                      i == 0 ? TravelSpace.rCard : TravelSpace.rTight),
                  bottom: Radius.circular(i == rows.length - 1
                      ? TravelSpace.rCard
                      : TravelSpace.rTight),
                ),
              ),
            ],
            const SizedBox(height: TravelSpace.md),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: TravelSpace.cardPad),
              child: Text(
                '${TravelerMock.transferPriceDetail}. Você acompanha a '
                'corrida no app da parceira.',
                style: TravelType.caption.copyWith(color: p.inkMuted),
              ),
            ),
            const SizedBox(height: TravelSpace.xl),
            PrimaryButton(
              label: 'Pagar ${b.price}',
              loading: _paying,
              onPressed: _pay,
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    required this.detail,
    required this.radius,
  });

  final FaIconData icon;
  final String title;
  final String detail;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(
          horizontal: TravelSpace.cardPad, vertical: TravelSpace.sm),
      decoration: BoxDecoration(color: p.s1, borderRadius: radius),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 30,
            child: Center(child: FaIcon(icon, size: 18, color: p.ink)),
          ),
          const SizedBox(width: TravelSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style: TravelType.subheadStrong.copyWith(color: p.ink)),
                Text(detail,
                    style: TravelType.footnote.copyWith(color: p.inkMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Transfer pago: horário, motorista e atalho pro app da parceira. Usado
/// no chat e como atalho no dia do rolê (cena 6). Não rastreia a
/// localização dela (Q-12, D-06).
class TransferBookedCard extends StatelessWidget {
  const TransferBookedCard({this.today = false, super.key});

  /// No dia: "Hoje" no lugar do dia da semana.
  final bool today;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return BlocBuilder<TravelerCubit, TravelerState>(
      bloc: travelerCubit(),
      buildWhen: (a, b) => a.transfer != b.transfer,
      builder: (context, s) {
        final b = s.transfer;
        if (b == null) return const SizedBox.shrink();
        final role = TravelMock.roleById(b.roleId);
        String when(String v) =>
            '${today ? 'hoje' : 'sábado'} às ${_hour(v)}';
        return SolidBlock(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FaIcon(TravelIcons.circleCheck, size: 15, color: p.ink),
                  const SizedBox(width: TravelSpace.sm),
                  Expanded(
                    child: Text(
                      today ? 'Seu transfer' : 'Transfer pago',
                      style: TravelType.headline.copyWith(color: p.ink),
                    ),
                  ),
                  Text(b.price,
                      style: TravelType.subhead.copyWith(
                          color: p.inkMuted,
                          fontFeatures: TravelType.tabular)),
                ],
              ),
              const SizedBox(height: TravelSpace.xs),
              Text(
                '${b.driverName} te busca ${when(b.pickup)} pro '
                '${role.shortName}. Volta às ${_hour(b.back)}.',
                style: TravelType.subhead.copyWith(color: p.ink),
              ),
              const SizedBox(height: TravelSpace.md),
              SecondaryButton(
                label: 'Abrir app da parceira',
                icon: TravelIcons.arrowUpRight,
                onPressed: () => showMareNotice(
                  context,
                  'Lá você acompanha a ${b.driverName} a caminho.',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
