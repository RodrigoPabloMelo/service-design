import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/core/components/glass/app_glass.dart';
import 'package:studio_app/features/explore/data/explore_mock.dart';
import 'package:studio_app/features/explore/domain/explore_entities.dart';
import 'package:studio_app/features/explore/presentation/view_models/explore_cubit.dart';
import 'package:studio_app/features/explore/presentation/view_models/explore_state.dart';
import 'package:studio_app/features/explore/presentation/view_models/search_cubit.dart';
import 'package:studio_app/features/explore/presentation/views/profile_tab.dart';
import 'package:studio_app/features/explore/presentation/views/role_page.dart';
import 'package:studio_app/features/explore/presentation/views/saved_tab.dart';
import 'package:studio_app/features/explore/presentation/views/search_page.dart';
import 'package:studio_app/features/explore/presentation/views/search_results_page.dart';
import 'package:studio_app/features/explore/presentation/widgets/explore_cards.dart';
import 'package:studio_app/features/explore/presentation/widgets/explore_ui.dart';
import 'package:studio_app/features/explore/presentation/widgets/shorts_shelf.dart';
import 'package:studio_app/features/explore/presentation/widgets/glass_tab_bar.dart';
import 'package:studio_app/features/travel_agent/presentation/views/travel_agent_page.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/mare_mark.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';
import 'package:studio_app/features/traveler/presentation/view_models/traveler_cubit.dart';
import 'package:studio_app/features/traveler/presentation/widgets/account_sheet.dart';
import 'package:studio_app/features/traveler/presentation/widgets/transfer_sheets.dart';

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
          BlocProvider(
            create: (_) {
              final cubit = ExploreCubit(scenario: scenario);
              // `?aba=salvos` (vindo da gaveta da Maré) abre já na aba.
              final tab = _tabFromUrl(context);
              if (tab != null) cubit.selectTab(tab);
              return cubit;
            },
          ),
          BlocProvider(create: (_) => SearchCubit()),
        ],
        child: const _ExploreView(),
      ),
    );
  }
}

ExploreTab? _tabFromUrl(BuildContext context) {
  try {
    final aba = GoRouterState.of(context).uri.queryParameters['aba'];
    return ExploreTab.values.where((t) => t.name == aba).firstOrNull;
  } on Object {
    return null; // fora do go_router (testes, rota empilhada)
  }
}

/// Abre a Maré entrando da direita (push do iOS, não fade); a gaveta dela
/// pode devolver uma aba pra abrir.
Future<void> openAgent(BuildContext context) async {
  final explore = context.read<ExploreCubit>();
  final tab = await Navigator.of(context).push<ExploreTab>(
    slideRouteOf<ExploreTab>(context, const TravelAgentPage()),
  );
  if (tab != null && !explore.isClosed) explore.selectTab(tab);
}

class _ExploreView extends StatefulWidget {
  const _ExploreView();

