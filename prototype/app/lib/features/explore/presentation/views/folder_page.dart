import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/core/components/glass/app_glass.dart';
import 'package:studio_app/features/explore/data/explore_mock.dart';
import 'package:studio_app/features/explore/presentation/view_models/explore_cubit.dart';
import 'package:studio_app/features/explore/presentation/view_models/explore_state.dart';
import 'package:studio_app/features/explore/presentation/views/role_page.dart';
import 'package:studio_app/features/explore/presentation/widgets/explore_ui.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/mare_mark.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/place_detail.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';
import 'package:studio_app/features/traveler/data/traveler_mock.dart';
import 'package:studio_app/features/traveler/domain/traveler_entities.dart';
import 'package:studio_app/features/traveler/presentation/view_models/traveler_cubit.dart';
import 'package:studio_app/features/traveler/presentation/widgets/folder_cover.dart';
import 'package:studio_app/features/traveler/presentation/widgets/mare_sheet.dart';

/// Abre uma pasta de viagem (ou um dia dela, com [dayId]).
void openFolder(
  BuildContext context,
  String folderId, {
  required VoidCallback onOrganize,
  String? dayId,
}) {
  Navigator.of(context).push(exploreRoute(
    context,
    withExplore(
      context,
      FolderPage(folderId: folderId, dayId: dayId, onOrganize: onOrganize),
    ),
  ));
}

/// Pasta da viagem (ref. pasta do Pinterest, D-28): nome grande, dias como
/// seções e os rolês ainda sem dia em grade. Ela separa à mão em
/// "Organizar" (escolhe rolês e move pra um dia) ou pede pra Maré.
class FolderPage extends StatefulWidget {
  const FolderPage({
    required this.folderId,
    required this.onOrganize,
    this.dayId,
    super.key,
  });

  final String folderId;

  /// Dia aberto; null = a pasta inteira.
  final String? dayId;
  final VoidCallback onOrganize;

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  final _scroll = ScrollController();
  bool _organizing = false;
  final _selected = <String>{};

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _toggle(String id) => setState(() {
        if (!_selected.remove(id)) _selected.add(id);
      });

  void _stopOrganizing() => setState(() {
        _organizing = false;
        _selected.clear();
      });

  Future<void> _move(SavedFolder folder) async {
    final cubit = travelerCubit();
    final choice = await showMareSheet<String>(
      context,
      builder: (_) => _MoveSheet(folder: folder, exclude: widget.dayId),
    );
    if (choice == null || !mounted) return;
    final dayId = switch (choice) {
      _MoveSheet.newDay => cubit.addDay(folder.id),
      _MoveSheet.noDay => null,
      _ => choice,
    };
    cubit.moveToDay(folder.id, _selected, dayId);
    final label = dayId == null
        ? 'Sem dia'
        : cubit.state
            .folderById(folder.id)
            .days
            .firstWhere((d) => d.id == dayId)
            .label;
    _stopOrganizing();
    showMareNotice(context, 'Movido pra $label');
  }

