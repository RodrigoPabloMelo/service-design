import 'package:equatable/equatable.dart';
import 'package:studio_app/features/explore/domain/explore_entities.dart';

enum ExploreStatus { loading, ready, error }

/// Abas da tab bar. O agente não é aba: abre pelo botão no topo.
enum ExploreTab { explorar, salvos, perfil }

class ExploreState extends Equatable {
  const ExploreState({
    this.status = ExploreStatus.loading,
    this.sections = const [],
    this.tab = ExploreTab.explorar,
  });

  final ExploreStatus status;

  final List<ExploreSection> sections;
  final ExploreTab tab;

  ExploreState copyWith({
    ExploreStatus? status,
    List<ExploreSection>? sections,
    ExploreTab? tab,
  }) =>
      ExploreState(
        status: status ?? this.status,
        sections: sections ?? this.sections,
        tab: tab ?? this.tab,
      );

  @override
  List<Object?> get props => [status, sections, tab];
}
