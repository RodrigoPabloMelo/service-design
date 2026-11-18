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

/// Cupom do próprio serviço trocado por pontos (hipótese, Q-27/Q-28).
class Coupon extends Equatable {
  const Coupon({
    required this.id,
    required this.title,
    required this.detail,
    required this.cost,
  });

  final String id;
  final String title;
  final String detail;
  final int cost;

  @override
  List<Object?> get props => [id];
}
