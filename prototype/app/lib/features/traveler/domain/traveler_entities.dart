import 'package:equatable/equatable.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';

/// Como ela entrou na conta rápida (D-16, D-23). Tudo mock: sem OAuth real.
enum AccountProvider { google, apple, email }

/// Conta criada na hora de salvar o primeiro rolê. Sem verificação (Q-13).
class TravelerAccount extends Equatable {
  const TravelerAccount({required this.name, required this.provider});

  final String name;
  final AccountProvider provider;

  @override
  List<Object?> get props => [name, provider];
}

/// Hospedagem que ela informa ao agente (etapa 04).
class Stay extends Equatable {
  const Stay({
    required this.id,
    required this.name,
    required this.neighborhood,
    required this.location,
  });

  final String id;
  final String name;
  final String neighborhood;
  final GeoPoint location;

  @override
  List<Object?> get props => [id];
}

/// Datas e hospedagem informadas — o agente só monta o roteiro com elas.
class TripInfo extends Equatable {
  const TripInfo({required this.dates, required this.stay});

  /// Rótulo das datas: "14 a 16 nov".
  final String dates;
  final Stay stay;

  @override
  List<Object?> get props => [dates, stay];
}

/// Transfer com motorista parceira contratado e pago no app (D-26). O
/// acompanhamento da corrida fica no app da parceira.
class TransferBooking extends Equatable {
  const TransferBooking({
    required this.roleId,
    required this.driverName,
    required this.car,
    required this.pickup,
    required this.back,
    required this.price,
    required this.paidWith,
  });

  /// Rolê de destino.
  final String roleId;
  final String driverName;
  final String car;

  /// "Sáb, 19h" — ida a partir da hospedagem.
  final String pickup;

  /// "Sáb, 23h30" — volta para a hospedagem.
  final String back;
  final String price;

  /// Meio de pagamento mock: "Cartão final 4242".
  final String paidWith;

  @override
  List<Object?> get props => [roleId, driverName, pickup, back, price];
}

/// Avaliação em um toque: foi bom ou não (E-08, D-09).
enum RatingValue { bom, naoCurti }

/// Avaliação de uma saída: o rolê e, se houve, o transfer.
class OutingRating extends Equatable {
  const OutingRating({
    required this.roleId,
    this.role,
    this.transfer,
    this.reason,
  });

  final String roleId;
  final RatingValue? role;
  final RatingValue? transfer;

  /// Motivo opcional (chip).
  final String? reason;

  int get answered => (role != null ? 1 : 0) + (transfer != null ? 1 : 0);

  @override
  List<Object?> get props => [roleId, role, transfer, reason];
}

/// Linha do histórico da carteira.
class PointsEntry extends Equatable {
  const PointsEntry({
    required this.label,
    required this.points,
    required this.date,
  });

  final String label;
  final int points;
  final String date;

  @override
  List<Object?> get props => [label, points, date];
}

/// De onde vem o cupom: do próprio serviço, de um app de transporte
/// parceiro ou de um lugar de rolê (hipótese, Q-27/Q-28).
enum CouponKind { servico, transporte, role }

/// Cupom trocado por pontos (hipótese, Q-27/Q-28). O código só aparece
/// depois de trocar.
class Coupon extends Equatable {
  const Coupon({
    required this.id,
    required this.value,
    required this.title,
    required this.detail,
    required this.cost,
    required this.kind,
    required this.code,
    required this.validUntil,
    required this.action,
    this.partner,
    this.roleId,
    this.isNew = false,
  });

  final String id;

  /// Valor grande no card: "R$ 5", "15%", "Drink".
  final String value;

  /// "no próximo transfer".
  final String title;

  /// Regra em uma linha.
  final String detail;
  final int cost;
  final CouponKind kind;

  /// Nome do parceiro ("99", "Uber", "Casa Astral"); null = do serviço.
  final String? partner;

  /// Rolê do cupom (tipo [CouponKind.role]).
  final String? roleId;
  final String code;

  /// "Até 30 dez".
  final String validUntil;

  /// Segunda ação do botão segmentado: "Abrir na 99", "Usar no transfer".
  final String action;
  final bool isNew;

  /// "R$ 5 no próximo transfer".
  String get fullTitle => '$value $title';

  @override
  List<Object?> get props => [id];
}

/// Um dia dentro de uma pasta de viagem: "Sexta, 14 nov" (com datas) ou
/// "Dia 1" (sem). Ela separa à mão ou a Maré organiza (D-28).
class FolderDay extends Equatable {
  const FolderDay({
    required this.id,
    required this.label,
    this.roleIds = const [],
  });

  final String id;

  /// "Sexta, 14 nov" ou "Dia 1".
  final String label;
  final List<String> roleIds;

  FolderDay copyWith({List<String>? roleIds}) =>
      FolderDay(id: id, label: label, roleIds: roleIds ?? this.roleIds);

  @override
  List<Object?> get props => [id, label, roleIds];
}

/// Pasta de viagem nos Salvos (ref. pastas do Pinterest, D-28). A pasta
/// [tripId] é a da viagem atual: o nome vem das datas ("Recife, 14 a 16
/// nov") e os dias também, quando ela já informou.
class SavedFolder extends Equatable {
  const SavedFolder({
    required this.id,
    required this.name,
    this.roleIds = const [],
    this.days = const [],
  });

  static const tripId = 'viagem';

  final String id;

  /// Nome que ela deu. Na pasta da viagem é ignorado (vem das datas).
  final String name;

  /// Rolês na ordem em que salvou.
  final List<String> roleIds;
  final List<FolderDay> days;

  bool get isTrip => id == tripId;

  /// Rolês que ainda não estão em nenhum dia.
  List<String> get unsorted {
    final inDays = {for (final d in days) ...d.roleIds};
    return [for (final id in roleIds) if (!inDays.contains(id)) id];
  }

  SavedFolder copyWith({List<String>? roleIds, List<FolderDay>? days}) =>
      SavedFolder(
        id: id,
        name: name,
        roleIds: roleIds ?? this.roleIds,
        days: days ?? this.days,
      );

  @override
  List<Object?> get props => [id, name, roleIds, days];
}
