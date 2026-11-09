import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_app/design_hub_page.dart';
import 'package:studio_app/design_theme.dart';
import 'package:studio_app/features/feature_registry.dart';

/// Release é o eixo de LANÇAMENTO do hub: agrupa jornadas inteiras, não
/// telas, e é independente da versão de tela (que vive na doc dela).
void main() {
  setUp(() => designRelease.value = null);
  tearDown(() => designRelease.value = null);

  group('registro de releases - ', () {
    test('todo fluxo de uma release existe no registry', () {
      final fluxos = {for (final s in designScreens) s.flow};
      for (final r in designReleases) {
        for (final f in r.flows) {
          expect(fluxos, contains(f), reason: '${r.label} aponta para "$f"');
        }
      }
    });

    test('releaseNamed acha pelo rótulo e devolve null fora dele', () {
      expect(releaseNamed(designReleases.first.label)?.label,
          designReleases.first.label);
      expect(releaseNamed('R404'), isNull);
      expect(releaseNamed(null), isNull);
    });
  });

  group('eixo de release no hub - ', () {
    final telas = [
      RegisteredScreen(
        title: 'Agente',
        route: '/agente',
        flow: 'Agente',
        builder: (_) => const SizedBox.shrink(),
      ),
      RegisteredScreen(
        title: 'Rascunho',
        route: '/rascunho',
        flow: 'Rascunho',
        builder: (_) => const SizedBox.shrink(),
      ),
    ];

    testWidgets('release recorta os fluxos da sidebar e da grade', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(home: DesignHubPage(screens: telas)));
      expect(find.text('Agente'), findsWidgets);
      expect(find.text('Rascunho'), findsWidgets);

      // R1 não leva o Rascunho: ele some da sidebar e da grade.
      designRelease.value = 'R1';
      await tester.pumpAndSettle();
      expect(find.text('Agente'), findsWidgets);
      expect(find.text('Rascunho'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
