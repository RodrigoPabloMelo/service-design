import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_app/design_system_page.dart';
import 'package:studio_app/features/feature_registry.dart';

/// A Biblioteca é o Widgetbook do projeto: componente vivo no palco, knobs
/// que mexem nele em tempo real e os estados fixos abaixo.
void main() {
  Future<void> pump(WidgetTester tester, {String? slug}) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: DesignSystemPage(slug: slug)));
    // pump e não pumpAndSettle: o estado "Carregando" tem indicador que gira
    // para sempre — settle nunca voltaria.
    await tester.pump(const Duration(milliseconds: 50));
  }

  group('registro de componentes - ', () {
    test('slug é único', () {
      final slugs = designComponents.map((c) => c.slug).toList();
      expect(slugs.toSet().length, slugs.length);
    });

    test('knobs de opção declaram pelo menos uma opção', () {
      for (final c in designComponents) {
        for (final k in c.knobs) {
          if (k is KnobOpcao) {
            expect(k.opcoes, isNotEmpty, reason: '${c.title} / ${k.label}');
          }
        }
      }
    });
  });

  group('Biblioteca - ', () {
    testWidgets('abre no primeiro componente e lista os grupos', (
      tester,
    ) async {
      await pump(tester);
      final primeiro = designComponents.first;
      expect(find.text(primeiro.title), findsWidgets);
      expect(find.text(primeiro.group), findsWidgets);
      expect(find.text('Controles'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('slug da URL abre o componente daquele slug', (tester) async {
      final alvo = designComponents.last;
      await pump(tester, slug: alvo.slug);
      expect(find.text(alvo.title), findsWidgets);
    });

    testWidgets('knob de texto muda o componente no palco', (tester) async {
      // O botão primário é o caso com knob de texto no registro semente.
      final comTexto = designComponents.firstWhere(
        (c) => c.knobs.any((k) => k is KnobTexto),
      );
      await pump(tester, slug: comTexto.slug);
      final knob = comTexto.knobs.whereType<KnobTexto>().first;

      expect(find.text(knob.inicial), findsWidgets);
      await tester.enterText(find.byType(TextFormField).first, 'Enviar agora');
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Enviar agora'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('estados declarados aparecem abaixo do palco', (tester) async {
      final comVariantes = designComponents.firstWhere(
        (c) => c.variants.isNotEmpty,
      );
      await pump(tester, slug: comVariantes.slug);
      expect(find.text('Estados'), findsOneWidget);
      for (final v in comVariantes.variants) {
        expect(find.text(v.label), findsOneWidget);
      }
    });
  });
}
