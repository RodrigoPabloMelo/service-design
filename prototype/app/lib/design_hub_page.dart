import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import 'package:studio_app/design_canvas.dart';
import 'package:studio_app/design_doc_page.dart';
import 'package:studio_app/design_presentation.dart';
import 'package:studio_app/design_theme.dart';
import 'package:studio_app/design_tokens.dart';
import 'package:studio_app/features/feature_registry.dart';

/// Hub do designer — rota `/` do main_design.dart. Vibe Figma sobre as telas
/// registradas em feature_registry.dart (spec 2026-08-15-design-canvas.md):
///
/// - **Sidebar de fluxos** (painel de páginas do Figma): colapsável, com
///   contagem de telas; seleciona o que a grade/canvas mostram.
/// - **Grade**: miniaturas reais em frames de celular.
/// - **Fluxo**: canvas com pan/zoom e setas derivadas de `next`.
/// - **Apresentar**: overlay fullscreen com atalhos ←/→/Esc.
/// - **Tema claro/escuro** do preview (as telas reais respondem ao tema).
///
/// Deep-link: `/docs/fluxo/<slug>` abre com o fluxo selecionado (o antigo
/// `?flow=Nome` ainda vale); a rota de cada
/// tela já é a URL compartilhável dela (SPA fallback do preview estático).
/// `screens` é injetável para testes; o app usa o registry global.
class DesignHubPage extends StatefulWidget {
  const DesignHubPage({this.screens, this.flowSlug, super.key});

  final List<RegisteredScreen>? screens;

  /// Fluxo aberto pela URL (`/docs/fluxo/<slug>`). Null = todos.
  final String? flowSlug;

  @override
  State<DesignHubPage> createState() => _DesignHubPageState();
}

enum _HubMode { grade, fluxo }

class _DesignHubPageState extends State<DesignHubPage> {
  // Abre no canvas: a jornada inteira ligada é o que o designer quer ver
  // primeiro; a grade é o detalhe tela a tela.
  _HubMode _mode = _HubMode.fluxo;
  FrameMode _frame = readFrameMode();
  String? _selectedFlow; // null = todos
  bool _sidebarOpen = true;
  bool _readDeepLink = false;

  // Seleção da grade: clicar num card abre o painel lateral (o mesmo do
  // canvas), com o select de estado. `/docs/<slug>` continua a um clique,
  // no botão "Abrir tela" do painel.
  String? _selectedRoute;
  String? _selectedScenario;

  RegisteredScreen? get _selectedScreen {
    for (final s in _screens) {
      if (s.route == _selectedRoute) return s;
    }
    return null;
  }

  /// Telas do registro já recortadas pela release escolhida — é a base de
  /// tudo no hub: sidebar, contagem, grade, canvas e painel.
  List<RegisteredScreen> get _screens {
    final todas = widget.screens ?? designScreens;
    final release = releaseNamed(designRelease.value);
    if (release == null) return todas;
    return [
      for (final s in todas)
        if (release.flows.contains(s.flow)) s,
    ];
  }

  List<String> get _flows =>
      {for (final s in _screens) s.flow}.toList()..sort();

