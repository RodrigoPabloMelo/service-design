import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_app/design_hub_page.dart';
import 'package:studio_app/features/feature_registry.dart';
import 'package:studio_app/features/welcome/presentation/views/welcome_page.dart';

// Smoke do loop de design: o hub lista o que está no registry e as telas
// registradas renderizam. Se isso quebrar, o preview hospedado quebrou.
void main() {
  testWidgets('hub lista todas as telas do registry', (tester) async {
    // Viewport alto: a grade é lazy (ListView) e com muitas telas os títulos
    // abaixo da dobra não seriam construídos num viewport 800x600.
    tester.view.physicalSize = const Size(1600, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: DesignHubPage()));
    for (final screen in designScreens) {
      // findsWidgets: o título aparece no label da miniatura e pode aparecer
      // de novo dentro da própria tela renderizada em miniatura.
      expect(find.text(screen.title), findsWidgets);
    }
  });

  testWidgets('telas registradas renderizam sem erro', (tester) async {
    for (final screen in designScreens) {
      await tester
          .pumpWidget(MaterialApp(home: Builder(builder: screen.builder)));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('WelcomePage mostra o call-to-action', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: WelcomePage()));
    expect(find.textContaining('Peça uma tela nova'), findsOneWidget);
  });
}
