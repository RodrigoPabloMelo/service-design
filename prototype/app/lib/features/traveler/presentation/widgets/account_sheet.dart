import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';
import 'package:studio_app/features/traveler/data/traveler_mock.dart';
import 'package:studio_app/features/traveler/domain/traveler_entities.dart';
import 'package:studio_app/features/traveler/presentation/view_models/traveler_cubit.dart';
import 'package:studio_app/features/traveler/presentation/widgets/mare_sheet.dart';

/// Salvar um rolê. Sem conta, abre a conta rápida antes (D-16, D-23) e
/// salva logo depois — ela volta ao rolê já salvo.
Future<void> saveRole(BuildContext context, String roleId) async {
  final traveler = travelerCubit();
  if (!traveler.hasAccount) {
    final provider = await showAccountSheet(context);
    if (provider == null) return;
    traveler.signIn(provider);
  }
  final wasSaved = traveler.state.saved.contains(roleId);
  traveler.toggleSaved(roleId);
  if (!context.mounted) return;
  showMareNotice(
    context,
    wasSaved
        ? 'Tirado dos salvos'
        : 'Salvo em ${TravelerMock.folderName(traveler.state.trip)}',
  );
}

/// Conta rápida: um passo, sem verificação (Q-13). Tudo mock.
Future<AccountProvider?> showAccountSheet(BuildContext context) =>
    showMareSheet<AccountProvider>(
      context,
      builder: (_) => const AccountSheet(),
    );

class AccountSheet extends StatelessWidget {
  const AccountSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    void pick(AccountProvider provider) =>
        Navigator.of(context).pop(provider);
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
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: TravelSpace.cardPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Crie sua conta pra salvar',
                      style: TravelType.title2.copyWith(color: p.ink)),
                  const SizedBox(height: TravelSpace.sm),
                  Text(
                    'Seus rolês ficam numa pasta da viagem. Ver rolês, '
                    'vídeos e selo continua sem conta.',
                    style: TravelType.subhead
                        .copyWith(color: p.inkMuted, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TravelSpace.xl),
            _ProviderButton(
              icon: TravelIcons.apple,
              label: 'Continuar com Apple',
              onTap: () => pick(AccountProvider.apple),
            ),
            const SizedBox(height: TravelSpace.sm),
            _ProviderButton(
              icon: TravelIcons.envelope,
              label: 'Continuar com e-mail',
              onTap: () => pick(AccountProvider.email),
            ),
            const SizedBox(height: TravelSpace.sm),
            // Provedores com o mesmo peso: nenhum vira primário.
            _ProviderButton(
              icon: TravelIcons.google,
              label: 'Continuar com Google',
              onTap: () => pick(AccountProvider.google),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderButton extends StatelessWidget {
  const _ProviderButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final FaIconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) =>
      SecondaryButton(label: label, icon: icon, onPressed: onTap);
}

/// Botão de salvar no cabeçalho do detalhe: círculo de 44 como o voltar.
class SaveRoleButton extends StatelessWidget {
  const SaveRoleButton({required this.roleId, super.key});

  final String roleId;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return BlocBuilder<TravelerCubit, TravelerState>(
      bloc: travelerCubit(),
      buildWhen: (a, b) => a.saved != b.saved,
      builder: (context, s) {
        final saved = s.saved.contains(roleId);
        void onTap() => saveRole(context, roleId);
        return Semantics(
          button: true,
          label: saved ? 'Tirar dos salvos' : 'Salvar',
          excludeSemantics: true,
          onTap: onTap,
          child: Pressable(
            onTap: onTap,
            child: Container(
              width: TravelSpace.tap,
              height: TravelSpace.tap,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: p.s1, shape: BoxShape.circle),
              child: FaIcon(
                saved ? TravelIcons.bookmarkSolid : TravelIcons.bookmark,
                size: 16,
                color: saved ? p.accent : p.ink,
              ),
            ),
          ),
        );
      },
    );
  }
}
