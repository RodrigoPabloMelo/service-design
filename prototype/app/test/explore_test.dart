import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_app/features/explore/data/explore_mock.dart';
import 'package:studio_app/features/explore/domain/explore_entities.dart';
import 'package:studio_app/features/explore/presentation/view_models/explore_cubit.dart';
import 'package:studio_app/features/explore/presentation/view_models/explore_state.dart';
import 'package:studio_app/features/explore/presentation/view_models/search_cubit.dart';
import 'package:studio_app/features/explore/presentation/views/explore_page.dart';
import 'package:studio_app/features/explore/presentation/widgets/explore_ui.dart';
import 'package:studio_app/features/explore/presentation/widgets/filter_pickers.dart';
import 'package:studio_app/features/explore/presentation/widgets/glass_tab_bar.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';

void main() {
  group('ExploreCubit', () {
    test('monta as seções pela hora', () {
      final cubit = ExploreCubit(now: () => DateTime(2026, 11, 14, 20));
      addTearDown(cubit.close);
      final s = cubit.state;
      expect(s.status, ExploreStatus.ready);
      expect(s.sections.first.title, 'Pra hoje à noite');
      for (final section in s.sections) {
        expect(section.roleIds, isNotEmpty);
        expect(section.roleIds.length, lessThanOrEqualTo(5));
      }
      // Seção da hora só tem rolês daquele período.
      for (final id in s.sections.first.roleIds) {
        expect(ExploreMock.tags[id]!.periods, contains(StopPeriod.noite));
      }
    });

    test('de manhã a seção da hora muda', () {
      final cubit = ExploreCubit(now: () => DateTime(2026, 11, 14, 9));
      addTearDown(cubit.close);
      expect(cubit.state.sections.first.title, 'Pra esta manhã');
    });

    test('perto do hotel vem ordenado pela distância', () {
      final perto =
          ExploreCubit.buildSections(15).firstWhere((s) => s.id == 'perto');
      final stay = ExploreMock.profile.stayLocation;
      final kms = [
        for (final id in perto.roleIds)
          distanceKm(stay, ExploreMock.roleById(id).location),
      ];
      expect(kms, orderedEquals([...kms]..sort()));
    });

    blocTest<ExploreCubit, ExploreState>(
      'erro → tentar de novo → carrega',
      build: () => ExploreCubit(scenario: ExploreScenario.erro),
      act: (c) => c.retry(),
      wait: const Duration(seconds: 1),
      verify: (c) => expect(c.state.status, ExploreStatus.ready),
    );

    test('todo rolê tem etiqueta', () {
      for (final r in ExploreMock.roles) {
        expect(ExploreMock.tags, contains(r.id));
      }
    });
  });

  group('SearchCubit', () {
    test('companhia vem do perfil', () {
      expect(SearchCubit().state.query.company, Company.sozinha);
    });

    test('categoria filtra os resultados', () {
      final cubit = SearchCubit()..startWithCategory(ExploreCategory.museu);
      addTearDown(cubit.close);
      expect(cubit.state.results.map((r) => r.id), ['paco-do-frevo']);
    });

    test('café ainda não tem rolê curado: lista vazia, sem inventar', () {
      final cubit = SearchCubit()..startWithCategory(ExploreCategory.cafe);
      addTearDown(cubit.close);
      expect(cubit.state.results, isEmpty);
    });

    test('filtros somam e o contador acompanha', () {
      final cubit = SearchCubit()
        ..toggleFree()
        ..setPeriod(StopPeriod.tarde);
      addTearDown(cubit.close);
      expect(cubit.state.filters.count, 2);
      for (final r in cubit.state.results) {
        expect(r.price, 'Grátis');
        expect(ExploreMock.tags[r.id]!.periods, contains(StopPeriod.tarde));
      }
      cubit.clearFilters();
      expect(cubit.state.filters.count, 0);
      expect(cubit.state.results.length, ExploreMock.roles.length);
    });

    test('faixa de preço filtra pelo gasto por pessoa', () {
      final cubit = SearchCubit()..setPriceRange(10, 20);
      addTearDown(cubit.close);
      expect(cubit.state.filters.count, 1);
      expect(cubit.state.results, isNotEmpty);
      for (final r in cubit.state.results) {
        final v = ExploreMock.tags[r.id]!.priceFrom;
        expect(v, inInclusiveRange(10, 20));
      }
      cubit.setPriceRange(0, kPriceCap);
      expect(cubit.state.filters.count, 0);
    });

    test('onde: Recife traz a base; Olinda ainda sem rolê curado', () {
      final cubit = SearchCubit()..setPlace('Recife');
      addTearDown(cubit.close);
      expect(cubit.state.results.length, ExploreMock.roles.length);
      cubit.setPlace('Olinda');
      expect(cubit.state.results, isEmpty);
      cubit.setPlace('Casa Forte');
      expect(cubit.state.results.map((r) => r.neighborhood).toSet(),
          {'Casa Forte'});
    });

    test('quando: dois toques fazem o intervalo, folga e rótulo', () {
      final cubit = SearchCubit()
        ..pickDate(DateTime(2026, 11, 14))
        ..pickDate(DateTime(2026, 11, 16));
      addTearDown(cubit.close);
      final q = cubit.state.query;
      expect(q.days.length, 3);
      expect(dayLabel(q), '14 a 16 nov');
      cubit.setSlack(1);
      expect(cubit.state.query.days.length, 5);
      expect(dayLabel(cubit.state.query), '14 a 16 nov, ±1 dia');
      // Toque antes do início recomeça.
      cubit.pickDate(DateTime(2026, 11, 12));
      expect(cubit.state.query.end, isNull);
    });

    test('quando: flexível tira as datas exatas', () {
      final cubit = SearchCubit()
        ..pickDate(DateTime(2026, 11, 14))
        ..setFlexible(month: DateTime(2026, 12));
      addTearDown(cubit.close);
      expect(cubit.state.query.hasDates, isFalse);
      expect(dayLabel(cubit.state.query), 'Fim de semana em dez');
    });

    test('perto do hotel só traz rolês a até 4 km', () {
      final cubit = SearchCubit()..setPlace(SearchQuery.nearHotel);
      addTearDown(cubit.close);
      final stay = ExploreMock.profile.stayLocation;
      expect(cubit.state.results, isNotEmpty);
      for (final r in cubit.state.results) {
        expect(distanceKm(stay, r.location), lessThanOrEqualTo(kNearHotelKm));
      }
    });
  });

  testWidgets('home abre com busca, Maré e tab bar', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: ExplorePage()));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Inicie sua pesquisa'), findsOneWidget);
    expect(find.bySemanticsLabel('Abrir a Maré'), findsOneWidget);
    expect(find.text('Explorar'), findsOneWidget);
    expect(find.text('Salvos'), findsWidgets);
    expect(find.text('Museu'), findsOneWidget);
    expect(find.text('Explore rolês'), findsOneWidget);
  });

  testWidgets('arrastar a seleção da tab bar troca a aba', (tester) async {
    var picked = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 330,
            child: StatefulBuilder(
              builder: (context, setState) => GlassTabBar(
                items: const [
                  GlassTabItem(TravelIcons.compass, 'Explorar'),
                  GlassTabItem(TravelIcons.bookmark, 'Salvos'),
                  GlassTabItem(TravelIcons.user, 'Perfil'),
                ],
                index: picked,
                onChanged: (i) => setState(() => picked = i),
              ),
            ),
          ),
        ),
      ),
    ));
    final start = tester.getCenter(find.text('Explorar'));
    final end = tester.getCenter(find.text('Perfil'));
    await tester.dragFrom(start, end - start);
    await tester.pumpAndSettle();
    expect(picked, 2);
  });

  testWidgets('arco do dia: tocar em Noite escolhe a noite', (tester) async {
    StopPeriod? picked;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 360,
            child: StatefulBuilder(
              builder: (context, setState) => DayArcPicker(
                value: picked,
                onChanged: (v) => setState(() => picked = v),
              ),
            ),
          ),
        ),
      ),
    ));
    expect(find.text('Qualquer horário'), findsOneWidget);
    await tester.tap(find.text('Noite'));
    await tester.pumpAndSettle();
    expect(picked, StopPeriod.noite);
    expect(find.text('À noite'), findsOneWidget);
  });
}
