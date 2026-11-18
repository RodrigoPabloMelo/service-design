import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/core/components/glass/app_glass.dart';
import 'package:studio_app/features/explore/data/explore_mock.dart';
import 'package:studio_app/features/explore/domain/explore_entities.dart';
import 'package:studio_app/features/explore/presentation/view_models/explore_cubit.dart';
import 'package:studio_app/features/explore/presentation/view_models/explore_state.dart';
import 'package:studio_app/features/explore/presentation/view_models/search_cubit.dart';
import 'package:studio_app/features/explore/presentation/views/role_page.dart';
import 'package:studio_app/features/explore/presentation/views/search_page.dart';
import 'package:studio_app/features/explore/presentation/views/search_results_page.dart';
import 'package:studio_app/features/explore/presentation/widgets/explore_cards.dart';
import 'package:studio_app/features/explore/presentation/widgets/explore_ui.dart';
import 'package:studio_app/features/explore/presentation/widgets/glass_tab_bar.dart';
import 'package:studio_app/features/travel_agent/presentation/views/travel_agent_page.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/mare_mark.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';

/// Tela inicial "Explorar": busca guiada + Maré no topo, categorias e
/// seções curtas que mudam com a hora e o perfil. Tab bar de vidro com
/// Explorar, Salvos e Perfil (as duas últimas ainda não construídas).
class ExplorePage extends StatelessWidget {
  const ExplorePage({this.scenario = ExploreScenario.padrao, super.key});

  final ExploreScenario scenario;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: travelTheme(context),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ExploreCubit(scenario: scenario)),
          BlocProvider(create: (_) => SearchCubit()),
        ],
        child: const _ExploreView(),
      ),
    );
  }
}

class _ExploreView extends StatefulWidget {
  const _ExploreView();

