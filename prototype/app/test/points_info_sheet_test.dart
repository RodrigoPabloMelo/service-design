import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_app/features/traveler/presentation/widgets/points_info_sheet.dart';

/// "i" dos pontos: três páginas (avaliar, juntar, trocar) e "Entendi".
void main() {
  testWidgets('passa pelas três páginas até Entendi', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: PointsInfoSheet()),
    ));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Avalie suas saídas'), findsOneWidget);

    await tester.tap(find.text('Próximo'));
    for (var i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 40));
    }
    expect(find.text('Junte pontos'), findsOneWidget);

    await tester.tap(find.text('Próximo'));
    for (var i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 40));
    }
    expect(find.text('Troque por cupons'), findsOneWidget);
    expect(find.text('Entendi'), findsOneWidget);
  });
}
