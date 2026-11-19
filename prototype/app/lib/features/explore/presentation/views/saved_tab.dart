import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/features/explore/data/explore_mock.dart';
import 'package:studio_app/features/explore/presentation/views/role_page.dart';
import 'package:studio_app/features/explore/presentation/widgets/explore_cards.dart';
import 'package:studio_app/features/explore/presentation/widgets/explore_ui.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';
import 'package:studio_app/features/traveler/data/traveler_mock.dart';
import 'package:studio_app/features/traveler/presentation/view_models/traveler_cubit.dart';
import 'package:studio_app/features/traveler/presentation/widgets/account_sheet.dart';

/// Aba Salvos: a pasta da viagem (D-24) com os rolês salvos, e o atalho
/// pra Maré organizar. Pastas compartilhadas e várias pastas seguem em
/// aberto (Q-37).
class SavedTab extends StatelessWidget {
  const SavedTab({required this.onExplore, required this.onOrganize, super.key});

  /// Vazio: volta pra aba Explorar.
  final VoidCallback onExplore;

  /// Abre a Maré pra organizar os salvos.
  final VoidCallback onOrganize;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return BlocBuilder<TravelerCubit, TravelerState>(
      bloc: travelerCubit(),
      buildWhen: (a, b) => a.saved != b.saved || a.trip != b.trip,
      builder: (context, s) {
        if (s.saved.isEmpty) {
          return _Empty(onExplore: onExplore);
        }
        final folder = TravelerMock.folderName(s.trip);
        final roles = [for (final id in s.saved) ExploreMock.roleById(id)];
        return ListView(
          padding: EdgeInsets.fromLTRB(
              0, top + TravelSpace.lg, 0, 120 + bottom),
          children: [
            const ExploreSectionTitle('Salvos'),
            const SizedBox(height: TravelSpace.lg),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: TravelSpace.gutter),
              child: SolidBlock(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        FaIcon(TravelIcons.folder, size: 16, color: p.ink),
                        const SizedBox(width: TravelSpace.sm),
                        Expanded(
                          child: Text(folder,
                              style:
                                  TravelType.headline.copyWith(color: p.ink)),
                        ),
                        Text(
                          roles.length == 1
                              ? '1 rolê'
                              : '${roles.length} rolês',
                          style: TravelType.subhead.copyWith(
                              color: p.inkMuted,
                              fontFeatures: TravelType.tabular),
                        ),
                      ],
                    ),
                    const SizedBox(height: TravelSpace.md),
                    SecondaryButton(
                      label: 'Organizar com a Maré',
                      onPressed: onOrganize,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: TravelSpace.xl),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: TravelSpace.gutter),
              child: Column(
                children: [
                  for (var i = 0; i < roles.length; i++) ...[
                    if (i > 0) const SizedBox(height: TravelSpace.xxl),
                    RoleCard(
                      role: roles[i],
                      heroTag: 'salvos-${roles[i].id}',
                      saved: true,
                      photoAspect: 16 / 11,
                      onTap: () => openRole(
                          context, roles[i], 'salvos-${roles[i].id}'),
                      onToggleSave: () => saveRole(context, roles[i].id),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Vazio honesto: diz como a pasta enche, sem inventar sugestão.
class _Empty extends StatelessWidget {
  const _Empty({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: TravelSpace.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(TravelIcons.bookmark, size: 28, color: p.inkMuted),
            const SizedBox(height: TravelSpace.md),
            Text('Nada salvo ainda',
                style: TravelType.title2.copyWith(color: p.ink)),
            const SizedBox(height: TravelSpace.xs),
            Text(
              'Toque em salvar num rolê e ele entra na pasta da viagem.',
              textAlign: TextAlign.center,
              style: TravelType.subhead.copyWith(color: p.inkMuted),
            ),
            const SizedBox(height: TravelSpace.xl),
            SecondaryButton(
              label: 'Explorar rolês',
              expand: false,
              onPressed: onExplore,
            ),
          ],
        ),
      ),
    );
  }
}
