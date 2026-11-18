import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_app/core/components/glass/app_glass.dart';
import 'package:studio_app/features/travel_agent/presentation/view_models/travel_agent_cubit.dart';
import 'package:studio_app/features/travel_agent/presentation/views/travel_agent_page.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/agent_sheet.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/connector_carousel.dart';

/// Modo leve (celular no navegador): vidro minimal, desfoque em 3 faixas e
/// aurora por timer. A tela monta, vai ao mapa e volta sem erro, e o timer
/// da aurora morre com a tela — o teste falha se sobrar timer pendente.
void main() {
  setUp(() => AppEffects.debugOverride(true));
  tearDown(() => AppEffects.debugOverride(null));

  testWidgets('modo leve: conversa → mapa → conversa', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: TravelAgentPage()));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(Aurora), findsWidgets,
        reason: 'aurora da abertura sob o composer');

    Future<void> frames() async {
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 40));
      }
    }

    double top() => tester.getTopLeft(find.byType(AgentConversation)).dy;
    final chatTop = top();
    final cubit =
        tester.element(find.byType(AgentConversation)).read<TravelAgentCubit>();

    cubit.openMap();
    await frames();
    expect(top(), greaterThan(844 * 0.4),
        reason: 'sheet desce e revela o mapa');

    cubit.closeMap();
    await frames();
    expect(top(), chatTop, reason: 'volta à conversa em tela cheia');

    // Desmonta a tela: o dispose tem que cancelar o timer da aurora.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
