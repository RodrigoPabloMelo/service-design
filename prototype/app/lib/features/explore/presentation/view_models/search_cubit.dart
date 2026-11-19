import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studio_app/features/explore/data/explore_mock.dart';
import 'package:studio_app/features/explore/domain/explore_entities.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';

/// Passos da busca guiada (sanfona).
enum SearchStep { onde, quando, quem, tipo }

class SearchState extends Equatable {
  const SearchState({
    this.query = const SearchQuery(),
    this.filters = const ExploreFilters(),
    this.step = SearchStep.onde,
  });

  final SearchQuery query;
  final ExploreFilters filters;

  /// Card aberto da sanfona.
  final SearchStep step;

  /// Resultado com busca + filtros (só a base curada).
  List<Role> get results => searchRoles(
        roles: ExploreMock.roles,
        tags: ExploreMock.tags,
        stay: ExploreMock.profile.stayLocation,
        query: query,
        filters: filters,
        cityOf: ExploreMock.cityOf,
      );

  SearchState copyWith({
    SearchQuery? query,
    ExploreFilters? filters,
    SearchStep? step,
  }) =>
      SearchState(
        query: query ?? this.query,
        filters: filters ?? this.filters,
        step: step ?? this.step,
      );

  @override
  List<Object?> get props => [query, filters, step];
}

/// Busca guiada (onde, quando, com quem, que tipo) e filtros depois.
/// Vive com a home: abrir a busca reaproveita o mesmo estado.
class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchState(query: defaultQuery));

  /// Companhia do perfil ("sozinha") — editável, nunca presumida.
  static SearchQuery get defaultQuery => SearchQuery(
        company: companyFromProfile(ExploreMock.profile.company),
      );

  static Company companyFromProfile(String company) {
    final c = company.toLowerCase();
    if (c.contains('amig')) return Company.amiga;
    if (c.contains('parceir') || c.contains('namor')) return Company.parceiro;
    return Company.sozinha;
  }

  /// Abre a busca do zero (pílula da home).
  void start() => emit(SearchState(query: defaultQuery));

  /// Toque num card de categoria: busca já filtrada pelo tipo.
  void startWithCategory(ExploreCategory c) => emit(SearchState(
        query: defaultQuery.copyWith(categories: {c}),
        step: SearchStep.tipo,
      ));

  void openStep(SearchStep step) => emit(state.copyWith(step: step));

  void setPlace(String? place) =>
      emit(state.copyWith(query: state.query.copyWith(place: () => place)));

  /// Toque num dia do calendário: 1º toque começa, 2º fecha o intervalo
  /// (antes do início, recomeça). Datas tiram o modo flexível.
  void pickDate(DateTime day) {
    final q = state.query;
    final s = q.start;
    final SearchQuery next;
    if (s == null || q.end != null || day.isBefore(s)) {
      next = q.copyWith(start: () => day, end: () => null);
    } else {
      next = q.copyWith(end: () => day.isAtSameMomentAs(s) ? null : day);
    }
    emit(state.copyWith(
        query: next.copyWith(flexStay: () => null, flexMonth: () => null)));
  }

  void setSlack(int slack) =>
      emit(state.copyWith(query: state.query.copyWith(slack: slack)));

  /// Aba "Flexível": duração + mês. Tira as datas exatas.
  void setFlexible({FlexStay? stay, DateTime? month}) {
    final q = state.query;
    emit(state.copyWith(
      query: q.copyWith(
        flexStay: () => stay ?? q.flexStay ?? FlexStay.fimDeSemana,
        flexMonth: () => month ?? q.flexMonth,
        start: () => null,
        end: () => null,
        slack: 0,
      ),
    ));
  }

  /// "Qualquer dia".
  void clearWhen() => emit(state.copyWith(
        query: state.query.copyWith(
          start: () => null,
          end: () => null,
          slack: 0,
          flexStay: () => null,
          flexMonth: () => null,
        ),
      ));

  void setCompany(Company company) =>
      emit(state.copyWith(query: state.query.copyWith(company: company)));

  void toggleCategory(ExploreCategory c) {
    final next = {...state.query.categories};
    if (!next.remove(c)) next.add(c);
    emit(state.copyWith(query: state.query.copyWith(categories: next)));
  }

  /// "Limpar" da busca: volta ao padrão, mantém o card aberto.
  void clearQuery() => emit(SearchState(
      query: defaultQuery, filters: state.filters, step: state.step));

  void toggleCovered() => emit(state.copyWith(
      filters: state.filters.copyWith(covered: !state.filters.covered)));

  void toggleFree() => emit(state.copyWith(
      filters: state.filters.copyWith(free: !state.filters.free)));

  void toggleNearHotel() => emit(state.copyWith(
      filters: state.filters.copyWith(nearHotel: !state.filters.nearHotel)));

  void setPeriod(StopPeriod? period) => emit(
      state.copyWith(filters: state.filters.copyWith(period: () => period)));

  void setPriceRange(int min, int max) => emit(state.copyWith(
      filters: state.filters.copyWith(priceMin: min, priceMax: max)));

  void clearFilters() => emit(state.copyWith(filters: const ExploreFilters()));

  /// "Limpar" do sheet de filtros: zera também o tipo de rolê (que aparece
  /// no sheet).
  void clearFiltersAndTypes() => emit(state.copyWith(
        filters: const ExploreFilters(),
        query: state.query.copyWith(categories: const {}),
      ));
}
