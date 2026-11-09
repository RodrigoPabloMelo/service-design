import 'package:flutter/material.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/connector_carousel.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';

/// Abre a comparação de corridas (99 e Uber) de um extra de transfer.
/// [options] já vem ordenada por preço: a primeira é a mais em conta e
/// vem pré-selecionada. Devolve o id escolhido, ou null se fechou.
///
/// Ref. Mobbin: lista do Uber (preço à direita, CTA nomeia a escolha) +
/// selo "mais em conta" do Gojek na linha do topo.
Future<String?> showRideSheet(
  BuildContext context, {
  required TravelExtra extra,
  required List<RideOption> options,
  String? selectedId,
}) {
  final p = TravelPalette.of(context);
  return showModalBottomSheet<String>(
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
      child: _RideSheet(
        extra: extra,
        options: options,
        selectedId: selectedId,
      ),
    ),
  );
}

/// Lista segmentada (M3 Expressive): cada opção é um tile `s1` separado
/// por 2, cantos de fora 24 (sheet 36 − margem 12) e cantos entre itens 8.
/// Superfícies na margem 12; texto solto a 24, alinhado com o dos tiles.
class _RideSheet extends StatefulWidget {
  const _RideSheet({
    required this.extra,
    required this.options,
    this.selectedId,
  });

  final TravelExtra extra;
  final List<RideOption> options;
  final String? selectedId;

  @override
  State<_RideSheet> createState() => _RideSheetState();
}

/// Cantos do item [i] de [n]: 24 nas pontas da lista, 8 entre itens.
BorderRadius _segmentRadius(int i, int n) {
  const outer = Radius.circular(TravelSpace.rCard);
  const inner = Radius.circular(TravelSpace.rTight);
  return BorderRadius.vertical(
    top: i == 0 ? outer : inner,
    bottom: i == n - 1 ? outer : inner,
  );
}

class _RideSheetState extends State<_RideSheet> {
  late String _selected = widget.selectedId ?? widget.options.first.id;

  RideOption get _choice => widget.options.firstWhere(
        (o) => o.id == _selected,
        orElse: () => widget.options.first,
      );

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
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
              title: 'Escolha a corrida',
              onClose: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: TravelSpace.sm),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: TravelSpace.cardPad),
              child: Text(
                '${widget.extra.detail}, motorista mulher',
                style: TravelType.section.copyWith(color: p.inkMuted),
              ),
            ),
            const SizedBox(height: TravelSpace.sm),
            for (var i = 0; i < widget.options.length; i++) ...[
              if (i > 0) const SizedBox(height: TravelSpace.segmentGap),
              _RideRow(
                option: widget.options[i],
                cheapest: i == 0,
                selected: widget.options[i].id == _selected,
                radius: _segmentRadius(i, widget.options.length),
                onTap: () => setState(() => _selected = widget.options[i].id),
              ),
            ],
            const SizedBox(height: TravelSpace.md),
            // Alinha com o ícone dos tiles (texto solto a 24).
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: TravelSpace.cardPad),
              child: Text(
                'Preço estimado. Cancele grátis até 2h antes.',
                style: TravelType.caption.copyWith(color: p.inkMuted),
              ),
            ),
            const SizedBox(height: TravelSpace.xl),
            PrimaryButton(
              label: 'Adicionar ${_choice.name}',
              onPressed: () => Navigator.of(context).pop(_selected),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tile 64 da lista segmentada: ícone do app, nome + descrição, preço à
/// direita. Selecionado ganha o tint `accentSoft` e vira pílula; sem
/// divisor, radio nem sombra.
class _RideRow extends StatelessWidget {
  const _RideRow({
    required this.option,
    required this.cheapest,
    required this.selected,
    required this.radius,
    required this.onTap,
  });

  final RideOption option;
  final bool cheapest;
  final bool selected;
  final BorderRadius radius;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: [
        option.name,
        option.detail,
        option.priceLabel,
        if (cheapest) 'mais em conta',
      ].join(', '),
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? const Duration(milliseconds: 1)
              : const Duration(milliseconds: 150),
          curve: const Cubic(0.2, 0, 0, 1),
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: TravelSpace.cardPad),
          decoration: BoxDecoration(
            color: selected ? p.accentSoft : p.s1,
            // Selecionado vira pílula (M3 Expressive): além da cor, a
            // forma muda. Sem sombra.
            // Meia altura (32), não 999: a forma anima de verdade.
            borderRadius: selected ? BorderRadius.circular(64 / 2) : radius,
          ),
          child: Row(
            children: [
              ConnectorTile(kind: option.provider, size: 36),
              const SizedBox(width: TravelSpace.md),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            option.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                TravelType.subheadStrong.copyWith(color: p.ink),
                          ),
                        ),
                        if (cheapest) ...[
                          const SizedBox(width: TravelSpace.sm),
                          const _CheapestTag(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option.detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TravelType.footnote.copyWith(color: p.inkMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: TravelSpace.md),
              Text(
                option.priceLabel,
                style: TravelType.headline.copyWith(
                  color: p.ink,
                  fontFeatures: TravelType.tabular,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Selo da opção mais em conta (ref. "Recommended" do Uber).
class _CheapestTag extends StatelessWidget {
  const _CheapestTag();

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: p.accent,
        borderRadius: BorderRadius.circular(TravelSpace.rPill),
      ),
      child: Text(
        'Mais em conta',
        style: TravelType.caption
            .weight(FontWeight.w500)
            .copyWith(color: p.onAccent, height: 1.2),
      ),
    );
  }
}
