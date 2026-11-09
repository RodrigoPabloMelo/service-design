import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_app/design_canvas.dart';
import 'package:studio_app/design_doc_page.dart';
import 'package:studio_app/design_hub_page.dart';
import 'package:studio_app/design_theme.dart';
import 'package:studio_app/design_toast.dart';
import 'package:studio_app/features/feature_registry.dart';

// Cenários (edge cases) do preview: resolução de variação, eixo global e
// deep link. Tela sintética com texto por estado — não depende das features.
RegisteredScreen _screen({List<String> scenarios = const []}) {
  return RegisteredScreen(
    title: 'Tela',
    route: '/tela',
    builder: (_) => const _Corpo('padrao'),
    variants: [
      for (final s in scenarios)
        ScreenVariant(scenario: s, builder: (_) => _Corpo(s)),
    ],
  );
}

class _Corpo extends StatelessWidget {
  const _Corpo(this.label);
  final String label;

  @override
  Widget build(BuildContext context) =>
      ColoredBox(color: Colors.white, child: Center(child: Text(label)));
}

void main() {
  tearDown(() => designScenario.value = null);

  group('registry de cenários - ', () {
    test('toda variação declarada usa um cenário do eixo global', () {
      // Sem isto, uma variação com cenário fora de `designScenarios` some do
      // seletor da sidebar sem ninguém notar.
      for (final screen in designScreens) {
        for (final v in screen.variants) {
          expect(
            designScenarios,
            contains(v.scenario),
            reason: '${screen.title} declara cenário "${v.scenario}" fora de '
                'designScenarios',
          );
        }
      }
    });

    test('cenário base não é um eixo declarável', () {
      expect(designScenarios, isNot(contains(kScenarioDefault)));
    });

    test('scenarios respeita a ordem de designScenarios', () {
      final screen = _screen(scenarios: ['Carregando', 'Erro']);
      expect(
        screen.scenarios,
        designScenarios.where(screen.hasScenario).toList(),
      );
      expect(screen.scenarios.first, 'Erro');
    });
  });

  group('builderFor - ', () {
    testWidgets('cenário declarado resolve na variação', (tester) async {
      final screen = _screen(scenarios: ['Erro']);
      await tester.pumpWidget(
        MaterialApp(home: Builder(builder: screen.builderFor('Erro'))),
      );
      expect(find.text('Erro'), findsOneWidget);
    });

    testWidgets('cenário sem variação cai no padrão', (tester) async {
      final screen = _screen(scenarios: ['Erro']);
      await tester.pumpWidget(
        MaterialApp(home: Builder(builder: screen.builderFor('Vazio'))),
      );
      expect(find.text('padrao'), findsOneWidget);
    });

    testWidgets('null e cenário base caem no padrão', (tester) async {
      final screen = _screen(scenarios: ['Erro']);
      for (final cenario in [null, kScenarioDefault]) {
        await tester.pumpWidget(
          MaterialApp(home: Builder(builder: screen.builderFor(cenario))),
        );
        expect(find.text('padrao'), findsOneWidget);
      }
    });
  });

  group('slug de cenário - ', () {
    test('normaliza acento', () {
      expect(scenarioSlug(kScenarioDefault), 'padrao');
      expect(scenarioSlug('Erro'), 'erro');
    });

    test('round-trip de todos os cenários', () {
      for (final s in [kScenarioDefault, ...designScenarios]) {
        expect(scenarioFromSlug(scenarioSlug(s)), s);
      }
    });

    test('slug desconhecido ou nulo devolve null', () {
      expect(scenarioFromSlug(null), isNull);
      expect(scenarioFromSlug('offline'), isNull);
    });
  });

  group('canvas - ', () {
    testWidgets('cenário é aplicado no lugar, um nó por tela', (tester) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final screens = [
        RegisteredScreen(
          title: 'Login',
          route: '/login',
          next: const ['/home'],
          builder: (_) => const _Corpo('padrao'),
          variants: [
            ScreenVariant(
                scenario: 'Erro', builder: (_) => const _Corpo('Erro')),
          ],
        ),
        RegisteredScreen(
          title: 'Home',
          route: '/home',
          builder: (_) => const _Corpo('home'),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(home: DesignHubPage(screens: screens)),
      );
      // Modo Fluxo.
      await tester.tap(find.byTooltip('Fluxo'));
      await tester.pumpAndSettle();

      // Duas telas, dois nós — cenário não cria nó extra.
      expect(find.byType(MiniPhoneFrame), findsNWidgets(2));
      expect(find.text('padrao'), findsOneWidget);

      // Selecionando Erro, o Login troca no lugar e a Home é marcada.
      designScenario.value = 'Erro';
      await tester.pumpAndSettle();
      expect(find.byType(MiniPhoneFrame), findsNWidgets(2));
      // Ancorado no canvas: "Erro" também é item da sidebar de cenários.
      expect(
        find.descendant(
          of: find.byType(DesignCanvas),
          matching: find.text('Erro'),
        ),
        findsOneWidget,
      );
      expect(find.text('sem variação'), findsOneWidget);
    });
  });

  group('canvas de todos os fluxos - ', () {
    testWidgets('desenha as telas dos dois fluxos ligadas', (tester) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final screens = [
        RegisteredScreen(
          title: 'Home',
          route: '/home',
          flow: 'Onboarding',
          next: const ['/pedidos'],
          builder: (_) => const _Corpo('home'),
        ),
        RegisteredScreen(
          title: 'Pedidos',
          route: '/pedidos',
          flow: 'Pedidos',
          builder: (_) => const _Corpo('pedidos'),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(home: DesignHubPage(screens: screens)),
      );
      await tester.tap(find.byTooltip('Fluxo'));
      await tester.pumpAndSettle();

      // "Todos os fluxos" é o recorte inicial: as duas telas no mesmo canvas.
      expect(find.byType(DesignCanvas), findsOneWidget);
      expect(find.byType(MiniPhoneFrame), findsNWidgets(2));

      // Recortando um fluxo, sobra a tela dele.
      await tester.tap(find.text('Pedidos').first);
      await tester.pumpAndSettle();
      expect(find.byType(MiniPhoneFrame), findsOneWidget);
    });
  });

  group('porta de saída - ', () {
    testWidgets('recorte de um fluxo mostra a próxima jornada e leva a ela', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final screens = [
        RegisteredScreen(
          title: 'Home',
          route: '/home',
          flow: 'Onboarding',
          next: const ['/pedidos'],
          builder: (_) => const _Corpo('home'),
        ),
        RegisteredScreen(
          title: 'Lista de pedidos',
          route: '/pedidos',
          flow: 'Pedidos',
          builder: (_) => const _Corpo('pedidos'),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(home: DesignHubPage(screens: screens)),
      );
      await tester.tap(find.byTooltip('Fluxo'));
      await tester.pumpAndSettle();

      // Todos os fluxos: as duas telas, sem porta (o destino está desenhado).
      expect(find.text('Próxima jornada'), findsNothing);

      // Recortando Onboarding, a Lista de pedidos sai e vira porta.
      await tester.tap(find.text('Onboarding').last);
      await tester.pumpAndSettle();
      expect(find.byType(MiniPhoneFrame), findsOneWidget);
      expect(find.text('Próxima jornada'), findsOneWidget);

      // Tocar na porta leva ao fluxo de destino.
      await tester.tap(find.text('Próxima jornada'));
      await tester.pumpAndSettle();
      expect(find.byType(MiniPhoneFrame), findsOneWidget);
      expect(find.text('pedidos'), findsOneWidget);
    });
  });

  group('MiniPhoneFrame - ', () {
    Future<void> pump(WidgetTester tester, RegisteredScreen screen,
        {String? scenario}) {
      return tester.pumpWidget(
        MaterialApp(
          home: MiniPhoneFrame(screen: screen, scenario: scenario),
        ),
      );
    }

    testWidgets('segue o seletor global', (tester) async {
      final screen = _screen(scenarios: ['Erro']);
      await pump(tester, screen);
      expect(find.text('padrao'), findsOneWidget);

      designScenario.value = 'Erro';
      await tester.pump();
      // A tela guarda o cenário em initState: sem ValueKey nova o State
      // seria reusado e este expect falharia.
      expect(find.text('Erro'), findsOneWidget);

      designScenario.value = null;
      await tester.pump();
      expect(find.text('padrao'), findsOneWidget);
    });

    testWidgets('cenário fixo ignora o seletor global', (tester) async {
      final screen = _screen(scenarios: ['Erro', 'Vazio']);
      await pump(tester, screen, scenario: 'Vazio');
      designScenario.value = 'Erro';
      await tester.pump();
      expect(find.text('Vazio'), findsOneWidget);
    });

    testWidgets('tela sem variação não muda com o seletor', (tester) async {
      final screen = _screen();
      await pump(tester, screen);
      designScenario.value = 'Erro';
      await tester.pump();
      expect(find.text('padrao'), findsOneWidget);
    });
  });

  group('grade do hub - ', () {
    testWidgets('clique no card abre o painel lateral com o select', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1400, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: DesignHubPage(
            screens: [
              RegisteredScreen(
                title: 'Login',
                route: '/login',
                builder: (_) => const _Corpo('padrao'),
                variants: [
                  ScreenVariant(
                    scenario: 'Erro',
                    note: 'senha recusada',
                    builder: (_) => const _Corpo('Erro'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      expect(find.byType(DesignPreviewPanel), findsNothing);
      await tester.tap(find.byType(MiniPhoneFrame).first);
      await tester.pump();

      expect(find.byType(DesignPreviewPanel), findsOneWidget);
      expect(find.text('Estado'), findsOneWidget);
      expect(find.text('senha recusada'), findsNothing);
    });
  });

  group('tela expandida - ', () {
    testWidgets('"Abrir tela" expande com seletor de estado', (tester) async {
      tester.view.physicalSize = const Size(1400, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: DesignHubPage(
            screens: [
              RegisteredScreen(
                title: 'Login',
                route: '/login',
                next: const ['/home'],
                builder: (_) => const _Corpo('padrao'),
                variants: [
                  ScreenVariant(
                    scenario: 'Erro',
                    builder: (_) => const _Corpo('Erro'),
                  ),
                ],
              ),
              RegisteredScreen(
                title: 'Home',
                route: '/home',
                builder: (_) => const _Corpo('home'),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(MiniPhoneFrame).first);
      await tester.pump();
      await tester.tap(find.byTooltip('Abrir tela'));
      await tester.pumpAndSettle();

      // O pill de estado do overlay — "Padrão" também aparece na sidebar e
      // no select do painel, então o finder é ancorado no tooltip do pill.
      // O painel também tem um select com esse tooltip; o do overlay é o
      // último da árvore.
      final pill = find.byTooltip('Estado da tela').last;
      // "01" está no contador do overlay e na lista de telas do painel.
      expect(find.text('01'), findsWidgets);
      expect(
        find.descendant(of: pill, matching: find.text(kScenarioDefault)),
        findsOneWidget,
      );

      // Trocar para Erro troca a tela renderizada no overlay.
      await tester.tap(pill);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Erro').last);
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: pill, matching: find.text('Erro')),
        findsOneWidget,
      );

      // Navegar no fluxo: Home não cobre Erro, então volta ao padrão.
      await tester.tap(find.byTooltip('Próxima (→)'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byTooltip('Esta tela não tem estado alternativo'),
          matching: find.text(kScenarioDefault),
        ),
        findsOneWidget,
      );
    });
  });

  group('copiar como imagem - ', () {
    testWidgets('botão vive no painel, sobre uma RepaintBoundary', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1400, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: DesignHubPage(
            screens: [
              RegisteredScreen(
                title: 'Login',
                route: '/login',
                builder: (_) => const _Corpo('padrao'),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(MiniPhoneFrame).first);
      await tester.pump();

      final botao = find.byTooltip('Copiar tela como imagem');
      expect(botao, findsOneWidget);

      // A miniatura do painel precisa estar sob uma RepaintBoundary — é dela
      // que sai o PNG. O resultado do clipboard em si só é verificável no
      // browser: `toImage` não resolve dentro do zone de teste, e a Clipboard
      // API não existe na VM (o stub devolve false).
      expect(
        find.ancestor(
          of: find.descendant(
            of: find.byType(DesignPreviewPanel),
            matching: find.byType(MiniPhoneFrame),
          ),
          matching: find.byType(RepaintBoundary),
        ),
        findsWidgets,
      );

      await tester.tap(botao);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('toast do chrome - ', () {
    tearDown(resetLoomiToasts);

    testWidgets('aparece no canto e sai sozinho', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showLoomiToast(
                context,
                'Tela copiada',
                tone: LoomiToastTone.success,
                description: 'É um PNG com a moldura.',
              ),
              child: const Text('copiar'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('copiar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Tela copiada'), findsOneWidget);
      expect(find.text('É um PNG com a moldura.'), findsOneWidget);

      // Some sozinho: 4s de exibição + a animação de saída.
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(find.text('Tela copiada'), findsNothing);
    });

    testWidgets('dois toasts empilham e o tap dispensa', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Column(
              children: [
                TextButton(
                  onPressed: () => showLoomiToast(context, 'primeiro'),
                  child: const Text('a'),
                ),
                TextButton(
                  onPressed: () => showLoomiToast(context, 'segundo'),
                  child: const Text('b'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('a'));
      await tester.pump();
      await tester.tap(find.text('b'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('primeiro'), findsOneWidget);
      expect(find.text('segundo'), findsOneWidget);

      await tester.tap(find.text('primeiro'));
      await tester.pumpAndSettle();
      expect(find.text('primeiro'), findsNothing);
      expect(find.text('segundo'), findsOneWidget);
    });
  });

  group('subpágina de doc - ', () {
    testWidgets('tela com três cenários monta sem estourar', (tester) async {
      // O agente tem Carregando, Vazio e Erro: quatro estados na trilha mais
      // o copiar. Largura apertada de propósito.
      tester.view.physicalSize = const Size(760, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(home: DesignDocPage(slug: screenSlug(designScreens.first))),
      );
      await tester.pump();

      // Um ícone por estado (Padrão + os três) e o de copiar.
      expect(find.byIcon(HugeIcons.strokeRoundedCopy01), findsWidgets);
      expect(find.byIcon(HugeIcons.strokeRoundedAlertCircle), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('clicar num estado troca a tela mostrada', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(home: DesignDocPage(slug: screenSlug(designScreens.first))),
      );
      await tester.pump();

      // O estado de erro do agente mostra o card "Maré fora do ar".
      const erro = 'Maré fora do ar';
      expect(find.text(erro), findsNothing);

      await tester.tap(find.byTooltip('Erro'));
      await tester.pump();
      expect(find.text(erro), findsWidgets);
    });
  });
}
