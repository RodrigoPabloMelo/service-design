import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';

/// Categorias da home (Explorar). Taxonomia própria, separada de
/// [RoleCategory] (a do agente, com 5 tipos) — a conciliação está em
/// `docs/questoes-em-aberto.md` (Q-37).
enum ExploreCategory { restaurantes, cafe, museu, cultura, arte, historia }

/// Com quem ela vai (D-11). Vem do perfil e é editável na busca.
enum Company { sozinha, amiga, parceiro }

/// Faixa de preço do filtro (mesmos valores de [Role.price]).
enum PriceBand { gratis, um, dois }

/// Etiquetas do rolê usadas só pela home e pela busca.
class ExploreTags extends Equatable {
  const ExploreTags({
    required this.categories,
    required this.periods,
    required this.days,
    required this.reason,
  });

  final Set<ExploreCategory> categories;
  final Set<StopPeriod> periods;

  /// Dias da viagem em que o rolê funciona (0 = sex, 1 = sáb, 2 = dom).
  final Set<int> days;

  /// Por que pra você — uma linha (F-13).
  final String reason;

  @override
  List<Object?> get props => [categories, periods, days, reason];
}

/// O que ela respondeu na busca guiada (onde, quando, com quem, que tipo).
class SearchQuery extends Equatable {
  const SearchQuery({
    this.place,
    this.day,
    this.company = Company.sozinha,
    this.categories = const {},
  });

  /// Bairro, [nearHotel] ou null (qualquer lugar).
  final String? place;

  /// Dia da viagem (0..2) ou null (qualquer dia).
  final int? day;
  final Company company;
  final Set<ExploreCategory> categories;

  static const nearHotel = 'Perto do hotel';

  SearchQuery copyWith({
    String? Function()? place,
    int? Function()? day,
    Company? company,
    Set<ExploreCategory>? categories,
  }) =>
      SearchQuery(
        place: place == null ? this.place : place(),
        day: day == null ? this.day : day(),
        company: company ?? this.company,
        categories: categories ?? this.categories,
      );

  @override
  List<Object?> get props => [place, day, company, categories];
}

/// Filtros aplicados depois da busca (sheet "Filtros").
class ExploreFilters extends Equatable {
  const ExploreFilters({
    this.covered = false,
    this.free = false,
    this.nearHotel = false,
    this.period,
    this.price,
  });

  final bool covered;
  final bool free;
  final bool nearHotel;
  final StopPeriod? period;
  final PriceBand? price;

  /// Quantos filtros estão ligados (contador do botão).
  int get count => [covered, free, nearHotel, period != null, price != null]
      .where((on) => on)
      .length;

  ExploreFilters copyWith({
    bool? covered,
    bool? free,
    bool? nearHotel,
    StopPeriod? Function()? period,
    PriceBand? Function()? price,
  }) =>
      ExploreFilters(
        covered: covered ?? this.covered,
        free: free ?? this.free,
        nearHotel: nearHotel ?? this.nearHotel,
        period: period == null ? this.period : period(),
        price: price == null ? this.price : price(),
      );

  @override
  List<Object?> get props => [covered, free, nearHotel, period, price];
}

/// Uma seção da home: título curto + poucos rolês (sem feed infinito, F-06).
class ExploreSection extends Equatable {
  const ExploreSection({
    required this.id,
    required this.title,
    required this.roleIds,
    this.showDistance = false,
  });

  final String id;
  final String title;
  final List<String> roleIds;

  /// Mostra "a 1,2 km do hotel" no card em vez do bairro.
  final bool showDistance;

  @override
  List<Object?> get props => [id, title, roleIds, showDistance];
}

/// Distância em linha reta (km), suficiente pro protótipo.
double distanceKm(GeoPoint a, GeoPoint b) {
  const r = 6371.0;
  double rad(double d) => d * math.pi / 180;
  final dLat = rad(b.lat - a.lat);
  final dLng = rad(b.lng - a.lng);
  final h = math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(a.lat)) *
          math.cos(rad(b.lat)) *
          math.pow(math.sin(dLng / 2), 2);
  return 2 * r * math.asin(math.sqrt(h));
}

/// "2,1 km".
String formatKm(double km) =>
    '${km.toStringAsFixed(1).replaceAll('.', ',')} km';

/// Até onde conta como "perto do hotel".
const kNearHotelKm = 4.0;

PriceBand? priceBandOf(Role r) => switch (r.price) {
      'Grátis' => PriceBand.gratis,
      r'$' => PriceBand.um,
      r'$$' => PriceBand.dois,
      _ => null,
    };

/// Filtra os rolês curados pela busca + filtros. Só a base curada (D-07):
/// sem resultado, a tela diz isso em vez de completar.
List<Role> searchRoles({
  required List<Role> roles,
  required Map<String, ExploreTags> tags,
  required GeoPoint stay,
  required SearchQuery query,
  required ExploreFilters filters,
}) {
  bool near(Role r) => distanceKm(stay, r.location) <= kNearHotelKm;
  return [
    for (final r in roles)
      if (_matches(r, tags[r.id], query, filters, near(r))) r,
  ];
}

bool _matches(
    Role r, ExploreTags? t, SearchQuery q, ExploreFilters f, bool isNear) {
  if (t == null) return false;
  final place = q.place;
  if (place != null) {
    if (place == SearchQuery.nearHotel) {
      if (!isNear) return false;
    } else if (r.neighborhood != place) {
      return false;
    }
  }
  if (q.day != null && !t.days.contains(q.day)) return false;
  if (q.categories.isNotEmpty &&
      t.categories.intersection(q.categories).isEmpty) {
    return false;
  }
  if (f.covered && !r.covered) return false;
  if (f.free && r.price != 'Grátis') return false;
  if (f.nearHotel && !isNear) return false;
  if (f.period != null && !t.periods.contains(f.period)) return false;
  if (f.price != null && priceBandOf(r) != f.price) return false;
  return true;
}