  List<RegisteredScreen> get _visible => _selectedFlow == null
      ? _screens
      : [
          for (final s in _screens)
            if (s.flow == _selectedFlow) s,
        ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_readDeepLink) return;
    _readDeepLink = true;
    // `/docs/fluxo/<slug>` abre no fluxo. O `?flow=Nome` antigo continua
    // valendo para links já compartilhados. Em testes não há GoRouter — o
    // try/catch mantém o widget utilizável fora do router.
    _selectedFlow = flowFromSlug(widget.flowSlug, _screens);
    try {
      final params = GoRouterState.of(context).uri.queryParameters;
      final flow = params['flow'];
      if (_selectedFlow == null && flow != null && _flows.contains(flow)) {
        _selectedFlow = flow;
      }
      final cenario = scenarioFromSlug(params['cenario']);
      if (cenario != null) {
        designScenario.value = cenario == kScenarioDefault ? null : cenario;
      }
    } catch (_) {}
  }

  /// `/docs` e `/docs/fluxo/<slug>` compartilham o mesmo State (key única em
  /// main_design.dart), então a URL manda no fluxo aberto: voltar/avançar no
  /// browser e clicar na sidebar chegam aqui.
  @override
  void didUpdateWidget(DesignHubPage old) {
    super.didUpdateWidget(old);
    if (widget.flowSlug == old.flowSlug) return;
    setState(() {
      _selectedFlow = flowFromSlug(widget.flowSlug, _screens);
    });
  }

  /// Troca o cenário global e mantém o painel lateral coerente: se a tela
  /// aberta nele cobre o cenário novo, ele acompanha; se não, volta ao padrão.
  void _selectScenario(String? cenario) {
    designScenario.value = cenario;
    final selected = _selectedScreen;
    if (selected == null) return;
    setState(() {
      _selectedScenario =
          cenario != null && selected.hasScenario(cenario) ? cenario : null;
    });
  }

  /// Abre um fluxo (null = todos) e leva a URL junto: a barra de endereço é
  /// o estado do hub, então `/docs/fluxo/pedidos` é sempre copiável.
  void _abrirFluxo(String? flow) {
    setState(() {
      _selectedFlow = flow;
    });
    // Fora do router (testes) o go falha e a seleção local basta.
    try {
      context.go(flow == null ? '/docs' : '/docs/fluxo/${flowSlug(flow)}');
    } catch (_) {}
  }

  void _present() {
    final screens = _visible;
    if (screens.isEmpty) return;
    showDesignPresentation(
      context,
      screens: screens,
      initialIndex: 0,
      frameMode: _frame,
    );
  }

  @override
  Widget build(BuildContext context) {
    // O cenário é global (designScenario): a grade, o canvas e a
    // apresentação trocam de estado juntos. Aqui o listener existe para as
    // tags e o esmaecimento de "sem variação" — as miniaturas escutam sós.
    return ValueListenableBuilder<String?>(
      valueListenable: designScenario,
      builder: (context, scenario, _) => ValueListenableBuilder<String?>(
        // Release é o segundo eixo global: recorta os fluxos visíveis.
        valueListenable: designRelease,
        builder: (context, _, __) => _scaffold(context, scenario),
      ),
    );
  }

  /// Shell do portal: fundo neutro e cartões flutuantes (sidebar
  /// transparente · canvas · preview), como a tela de protótipos do portal
  /// de jornadas.
  Widget _scaffold(BuildContext context, String? scenario) {
    final p = LoomiPalette.of(context);
    if (_screens.isEmpty) {
      return Scaffold(
        backgroundColor: p.background,
        body: Center(
          child: LoomiCard(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  HugeIcons.strokeRoundedInbox,
                  size: 32,
                  color: p.mutedForeground.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 12),
                Text(
                  'Nenhuma tela registrada',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Peça uma ao Claude para começar.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: p.mutedForeground),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final selected = _selectedScreen;
    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FlowSidebar(
                flows: _flows,
                screens: _screens,
                selected: _selectedFlow,
                open: _sidebarOpen,
                onToggle: () => setState(() => _sidebarOpen = !_sidebarOpen),
                onSelect: _abrirFluxo,
                onLibrary: () => context.go('/docs/design-system'),
                scenario: scenario,
                onSelectScenario: _selectScenario,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LoomiPanelSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _header(context, scenario),
                      Expanded(child: _content(context, scenario)),
                    ],
                  ),
                ),
              ),
              if (selected != null) ...[
                const SizedBox(width: 16),
                LoomiPanelSurface(
                  child: DesignPreviewPanel(
                    screen: selected,
                    screens: _visible,
                    frameMode: _frame,
                    scenario: _selectedScenario,
                    onScenario: (s) => setState(() => _selectedScenario = s),
                    onClose: () => setState(() {
                      _selectedRoute = null;
                      _selectedScenario = null;
                    }),
                    onSelect: (route) => setState(() {
                      _selectedRoute = route;
                      _selectedScenario = null;
                    }),
                    onDocs: () => context.go('/docs/${screenSlug(selected)}'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// `2026-08-27` -> `27/08`: a barra é estreita e o ano raramente muda.
  String _dataCurta(String iso) {
    final partes = iso.split('-');
    return partes.length == 3 ? '${partes[2]}/${partes[1]}' : iso;
  }

  /// Cabeçalho do cartão do canvas em três blocos: identidade à esquerda,
  /// exibição (versão e visão) centralizada, ações à direita. Os Expanded de
  /// mesma largura nas pontas são o que centraliza o meio — com Spacer o
  /// grupo escorregaria conforme o tamanho do título.
  Widget _header(BuildContext context, String? scenario) {
    final theme = Theme.of(context);
    final p = LoomiPalette.of(context);
    final release = releaseNamed(designRelease.value);
    final subtitle = [
      '${_visible.length} telas',
      if (scenario != null) scenario,
      if (release != null) '${release.label} · ${release.date}',
    ].join(' · ');

    // Em cartão estreito o bloco da direita não cabe dentro de um Expanded
    // de meia largura e estoura; ali o meio deixa de ser centralizado e as
    // ações passam a ocupar só o que precisam.
    return LayoutBuilder(
      builder: (context, c) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _selectedFlow ?? 'Todos os fluxos',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      // Em que lançamentos este fluxo entra — a tag responde
                      // "isso vai pro ar quando?" sem sair do cabeçalho.
                      if (_selectedFlow != null)
                        for (final r in releasesOfFlow(_selectedFlow!))
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: LoomiBadge(label: r.label),
                          ),
                    ],
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: p.mutedForeground),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (designReleases.isNotEmpty) ...[
                  // Eixo de release: o lançamento. "Todas" mostra o produto
                  // inteiro; cada release recorta as jornadas que entram nela.
                  LoomiDropdown<String>(
                    tooltip: 'Release',
                    pill: true,
                    value: designRelease.value ?? '',
                    onChanged: (v) => setState(() {
                      designRelease.value = v.isEmpty ? null : v;
                      // Fluxo selecionado que saiu do recorte volta para
                      // "Todos os fluxos" — senão a grade abre vazia.
                      final r = releaseNamed(designRelease.value);
                      if (r != null &&
                          _selectedFlow != null &&
                          !r.flows.contains(_selectedFlow)) {
                        _selectedFlow = null;
                      }
                    }),
                    options: [
                      const LoomiOption(
                        value: '',
                        label: 'Todas',
                        icon: HugeIcons.strokeRoundedRocket01,
                        hint: 'produto inteiro',
                      ),
                      for (final r in designReleases)
                        LoomiOption(
                          value: r.label,
                          label: '${r.label} · ${_dataCurta(r.date)}',
                          icon: HugeIcons.strokeRoundedRocket01,
                          hint: '${r.flows.length} jornadas',
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
                // Fluxo x grade: segmentado em pílula, como no portal.
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: p.muted,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final m in const [
                        (
                          _HubMode.fluxo,
                          HugeIcons.strokeRoundedHierarchySquare01,
                          'Fluxo'
                        ),
                        (
                          _HubMode.grade,
                          HugeIcons.strokeRoundedGridView,
                          'Grade'
                        ),
                      ])
                        _ModeToggle(
                          icon: m.$2,
                          label: m.$3,
                          active: _mode == m.$1,
                          onTap: () => setState(() => _mode = m.$1),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            _TalvezExpandido(
              expandir: c.maxWidth >= 900,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  LoomiDropdown<FrameMode>(
                    tooltip: 'Moldura das miniaturas',
                    iconOnly: true,
                    value: _frame,
                    onChanged: (f) {
                      saveFrameMode(f);
                      setState(() => _frame = f);
                    },
                    options: [
                      const LoomiOption(
                        value: FrameMode.plano,
                        icon: HugeIcons.strokeRoundedSquare,
                        label: 'Sem moldura',
                        hint: 'Tela pura',
                      ),
                      LoomiOption(
                        value: FrameMode.ios,
                        icon: HugeIcons.strokeRoundedSmartPhone01,
                        label: 'iOS',
                        hint: 'iPhone com Dynamic Island',
                        color: p.primary,
                      ),
                      LoomiOption(
                        value: FrameMode.android,
                        icon: HugeIcons.strokeRoundedAndroid,
                        label: 'Android',
                        hint: 'Galaxy S20',
                        color: p.primary,
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'Tema do preview (claro/escuro)',
                    icon: ValueListenableBuilder<ThemeMode>(
                      valueListenable: designThemeMode,
                      builder: (_, mode, __) => Icon(
                        mode == ThemeMode.dark
                            ? HugeIcons.strokeRoundedSun03
                            : HugeIcons.strokeRoundedMoon02,
                        size: 18,
                      ),
                    ),
                    onPressed: toggleDesignTheme,
                  ),
                  IconButton(
                    tooltip: 'Apresentar',
                    icon: const Icon(HugeIcons.strokeRoundedPlay, size: 18),
                    onPressed: _screens.isEmpty ? null : _present,
                  ),
                  _RoundIconButton(
                    tooltip: 'Abrir protótipo (device preview)',
                    icon: HugeIcons.strokeRoundedComputerPhoneSync,
                    size: 32,
                    onTap: () => context.go('/'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, String? scenario) {
    switch (_mode) {
      case _HubMode.grade:
        return _Grade(
          screens: _visible,
          frameMode: _frame,
          scenario: scenario,
          selectedRoute: _selectedRoute,
          onOpen: (s) => setState(() {
            _selectedRoute = s.route;
            // O painel abre no cenário global, quando a tela o cobre.
            _selectedScenario =
                scenario != null && s.hasScenario(scenario) ? scenario : null;
          }),
        );
      case _HubMode.fluxo:
        // "Todos os fluxos" desenha o grafo inteiro: uma tela pode apontar
        // para a rota de outro fluxo (Home → Lista de pedidos), e é aqui que
        // essas ligações aparecem. Com um fluxo selecionado, recorta nele.
        return DesignCanvas(
          // key força relayout/refit ao trocar de recorte.
          key: ValueKey(_selectedFlow ?? 'todos'),
          screens: _visible,
          frameMode: _frame,
          scenario: scenario,
          allScreens: _screens,
          onOpenFlow: _abrirFluxo,
          onOpenScreen: (s) => context.go('/docs/${screenSlug(s)}'),
          // Seleção controlada: o preview é cartão do hub, ao lado do canvas.
          selectedRoute: _selectedRoute,
          onSelect: (s, estado) => setState(() {
            _selectedRoute = s.route;
            _selectedScenario = estado;
          }),
        );
    }
  }
}

/// Envolve em Expanded só quando pedido — Row não aceita `Expanded?`.
class _TalvezExpandido extends StatelessWidget {
  const _TalvezExpandido({required this.expandir, required this.child});

  final bool expandir;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      expandir ? Expanded(child: child) : child;
}

/// Botão do segmentado Fluxo/Grade do cabeçalho.
class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = LoomiPalette.of(context);
    return Tooltip(
      message: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(99),
        onTap: onTap,
        child: Container(
          width: 30,
          height: 26,
          decoration: BoxDecoration(
            color: active ? p.card : null,
            borderRadius: BorderRadius.circular(99),
            boxShadow: active ? LoomiTokens.shadowSm : null,
          ),
          child: Icon(
            icon,
            size: 15,
            color: active ? p.primary : p.mutedForeground,
          ),
        ),
      ),
    );
  }
}

class _FlowSidebar extends StatelessWidget {
  const _FlowSidebar({
    required this.flows,
    required this.screens,
    required this.selected,
    required this.open,
    required this.onToggle,
    required this.onSelect,
    required this.onLibrary,
    required this.scenario,
    required this.onSelectScenario,
  });

  final List<String> flows;
  final List<RegisteredScreen> screens;
  final String? selected;
  final bool open;
  final VoidCallback onToggle;
  final void Function(String? flow) onSelect;
  final VoidCallback onLibrary;

  /// Cenário pré-selecionado (null = Padrão) e seu callback. Selecionar aqui
  /// troca o estado de TODAS as telas que cobrem o cenário.
  final String? scenario;
  final void Function(String? scenario) onSelectScenario;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = LoomiPalette.of(context);

    Widget group(String label) => Padding(
          padding: const EdgeInsets.fromLTRB(12, 20, 12, 8),
          child: open
              ? Text(
                  label,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: p.mutedForeground),
                )
              : Divider(color: p.border, height: 1),
        );

    Widget item({
      required IconData icon,
      required String label,
      required int count,
      required bool active,
      required VoidCallback onTap,
    }) {
      // Item do portal: ativo em `sidebar-accent` com a tinta de marca no
      // texto; inativo em foreground esmaecido, sem fundo.
      final color = active ? p.primary : p.foreground.withValues(alpha: 0.8);
      final tile = InkWell(
        borderRadius: BorderRadius.circular(LoomiTokens.radiusLg),
        onTap: onTap,
        child: Container(
          padding:
              EdgeInsets.symmetric(horizontal: open ? 12 : 0, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(LoomiTokens.radiusLg),
            color: active ? p.sidebarAccent : null,
          ),
          child: Row(
            mainAxisAlignment:
                open ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              if (open) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: color,
                      fontWeight: active ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
                Text(
                  '$count',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: p.mutedForeground),
                ),
              ],
            ],
          ),
        ),
      );
      return open ? tile : Tooltip(message: label, child: tile);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: open ? 240 : 56,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(open ? 12 : 0, 8, 0, 4),
            child: Row(
              children: [
                if (open)
                  Expanded(
                    child: Text(
                      'Protótipos',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                _RoundIconButton(
                  tooltip: open ? 'Recolher navegação' : 'Expandir navegação',
                  icon: open
                      ? HugeIcons.strokeRoundedArrowLeftDouble
                      : HugeIcons.strokeRoundedArrowRightDouble,
                  onTap: onToggle,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 8),
              children: [
                group('Fluxos'),
                item(
                  icon: HugeIcons.strokeRoundedDashboardSquare01,
                  label: 'Todos os fluxos',
                  count: screens.length,
                  active: selected == null,
                  onTap: () => onSelect(null),
                ),
                const SizedBox(height: 4),
                for (final flow in flows)
                  item(
                    icon: HugeIcons.strokeRoundedSmartPhone01,
                    label: flow,
                    count: screens.where((s) => s.flow == flow).length,
                    active: selected == flow,
                    onTap: () => onSelect(flow),
                  ),
              ],
            ),
          ),
          // ── Cenários ──
          // Fica FORA do ListView: eixo independente do fluxo, ancorado no
          // rodapé pra continuar alcançável com muitos fluxos na lista.
          // Escolher um aqui troca o estado de todas as telas que o cobrem.
          // A contagem é quantas telas do recorte atual têm variação para ele.
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                group('Cenários'),
                item(
                  icon: scenarioIcon(kScenarioDefault),
                  label: kScenarioDefault,
                  count: screens.length,
                  active: scenario == null,
                  onTap: () => onSelectScenario(null),
                ),
                for (final s in designScenarios)
                  item(
                    icon: scenarioIcon(s),
                    label: s,
                    count: screens.where((t) => t.hasScenario(s)).length,
                    active: scenario == s,
                    onTap: () => onSelectScenario(s),
                  ),
              ],
            ),
          ),
          // Rodapé: pílula branca com sombra, o atalho do design system.
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Material(
              color: p.card,
              borderRadius: BorderRadius.circular(99),
              elevation: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(99),
                onTap: onLibrary,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: LoomiTokens.shadowMd,
                    color: p.card,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        HugeIcons.strokeRoundedPaintBoard,
                        size: 16,
                        color: p.mutedForeground,
                      ),
                      if (open) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Visualizar design system',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: p.mutedForeground,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botão redondo de recolher/expandir, com anel de borda como no portal.
class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.size = 28,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = LoomiPalette.of(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(99),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: p.card,
            shape: BoxShape.circle,
            border: Border.all(color: p.border),
          ),
          child: Icon(icon, size: size / 2, color: p.mutedForeground),
        ),
      ),
    );
  }
}