  void _explore() {
    Navigator.of(context).popUntil((r) => r.isFirst);
    context.read<ExploreCubit>().selectTab(ExploreTab.explorar);
  }

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return BlocBuilder<TravelerCubit, TravelerState>(
      bloc: travelerCubit(),
      builder: (context, s) {
        final folder =
            s.folders.where((f) => f.id == widget.folderId).firstOrNull;
        if (folder == null) return const SizedBox.shrink();
        final day = widget.dayId == null
            ? null
            : folder.days.where((d) => d.id == widget.dayId).firstOrNull;
        final folderName = TravelerMock.folderLabel(folder, s.trip);
        final title = day?.label ?? folderName;
        final showDays = day == null && folder.days.isNotEmpty;
        final gridIds = day?.roleIds ?? folder.unsorted;
        final grid = [for (final id in gridIds) ExploreMock.roleById(id)];
        final daysWithRoles =
            folder.days.where((d) => d.roleIds.isNotEmpty).length;

        final content = ListView(
          controller: _scroll,
          padding: EdgeInsets.fromLTRB(0, top + 64, 0, 140 + bottom),
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: TravelSpace.content),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (day != null)
                    Text(folderName,
                        style: TravelType.subhead.copyWith(color: p.inkMuted)),
                  Semantics(
                    header: true,
                    child: Text(title,
                        style: TravelType.title1.copyWith(color: p.ink)),
                  ),
                  const SizedBox(height: TravelSpace.sm),
                  Row(
                    children: [
                      _Meta(
                        icon: TravelIcons.bookmark,
                        text: _count(
                            day?.roleIds.length ?? folder.roleIds.length),
                      ),
                      if (day == null && daysWithRoles > 0) ...[
                        const SizedBox(width: TravelSpace.lg),
                        _Meta(
                          icon: TravelIcons.calendar,
                          text: daysWithRoles == 1
                              ? '1 dia'
                              : '$daysWithRoles dias',
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (folder.roleIds.isEmpty)
              _EmptyFolder(onExplore: _explore)
            else ...[
              if (showDays) ...[
                const SizedBox(height: TravelSpace.xl),
                for (var i = 0; i < folder.days.length; i++) ...[
                  if (i > 0) const SizedBox(height: TravelSpace.segmentGap),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: TravelSpace.gutter),
                    child: _DayRow(
                      day: folder.days[i],
                      radius: segmentRadius(i, folder.days.length),
                      onTap: _organizing
                          ? null
                          : () => openFolder(context, folder.id,
                              dayId: folder.days[i].id,
                              onOrganize: widget.onOrganize),
                    ),
                  ),
                ],
              ],
              if (grid.isNotEmpty) ...[
                const SizedBox(height: TravelSpace.xxl),
                if (showDays) ...[
                  const ExploreSectionTitle('Sem dia'),
                  const SizedBox(height: TravelSpace.md),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: TravelSpace.gutter),
                  child: LayoutBuilder(builder: (context, box) {
                    const gap = TravelSpace.md;
                    final w = (box.maxWidth - gap) / 2;
                    return Wrap(
                      spacing: gap,
                      runSpacing: TravelSpace.lg,
                      children: [
                        for (final role in grid)
                          SizedBox(
                            width: w,
                            child: _RoleTile(
                              role: role,
                              width: w,
                              organizing: _organizing,
                              selected: _selected.contains(role.id),
                              heroTag: 'pasta-${folder.id}-${role.id}',
                              onTap: _organizing
                                  ? () => _toggle(role.id)
                                  : () => openRole(context, role,
                                      'pasta-${folder.id}-${role.id}'),
                            ),
                          ),
                      ],
                    );
                  }),
                ),
              ] else if (day != null) ...[
                const SizedBox(height: TravelSpace.xxl),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: TravelSpace.content),
                  child: Text('Nenhum rolê neste dia ainda.',
                      style: TravelType.subhead.copyWith(color: p.inkMuted)),
                ),
              ],
            ],
          ],
        );

        final canOrganize = grid.isNotEmpty;
        return Scaffold(
          backgroundColor: p.s0,
          body: AppGlassScope(
            background: ColoredBox(
              color: p.s0,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  content,
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: ProgressiveBlurTop(height: top + 64),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ProgressiveBlurBottom(height: 112 + bottom),
                  ),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: top + 8,
                  left: TravelSpace.gutter,
                  right: TravelSpace.gutter,
                  child: DetailHeader(
                    scroll: _scroll,
                    title: title,
                    backLabel: 'Voltar',
                    onBack: () => Navigator.of(context).maybePop(),
                    trailing: _organizing
                        ? _PillAction(label: 'Concluir', onTap: _stopOrganizing)
                        : null,
                  ),
                ),
                if (folder.roleIds.isNotEmpty)
                  Positioned(
                    left: TravelSpace.xl,
                    right: TravelSpace.xl,
                    bottom: TravelSpace.md + bottom,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 340),
                        child: AnimatedSwitcher(
                          duration: exploreMotion(context, 220),
                          child: _organizing
                              ? PrimaryButton(
                                  key: const ValueKey('mover'),
                                  label: _selected.isEmpty
                                      ? 'Escolha os rolês'
                                      : 'Mover pra um dia',
                                  onPressed: _selected.isEmpty
                                      ? null
                                      : () => _move(folder),
                                )
                              : _FolderBar(
                                  key: const ValueKey('barra'),
                                  onOrganize: canOrganize
                                      ? () =>
                                          setState(() => _organizing = true)
                                      : null,
                                  onMare: widget.onOrganize,
                                ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

String _count(int n) => n == 1 ? '1 rolê' : '$n rolês';

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

/// Dia como seção (ref. seção do Pinterest): capa 56, nome e contagem, em
/// lista segmentada `s1`.
class _DayRow extends StatelessWidget {
  const _DayRow({required this.day, required this.radius, this.onTap});

  final FolderDay day;
  final BorderRadius radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final row = Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: p.s1, borderRadius: radius),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 56,
            child: FolderCover(
              roleIds: day.roleIds,
              // Concêntrico: tile 24 − padding 8 = 16.
              radius: 16,
              mosaic: false,
            ),
          ),
          const SizedBox(width: TravelSpace.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day.label,
                    style: TravelType.headline.copyWith(color: p.ink)),
                Text(_count(day.roleIds.length),
                    style: TravelType.footnote.copyWith(
                        color: p.inkMuted, fontFeatures: TravelType.tabular)),
              ],
            ),
          ),
          FaIcon(TravelIcons.chevronRight, size: 13, color: p.inkMuted),
          const SizedBox(width: 8),
        ],
      ),
    );
    final tap = onTap;
    if (tap == null) return Opacity(opacity: 0.5, child: row);
    return Semantics(
      button: true,
      label: '${day.label}, ${_count(day.roleIds.length)}',
      excludeSemantics: true,
      onTap: tap,
      child: Pressable(onTap: tap, child: row),
    );
  }
}

