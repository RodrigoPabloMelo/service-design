import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studio_app/features/explore/data/explore_mock.dart';
import 'package:studio_app/features/explore/domain/explore_entities.dart';
import 'package:studio_app/features/explore/presentation/view_models/explore_state.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';

/// Home "Explorar": seções montadas do mock conforme a hora e o perfil.
class ExploreCubit extends Cubit<ExploreState> {
  ExploreCubit({
    this.scenario = ExploreScenario.padrao,
    DateTime Function()? now,
  })  : _now = now ?? DateTime.now,
        super(const ExploreState()) {
    switch (scenario) {
      case ExploreScenario.padrao:
        _load();
      case ExploreScenario.carregando:
        break; // fica no skeleton
      case ExploreScenario.erro:
        emit(state.copyWith(status: ExploreStatus.error));
    }
  }

  final ExploreScenario scenario;
  final DateTime Function() _now;
  Timer? _retry;

  void _load() {
    final hour = _now().hour;
    emit(state.copyWith(
      status: ExploreStatus.ready,
      greeting: '${_salutation(hour)}, ${ExploreMock.profile.travelerName}.',
      sections: buildSections(hour),
    ));
  }

  /// Tentar de novo (cenário Erro): passa pelo skeleton e carrega.
  void retry() {
    emit(state.copyWith(status: ExploreStatus.loading));
    _retry?.cancel();
    _retry = Timer(const Duration(milliseconds: 900), () {
      if (!isClosed) _load();
    });
  }

  void selectTab(ExploreTab tab) {
    if (tab != state.tab) emit(state.copyWith(tab: tab));
  }

  void toggleSaved(String roleId) {
    final saved = {...state.saved};
    if (!saved.remove(roleId)) saved.add(roleId);
    emit(state.copyWith(saved: saved));
  }

  static String _salutation(int hour) => hour < 5
      ? 'Boa noite'
      : hour < 12
          ? 'Bom dia'
          : hour < 18
              ? 'Boa tarde'
              : 'Boa noite';

  static StopPeriod periodOf(int hour) => hour >= 5 && hour < 12
      ? StopPeriod.manha
      : hour >= 12 && hour < 18
          ? StopPeriod.tarde
          : StopPeriod.noite;

  /// Seções curtas (até 5 rolês cada). A da hora vem primeiro — é a que
  /// muda ao longo do dia.
  static List<ExploreSection> buildSections(int hour) {
    final period = periodOf(hour);
    const tags = ExploreMock.tags;
    final stay = ExploreMock.profile.stayLocation;

    final now = [
      for (final r in ExploreMock.roles)
        if (tags[r.id]?.periods.contains(period) ?? false) r.id,
    ].take(5).toList();

    final byDistance = [...ExploreMock.roles]..sort((a, b) =>
        distanceKm(stay, a.location).compareTo(distanceKm(stay, b.location)));

    final rain = [
      for (final r in ExploreMock.roles)
        if (r.covered) r.id,
    ].take(5).toList();

    return [
      ExploreSection(
        id: 'agora',
        title: switch (period) {
          StopPeriod.manha => 'Pra esta manhã',
          StopPeriod.tarde => 'Pra esta tarde',
          StopPeriod.noite => 'Pra hoje à noite',
        },
        roleIds: now,
      ),
      ExploreSection(
        id: 'companhia',
        title: 'Pra ir ${ExploreMock.profile.company}',
        roleIds: ExploreMock.forCompany,
      ),
      ExploreSection(
        id: 'perto',
        title: 'Mais perto do hotel',
        roleIds: [for (final r in byDistance.take(4)) r.id],
        showDistance: true,
      ),
      ExploreSection(id: 'chuva', title: 'Se chover', roleIds: rain),
    ];
  }

  @override
  Future<void> close() {
    _retry?.cancel();
    return super.close();
  }
}
