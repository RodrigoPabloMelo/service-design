import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:studio_app/features/traveler/presentation/view_models/traveler_cubit.dart';
import 'package:studio_app/features/traveler/presentation/widgets/account_sheet.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/features/explore/data/explore_mock.dart';
import 'package:studio_app/features/explore/domain/explore_entities.dart';
import 'package:studio_app/features/explore/presentation/view_models/search_cubit.dart';
import 'package:studio_app/features/explore/presentation/views/role_page.dart';
import 'package:studio_app/features/explore/presentation/views/search_page.dart';
import 'package:studio_app/features/explore/presentation/widgets/explore_cards.dart';
import 'package:studio_app/features/explore/presentation/widgets/explore_ui.dart';
import 'package:studio_app/features/explore/presentation/widgets/filter_pickers.dart';
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
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: exploreMotion(context, 260),
                  switchInCurve: kExploreEase,
                  child: results.isEmpty
                      // Vazio ocupa a tela: conteúdo no centro, ações
                      // embaixo, perto do polegar.
                      ? _Empty(
                          key: const ValueKey('vazio'),
                          state: s,
                          top: top + 80,
                          bottom: bottom,
                        )
                      : CustomScrollView(
                          key: const ValueKey('lista'),
                          controller: _scroll,
                          slivers: [
                            SliverToBoxAdapter(
                                child: SizedBox(height: top + 84)),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: TravelSpace.content),
                                child: AnimatedSwitcher(
                                  duration: exploreMotion(context, 200),
                                  layoutBuilder: (current, previous) =>
                                      Stack(
                                    alignment: Alignment.centerLeft,
                                    children: [
                                      ...previous,
                                      if (current != null) current,
                                    ],
                                  ),
                                  child: Text(
                                    rolesCount(results.length),
                                    key: ValueKey(results.length),
                                    style: TravelType.title1.copyWith(
                                        color: p.ink,
                                        fontFeatures: TravelType.tabular),
                                  ),
                                ),
                              ),
                            ),
                            const SliverToBoxAdapter(
                                child: SizedBox(height: TravelSpace.xl)),
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                  TravelSpace.gutter,
                                  0,
                                  TravelSpace.gutter,
                                  TravelSpace.xxl + bottom),
                              sliver: SliverToBoxAdapter(
                                child: AnimatedSwitcher(
                                  duration: exploreMotion(context, 260),
                                  switchInCurve: kExploreEase,
                                  layoutBuilder: (current, previous) =>
                                      Stack(
                                    alignment: Alignment.topCenter,
                                    children: [
                                      ...previous,
                                      if (current != null) current,
                                    ],
                                  ),
                                  child: _ResultList(
                                    key: ValueKey(
                                        results.map((r) => r.id).join()),
                                    roles: results,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ProgressiveBlurTop(height: top + 80),
              ),
              Positioned(
                top: top + 8,
                left: TravelSpace.gutter,
                right: TravelSpace.gutter,
                // Três containers separados (mesma altura, 56): voltar,
                // resumo da busca (toque reabre; recebe a pílula em Hero) e
                // filtrar com contador.
                child: Row(
                  children: [
                    RoundButton(
                      size: 56,
                      label: 'Voltar',
                      onTap: () => Navigator.of(context).maybePop(),
                      icon: const FaIcon(TravelIcons.back),
                    ),
                    const SizedBox(width: TravelSpace.sm),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Hero(
                                tag: kSearchHero,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: p.s1,
                                    borderRadius: BorderRadius.circular(
                                        TravelSpace.rComposer),
                                  ),
                                ),
                              ),
                            ),
                            _Summary(query: s.query, onTap: _editSearch),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: TravelSpace.sm),
                    RoundButton(
                      size: 56,
                      label: 'Filtrar',
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
    // Ref. Airbnb: onde em cima; quando, com quem e tipo embaixo.
    final line1 = placeLabel(query);
    final line2 = [
      if (query.hasDates || query.isFlexible) dayLabel(query),
      companyLabel(query.company),
      if (query.categories.isNotEmpty) categoriesLabel(query.categories),
    ].join(', ');
    return Semantics(
      button: true,
      label: 'Editar busca: $line1. $line2',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: SizedBox(
          height: 56,
          child: Stack(
            children: [
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
    return BlocSelector<TravelerCubit, TravelerState, List<String>>(
      bloc: travelerCubit(),
      selector: (s) => s.saved,
      builder: (context, saved) => Column(
        children: [
          for (var i = 0; i < roles.length; i++) ...[
            if (i > 0) const SizedBox(height: TravelSpace.xxl),
            Reveal(
              index: i,
              child: RoleResultCard(
                role: roles[i],
                heroTag: 'busca-${roles[i].id}',
                saved: saved.contains(roles[i].id),
                distance:
                    'a ${formatKm(distanceKm(stay, roles[i].location))}',
                onTap: () =>
                    openRole(context, roles[i], 'busca-${roles[i].id}'),
                onToggleSave: () => saveRole(context, roles[i].id),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Sem resultado: diz que a base curada não cobre (D-07), sem completar
/// com rolê genérico. Ilustração + o que afrouxar, cada opção com quantos
/// rolês curados ela traria (contagem real da base).
class _Empty extends StatelessWidget {
  const _Empty({
    required this.state,
    required this.top,
    required this.bottom,
    super.key,
  });

  final SearchState state;

  /// Espaço do cabeçalho flutuante e da área segura de baixo.
  final double top;
  final double bottom;

  int _count(SearchQuery q, ExploreFilters f) => searchRoles(
        roles: ExploreMock.roles,
        tags: ExploreMock.tags,
        stay: ExploreMock.profile.stayLocation,
        query: q,
        filters: f,
        cityOf: ExploreMock.cityOf,
      ).length;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final cubit = context.read<SearchCubit>();
    final q = state.query;
    final f = state.filters;
    final hasFilters = f.count + q.categories.length > 0;
    final hasWhen = q.hasDates || q.isFlexible;
    final city = q.place;

    final title = city == 'Olinda'
        ? 'Olinda ainda não tem rolês curados'
        : hasFilters
            ? 'Nenhum rolê com esses filtros'
            : 'Ainda não temos rolês curados assim';

    // O que afrouxar, só se trouxer algum rolê.
    final options = <(String, int, VoidCallback)>[
      if (hasFilters)
        (
          'Limpar filtros',
          _count(q.copyWith(categories: const {}), const ExploreFilters()),
          cubit.clearFiltersAndTypes,
        ),
      if (hasWhen)
        (
          'Qualquer dia',
          _count(
              q.copyWith(
                start: () => null,
                end: () => null,
                flexStay: () => null,
                flexMonth: () => null,
              ),
              f),
          cubit.clearWhen,
        ),
      if (city != null && city != 'Recife')
        (
          'Buscar em Recife',
          _count(q.copyWith(place: () => 'Recife'), f),
          () => cubit.setPlace('Recife'),
        ),
    ].where((o) => o.$2 > 0).toList();

    return Padding(
      // Ações com respiro da borda de baixo (não coladas no gesto).
      padding: EdgeInsets.fromLTRB(TravelSpace.gutter, top, TravelSpace.gutter,
          40 + bottom),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: TravelSpace.cardPad),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _EmptyIllustration(),
                    const SizedBox(height: TravelSpace.xl),
                    Text(title,
                        textAlign: TextAlign.center,
                        style: TravelType.title2.copyWith(color: p.ink)),
                    const SizedBox(height: TravelSpace.sm),
                    Text(
                      'Só mostramos o que foi indicado por quem é daqui.',
                      textAlign: TextAlign.center,
                      style: TravelType.subhead.copyWith(color: p.inkMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
          for (final (i, o) in options.indexed) ...[
            if (i > 0) const SizedBox(height: TravelSpace.md),
            _RelaxRow(label: o.$1, count: o.$2, onTap: o.$3),
          ],
          if (options.isNotEmpty) const SizedBox(height: TravelSpace.md),
          SecondaryButton(
            label: 'Mudar a busca',
            onPressed: () => Navigator.of(context).push(exploreRoute(
              context,
              withExplore(context, const SearchPage(editing: true)),
            )),
          ),
        ],
      ),
    );
  }
}

/// Mapa dobrado com o caminho pontilhado e o pino "sem lugar" por cima,
/// num círculo `accentSoft`.
class _EmptyIllustration extends StatelessWidget {
  const _EmptyIllustration();

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final ink = ColorFilter.mode(p.accent, BlendMode.srcIn);
    return Container(
      width: 136,
      height: 136,
      decoration: BoxDecoration(color: p.accentSoft, shape: BoxShape.circle),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset('assets/icons/places/vazio.svg',
              width: 96, height: 96, colorFilter: ink),
          Positioned(
            right: 30,
            top: 26,
            // Fundo do pino na cor do círculo: esconde as linhas do mapa.
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                  color: p.accentSoft,
                  borderRadius: BorderRadius.circular(16)),
              child: SvgPicture.asset('assets/icons/places/pino_vazio.svg',
                  width: 30, height: 38, colorFilter: ink),
            ),
          ),
        ],
      ),
    );
  }
}

/// Opção pra afrouxar a busca: contorno (regra 15), rótulo, quantos rolês
/// traria e seta.
class _RelaxRow extends StatelessWidget {
  const _RelaxRow({
    required this.label,
    required this.count,
    required this.onTap,
  });

  final String label;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Semantics(
      button: true,
      label: '$label, ${rolesCount(count)}',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: outlineChoiceDecoration(p,
              selected: false, radius: TravelSpace.rInner),
          child: Row(
            children: [
              Expanded(
                child: Text(label,
                    style: TravelType.subheadStrong.copyWith(color: p.ink)),
              ),
              Text(rolesCount(count),
                  style: TravelType.subhead.copyWith(
                      color: p.inkMuted, fontFeatures: TravelType.tabular)),
              const SizedBox(width: TravelSpace.sm),
              FaIcon(TravelIcons.chevronRight, size: 12, color: p.inkMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sheet "Filtros" (ref. Airbnb): aplica ao vivo; o primário mostra quantos
/// rolês sobram. Sem filtro de segurança — critérios em aberto (Q-10).
class FilterSheet extends StatelessWidget {
  const FilterSheet({super.key});

  /// Respiro entre as seções do sheet.
  static const _gap = 40.0;

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
                                icon: TravelIcons.cloud,
                                label: 'Coberto',
                                selected: f.covered,
                                onTap: cubit.toggleCovered,
                              ),
                            ),
                            const SizedBox(width: TravelSpace.sm),
                            Expanded(
                              child: _ToggleTile(
                                icon: TravelIcons.money,
                                label: 'Grátis',
                                selected: f.free,
                                onTap: cubit.toggleFree,
                              ),
                            ),
                            const SizedBox(width: TravelSpace.sm),
                            Expanded(
                              child: _ToggleTile(
                                icon: TravelIcons.home,
                                label: 'Perto do hotel',
                                selected: f.nearHotel,
                                onTap: cubit.toggleNearHotel,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: _gap),
                        const _Label('Período'),
                        DayArcPicker(
                          value: f.period,
                          onChanged: cubit.setPeriod,
                        ),
                        const SizedBox(height: _gap),
                        const _Label('Preço por pessoa'),
                        PriceRangePicker(
                          prices: [
                            for (final t in ExploreMock.tags.values)
                              t.priceFrom,
                          ],
                          min: f.priceMin,
                          max: f.priceMax,
                          onChanged: cubit.setPriceRange,
                        ),
                        const SizedBox(height: _gap),
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
            TravelSpace.cardPad, 0, TravelSpace.cardPad, TravelSpace.md),
        child: Text(text,
            style: TravelType.section
                .copyWith(color: TravelPalette.of(context).inkMuted)),
      );
}

/// Tile de "Pra você": ícone leve (regular, cinza) + rótulo. Selecionado
/// continua branco, só com o anel `accent` (tint azul se misturava).
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
          height: 104,
          padding: const EdgeInsets.fromLTRB(
              TravelSpace.lg, 18, TravelSpace.lg, TravelSpace.lg),
          decoration: selectionDecoration(p,
              selected: selected, fill: p.s1, radius: TravelSpace.rCard),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FaIcon(icon, size: 20, color: p.inkMuted),
              Text(
                label,
                maxLines: 2,
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
