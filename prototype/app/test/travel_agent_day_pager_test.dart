import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_app/features/travel_agent/presentation/view_models/travel_agent_cubit.dart';
import 'package:studio_app/features/travel_agent/presentation/views/travel_agent_page.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/agent_sheet.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';

/// Guia do dia: arrastar de lado troca o dia (sexta → sábado) e o
/// segmented acompanha; tocar no segmented também troca.
void main() {
  testWidgets('arrastar o guia troca o dia', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: TravelAgentPage()));
    await tester.pump(const Duration(seconds: 1));
    final cubit =
        tester.element(find.byType(AgentConversation)).read<TravelAgentCubit>();

    Future<void> frames() async {
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    cubit.send('Organizar meus 8 rolês');
    cubit.skipThinking();
    await frames();
    cubit.openItinerary();
    await frames();
    cubit.focusDay(0);
    await frames();

    expect(find.byType(PillSegmented), findsOneWidget);
    expect(cubit.state.dayIndex, 0);

    // Arrasta no guia, pelo título do dia.
    await tester.flingFrom(tester.getCenter(find.text('Sexta, 14 nov')),
        const Offset(-300, 0), 1200);
    await frames();
    expect(cubit.state.dayIndex, 1, reason: 'arrastou pra esquerda: sábado');

    await tester.tap(find.text('Dom 16'));
    await frames();
    expect(cubit.state.dayIndex, 2, reason: 'tocou no domingo');

    await tester.pump(const Duration(seconds: 5));
  });
}
