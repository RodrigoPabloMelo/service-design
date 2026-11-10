import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:studio_app/core/di/design_dependencies.dart';
import 'package:studio_app/design_browser.dart';
import 'package:studio_app/design_doc_page.dart';
import 'package:studio_app/design_system_page.dart';
import 'package:studio_app/design_hub_page.dart';
import 'package:studio_app/design_perf_hud.dart';
import 'package:studio_app/design_theme.dart';
import 'package:studio_app/design_tokens.dart';
import 'package:studio_app/features/feature_registry.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/core/components/glass/app_glass.dart';

// Entry point do loop de design (branch `design` — build web hospedado).
// NÃO importa bootstrap.dart nem nada com dart:io: este arquivo precisa
// buildar para web sempre — é o que o designer vê no browser.
//
// Novas telas: registre em lib/features/feature_registry.dart (o router e o
// hub leem de lá). DI da feature: lib/core/di/design_dependencies.dart.

/// `/docs` e `/docs/fluxo/<slug>` são a MESMA página: a key compartilhada
/// mantém um State de hub só, então modo, zoom e seleção atravessam a troca
/// de fluxo. Fluxo no caminho e não em query porque `/docs/fluxo/onboarding`
/// é o link que se manda para alguém.
const _hubPageKey = ValueKey('docs-hub');

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    // Raiz = o app de verdade: abre direto na primeira tela registrada.
    // O catálogo de fluxos (antigo hub) mora em /docs.
    GoRoute(
      path: '/',
      redirect: (_, __) =>
          designScreens.isEmpty ? '/docs' : designScreens.first.route,
    ),
    // /docs usa pageBuilder com NoTransitionPage, não builder: trocar de
    // fluxo na barra lateral é filtrar a mesma tela, e o slide padrão do
    // Material fazia o canvas "andar de lado" a cada clique.
    // Fluxo é rota IRMÃ de /docs, não filha: como filha o Navigator mantinha o
    // hub de /docs empilhado por baixo, então cada fluxo abria num State novo
    // (modo grade/fluxo voltava ao padrão) e o State velho guardava o fluxo
    // anterior — daí "Todos os fluxos" só pegar no segundo clique. Irmã +
    // mesma key = um hub só, e a URL manda no fluxo aberto.
    GoRoute(
      path: '/docs/fluxo/:flow',
      pageBuilder: (_, state) => NoTransitionPage(
        key: _hubPageKey,
        child: _DocsShell(
          child: DesignHubPage(flowSlug: state.pathParameters['flow']),
        ),
      ),
    ),
    GoRoute(
      path: '/docs',
      pageBuilder: (_, __) => const NoTransitionPage(
        key: _hubPageKey,
        child: _DocsShell(child: DesignHubPage()),
      ),
      routes: [
        // Biblioteca de componentes — o "Widgetbook" do projeto.
        GoRoute(
          path: 'design-system',
          pageBuilder: (_, __) => const NoTransitionPage(
            child: _DocsShell(child: DesignSystemPage()),
          ),
          routes: [
            GoRoute(
              path: ':slug',
              pageBuilder: (_, state) => NoTransitionPage(
                child: _DocsShell(
                  child: DesignSystemPage(slug: state.pathParameters['slug']),
                ),
              ),
            ),
          ],
        ),
        GoRoute(
          path: ':slug',
          pageBuilder: (_, state) => NoTransitionPage(
            child: _DocsShell(
              child: DesignDocPage(slug: state.pathParameters['slug']!),
            ),
          ),
        ),
      ],
    ),
    for (final screen in designScreens)
      GoRoute(
        path: screen.route,
        // `?cenario=erro` abre a tela já naquele edge case — é o link que a
        // subpágina de doc gera. Só o query param conta aqui: o seletor
        // global do /docs governa miniaturas, e no protótipo ele brigaria
        // com a interação (toda navegação cairia no mesmo estado).
        builder: (context, state) {
          final cenario =
              scenarioFromSlug(state.uri.queryParameters['cenario']);
          return Builder(
            // Key nova por cenário: as telas leem o cenário em initState.
            key: ValueKey(cenario),
            builder: screen.builderFor(cenario),
          );
        },
      ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // `?efeitos=leve|completo` e `?fps=1` lidos antes do router: o redirect de
  // `/` pra primeira tela descarta a query.
  AppEffects.init();
  final perfHud = DesignPerfHud.requested();
  // `/docs/fluxo/onboarding` em vez de `/#/docs?flow=Onboarding`.
  usePrettyUrls();
  await setupDesignDependencies();
  // Liquid Glass: pré-aquece shaders (sem isso, 1º frame pisca).
  await initAppGlass();
  runApp(perfHud
      ? const DesignPerfHud(child: _DesignRoot())
      : const _DesignRoot());
}

