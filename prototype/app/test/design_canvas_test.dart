import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_app/design_canvas.dart';
import 'package:studio_app/design_hub_page.dart';
import 'package:studio_app/features/feature_registry.dart';

// Telas sintéticas minúsculas: exercitam grade/canvas/layout sem depender
// de DI nem das features reais.
RegisteredScreen _screen(
  String title,
  String route, {
  String flow = 'Demo',
  List<String> next = const [],
}) {
  return RegisteredScreen(
    title: title,
    route: route,
    flow: flow,
    next: next,
    builder: (_) => ColoredBox(
      color: Colors.white,
      child: Center(child: Text('corpo de $title')),
    ),
  );
}

void main() {
  group('spineLayout - ', () {
    test('cadeia segue na mesma linha e bifurcação desce', () {
      final screens = [
        _screen('A', '/a', next: ['/b', '/d']),
        _screen('B', '/b', next: ['/c']),
        _screen('C', '/c'),
        _screen('D', '/d'),
      ];
      final cells = spineLayout(screens);
      expect(cells['/a'], const math.Point(0, 0));
      expect(cells['/b'], const math.Point(1, 0));
      expect(cells['/d'], const math.Point(1, 1));
      expect(cells['/c'], const math.Point(2, 0));
    });

    test('tela órfã cai em linha nova na coluna 0', () {
      final screens = [
        _screen('A', '/a', next: ['/b']),
        _screen('B', '/b'),
        _screen('Solta', '/solta'),
      ];
      final cells = spineLayout(screens);
      expect(cells['/solta']!.x, 0);
      expect(cells['/solta']!.y, greaterThan(cells['/a']!.y));
    });

    test('back-edge não reposiciona nem explode', () {
      final screens = [
        _screen('A', '/a', next: ['/b']),
        _screen('B', '/b', next: ['/a']),
      ];
      final cells = spineLayout(screens);
      expect(cells.length, 2);
      expect(cells['/a'], const math.Point(0, 0));
      expect(cells['/b'], const math.Point(1, 0));
    });

    test('destino em outro fluxo segue na mesma espinha', () {
      // É o que permite ligar a última tela de uma jornada à próxima: no
      // recorte "Todos os fluxos" as duas viram uma cadeia só.
      final cells = spineLayout([
        _screen('Home', '/home', flow: 'Onboarding', next: ['/pedidos']),
        _screen('Pedidos', '/pedidos', flow: 'Pedidos', next: ['/pedido']),
        _screen('Pedido', '/pedido', flow: 'Pedidos'),
      ]);
      expect(cells['/home'], const math.Point(0, 0));
      expect(cells['/pedidos'], const math.Point(1, 0));
      expect(cells['/pedido'], const math.Point(2, 0));
    });

    test('next para rota inexistente é ignorado', () {
      final cells = spineLayout([
        _screen('A', '/a', next: ['/nao-existe']),
      ]);
      expect(cells.length, 1);
    });
  });

  group('exitLayout - ', () {
    test('destino fora do recorte ganha célula à direita da origem', () {
      final slice = [
        _screen('Home', '/home', flow: 'Onboarding', next: ['/pedidos']),
      ];
      final cells = spineLayout(slice);
      final exits = exitLayout(slice, cells, {'/home', '/pedidos'});
      expect(exits['/pedidos'], const math.Point(1, 0));
    });

    test('destino dentro do recorte não gera porta', () {
      final slice = [
        _screen('Home', '/home', next: ['/pedidos']),
        _screen('Pedidos', '/pedidos'),
      ];
      final cells = spineLayout(slice);
      expect(exitLayout(slice, cells, {'/home', '/pedidos'}), isEmpty);
    });

    test('rota desconhecida no registro não gera porta', () {
      final slice = [
        _screen('Home', '/home', next: ['/nao-existe'])
      ];
      final cells = spineLayout(slice);
      expect(exitLayout(slice, cells, {'/home'}), isEmpty);
    });

    test('duas telas apontando para o mesmo destino geram uma porta', () {
      final slice = [
        _screen('A', '/a', next: ['/fora']),
        _screen('B', '/b', next: ['/fora']),
      ];
      final cells = spineLayout(slice);
      final exits = exitLayout(slice, cells, {'/a', '/b', '/fora'});
      expect(exits.length, 1);
    });
  });

  group('DesignHubPage - ', () {
    final screens = [
      _screen('Login', '/login', flow: 'Onboarding', next: ['/home']),
      _screen('Home', '/home', flow: 'Onboarding'),
      _screen('Perfil', '/perfil', flow: 'Conta'),
    ];

    testWidgets('grade agrupa por fluxo e mostra as miniaturas', (
      tester,
    ) async {
      // Viewport explícito: com as tags de cenário os cards ficaram mais
      // altos, e o ListView não constrói o que cai fora da tela — o segundo
      // fluxo não existiria na árvore em 800x600.
      tester.view.physicalSize = const Size(1200, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(home: DesignHubPage(screens: screens)),
      );
      // Aparecem no cabeçalho da grade E na sidebar de fluxos.
      expect(find.text('Onboarding'), findsWidgets);
      expect(find.text('Conta'), findsWidgets);
      expect(find.text('Login'), findsWidgets);
      expect(find.byType(MiniPhoneFrame), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });

    testWidgets('sidebar de fluxos filtra e o modo Fluxo mostra o canvas', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(home: DesignHubPage(screens: screens)),
      );
      // Sidebar à la Figma: cabeçalho + itens com contagem.
      expect(find.text('Fluxos'), findsOneWidget);
      // Aparece na sidebar e no título do cartão do canvas.
      expect(find.text('Todos os fluxos'), findsWidgets);

      await tester.tap(find.byTooltip('Fluxo'));
      await tester.pumpAndSettle();
      expect(find.byType(InteractiveViewer), findsOneWidget);
      // "Todos os fluxos" desenha o grafo inteiro: as três telas.
      expect(find.byType(MiniPhoneFrame), findsNWidgets(3));

      // Recortando um fluxo, sobram as telas dele.
      await tester.tap(find.text('Onboarding').last);
      await tester.pumpAndSettle();
      expect(find.byType(MiniPhoneFrame), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('apresentação abre com seletor central e fecha no X', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(home: DesignHubPage(screens: screens)),
      );
      await tester.tap(find.byTooltip('Apresentar'));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Sair (Esc)'), findsOneWidget);
      expect(find.textContaining('1/3'), findsOneWidget);

      // Atalhos de teclado (o upgrade sobre o vmqa): → navega, Esc sai.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(find.textContaining('2/3'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.textContaining('2/3'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('toggle de tema do preview alterna sem erro', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: DesignHubPage(screens: screens)),
      );
      await tester.tap(find.byTooltip('Tema do preview (claro/escuro)'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('canvas: tap seleciona e abre o painel lateral com Leva para', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(home: DesignHubPage(screens: screens)),
      );
      await tester.tap(find.byTooltip('Fluxo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Onboarding').last);
      await tester.pumpAndSettle();

      // Controles de zoom: atalhos de estado nas pontas e passos no meio.
      expect(find.byTooltip('Ver todo o fluxo'), findsOneWidget);
      expect(find.byTooltip('Ver 4 telas'), findsOneWidget);
      expect(find.byTooltip('Diminuir zoom'), findsOneWidget);
      expect(find.byTooltip('Aumentar zoom'), findsOneWidget);
      expect(find.textContaining('%'), findsOneWidget);

      // Tap no nó do Login → painel lateral com destino e Abrir tela.
      await tester.tap(find.text('Login').first);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Abrir tela'), findsOneWidget);
      expect(find.text('Leva para'), findsOneWidget);
      expect(find.widgetWithText(ActionChip, 'Home'), findsOneWidget);

      // Chip "Leva para" muda a seleção pro destino.
      await tester.tap(find.widgetWithText(ActionChip, 'Home'));
      await tester.pumpAndSettle();
      expect(find.text('Leva para'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('toggle de moldura troca sem erro', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: DesignHubPage(screens: screens)),
      );
      await tester.tap(find.byTooltip('Moldura das miniaturas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('iOS'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Moldura das miniaturas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Android'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('sem telas registradas mostra o vazio amigável', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: DesignHubPage(screens: [])),
      );
      expect(find.textContaining('Nenhuma tela registrada'), findsOneWidget);
    });
  });
}
