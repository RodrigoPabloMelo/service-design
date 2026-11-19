import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/features/explore/presentation/widgets/explore_ui.dart';
import 'package:studio_app/features/travel_agent/data/travel_agent_mock.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';
import 'package:studio_app/features/traveler/data/traveler_mock.dart';
import 'package:studio_app/features/traveler/presentation/view_models/traveler_cubit.dart';
import 'package:studio_app/features/traveler/presentation/views/wallet_page.dart';
import 'package:studio_app/features/traveler/presentation/widgets/account_sheet.dart';

/// Aba Perfil: conta, resumo da viagem (pós-serviço) e carteira.
/// Sem conta: só o convite pra entrar — nada aqui bloqueia o resto do app.
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final cubit = travelerCubit();
    return BlocBuilder<TravelerCubit, TravelerState>(
      bloc: cubit,
      builder: (context, s) {
        final account = s.account;
        if (account == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: TravelSpace.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(TravelIcons.user, size: 28, color: p.inkMuted),
                  const SizedBox(height: TravelSpace.md),
                  Text('Sua conta',
                      style: TravelType.title2.copyWith(color: p.ink)),
                  const SizedBox(height: TravelSpace.xs),
                  Text(
                    'Entre pra salvar rolês, montar o roteiro e juntar '
                    'pontos.',
                    textAlign: TextAlign.center,
                    style: TravelType.subhead.copyWith(color: p.inkMuted),
                  ),
                  const SizedBox(height: TravelSpace.xl),
                  SecondaryButton(
                    label: 'Entrar',
                    expand: false,
                    onPressed: () async {
                      final provider = await showAccountSheet(context);
                      if (provider != null) cubit.signIn(provider);
                    },
                  ),
                ],
              ),
            ),
          );
        }
        final trip = s.trip;
        final transfer = s.transfer;
        return ListView(
          padding: EdgeInsets.fromLTRB(
              TravelSpace.gutter, top + TravelSpace.lg, TravelSpace.gutter,
              120 + bottom),
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: TravelSpace.cardPad),
              child: Text('Oi, ${account.name}',
                  style: TravelType.title3.copyWith(color: p.ink)),
            ),
            const SizedBox(height: TravelSpace.xl),
            _PointsCard(
              points: s.points,
              onTap: () => Navigator.of(context)
                  .push(exploreRoute(context, const WalletPage())),
            ),
            const SizedBox(height: TravelSpace.xl),
            const SectionHeader('Sua viagem'),
            SolidBlock(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    TravelerMock.folderName(trip),
                    style: TravelType.headline.copyWith(color: p.ink),
                  ),
                  if (trip != null)
                    Text(trip.stay.name,
                        style:
                            TravelType.footnote.copyWith(color: p.inkMuted)),
                  const SizedBox(height: TravelSpace.md),
                  _Stat('Rolês salvos', '${s.saved.length}'),
                  _Stat('Saídas avaliadas', '${s.ratings.length}'),
                  if (transfer != null)
                    _Stat(
                      'Transfer com ${transfer.driverName}',
                      TravelMock.roleById(transfer.roleId).shortName,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TravelType.subhead.copyWith(color: p.ink)),
          ),
          Text(value,
              style: TravelType.subheadStrong
                  .copyWith(color: p.ink, fontFeatures: TravelType.tabular)),
        ],
      ),
    );
  }
}

/// Atalho pros pontos no Perfil: saldo grande e o quanto falta pro próximo
/// cupom; tocar abre a página de pontos.
class _PointsCard extends StatelessWidget {
  const _PointsCard({required this.points, required this.onTap});

  final int points;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Semantics(
      button: true,
      label: '$points pontos. Ver recompensas',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(TravelSpace.lg),
          decoration: BoxDecoration(
            color: p.s1,
            borderRadius: BorderRadius.circular(TravelSpace.rCard),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Seus pontos',
                        style: TravelType.footnote.copyWith(color: p.inkMuted)),
                    const SizedBox(height: 2),
                    Text(
                      '$points',
                      style: TravelType.title1.copyWith(
                          color: p.ink, fontFeatures: TravelType.tabular),
                    ),
                    Text('Troque por cupons',
                        style: TravelType.subhead.copyWith(color: p.inkMuted)),
                  ],
                ),
              ),
              FaIcon(TravelIcons.gift, size: 22, color: p.ink),
              const SizedBox(width: TravelSpace.md),
              FaIcon(TravelIcons.chevronRight, size: 13, color: p.inkMuted),
            ],
          ),
        ),
      ),
    );
  }
}