  @override
  State<_ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<_ExploreView> {
  bool _barVisible = true;

  static const _tabs = [
    GlassTabItem(TravelIcons.compass, 'Explorar'),
    GlassTabItem(TravelIcons.bookmark, 'Salvos'),
    GlassTabItem(TravelIcons.user, 'Perfil'),
  ];

  bool _onScroll(UserScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    final show =
        n.direction == ScrollDirection.forward || n.metrics.pixels <= 0;
    final hide = n.direction == ScrollDirection.reverse;
    if (show && !_barVisible) setState(() => _barVisible = true);
    if (hide && _barVisible) setState(() => _barVisible = false);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: p.s0,
      body: BlocBuilder<ExploreCubit, ExploreState>(
        buildWhen: (a, b) => a.tab != b.tab,
        builder: (context, s) {
          final cubit = context.read<ExploreCubit>();
          return AppGlassScope(
            background: ColoredBox(
              color: p.s0,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  for (final tab in ExploreTab.values)
                    _FadeThrough(
                      active: s.tab == tab,
                      child: switch (tab) {
                        ExploreTab.explorar =>
                          NotificationListener<UserScrollNotification>(
                            onNotification: _onScroll,
                            child: const _HomeTab(),
                          ),
                        ExploreTab.salvos => const _Placeholder(
                            icon: TravelIcons.bookmark,
                            title: 'Salvos',
                            line: 'Suas pastas de rolês vão ficar aqui.',
                          ),
                        ExploreTab.perfil => const _Placeholder(
                            icon: TravelIcons.user,
                            title: 'Perfil',
                            line: 'Em breve.',
                          ),
                      },
                    ),
                  // Scroll edge effect atrás da tab bar.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ProgressiveBlurBottom(height: 112 + bottom),
                  ),
                ],
              ),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    TravelSpace.xl, 0, TravelSpace.xl, TravelSpace.md + bottom),
                child: AnimatedSlide(
                  offset: _barVisible || s.tab != ExploreTab.explorar
                      ? Offset.zero
                      : const Offset(0, 1.6),
                  duration: exploreMotion(context, 320),
                  curve: kExploreEase,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 340),
                    child: GlassTabBar(
                      items: _tabs,
                      index: s.tab.index,
                      onChanged: (i) {
                        setState(() => _barVisible = true);
                        cubit.selectTab(ExploreTab.values[i]);
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Troca de aba em fade-through (opacidade + escala 0.98), mantendo o
/// estado de cada aba.
class _FadeThrough extends StatelessWidget {
  const _FadeThrough({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final d = exploreMotion(context, 220);
    return IgnorePointer(
      ignoring: !active,
      child: ExcludeSemantics(
        excluding: !active,
        child: AnimatedOpacity(
          opacity: active ? 1 : 0,
          duration: d,
          curve: kExploreEase,
          child: AnimatedScale(
            scale: active ? 1 : 0.98,
            duration: d,
            curve: kExploreEase,
            child: TickerMode(enabled: active, child: child),
          ),
        ),
      ),
    );
  }
}

// ── Aba Explorar ─────────────────────────────────────────────────────────

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  static const _cardW = 248.0;
  static const _rowH = _cardW * 4 / 5 + 132;

  void _openSearch() {
    context.read<SearchCubit>().start();
    Navigator.of(context).push(exploreRoute(
      context,
      withExplore(context, const SearchPage()),
      origin: Alignment.topCenter,
    ));
  }

  void _openCategory(ExploreCategory c) {
    context.read<SearchCubit>().startWithCategory(c);
    Navigator.of(context).push(exploreRoute(
      context,
      withExplore(context, const SearchResultsPage()),
    ));
  }

  void _openAgent() {
    Navigator.of(context).push(exploreRoute(
      context,
      const TravelAgentPage(),
      origin: Alignment.topRight,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return BlocBuilder<ExploreCubit, ExploreState>(
      buildWhen: (a, b) =>
          a.status != b.status ||
          a.sections != b.sections ||
          a.saved != b.saved,
      builder: (context, s) {
        final Widget content = switch (s.status) {
          ExploreStatus.loading => _Skeleton(top: top),
          ExploreStatus.error =>
            _ErrorView(onRetry: context.read<ExploreCubit>().retry),
          ExploreStatus.ready => _content(context, s, top, bottom),
        };
        return Stack(
          children: [
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: exploreMotion(context, 260),
                child: KeyedSubtree(key: ValueKey(s.status), child: content),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ProgressiveBlurTop(height: top + 84),
            ),
            Positioned(
              top: top + 8,
              left: TravelSpace.gutter,
              right: TravelSpace.gutter,
              child: _Header(onSearch: _openSearch, onAgent: _openAgent),
            ),
          ],
        );
      },
    );
  }

  Widget _content(
      BuildContext context, ExploreState s, double top, double bottom) {
    final cubit = context.read<ExploreCubit>();
    final stay = ExploreMock.profile.stayLocation;
    return ListView(
      padding: EdgeInsets.only(top: top + 80, bottom: 120 + bottom),
      children: [
        Reveal(
          index: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ExploreSectionTitle('Explore rolês'),
              const SizedBox(height: TravelSpace.md),
              EdgeFadeScroll(
                height: CategoryCard.height,
                itemCount: ExploreMock.categories.length,
                itemBuilder: (context, i) => CategoryCard(
                  info: ExploreMock.categories[i],
                  onTap: () =>
                      _openCategory(ExploreMock.categories[i].category),
                ),
              ),
            ],
          ),
        ),
        for (var si = 0; si < s.sections.length; si++) ...[
          const SizedBox(height: TravelSpace.xxl),
          Reveal(
            index: si + 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExploreSectionTitle(s.sections[si].title),
                const SizedBox(height: TravelSpace.md),
                EdgeFadeScroll(
                  height: _rowH,
                  spacing: TravelSpace.md,
                  itemCount: s.sections[si].roleIds.length,
                  itemBuilder: (context, i) {
                    final section = s.sections[si];
                    final role = ExploreMock.roleById(section.roleIds[i]);
                    final tag = '${section.id}-${role.id}';
                    return RoleCard(
                      role: role,
                      width: _cardW,
                      heroTag: tag,
                      saved: s.saved.contains(role.id),
                      meta: section.showDistance
                          ? 'a ${formatKm(distanceKm(stay, role.location))} '
                              'do hotel'
                          : null,
                      onTap: () => openRole(context, role, tag),
                      onToggleSave: () => cubit.toggleSaved(role.id),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Topo: pílula de busca no meio e a Maré à direita.
class _Header extends StatelessWidget {
  const _Header({required this.onSearch, required this.onAgent});

  final VoidCallback onSearch;
  final VoidCallback onAgent;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            label: 'Inicie sua pesquisa',
            excludeSemantics: true,
            onTap: onSearch,
            child: Pressable(
              onTap: onSearch,
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
                            borderRadius:
                                BorderRadius.circular(TravelSpace.rComposer),
                          ),
                        ),
                      ),
                    ),
                    // Ref. Airbnb: lupa + "Inicie sua pesquisa" no centro.
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(TravelIcons.search, size: 16, color: p.ink),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text('Inicie sua pesquisa',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TravelType.headline
                                    .copyWith(color: p.ink, height: 1.2)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: TravelSpace.sm),
        Semantics(
          button: true,
          label: 'Abrir a Maré',
          excludeSemantics: true,
          onTap: onAgent,
          child: Pressable(
            onTap: onAgent,
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: p.s1, shape: BoxShape.circle),
              child: const MareMark(size: 28),
            ),
          ),
        ),
      ],
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.top});

  final double top;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: top + 80),
        children: [
          SizedBox(
            height: CategoryCard.height,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: TravelSpace.gutter),
              itemCount: 4,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: TravelSpace.sm),
              itemBuilder: (_, __) => const SkeletonBox(
                width: CategoryCard.width,
                height: CategoryCard.height,
                radius: TravelSpace.rCard,
              ),
            ),
          ),
          const SizedBox(height: TravelSpace.xxl),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: TravelSpace.content),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SkeletonBox(width: 160, height: 20),
            ),
          ),
          const SizedBox(height: TravelSpace.md),
          SizedBox(
            height: _HomeTabState._rowH,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: TravelSpace.gutter),
              itemCount: 2,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: TravelSpace.md),
              itemBuilder: (_, __) => const RoleCardSkeleton(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: TravelSpace.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sem conexão agora',
                textAlign: TextAlign.center,
                style: TravelType.title2.copyWith(color: p.ink)),
            const SizedBox(height: TravelSpace.sm),
            Text(
              'Os rolês voltam assim que a internet voltar.',
              textAlign: TextAlign.center,
              style: TravelType.subhead.copyWith(color: p.inkMuted),
            ),
            const SizedBox(height: TravelSpace.xl),
            SecondaryButton(label: 'Tentar de novo', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.icon,
    required this.title,
    required this.line,
  });

  final FaIconData icon;
  final String title;
  final String line;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 28, color: p.inkMuted),
          const SizedBox(height: TravelSpace.md),
          Text(title, style: TravelType.title2.copyWith(color: p.ink)),
          const SizedBox(height: TravelSpace.xs),
          Text(line, style: TravelType.subhead.copyWith(color: p.inkMuted)),
        ],
      ),
    );
  }
}