class _Grade extends StatelessWidget {
  const _Grade({
    required this.screens,
    required this.frameMode,
    required this.scenario,
    required this.selectedRoute,
    required this.onOpen,
  });

  final List<RegisteredScreen> screens;
  final FrameMode frameMode;
  final String? selectedRoute;

  /// Cenário pré-selecionado (null = Padrão). O cenário é aplicado NO LUGAR:
  /// a tela que o cobre aparece nele, a que não cobre fica esmaecida e
  /// marcada "sem variação" — senão não se distingue "tela imune" de
  /// "esqueci a variação". Nada é duplicado: um fluxo, um card por tela.
  final String? scenario;
  final void Function(RegisteredScreen screen) onOpen;

  static const _cardW = 160.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final byFlow = <String, List<RegisteredScreen>>{};
    for (final s in screens) {
      byFlow.putIfAbsent(s.flow, () => []).add(s);
    }
    final flows = byFlow.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        for (final flow in flows) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 14, top: 4),
            child: Row(
              children: [
                Text(flow, style: theme.textTheme.titleMedium),
                const SizedBox(width: 10),
                LoomiBadge(label: '${byFlow[flow]!.length} telas'),
              ],
            ),
          ),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final screen in byFlow[flow]!) _card(context, screen),
            ],
          ),
          const SizedBox(height: 28),
        ],
      ],
    );
  }

  Widget _card(BuildContext context, RegisteredScreen screen) {
    final theme = Theme.of(context);
    final p = LoomiPalette.of(context);
    // Com cenário selecionado, tela sem variação fica esmaecida e marcada.
    final semVariacao = scenario != null && !screen.hasScenario(scenario!);

    final card = LoomiCard(
      variant: LoomiCardVariant.elevated,
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: _cardW,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MiniPhoneFrame(
              screen: screen,
              width: _cardW,
              mode: frameMode,
              selected: screen.route == selectedRoute,
            ),
            const SizedBox(height: 10),
            Text(
              screen.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium,
            ),
            Text(
              screen.route,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: p.mutedForeground,
                fontFamily: 'monospace',
              ),
            ),
            ..._tags(context, screen, semVariacao),
          ],
        ),
      ),
    );

    return InkWell(
      borderRadius: BorderRadius.circular(LoomiTokens.radiusXl),
      onTap: () => onOpen(screen),
      child: semVariacao ? Opacity(opacity: 0.5, child: card) : card,
    );
  }

  /// Tags de cenário da tela. Sem seleção global mostra tudo que ela cobre;
  /// com seleção mostra só o cenário em jogo (ou o aviso de que ela não tem).
  List<Widget> _tags(
    BuildContext context,
    RegisteredScreen screen,
    bool semVariacao,
  ) {
    final p = LoomiPalette.of(context);
    final List<Widget> tags;

    if (semVariacao) {
      tags = [
        LoomiBadge(label: 'sem variação', color: p.mutedForeground),
      ];
    } else if (scenario != null) {
      tags = [
        LoomiBadge(
          label: scenario!,
          color: scenarioColor(context, scenario!),
          icon: scenarioIcon(scenario!),
        ),
      ];
    } else {
      if (screen.scenarios.isEmpty) return const [];
      tags = [
        for (final s in screen.scenarios)
          LoomiBadge(
            label: s,
            color: scenarioColor(context, s),
            icon: scenarioIcon(s),
          ),
      ];
    }

    return [
      const SizedBox(height: 8),
      Wrap(spacing: 4, runSpacing: 4, children: tags),
    ];
  }
}
