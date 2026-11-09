import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_app/features/travel_agent/data/travel_agent_mock.dart';
import 'package:studio_app/features/travel_agent/presentation/view_models/travel_agent_cubit.dart';
import 'package:studio_app/features/travel_agent/presentation/views/travel_agent_page.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/agent_sheet.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/blank_start.dart';

/// Começo do zero: abre no mapa com a saudação (sem sheet); no primeiro
/// envio o sheet sobe até o detent médio e o mapa continua aberto.
void main() {
  test('vazio começa no mapa e a resposta mantém o mapa aberto', () async {
    final cubit = TravelAgentCubit(scenario: TravelAgentScenario.vazio);
    addTearDown(cubit.close);
    expect(cubit.state.mapOpen, isTrue);
    expect(cubit.state.isBlankStart, isTrue);

    cubit.send('Rolês de gente daqui');
    expect(cubit.state.isBlankStart, isFalse);
    cubit.skipThinking();
    expect(cubit.state.mapOpen, isTrue);
    expect(cubit.state.savedRoleIds, hasLength(8));
  });

  testWidgets('saudação no mapa → sheet no detent médio', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(
        home: TravelAgentPage(scenario: TravelAgentScenario.vazio)));
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(BlankStartHero), findsOneWidget);
    expect(find.byType(AgentConversation), findsNothing);

    final chip = find.descendant(
      of: find.byType(BlankStartHero),
      matching: find.byWidgetPredicate((w) =>
          w is Text &&
          TravelMock.blankSuggestions.contains(w.data)),
    );
    await tester.tap(chip);
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 40));
    }

    expect(find.byType(BlankStartHero), findsNothing);
    final top = tester.getTopLeft(find.byType(AgentConversation)).dy;
    expect(top, greaterThan(844 * 0.4), reason: 'sheet sobre o mapa');

    await tester.pump(const Duration(seconds: 5));
  });
}
