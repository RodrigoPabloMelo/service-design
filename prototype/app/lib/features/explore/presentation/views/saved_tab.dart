import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/features/explore/presentation/views/folder_page.dart';
import 'package:studio_app/features/explore/presentation/widgets/explore_ui.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';
import 'package:studio_app/features/traveler/data/traveler_mock.dart';
import 'package:studio_app/features/traveler/presentation/view_models/traveler_cubit.dart';
import 'package:studio_app/features/traveler/domain/traveler_entities.dart';
import 'package:studio_app/features/traveler/presentation/widgets/folder_cover.dart';
import 'package:studio_app/features/traveler/presentation/widgets/save_to_sheet.dart';

/// Aba Salvos: as pastas de viagem em grade (ref. pastas do Pinterest,
/// D-28). Cada pasta abre com os dias e os rolês sem dia. Pasta
/// compartilhada com a companhia segue em aberto (Q-22, Q-37).
class SavedTab extends StatelessWidget {
  const SavedTab({required this.onExplore, required this.onOrganize, super.key});

  /// Vazio: volta pra aba Explorar.
  final VoidCallback onExplore;

  /// Abre a Maré pra organizar os salvos.
  final VoidCallback onOrganize;

  Future<void> _newFolder(BuildContext context) => showNewFolderSheet(context);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return BlocBuilder<TravelerCubit, TravelerState>(
      bloc: travelerCubit(),
      buildWhen: (a, b) => a.folders != b.folders || a.trip != b.trip,
      builder: (context, s) {
        final custom = s.folders.where((f) => !f.isTrip).toList();
        if (s.saved.isEmpty && custom.isEmpty) {
          return _Empty(onExplore: onExplore);
        }
        // A pasta da viagem só aparece com rolês; as que ela criou, sempre.
        final folders = [
          for (final f in s.folders)
            if (!f.isTrip || f.roleIds.isNotEmpty) f,
        ];
        return ListView(
          padding: EdgeInsets.fromLTRB(
              0, top + TravelSpace.lg, 0, 120 + bottom),
          children: [
            Padding(
              padding: const EdgeInsets.only(right: TravelSpace.gutter),
              child: Row(
                children: [
                  const Expanded(child: ExploreSectionTitle('Salvos')),
                  RoundButton(
                    icon: const FaIcon(TravelIcons.plus),
                    label: 'Nova viagem',
                    onTap: () => _newFolder(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TravelSpace.lg),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: TravelSpace.gutter),
              child: LayoutBuilder(builder: (context, box) {
                const gap = TravelSpace.md;
                final w = (box.maxWidth - gap) / 2;
                return Wrap(
                  spacing: gap,
                  runSpacing: TravelSpace.xl,
                  children: [
                    for (final f in folders)
                      SizedBox(
                        width: w,
                        child: _FolderTile(
                          folder: f,
                          title: TravelerMock.folderLabel(f, s.trip),
                          onTap: () => openFolder(context, f.id,
                              onOrganize: onOrganize),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

/// Pasta na grade: capa-mosaico quadrada (raio 24), nome e contagem.
class _FolderTile extends StatelessWidget {
  const _FolderTile({
    required this.folder,
    required this.title,
    required this.onTap,
  });

  final SavedFolder folder;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final n = folder.roleIds.length;
    final count = n == 1 ? '1 rolê' : '$n rolês';
    final days = folder.days.where((d) => d.roleIds.isNotEmpty).length;
    return Semantics(
      button: true,
      label: '$title, $count',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Hero(
                tag: 'pasta-${folder.id}',
                child: FolderCover(
                    roleIds: folder.roleIds, radius: TravelSpace.rCard),
              ),
            ),
            const SizedBox(height: TravelSpace.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TravelType.headline.copyWith(color: p.ink)),
                  Text(
                    days > 0
                        ? '$count, $days ${days == 1 ? 'dia' : 'dias'}'
                        : count,
                    style: TravelType.footnote.copyWith(
                        color: p.inkMuted, fontFeatures: TravelType.tabular),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
              'Toque em salvar num rolê e escolha a viagem.',
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
