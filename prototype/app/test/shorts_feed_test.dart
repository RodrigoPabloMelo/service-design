import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_app/features/explore/data/explore_mock.dart';
import 'package:studio_app/features/explore/presentation/views/shorts_feed_page.dart';

/// Vídeos curtos da home: fila finita (D-29, F-06) que acaba numa página de
/// fim com recado curto.
void main() {
  test('fila curta e só com rolês da curadoria', () {
    expect(ExploreMock.shorts, isNotEmpty);
    expect(ExploreMock.shorts.length, lessThanOrEqualTo(10));
    for (final (role, video) in ExploreMock.shorts) {
      expect(role.videos, contains(video));
    }
  });

  testWidgets('rolar depois do último vídeo mostra o fim da fila',
      (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final last = ExploreMock.shorts.length - 1;
    await tester.pumpWidget(
        MaterialApp(home: ShortsFeedPage(initialIndex: last)));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Você viu tudo por hoje'), findsNothing);

    await tester.fling(find.byType(PageView), const Offset(0, -600), 2000);
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 40));
    }
    expect(find.text('Você viu tudo por hoje'), findsOneWidget);
    expect(find.text('Se cuida e bom rolê.'), findsOneWidget);
  });
}