/// Rolê na grade da pasta. Organizando, o toque escolhe: anel `accent` 1,5
/// e check no canto (regra 15 — anel é estado).
class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.role,
    required this.width,
    required this.organizing,
    required this.selected,
    required this.heroTag,
    required this.onTap,
  });

  final Role role;
  final double width;
  final bool organizing;
  final bool selected;
  final Object heroTag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return Semantics(
      button: true,
      selected: organizing ? selected : null,
      label: role.shortName,
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: heroTag,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(TravelSpace.rCard),
                      child: Image.asset(
                        role.photos.first.asset,
                        fit: BoxFit.cover,
                        cacheWidth: (width * dpr).round(),
                      ),
                    ),
                  ),
                  IgnorePointer(
                    child: AnimatedContainer(
                      duration: exploreMotion(context, 150),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(TravelSpace.rCard),
                        border: Border.all(
                          color: selected ? p.accent : Colors.transparent,
                          width: 1.5,
                          strokeAlign: BorderSide.strokeAlignOutside,
                        ),
                      ),
                    ),
                  ),
                  if (organizing)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: AnimatedContainer(
                        duration: exploreMotion(context, 150),
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected
                              ? p.accent
                              : Colors.black.withValues(alpha: 0.24),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: selected
                            ? const FaIcon(TravelIcons.check,
                                size: 11, color: Colors.white)
                            : null,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: TravelSpace.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(role.shortName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TravelType.cardTitle.copyWith(color: p.ink)),
                  Text(role.neighborhood,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TravelType.footnote.copyWith(color: p.inkMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Barra flutuante de vidro (ref. barra da pasta do Pinterest): organizar à
/// mão ou pedir pra Maré. Mesma pílula da tab bar.
class _FolderBar extends StatelessWidget {
  const _FolderBar({required this.onOrganize, required this.onMare, super.key});

  final VoidCallback? onOrganize;
  final VoidCallback onMare;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return AppGlassSurface(
      radius: 32,
      height: 64,
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: _BarItem(
              icon: FaIcon(TravelIcons.checkSquare, size: 18, color: p.ink),
              label: 'Organizar',
              onTap: onOrganize,
            ),
          ),
          Expanded(
            child: _BarItem(
              icon: const MareMark(size: 20),
              label: 'Organizar com a Maré',
              onTap: onMare,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  const _BarItem({required this.icon, required this.label, this.onTap});

  final Widget icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final tap = onTap;
    final child = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon,
        const SizedBox(height: 4),
        Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TravelType.caption.copyWith(color: p.ink, height: 1.2)),
      ],
    );
    if (tap == null) return Opacity(opacity: 0.4, child: child);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: tap,
      child: Pressable(onTap: tap, child: SizedBox.expand(child: child)),
    );
  }
}

