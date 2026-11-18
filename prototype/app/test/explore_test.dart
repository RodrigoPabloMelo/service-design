import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_app/features/explore/data/explore_mock.dart';
import 'package:studio_app/features/explore/domain/explore_entities.dart';
import 'package:studio_app/features/explore/presentation/view_models/explore_cubit.dart';
import 'package:studio_app/features/explore/presentation/view_models/explore_state.dart';
import 'package:studio_app/features/explore/presentation/view_models/search_cubit.dart';
import 'package:studio_app/features/explore/presentation/views/explore_page.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';

void main() {
  group('ExploreCubit', () {
    test('monta saudação e seções pela hora', () {
      final cubit = ExploreCubit(now: () => DateTime(2026, 11, 14, 20));
      addTearDown(cubit.close);
      final s = cubit.state;
      expect(s.status, ExploreStatus.ready);
      expect(s.greeting, 'Boa noite, Camila.');
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
      expect(cubit.state.greeting, startsWith('Bom dia'));
      expect(cubit.state.sections.first.title, 'Pra esta manhã');
    });

    test('perto do hotel vem ordenado pela distância', () {
      final perto = ExploreCubit.buildSections(15)
          .firstWhere((s) => s.id == 'perto');
      final stay = ExploreMock.profile.stayLocation;
      final kms = [
        for (final id in perto.roleIds)
          distanceKm(stay, ExploreMock.roleById(id).location),
      ];
      expect(kms, orderedEquals([...kms]..sort()));
    });

    blocTest<ExploreCubit, ExploreState>(
      'salvar e tirar dos salvos',
      build: ExploreCubit.new,
      act: (c) => c
        ..toggleSaved('paco-do-frevo')
        ..toggleSaved('paco-do-frevo'),
      verify: (c) => expect(c.state.saved, isEmpty),
    );

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

    expect(find.text('Pra onde hoje?'), findsOneWidget);
    expect(find.bySemanticsLabel('Abrir a Maré'), findsOneWidget);
    expect(find.text('Explorar'), findsOneWidget);
    expect(find.text('Salvos'), findsWidgets);
    expect(find.text('Museu'), findsOneWidget);
  });
}
