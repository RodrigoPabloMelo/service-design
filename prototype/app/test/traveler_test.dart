import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_app/features/travel_agent/data/travel_agent_mock.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';
import 'package:studio_app/features/travel_agent/presentation/view_models/travel_agent_cubit.dart';
import 'package:studio_app/features/traveler/data/traveler_mock.dart';
import 'package:studio_app/features/traveler/domain/traveler_entities.dart';
import 'package:studio_app/features/traveler/presentation/view_models/traveler_cubit.dart';
import 'package:studio_app/features/traveler/presentation/widgets/coupon_card.dart';

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

    test('salvar em outra viagem, separar por dia e tirar (D-28)', () {
      final c = TravelerCubit()..signIn(AccountProvider.email);
      addTearDown(c.close);
      final olinda = c.createFolder(' Olinda, dez ');
      expect(c.state.folderById(olinda).name, 'Olinda, dez');

      c
        ..saveTo(SavedFolder.tripId, 'casa-astral')
        ..saveTo(olinda, 'box-vitoria-regia')
        ..saveTo(olinda, 'parraxaxa-casa-forte')
        ..saveTo(olinda, 'box-vitoria-regia');
      expect(c.state.saved,
          ['casa-astral', 'box-vitoria-regia', 'parraxaxa-casa-forte']);

      // Sem datas, o dia novo é "Dia 1".
      final dia = c.addDay(olinda);
      expect(c.state.folderById(olinda).days.single.label, 'Dia 1');
      c.moveToDay(olinda, ['parraxaxa-casa-forte'], dia);
      expect(c.state.folderById(olinda).unsorted, ['box-vitoria-regia']);

      // Volta pra "Sem dia".
      c.moveToDay(olinda, ['parraxaxa-casa-forte'], null);
      expect(c.state.folderById(olinda).days.single.roleIds, isEmpty);

      c.unsave('box-vitoria-regia');
      expect(c.state.isSaved('box-vitoria-regia'), isFalse);
      expect(c.state.folderOf('casa-astral')?.id, SavedFolder.tripId);
    });

    test('com datas, a pasta da viagem nasce com os dias', () {
      final c = TravelerCubit.inRecife();
      addTearDown(c.close);
      final days = c.state.folderById(SavedFolder.tripId).days;
      expect(days.map((d) => d.label),
          ['Sexta, 14 nov', 'Sábado, 15 nov', 'Domingo, 16 nov']);
      final novo = c.addDay(SavedFolder.tripId);
      expect(novo, 'd17');
      expect(c.state.folderById(SavedFolder.tripId).days.last.label,
          'Segunda, 17 nov');
    });

    test('datas informadas depois encaixam os "Dia N" sem perder rolê', () {
      final c = TravelerCubit()..signIn(AccountProvider.email);
      addTearDown(c.close);
      c
        ..saveTo(SavedFolder.tripId, 'casa-astral')
        ..saveTo(SavedFolder.tripId, 'parraxaxa-casa-forte');
      final d1 = c.addDay(SavedFolder.tripId);
      final d2 = c.addDay(SavedFolder.tripId);
      c
        ..moveToDay(SavedFolder.tripId, ['casa-astral'], d1)
        ..moveToDay(SavedFolder.tripId, ['parraxaxa-casa-forte'], d2)
        ..setTrip(TravelerMock.trip);

      final days = c.state.folderById(SavedFolder.tripId).days;
      expect(days.map((d) => d.label),
          ['Sexta, 14 nov', 'Sábado, 15 nov', 'Domingo, 16 nov']);
      expect(days[0].roleIds, ['casa-astral']);
      expect(days[1].roleIds, ['parraxaxa-casa-forte']);
      expect(days[2].roleIds, isEmpty);

      // Informar as mesmas datas de novo não mexe em nada.
      c.setTrip(TravelerMock.trip);
      expect(c.state.folderById(SavedFolder.tripId).days, days);
    });

    test('cupons mostram bloqueado, disponível e trocado', () {
      final c = TravelerCubit.inRecife();
      addTearDown(c.close);
      CouponStatus status(String id) => couponStatus(
          TravelerMock.coupons.firstWhere((x) => x.id == id),
          c.state.points,
          c.state.redeemed);
      expect(c.state.points, 120);
      expect(status('99-corridas'), CouponStatus.redeemed);
      expect(status('uber-15'), CouponStatus.available);
      expect(status('casa-astral-drink'), CouponStatus.locked);

      final uber = TravelerMock.coupons.firstWhere((x) => x.id == 'uber-15');
      expect(c.redeem(uber), isTrue);
      expect(c.state.points, 0);
      expect(status('uber-15'), CouponStatus.redeemed);
      expect(c.state.history.first.label, 'Trocou por 15% numa corrida na Uber');
    });

    test('pontos premiam responder, não a nota (Q-27)', () {
      final c = TravelerCubit.afterOuting();
      addTearDown(c.close);
      final before = c.state.points;
      final earned = c.rate(const OutingRating(
        roleId: TravelMock.swapToId,
        roleName: 'Parraxaxá',
        roleStars: 1,
        transferStars: 5,
      ));
      expect(earned, 2 * TravelerMock.pointsPerRating);
      expect(c.state.points, before + earned);
      // Mandar de novo a mesma nota não soma.
      expect(
          c.rate(const OutingRating(
              roleId: TravelMock.swapToId,
              roleName: 'Parraxaxá',
              roleStars: 4,
              transferStars: 5)),
          0);
    });

    test('1 e 5 estrelas rendem o mesmo (D-30, Q-27)', () {
      final a = TravelerCubit();
      final b = TravelerCubit();
      addTearDown(a.close);
      addTearDown(b.close);
      expect(
        a.rate(const OutingRating(
            roleId: 'casa-astral', roleName: 'Casa Astral', roleStars: 1)),
        b.rate(const OutingRating(
            roleId: 'casa-astral', roleName: 'Casa Astral', roleStars: 5)),
      );
    });

    test('contar mais paga o bônus uma vez por rolê', () {
      final c = TravelerCubit();
      addTearDown(c.close);
      const quick = OutingRating(
          roleId: 'casa-astral', roleName: 'Casa Astral', roleStars: 5);
      expect(c.rate(quick), TravelerMock.pointsPerRating);
      // Completa depois com texto: só o bônus.
      expect(c.rate(quick.copyWith(text: 'Equipe atenta.')),
          TravelerMock.pointsPerDetail);
      // Detalhar de novo não paga.
      expect(c.rate(quick.copyWith(text: 'Equipe atenta. Bar bom.')), 0);
      expect(c.state.ratings, hasLength(1));
      expect(c.state.ratingFor('casa-astral')?.text, 'Equipe atenta. Bar bom.');
    });

    test('avaliar rolê só do Explorar não quebra', () {
      final c = TravelerCubit();
      addTearDown(c.close);
      expect(
        c.rate(const OutingRating(
            roleId: 'paco-do-frevo', roleName: 'Paço do Frevo', roleStars: 4)),
        TravelerMock.pointsPerRating,
      );
      expect(c.state.history.first.label, 'Avaliou o Paço do Frevo');
    });

    test('rascunho volta e some no envio', () {
      final c = TravelerCubit();
      addTearDown(c.close);
      const draft = OutingRating(
          roleId: 'dona-lindu',
          roleName: 'Parque Dona Lindu',
          roleStars: 2,
          tags: ['Volta complicada']);
      c.saveDraft(draft);
      expect(c.state.drafts['dona-lindu'], draft);
      c.rate(draft);
      expect(c.state.drafts.containsKey('dona-lindu'), isFalse);
      // Rascunho vazio não fica guardado.
      c.saveDraft(const OutingRating(roleId: 'x', roleName: 'X'));
      expect(c.state.drafts.containsKey('x'), isFalse);
    });

    test('avaliações do rolê: mais nova primeiro, média da lista', () {
      final list = TravelMock.reviewsFor('mercado-boa-vista');
      expect(list, isNotEmpty);
      for (var i = 1; i < list.length; i++) {
        expect(list[i - 1].date.isAfter(list[i].date) ||
            list[i - 1].date == list[i].date, isTrue);
      }
      final avg = TravelMock.averageOf([for (final r in list) r.stars]);
      expect(avg, [for (final r in list) r.stars].reduce((a, b) => a + b) /
          list.length);
      expect(TravelMock.reviewsFor('paco-do-frevo'), isEmpty);
      expect(TravelMock.averageOf(const []), 0);
    });

    test('cupom só com saldo e uma vez', () {
      final c = TravelerCubit();
      addTearDown(c.close);
      final cupom = TravelerMock.coupons.first;
      expect(c.redeem(cupom), isFalse);
      c.rate(const OutingRating(
          roleId: 'casa-astral',
          roleName: 'Casa Astral',
          roleStars: 5,
          transferStars: 5));
      c.rate(const OutingRating(
          roleId: 'dona-lindu', roleName: 'Parque Dona Lindu', roleStars: 4));
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
      final dia = agent.state.days
          .firstWhere((d) => d.id == TravelMock.swapDayId);
      expect(dia.stops.map((s) => s.roleId), contains(TravelMock.swapToId));
      expect(dia.stops.map((s) => s.roleId),
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
