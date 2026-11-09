import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_app/features/travel_agent/presentation/view_models/travel_agent_cubit.dart';
import 'package:studio_app/features/travel_agent/presentation/views/travel_agent_page.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/agent_sheet.dart';

/// A tela começa na conversa em tela cheia; abrir o mapa desce o sheet até
/// o detent médio e fechar volta à conversa.
void main() {
  testWidgets('conversa → mapa → conversa', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: TravelAgentPage()));
    await tester.pump(const Duration(seconds: 1));

    double top() => tester.getTopLeft(find.byType(AgentConversation)).dy;
    Future<void> frames() async {
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 40));
      }
    }

    final cubit =
        tester.element(find.byType(AgentConversation)).read<TravelAgentCubit>();
    final chatTop = top();
    expect(chatTop, lessThan(100), reason: 'conversa ocupa a tela toda');

    cubit.openMap();
    await frames();
    expect(top(), greaterThan(844 * 0.4),
        reason: 'sheet desce e revela o mapa');

    cubit.closeMap();
    await frames();
    expect(top(), chatTop, reason: 'volta à conversa em tela cheia');

    await tester.pump(const Duration(seconds: 2));
  });
}