  @override
  State<_ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<_ExploreView>
    with SingleTickerProviderStateMixin {
  /// 0 = expandido (tab bar à vista, busca larga); 1 = recolhido (tab bar e
  /// blur do rodapé fora da tela, busca compacta). Um controle só pra tudo
  /// andar junto, na mesma curva.
  late final AnimationController _collapse =
      AnimationController(vsync: this, duration: _kCollapseDuration);
  late final Animation<double> _collapseT =
      CurvedAnimation(parent: _collapse, curve: kExploreEase);

  static const _kCollapseDuration = Duration(milliseconds: 320);

  static const _tabs = [
    GlassTabItem(TravelIcons.compass, 'Explorar'),
    GlassTabItem(TravelIcons.bookmark, 'Salvos'),
    GlassTabItem(TravelIcons.user, 'Perfil'),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _collapse.duration = exploreMotion(context, 320);
  }

  @override
  void dispose() {
    _collapse.dispose();
    super.dispose();
  }

  void _expand() {
    if (_collapse.status != AnimationStatus.dismissed &&
        _collapse.status != AnimationStatus.reverse) {
      _collapse.reverse();
    }
  }

  /// Rolagem acumulada na mesma direção; só troca de estado depois de
  /// [_kFlipAfter] px, pra tremidinha do dedo não piscar a barra.
  double _drift = 0;
  static const _kFlipAfter = 8.0;

  // Pelo delta (e não por `UserScrollNotification`): vale pra toque,
  // trackpad e roda do mouse.
  bool _onScroll(ScrollUpdateNotification n) {
    if (n.metrics.axis != Axis.vertical || n.depth != 0) return false;
    final delta = n.scrollDelta ?? 0;
    if (n.metrics.pixels <= 0) {
      _drift = 0;
      _expand();
      return false;
    }
    if (delta == 0) return false;
    _drift = (_drift.sign == delta.sign ? _drift : 0) + delta;
    if (_drift > _kFlipAfter &&
        _collapse.status != AnimationStatus.completed &&
        _collapse.status != AnimationStatus.forward) {
      _collapse.forward();
    } else if (_drift < -_kFlipAfter) {
      _expand();
    }
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
                          NotificationListener<ScrollUpdateNotification>(
                            onNotification: _onScroll,
                            child: _HomeTab(collapse: _collapseT),
                          ),
                        ExploreTab.salvos => SavedTab(
                            onExplore: () =>
                                cubit.selectTab(ExploreTab.explorar),
                            onOrganize: () => openAgent(context),
                          ),
                        ExploreTab.perfil => const ProfileTab(),
                      },
                    ),
                  // Scroll edge effect atrás da tab bar; desce e sai junto
                  // com ela.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedBuilder(
                      animation: _collapseT,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(0, _collapseT.value * (112 + bottom)),
                        child: child,
                      ),
                      child: ProgressiveBlurBottom(height: 112 + bottom),
                    ),
                  ),
                ],
              ),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    TravelSpace.xl, 0, TravelSpace.xl, TravelSpace.md + bottom),
                // Recolhida, a barra desce a própria altura + a margem até a
                // borda + folga do brilho do vidro: sai inteira da tela.
                child: AnimatedBuilder(
                  animation: _collapseT,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(
                      0,
                      _collapseT.value *
                          (GlassTabBar.height +
                              TravelSpace.md +
                              bottom +
                              TravelSpace.lg),
                    ),
                    child: child,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 340),
                    child: GlassTabBar(
                      items: _tabs,
                      index: s.tab.index,
                      onChanged: (i) {
                        _expand();
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
  const _HomeTab({required this.collapse});

  /// 0 = busca larga; 1 = pílula compacta (ver `_ExploreViewState`).
  final Animation<double> collapse;

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

  void _openAgent() => openAgent(context);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return BlocBuilder<ExploreCubit, ExploreState>(
      buildWhen: (a, b) =>
          a.status != b.status ||
          a.sections != b.sections,
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
              child: AnimatedBuilder(
                animation: widget.collapse,
                builder: (context, _) => ProgressiveBlurTop(
                  height: top +
                      lerpDouble(84, 84 - (_Header.hFull - _Header.hCompact),
                          widget.collapse.value)!,
                ),
              ),
            ),
            Positioned(
              top: top + 8,
              left: TravelSpace.gutter,
              right: TravelSpace.gutter,
              child: _Header(
                collapse: widget.collapse,
                onSearch: _openSearch,
                onAgent: _openAgent,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _content(
      BuildContext context, ExploreState s, double top, double bottom) {
    final stay = ExploreMock.profile.stayLocation;
    return BlocBuilder<TravelerCubit, TravelerState>(
      bloc: travelerCubit(),
      buildWhen: (a, b) => a.folders != b.folders ||
          a.transfer != b.transfer ||
          a.outingDone != b.outingDone,
      builder: (context, traveler) => ListView(
      padding: EdgeInsets.only(top: top + 80, bottom: 120 + bottom),
      children: [
        // Cena 6: no dia, o transfer pago vira atalho no topo (D-26).
        if (traveler.transfer != null && !traveler.outingDone) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: TravelSpace.gutter),
            child: TransferBookedCard(today: true),
          ),
          const SizedBox(height: TravelSpace.xl),
        ],
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
          // Vídeos curtos logo depois da seção da hora (D-29).
          if (si == 1) ...[
            const SizedBox(height: TravelSpace.xxl),
            const Reveal(index: 2, child: ShortsShelf()),
          ],
          const SizedBox(height: TravelSpace.xxl),
          Reveal(
            index: si + (si >= 1 ? 3 : 2),
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
                      saved: traveler.isSaved(role.id),
                      meta: section.showDistance
                          ? 'a ${formatKm(distanceKm(stay, role.location))} '
                              'do hotel'
                          : null,
                      onTap: () => openRole(context, role, tag),
                      onToggleSave: () => saveRole(context, role.id),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ],
      ),
    );
  }
}

/// Topo: pílula de busca e a Maré à direita. Ao rolar pra baixo a pílula
/// encolhe pra lupa + "Pesquisar", centrada na **tela inteira** — ignora o
/// botão da Maré, como a busca compacta do iOS.
class _Header extends StatelessWidget {
  const _Header({
    required this.collapse,
    required this.onSearch,
    required this.onAgent,
  });

  final Animation<double> collapse;
  final VoidCallback onSearch;
  final VoidCallback onAgent;

  static const hFull = 56.0;
  static const hCompact = TravelSpace.tap;
  static const _iconSize = 16.0;
  static const _iconGap = 10.0;
  static const _compactPad = TravelSpace.lg;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final fullStyle = TravelType.headline.copyWith(color: p.ink, height: 1.2);
    final compactStyle =
        TravelType.calloutStrong.copyWith(color: p.ink, height: 1.2);
    final labelW = (TextPainter(
      text: TextSpan(text: 'Pesquisar', style: compactStyle),
      maxLines: 1,
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout())
        .width;
    final compactW = _compactPad * 2 + _iconSize + _iconGap + labelW + 1;

    return LayoutBuilder(
      builder: (context, box) => AnimatedBuilder(
        animation: collapse,
        builder: (context, _) {
          final t = collapse.value;
          final w = box.maxWidth;
          final h = lerpDouble(hFull, hCompact, t)!;
          // Centro da tela: o header começa no gutter, então o centro do
          // header é o centro da tela.
          final fullW = w - hFull - TravelSpace.sm;
          final pillW = lerpDouble(fullW, compactW, t)!;
          final pillLeft = lerpDouble(0, (w - compactW) / 2, t)!;
          return SizedBox(
            height: h,
            child: Stack(
              children: [
                Positioned(
                  left: pillLeft,
                  top: 0,
                  width: pillW,
                  height: h,
                  child: _pill(p, h, t, fullStyle, compactStyle),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  width: h,
                  height: h,
                  child: _agentButton(p, h),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _pill(
    TravelPalette p,
    double h,
    double t,
    TextStyle fullStyle,
    TextStyle compactStyle,
  ) {
    return Semantics(
      button: true,
      label: 'Inicie sua pesquisa',
      excludeSemantics: true,
      onTap: onSearch,
      child: Pressable(
        onTap: onSearch,
        child: Stack(
          children: [
            Positioned.fill(
              child: Hero(
                tag: kSearchHero,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: p.s1,
                    borderRadius: BorderRadius.circular(h / 2),
                  ),
                ),
              ),
            ),
            // Ref. Airbnb: lupa + rótulo no centro. Rótulo longo some e o
            // curto entra no mesmo lugar, em cross-fade com o encolher.
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: _compactPad),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(TravelIcons.search, size: _iconSize, color: p.ink),
                    const SizedBox(width: _iconGap),
                    Flexible(
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Opacity(
                            opacity: (1 - t * 2).clamp(0.0, 1.0),
                            child: Text('Inicie sua pesquisa',
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                style: fullStyle),
                          ),
                          Opacity(
                            opacity: (t * 2 - 1).clamp(0.0, 1.0),
                            child: Text('Pesquisar',
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                style: compactStyle),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _agentButton(TravelPalette p, double h) {
    return Semantics(
      button: true,
      label: 'Abrir a Maré',
      excludeSemantics: true,
      onTap: onAgent,
      child: Pressable(
        onTap: onAgent,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(color: p.s1, shape: BoxShape.circle),
          child: MareMark(size: h / 2),
        ),
      ),
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
