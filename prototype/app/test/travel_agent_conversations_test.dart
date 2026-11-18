import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_app/features/travel_agent/data/travel_agent_mock.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';
import 'package:studio_app/features/travel_agent/presentation/view_models/conversations_cubit.dart';
import 'package:studio_app/features/travel_agent/presentation/view_models/travel_agent_cubit.dart';
import 'package:studio_app/features/travel_agent/presentation/views/travel_agent_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/agent_sheet.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/blank_start.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/conversation_drawer.dart';

ConversationSeed _seed(String id) =>
    TravelMock.conversations.firstWhere((c) => c.id == id);

void main() {
  group('TravelAgentCubit', () {
    test('padrão abre em conversa nova, sem bloco-resumo', () {
      final cubit = TravelAgentCubit();
      expect(cubit.state.showSummary, isFalse);
      expect(cubit.state.isNewChat, isTrue);
      expect(cubit.state.savedRoleIds, hasLength(8));
      cubit.close();
    });

    test('conversa antiga de filtro responde na hora com os rolês', () {
      final cubit = TravelAgentCubit.fromSeed(_seed('noite'));
      final s = cubit.state;
      expect(s.phase, AgentPhase.idle);
      expect(s.messages.first.author, MessageAuthor.user);
      expect(s.messages.last.kind, MessageKind.savedRoles);
      expect(s.highlightRoleIds, isNotEmpty);
      expect(s.showSummary, isFalse);
      cubit.close();
    });

    test('conversa fixada do roteiro mantém o bloco-resumo', () {
      final cubit = TravelAgentCubit.fromSeed(_seed('roteiro'));
      expect(cubit.state.hasItinerary, isTrue);
      expect(cubit.state.showSummary, isTrue);
      cubit.close();
    });

    test('conversa que falhou abre no erro', () {
      final cubit = TravelAgentCubit.fromSeed(_seed('erro'));
      expect(cubit.state.phase, AgentPhase.error);
      cubit.close();
    });
  });

  group('ConversationsCubit', () {
    final sent = TravelAgentCubit.fromSeed(_seed('hotel')).state;

    blocTest<ConversationsCubit, ConversationsState>(
      'nova conversa com mensagem vira a primeira das recentes',
      build: ConversationsCubit.new,
      act: (c) => c.startNew(current: sent),
      verify: (c) {
        expect(c.state.activeId, isNull);
        expect(c.state.newChats, 1);
        expect(c.state.recent.first.title, 'Perto do hotel');
        expect(c.state.recent.first.snapshot, sent);
        expect(c.state.pinned.single.id, 'roteiro');
      },
    );

    blocTest<ConversationsCubit, ConversationsState>(
      'conversa nova sem mensagem some ao trocar',
      build: ConversationsCubit.new,
      act: (c) => c.open('noite', current: TravelAgentCubit().state),
      verify: (c) {
        expect(c.state.activeId, 'noite');
        expect(c.state.entries, hasLength(TravelMock.conversations.length));
      },
    );

    blocTest<ConversationsCubit, ConversationsState>(
      'conversa da gaveta guarda onde parou',
      build: ConversationsCubit.new,
      act: (c) => c
        ..open('noite')
        ..startNew(current: sent),
      verify: (c) {
        final noite = c.state.entries.firstWhere((e) => e.id == 'noite');
        expect(noite.snapshot, sent);
        expect(c.state.entries, hasLength(TravelMock.conversations.length));
      },
    );

    test('começo do zero não tem conversas antigas', () {
      final c = ConversationsCubit(seeded: false);
      expect(c.state.entries, isEmpty);
      c.close();
    });

    blocTest<ConversationsCubit, ConversationsState>(
      'chuva abre na fixada do roteiro e guarda ao sair',
      build: () => ConversationsCubit(activeId: 'roteiro'),
      act: (c) => c.startNew(
          current: TravelAgentCubit(scenario: TravelAgentScenario.chuva)
              .state),
      verify: (c) {
        expect(c.state.pinned.single.snapshot, isNotNull);
        expect(c.state.entries, hasLength(TravelMock.conversations.length));
      },
    );

    blocTest<ConversationsCubit, ConversationsState>(
      'contagem de mensagens segue entre conversas',
      build: ConversationsCubit.new,
      act: (c) => c.open('noite',
          current: TravelAgentCubit().state.copyWith(messagesUsed: 12)),
      verify: (c) => expect(c.state.messagesUsed, 12),
    );
  });

  testWidgets('saudação → gaveta → conversa antiga → nova conversa',
      (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: TravelAgentPage()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Conversa nova: saudação, sem bloco-resumo nem mapa.
    expect(find.byType(AgentGreeting), findsOneWidget);
    expect(find.byType(BlankStartHero), findsNothing);

    await tester.tap(find.bySemanticsLabel('Conversas'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Fixadas'), findsOneWidget);
    expect(find.text('Recentes'), findsOneWidget);

    await tester.tap(find.descendant(
        of: find.byType(ConversationDrawer),
        matching: find.text('Noite com as amigas')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(AgentGreeting), findsNothing);
    expect(
        find.textContaining('Pra noite com as amigas', findRichText: true),
        findsWidgets);

    await tester.tap(find.bySemanticsLabel('Conversas'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.bySemanticsLabel('Nova conversa'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(AgentGreeting), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('voltar do sistema fecha a gaveta antes de sair',
      (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    // A Maré empilhada sobre outra tela, como vinda do Explorar.
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const TravelAgentPage())),
          child: const Text('abrir'),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    TravelAgentCubit cubit() => tester
        .element(find.byType(AgentConversation, skipOffstage: false))
        .read<TravelAgentCubit>();
    final before = cubit();

    await tester.tap(find.bySemanticsLabel('Conversas'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    // Abrir a gaveta não remonta a conversa (o estado continua).
    expect(identical(cubit(), before), isTrue);
    expect(find.bySemanticsLabel('Salvos'), findsOneWidget);
    expect(find.bySemanticsLabel('Perfil'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(TravelAgentPage), findsOneWidget);
    expect(find.text('Fixadas'), findsNothing);

    await tester.pump(const Duration(seconds: 3));
  });
}
