import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_app/features/traveler/domain/traveler_entities.dart';
import 'package:studio_app/features/traveler/presentation/view_models/traveler_cubit.dart';
import 'package:studio_app/features/traveler/presentation/widgets/rating_sheet.dart';
import 'package:studio_app/features/traveler/presentation/widgets/star_rating.dart';

/// Sheet de avaliação (D-30): estrelas → motivos da faixa → Enviar.
void main() {
  // PNG 1×1 transparente.
  final pixel = Uint8List.fromList(const [
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
    0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
    0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
    0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
  ]);

  Future<void> open(WidgetTester tester, {String roleId = 'teste'}) async {
    tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: RatingSheet(roleId: roleId, roleName: 'Casa Teste'),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('chips mudam com a nota e Enviar liga na primeira estrela',
      (tester) async {
    await open(tester, roleId: 'chips');
    expect(find.text('O que você amou?'), findsNothing);
    // Sem estrela, Enviar não faz nada.
    await tester.tap(find.text('Enviar'));
    await tester.pumpAndSettle();
    expect(travelerCubit().state.ratingFor('chips'), isNull);

    await tester.tap(find.bySemanticsLabel(RegExp(r'2 estrelas$')));
    await tester.pumpAndSettle();
    expect(find.text('O que não rolou?'), findsOneWidget);
    expect(find.text('Fraco'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(RegExp(r'5 estrelas$')));
    await tester.pumpAndSettle();
    expect(find.text('O que você amou?'), findsOneWidget);
    expect(find.text('Amei'), findsOneWidget);

    await tester.tap(find.text('Ok pra ir sozinha'));
    await tester.tap(find.text('Enviar'));
    await tester.pumpAndSettle();
    expect(find.text('+20 pontos'), findsOneWidget);
    final sent = travelerCubit().state.ratingFor('chips');
    expect(sent?.roleStars, 5);
    expect(sent?.tags, ['Ok pra ir sozinha']);
  });

  testWidgets('contar mais: foto entra como miniatura e soma bônus',
      (tester) async {
    reviewPhotoPicker =
        (max) async => [ReviewPhoto(id: 'p1', bytes: pixel)];
    await open(tester, roleId: 'foto');
    await tester.tap(find.bySemanticsLabel(RegExp(r'4 estrelas$')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Contar mais'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Adicionar fotos ou vídeos'));
    await tester.pumpAndSettle();
    expect(find.byType(ReviewMediaThumb), findsOneWidget);
    await tester.tap(find.text('Enviar'));
    await tester.pumpAndSettle();
    expect(find.text('+30 pontos'), findsOneWidget);
  });

  testWidgets('fechar guarda o rascunho', (tester) async {
    await open(tester, roleId: 'rascunho');
    // Fonte de teste = glifo quadrado: a faixa 3 tem chip largo demais.
    await tester.tap(find.bySemanticsLabel(RegExp(r'4 estrelas$')));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    expect(travelerCubit().state.drafts['rascunho']?.roleStars, 4);
  });

  group('StarRow', () {
    Future<List<double>> pumpRow(WidgetTester tester) async {
      final got = <double>[];
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: StarRow(value: null, onChanged: got.add),
          ),
        ),
      ));
      return got;
    }

    // Cada estrela ocupa 44 (alvo mínimo).
    testWidgets('tocar na metade esquerda dá meia estrela', (tester) async {
      final got = await pumpRow(tester);
      final origin = tester.getTopLeft(find.byType(StarRow));
      await tester.tapAt(origin + const Offset(44 * 2 + 10, 22));
      await tester.tapAt(origin + const Offset(44 * 2 + 34, 22));
      expect(got, [2.5, 3.0]);
    });

    testWidgets('arrastar preenche ao vivo e entrega só ao soltar',
        (tester) async {
      final got = await pumpRow(tester);
      final origin = tester.getTopLeft(find.byType(StarRow));
      final g = await tester.startGesture(origin + const Offset(10, 22));
      await g.moveBy(const Offset(40, 0));
      await g.moveBy(const Offset(100, 0));
      await tester.pump();
      expect(got, isEmpty);
      await g.up();
      await tester.pump();
      expect(got, [3.5]);
    });

    test('meia em meia, entre 0,5 e 5', () {
      expect(halfStep(0), 0.5);
      expect(halfStep(3.26), 3.5);
      expect(halfStep(9), 5);
    });
  });
}
