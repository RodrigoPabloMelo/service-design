import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/features/explore/presentation/widgets/explore_ui.dart';
import 'package:studio_app/features/travel_agent/data/travel_agent_mock.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';
import 'package:studio_app/features/traveler/data/traveler_mock.dart';
import 'package:studio_app/features/traveler/domain/traveler_entities.dart';
import 'package:studio_app/features/traveler/presentation/view_models/traveler_cubit.dart';
import 'package:studio_app/features/traveler/presentation/widgets/mare_sheet.dart';

/// Avaliação em 1 ou 2 toques (E-08, D-09, F-10): o rolê e o transfer.
/// Nada bloqueia; fechar não perde nada. Pontos premiam o ato de avaliar,
/// nunca a nota (hipótese, Q-27). [onWallet] abre a carteira depois.
Future<void> showRatingSheet(
  BuildContext context, {
  required String roleId,
  VoidCallback? onWallet,
}) =>
    showMareSheet<void>(
      context,
      builder: (_) => RatingSheet(roleId: roleId, onWallet: onWallet),
    );

class RatingSheet extends StatefulWidget {
  const RatingSheet({required this.roleId, this.onWallet, super.key});

  final String roleId;
  final VoidCallback? onWallet;

  @override
  State<RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<RatingSheet> {
  RatingValue? _role;
  RatingValue? _transfer;
  String? _reason;
  int? _earned;

  void _send() {
    final earned = travelerCubit().rate(OutingRating(
      roleId: widget.roleId,
      role: _role,
      transfer: _transfer,
      reason: _reason,
    ));
    setState(() => _earned = earned);
  }

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final role = TravelMock.roleById(widget.roleId);
    final transfer = travelerCubit().state.transfer;
    final close = Navigator.of(context).maybePop;
    final earned = _earned;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            TravelSpace.gutter, TravelSpace.sm, TravelSpace.gutter, 16),
        child: AnimatedSize(
          duration: exploreMotion(context, 260),
          curve: kExploreEase,
          alignment: Alignment.topCenter,
          child: earned != null
              ? _Done(
                  earned: earned,
                  onClose: close,
                  onWallet: widget.onWallet == null
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          widget.onWallet!();
                        },
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SheetBar(title: 'Como foi?', onClose: close),
                    const SizedBox(height: TravelSpace.sm),
                    _Question(
                      photo: role.photos.first.asset,
                      title: role.shortName,
                      value: _role,
                      onChanged: (v) => setState(() => _role = v),
                    ),
                    if (transfer != null) ...[
                      const SizedBox(height: TravelSpace.sm),
                      _Question(
                        icon: TravelIcons.car,
                        title: 'Transfer com ${transfer.driverName}',
                        value: _transfer,
                        onChanged: (v) => setState(() => _transfer = v),
                      ),
                    ],
                    if (_role != null || _transfer != null) ...[
                      const SizedBox(height: TravelSpace.lg),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: TravelSpace.cardPad),
                        child: Text('Quer contar mais?',
                            style: TravelType.section
                                .copyWith(color: p.inkMuted)),
                      ),
                      const SizedBox(height: TravelSpace.sm),
                      Wrap(
                        spacing: TravelSpace.sm,
                        runSpacing: TravelSpace.sm,
                        children: [
                          for (final r in TravelerMock.reasons)
                            ExploreChip(
                              label: r,
                              selected: r == _reason,
                              onCard: false,
                              onTap: () => setState(
                                  () => _reason = r == _reason ? null : r),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: TravelSpace.xl),
                    PrimaryButton(
                      label: 'Enviar',
                      onPressed: _role == null && _transfer == null
                          ? null
                          : _send,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Uma pergunta: o que está sendo avaliado + "Foi bom" / "Não curti".
class _Question extends StatelessWidget {
  const _Question({
    required this.title,
    required this.value,
    required this.onChanged,
    this.photo,
    this.icon,
  });

  final String title;
  final String? photo;
  final FaIconData? icon;
  final RatingValue? value;
  final ValueChanged<RatingValue> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return SolidBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Foto recortada; ícone direto na superfície (regra 6).
              photo != null
                  ? ClipRRect(
                      borderRadius:
                          BorderRadius.circular(TravelSpace.rTight),
                      child: Image.asset(photo!,
                          width: 36, height: 36, fit: BoxFit.cover),
                    )
                  : SizedBox.square(
                      dimension: 36,
                      child: Center(
                          child: FaIcon(icon, size: 18, color: p.ink)),
                    ),
              const SizedBox(width: TravelSpace.md),
              Expanded(
                child: Text(title,
                    style: TravelType.headline.copyWith(color: p.ink)),
              ),
            ],
          ),
          const SizedBox(height: TravelSpace.md),
          Row(
            children: [
              Expanded(
                child: _Choice(
                  icon: TravelIcons.thumbsUp,
                  label: 'Foi bom',
                  selected: value == RatingValue.bom,
                  onTap: () => onChanged(RatingValue.bom),
                ),
              ),
              const SizedBox(width: TravelSpace.sm),
              Expanded(
                child: _Choice(
                  icon: TravelIcons.thumbsDown,
                  label: 'Não curti',
                  selected: value == RatingValue.naoCurti,
                  onTap: () => onChanged(RatingValue.naoCurti),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final FaIconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: outlineChoiceDecoration(p,
              selected: selected, radius: TravelSpace.rInner),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(icon, size: 15, color: p.ink),
              const SizedBox(width: TravelSpace.sm),
              Text(label,
                  style: TravelType.subheadStrong.copyWith(color: p.ink)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Depois de enviar: pontos ganhos e o porquê.
class _Done extends StatelessWidget {
  const _Done({required this.earned, required this.onClose, this.onWallet});

  final int earned;
  final VoidCallback onClose;
  final VoidCallback? onWallet;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SheetBar(onClose: onClose),
        const SizedBox(height: TravelSpace.sm),
        FaIcon(TravelIcons.circleCheck, size: 32, color: p.ink),
        const SizedBox(height: TravelSpace.md),
        Text(
          earned > 0 ? '+$earned pontos' : 'Avaliação enviada',
          style: TravelType.title1
              .copyWith(color: p.ink, fontFeatures: TravelType.tabular),
        ),
        const SizedBox(height: TravelSpace.sm),
        Text(
          'Sua avaliação ajuda outras mulheres a decidir.',
          textAlign: TextAlign.center,
          style: TravelType.subhead.copyWith(color: p.inkMuted),
        ),
        const SizedBox(height: TravelSpace.xl),
        // O X fecha; um primário só (sem "Fechar" repetido).
        PrimaryButton(
          label: onWallet != null ? 'Ver carteira' : 'Pronto',
          onPressed: onWallet ?? onClose,
        ),
      ],
    );
  }
}
