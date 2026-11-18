import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/features/explore/data/explore_mock.dart';
import 'package:studio_app/features/explore/domain/explore_entities.dart';
import 'package:studio_app/features/explore/presentation/view_models/explore_cubit.dart';
import 'package:studio_app/features/explore/presentation/view_models/explore_state.dart';
import 'package:studio_app/features/explore/presentation/view_models/search_cubit.dart';
import 'package:studio_app/features/explore/presentation/views/role_page.dart';
import 'package:studio_app/features/explore/presentation/views/search_page.dart';
import 'package:studio_app/features/explore/presentation/widgets/explore_cards.dart';
import 'package:studio_app/features/explore/presentation/widgets/explore_ui.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';

/// Resultados da busca: lista curta da base curada (sem feed infinito),
/// resumo da busca no topo (toque reabre a busca) e filtros depois.
class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({super.key});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _editSearch() => Navigator.of(context).push(exploreRoute(
        context,
        withExplore(context, const SearchPage(editing: true)),
        origin: Alignment.topCenter,
      ));

  void _openFilters() {
    final p = TravelPalette.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: p.s0,
      barrierColor: Colors.black.withValues(alpha: 0.32),
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(TravelSpace.rSheet)),
      ),
      builder: (_) => withExplore(context, const FilterSheet()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: p.s0,
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, s) {
          final results = s.results;
          return Stack(
            children: [
              CustomScrollView(
                controller: _scroll,
                slivers: [
                  SliverToBoxAdapter(child: SizedBox(height: top + 68)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: TravelSpace.content),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedSwitcher(
                            duration: exploreMotion(context, 200),
                            child: Text(
                              rolesCount(results.length),
                              key: ValueKey(results.length),
                              style: TravelType.title1.copyWith(
                                  color: p.ink,
                                  fontFeatures: TravelType.tabular),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                      child: SizedBox(height: TravelSpace.xl)),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(TravelSpace.gutter, 0,
                        TravelSpace.gutter, TravelSpace.xxl + bottom),
                    sliver: SliverToBoxAdapter(
                      child: AnimatedSwitcher(
                        duration: exploreMotion(context, 260),
                        switchInCurve: kExploreEase,
                        layoutBuilder: (current, previous) => Stack(
                          alignment: Alignment.topCenter,
                          children: [...previous, if (current != null) current],
                        ),
                        child: results.isEmpty
                            ? _Empty(
                                key: const ValueKey('vazio'),
                                hasFilters: s.filters.count +
                                        s.query.categories.length >
                                    0,
                              )
                            : _ResultList(
                                key: ValueKey(results.map((r) => r.id).join()),
                                roles: results,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ProgressiveBlurTop(height: top + 72),
              ),
              Positioned(
                top: top + 8,
                left: TravelSpace.gutter,
                right: TravelSpace.gutter,
                child: Row(
                  children: [
                    RoundButton(
                      label: 'Voltar',
                      onTap: () => Navigator.of(context).maybePop(),
                      icon: const FaIcon(TravelIcons.back),
                    ),
                    const SizedBox(width: TravelSpace.sm),
                    Expanded(
                      child: _Summary(query: s.query, onTap: _editSearch),
                    ),
                    const SizedBox(width: TravelSpace.sm),
                    RoundButton(
                      label: 'Filtros',
                      badge: s.filters.count + s.query.categories.length,
                      onTap: _openFilters,
                      icon: const FaIcon(TravelIcons.sliders),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.query, required this.onTap});

  final SearchQuery query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final line1 = [
      placeLabel(query),
      if (query.day != null) ExploreMock.tripDaysShort[query.day!],
      companyLabel(query.company).toLowerCase(),
    ].join(', ');
    final line2 = categoriesLabel(query.categories);
    return Semantics(
      button: true,
      label: 'Editar busca: $line1. $line2',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Stack(
            children: [
              Positioned.fill(
                child: Hero(
                  tag: kSearchHero,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: p.s1,
                      borderRadius: BorderRadius.circular(TravelSpace.rCard),
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(line1,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TravelType.footnoteStrong
                              .copyWith(color: p.ink, height: 1.25)),
                      Text(line2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TravelType.caption
                              .copyWith(color: p.inkMuted, height: 1.25)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultList extends StatelessWidget {
  const _ResultList({required this.roles, super.key});

  final List<Role> roles;

  @override
  Widget build(BuildContext context) {
    final stay = ExploreMock.profile.stayLocation;
    return BlocSelector<ExploreCubit, ExploreState, Set<String>>(
      selector: (s) => s.saved,
      builder: (context, saved) => Column(
        children: [
          for (var i = 0; i < roles.length; i++) ...[
            if (i > 0) const SizedBox(height: TravelSpace.xxl),
            Reveal(
              index: i,
              child: RoleCard(
                role: roles[i],
                heroTag: 'busca-${roles[i].id}',
                saved: saved.contains(roles[i].id),
                photoAspect: 16 / 11,
                meta: '${roles[i].neighborhood}, ${roles[i].price}, '
                    'a ${formatKm(distanceKm(stay, roles[i].location))} do hotel',
                onTap: () =>
                    openRole(context, roles[i], 'busca-${roles[i].id}'),
                onToggleSave: () =>
                    context.read<ExploreCubit>().toggleSaved(roles[i].id),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Sem resultado: diz que a base curada não cobre (D-07), sem completar.
class _Empty extends StatelessWidget {
  const _Empty({required this.hasFilters, super.key});

  final bool hasFilters;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final cubit = context.read<SearchCubit>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TravelSpace.cardPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ainda não temos rolês curados assim',
              style: TravelType.title3.copyWith(color: p.ink)),
          const SizedBox(height: TravelSpace.sm),
          Text(
            'Só mostramos o que foi indicado por quem é daqui.',
            style: TravelType.subhead.copyWith(color: p.inkMuted),
          ),
          const SizedBox(height: TravelSpace.xl),
          SecondaryButton(
            label: hasFilters ? 'Limpar filtros' : 'Mudar a busca',
            onPressed: hasFilters
                ? cubit.clearFiltersAndTypes
                : () => Navigator.of(context).push(exploreRoute(
                      context,
                      withExplore(context, const SearchPage(editing: true)),
                    )),
          ),
        ],
      ),
    );
  }
}

/// Sheet "Filtros" (ref. Airbnb): aplica ao vivo; o primário mostra quantos
/// rolês sobram. Sem filtro de segurança — critérios em aberto (Q-10).
class FilterSheet extends StatelessWidget {
  const FilterSheet({super.key});

  static const _periods = [
    null,
    StopPeriod.manha,
    StopPeriod.tarde,
    StopPeriod.noite
  ];
  static const _prices = [null, PriceBand.gratis, PriceBand.um, PriceBand.dois];

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final cubit = context.read<SearchCubit>();
    final bottom = MediaQuery.paddingOf(context).bottom;
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, s) {
        final f = s.filters;
        final n = s.results.length;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: TravelSpace.gutter),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: TravelSpace.sm),
              SheetBar(
                title: 'Filtros',
                leading:
                    TextAction('Limpar', onTap: cubit.clearFiltersAndTypes),
                onClose: () => Navigator.of(context).maybePop(),
              ),
              Flexible(
                child: VerticalEdgeFade(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: TravelSpace.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _Label('Pra você'),
                        Row(
                          children: [
                            Expanded(
                              child: _ToggleTile(
                                icon: TravelIcons.rain,
                                label: 'Coberto',
                                selected: f.covered,
                                onTap: cubit.toggleCovered,
                              ),
                            ),
                            const SizedBox(width: TravelSpace.sm),
                            Expanded(
                              child: _ToggleTile(
                                icon: TravelIcons.ticket,
                                label: 'Grátis',
                                selected: f.free,
                                onTap: cubit.toggleFree,
                              ),
                            ),
                            const SizedBox(width: TravelSpace.sm),
                            Expanded(
                              child: _ToggleTile(
                                icon: TravelIcons.place,
                                label: 'Perto do hotel',
                                selected: f.nearHotel,
                                onTap: cubit.toggleNearHotel,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: TravelSpace.xl),
                        const _Label('Período'),
                        PillSegmented(
                          labels: const ['Qualquer', 'Manhã', 'Tarde', 'Noite'],
                          index: _periods.indexOf(f.period),
                          onChanged: (i) => cubit.setPeriod(_periods[i]),
                        ),
                        const SizedBox(height: TravelSpace.xl),
                        const _Label('Preço'),
                        PillSegmented(
                          labels: const ['Qualquer', 'Grátis', r'$', r'$$'],
                          semanticLabels: const [
                            'Qualquer preço',
                            'Grátis',
                            'Barato',
                            'Médio'
                          ],
                          index: _prices.indexOf(f.price),
                          onChanged: (i) => cubit.setPrice(_prices[i]),
                        ),
                        const SizedBox(height: TravelSpace.xl),
                        const _Label('Tipo de rolê'),
                        Wrap(
                          spacing: TravelSpace.sm,
                          runSpacing: TravelSpace.sm,
                          children: [
                            for (final info in ExploreMock.categories)
                              ExploreChip(
                                label: info.label,
                                onCard: false,
                                selected:
                                    s.query.categories.contains(info.category),
                                leading: CategoryIcon(info.category,
                                    color: p.ink, size: 22),
                                onTap: () =>
                                    cubit.toggleCategory(info.category),
                              ),
                          ],
                        ),
                        const SizedBox(height: TravelSpace.xl),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: TravelSpace.sm, bottom: TravelSpace.md + bottom),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: n.toDouble()),
                  duration: exploreMotion(context, 260),
                  curve: kExploreEase,
                  builder: (context, v, _) => PrimaryButton(
                    label: 'Mostrar ${rolesCount(v.round())}',
                    onPressed:
                        n == 0 ? null : () => Navigator.of(context).maybePop(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(
            TravelSpace.cardPad, 0, TravelSpace.cardPad, TravelSpace.sm),
        child: Text(text,
            style: TravelType.section
                .copyWith(color: TravelPalette.of(context).inkMuted)),
      );
}

/// Tile de "Pra você": ícone + rótulo, selecionado em `accentSoft`.
class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
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
        child: AnimatedContainer(
          duration: exploreMotion(context, 150),
          curve: kExploreEase,
          height: 88,
          padding: const EdgeInsets.all(TravelSpace.cardPad),
          decoration: BoxDecoration(
            color: selected ? p.accentSoft : p.s1,
            borderRadius: BorderRadius.circular(TravelSpace.rCard),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FaIcon(icon, size: 18, color: p.ink),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TravelType.footnoteStrong.copyWith(color: p.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