class _DesignRoot extends StatefulWidget {
  const _DesignRoot();

  @override
  State<_DesignRoot> createState() => _DesignRootState();
}

/// Fundo do protótipo (o `s0` da Maré) no tema atual. Vira o fundo da página
/// e a `theme-color`: no celular o navegador pinta as próprias barras com
/// essas cores (Safari no iPhone pelo fundo da página, Chrome no Android pela
/// `theme-color`) — em branco, elas pareciam cortar o app.
Color _pageColor(ThemeMode mode) {
  final dark = mode == ThemeMode.dark ||
      (mode == ThemeMode.system &&
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark);
  return (dark ? TravelPalette.dark : TravelPalette.light).s0;
}

class _DesignRootState extends State<_DesignRoot> {
  bool _toolbarVisible = false;

  @override
  void initState() {
    super.initState();
    _router.routerDelegate.addListener(_onRoute);
    designThemeMode.addListener(_syncPageColor);
    _syncPageColor();
  }

  @override
  void dispose() {
    _router.routerDelegate.removeListener(_onRoute);
    designThemeMode.removeListener(_syncPageColor);
    super.dispose();
  }

  void _syncPageColor() => setPageColor(_pageColor(designThemeMode.value));

  /// `/docs` é documentação — sem moldura de device. As rotas de tela são o
  /// protótipo e ganham o device_preview em volta.
  ///
  /// Lido no build, não guardado em campo: a rota inicial só é resolvida
  /// quando o MaterialApp.router monta, ou seja DEPOIS deste initState —
  /// um valor cacheado ali nasce errado e `/docs` abria emoldurado.
  bool get _isDocs {
    final path = _router.routerDelegate.currentConfiguration.uri.path;
    return path == '/docs' || path.startsWith('/docs/');
  }

  void _onRoute() {
    if (!mounted) return;
    // A notificação pode chegar durante o build do Router; adiar um frame
    // evita "setState() called during build".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDocs = _isDocs;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          Container(color: Colors.white),
          DevicePreview(
            enabled: kIsWeb && !isDocs,
            isToolbarVisible: _toolbarVisible,
            backgroundColor: Colors.white,
            builder: (context) => const _DesignApp(),
          ),
          if (!isDocs)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              top: 12,
              // Com o painel aberto, sai de cima dele: DevicePreview o desenha
              // encostado à direita com ToolPanel.panelWidth (320, não
              // exportado pelo pacote) de largura.
              right: _toolbarVisible ? 332 : 12,
              child: SafeArea(
                child: Column(
                  children: [
                    _PreviewButton(
                      icon: _toolbarVisible
                          ? HugeIcons.strokeRoundedArrowRight01
                          : HugeIcons.strokeRoundedArrowLeft01,
                      onTap: () =>
                          setState(() => _toolbarVisible = !_toolbarVisible),
                    ),
                    const SizedBox(height: 8),
                    _PreviewButton(
                      icon: HugeIcons.strokeRoundedBookOpen01,
                      onTap: () => _router.go('/docs'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Veste `/docs` com o design system @loomi/ui. Só a documentação: as telas
/// do protótipo ficam fora deste Theme, com o visual do produto.
class _DocsShell extends StatelessWidget {
  const _DocsShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: loomiDocsTheme(Theme.of(context).brightness),
      child: child,
    );
  }
}

/// Botão de chrome do preview — vive acima do MaterialApp, então não pode
/// usar Tooltip (exige Overlay) nem herdar tema. Branco, quadrado, discreto.
class _PreviewButton extends StatelessWidget {
  const _PreviewButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 2,
      shadowColor: const Color(0x33000000),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: const Color(0xFF1C1B1F)),
        ),
      ),
    );
  }
}

class _DesignApp extends StatelessWidget {
  const _DesignApp();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: designThemeMode,
      builder: (context, mode, _) => MaterialApp.router(
        title: 'Studio Design',
        // Cor do app pro sistema (seletor de abas). No web o Title também a
        // manda pra meta `theme-color` do engine — sem ela ia o roxo do
        // Material. Quem vale no navegador é a `#mare-theme` (index.html),
        // que vem antes e o engine não apaga.
        color: _pageColor(mode),
        debugShowCheckedModeBanner: false,
        locale: DevicePreview.locale(context),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        builder: DevicePreview.appBuilder,
        theme: ThemeData.light(useMaterial3: true),
        darkTheme: ThemeData.dark(useMaterial3: true),
        themeMode: mode,
        routerConfig: _router,
      ),
    );
  }
}
