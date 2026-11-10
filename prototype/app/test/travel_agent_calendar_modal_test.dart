import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_app/features/travel_agent/presentation/view_models/travel_agent_cubit.dart';
import 'package:studio_app/features/travel_agent/presentation/views/travel_agent_page.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/agent_sheet.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/calendar_connect_sheet.dart';

/// A agenda fechada fica montada mas fora da pintura (offstage) — e abre de
/// novo normalmente, quantas vezes for.
void main() {
  testWidgets('agenda: fechada fora da pintura, abre e fecha', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: TravelAgentPage()));
    await tester.pump(const Duration(seconds: 1));

    // `find` pula o que está offstage por padrão.
    final visible = find.byType(CalendarConnectSheet);
    final mounted = find.byType(CalendarConnectSheet, skipOffstage: false);
    expect(mounted, findsOneWidget, reason: 'montada desde o início');
    expect(visible, findsNothing, reason: 'fechada não é pintada');

    final cubit =
        tester.element(find.byType(AgentConversation)).read<TravelAgentCubit>();

    for (var round = 0; round < 2; round++) {
      cubit.openCalendar();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(visible, findsOneWidget, reason: 'aberta aparece ($round)');

      cubit.closeCalendar();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(visible, findsNothing, reason: 'saída concluída sai da pintura');
      expect(mounted, findsOneWidget, reason: 'continua montada');
    }

    await tester.pump(const Duration(seconds: 2));
  });
}
