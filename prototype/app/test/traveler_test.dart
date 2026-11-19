import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_app/features/travel_agent/data/travel_agent_mock.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';
import 'package:studio_app/features/travel_agent/presentation/view_models/travel_agent_cubit.dart';
import 'package:studio_app/features/traveler/data/traveler_mock.dart';
import 'package:studio_app/features/traveler/domain/traveler_entities.dart';
import 'package:studio_app/features/traveler/presentation/view_models/traveler_cubit.dart';

void main() {
  group('TravelerCubit', () {
    blocTest<TravelerCubit, TravelerState>(
      'sem conta não salva (D-16)',
      build: TravelerCubit.new,
      act: (c) => c.toggleSaved('parraxaxa-casa-forte'),
      verify: (c) => expect(c.state.saved, isEmpty),
    );

    blocTest<TravelerCubit, TravelerState>(
      'com conta salva e tira dos salvos',
      build: TravelerCubit.new,
      act: (c) => c
        ..signIn(AccountProvider.google)
        ..toggleSaved('box-vitoria-regia')
        ..toggleSaved('parraxaxa-casa-forte')
        ..toggleSaved('box-vitoria-regia'),
      verify: (c) => expect(c.state.saved, ['parraxaxa-casa-forte']),
    );

    test('pontos premiam responder, não a nota (Q-27)', () {
      final c = TravelerCubit.afterOuting();
      addTearDown(c.close);
      final before = c.state.points;
      final earned = c.rate(const OutingRating(
        roleId: TravelMock.swapToId,
        role: RatingValue.naoCurti,
        transfer: RatingValue.bom,
      ));
      expect(earned, 2 * TravelerMock.pointsPerRating);
      expect(c.state.points, before + earned);
      // Avaliar de novo a mesma saída não soma.
      expect(
          c.rate(const OutingRating(
              roleId: TravelMock.swapToId, role: RatingValue.bom)),
          0);
    });

    test('cupom só com saldo e uma vez', () {
      final c = TravelerCubit();
      addTearDown(c.close);
      final cupom = TravelerMock.coupons.first;
      expect(c.redeem(cupom), isFalse);
      c.rate(const OutingRating(
          roleId: 'casa-astral', role: RatingValue.bom, transfer: RatingValue.bom));
      c.rate(const OutingRating(roleId: 'dona-lindu', role: RatingValue.bom));
      expect(c.state.points, greaterThanOrEqualTo(cupom.cost));
      expect(c.redeem(cupom), isTrue);
      expect(c.redeem(cupom), isFalse);
    });
  });

  group('TravelAgentCubit + viagem', () {
    test('organizar sem viagem pergunta datas e hotel antes', () {
      final traveler = TravelerCubit();
      final agent = TravelAgentCubit(traveler: traveler);
      addTearDown(agent.close);
      addTearDown(traveler.close);
      agent.send('Organizar meus 8 rolês');
      expect(agent.state.phase, AgentPhase.idle);
      expect(agent.state.messages.last.kind, MessageKind.tripInfo);

      agent.submitTrip(dates: '14 a 16 nov', stayId: 'gracas');
      expect(traveler.state.trip?.stay.id, 'gracas');
      expect(agent.state.phase, AgentPhase.thinking);
      agent.skipThinking();
      expect(agent.state.hasItinerary, isTrue);
    });

    test('alerta de chuva → troca → oferta de transfer', () {
      final traveler = TravelerCubit.inRecife();
      final agent = TravelAgentCubit(
          scenario: TravelAgentScenario.chuva, traveler: traveler);
      addTearDown(agent.close);
      addTearDown(traveler.close);

      agent.startRainAlert();
      expect(agent.state.swapStatus, SwapStatus.proposed);
      agent.acceptSwap();
      final sab = agent.state.days
          .firstWhere((d) => d.id == TravelMock.swapDayId);
      expect(sab.stops.map((s) => s.roleId), contains(TravelMock.swapToId));
      expect(sab.stops.map((s) => s.roleId),
          isNot(contains(TravelMock.swapFromId)));
      expect(agent.state.messages.last.kind, MessageKind.transferOffer);

      traveler.bookTransfer(TravelerMock.transferTo(TravelMock.swapToId));
      agent.transferBooked();
      expect(agent.state.messages.last.kind, MessageKind.transferBooked);
    });

    test('rolê da troca tem acesso com fonte e data', () {
      final to = TravelMock.roleById(TravelMock.swapToId);
      expect(to.covered, isTrue);
      expect(to.access, isNotNull);
      expect(to.access!.source, isNotEmpty);
      expect(TravelMock.roleById(TravelMock.swapFromId).covered, isFalse);
    });
  });
}