/// "Concluir" no cabeçalho, no círculo/pílula `s1` dos botões de 44.
class _PillAction extends StatelessWidget {
  const _PillAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: Container(
          height: TravelSpace.tap,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: p.s1,
            borderRadius: BorderRadius.circular(TravelSpace.rPill),
          ),
          child: Text(label,
              style: TravelType.subheadStrong.copyWith(color: p.ink)),
        ),
      ),
    );
  }
}

class _EmptyFolder extends StatelessWidget {
  const _EmptyFolder({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          TravelSpace.content, TravelSpace.xxl, TravelSpace.content, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nada nesta viagem ainda.',
              style: TravelType.subhead.copyWith(color: p.inkMuted)),
          const SizedBox(height: TravelSpace.lg),
          SecondaryButton(
            label: 'Explorar rolês',
            expand: false,
            onPressed: onExplore,
          ),
        ],
      ),
    );
  }
}

/// "Mover pra": dias da pasta em lista segmentada, "Sem dia" e "Novo dia".
class _MoveSheet extends StatelessWidget {
  const _MoveSheet({required this.folder, this.exclude});

  static const newDay = '+novo';
  static const noDay = '+sem-dia';

  final SavedFolder folder;

  /// Dia aberto agora (não aparece como destino).
  final String? exclude;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final days = [
      for (final d in folder.days)
        if (d.id != exclude) d,
    ];
    final rows = <(String, String, String?)>[
      for (final d in days) (d.id, d.label, _count(d.roleIds.length)),
      if (exclude != null) (noDay, 'Sem dia', null),
      (newDay, 'Novo dia', null),
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
              title: 'Mover pra',
              onClose: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: TravelSpace.sm),
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) const SizedBox(height: TravelSpace.segmentGap),
              Semantics(
                button: true,
                label: rows[i].$2,
                excludeSemantics: true,
                onTap: () => Navigator.of(context).pop(rows[i].$1),
                child: Pressable(
                  onTap: () => Navigator.of(context).pop(rows[i].$1),
                  child: Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: p.s1,
                      borderRadius: segmentRadius(i, rows.length),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 30,
                          child: FaIcon(
                            switch (rows[i].$1) {
                              newDay => TravelIcons.plus,
                              noDay => TravelIcons.bookmark,
                              _ => TravelIcons.calendar,
                            },
                            size: 18,
                            color: p.ink,
                          ),
                        ),
                        const SizedBox(width: TravelSpace.sm),
                        Expanded(
                          child: Text(
                            rows[i].$2,
                            style: TravelType.headline.copyWith(color: p.ink),
                          ),
                        ),
                        if (rows[i].$3 != null)
                          Text(rows[i].$3!,
                              style: TravelType.footnote.copyWith(
                                  color: p.inkMuted,
                                  fontFeatures: TravelType.tabular)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
