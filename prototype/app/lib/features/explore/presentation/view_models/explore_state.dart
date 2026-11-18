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
    this.saved = const {},
  });

  final ExploreStatus status;

  final List<ExploreSection> sections;
  final ExploreTab tab;

  /// Rolês salvos nesta sessão (a aba Salvos ainda não existe — Q-37).
  final Set<String> saved;

  ExploreState copyWith({
    ExploreStatus? status,
    List<ExploreSection>? sections,
    ExploreTab? tab,
    Set<String>? saved,
  }) =>
      ExploreState(
        status: status ?? this.status,
        sections: sections ?? this.sections,
        tab: tab ?? this.tab,
        saved: saved ?? this.saved,
      );

  @override
  List<Object?> get props => [status, sections, tab, saved];
}
