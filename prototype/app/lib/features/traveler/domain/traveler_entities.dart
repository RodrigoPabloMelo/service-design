import 'dart:typed_data';

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

/// Foto ou vídeo que ela anexou à avaliação (bytes do seletor — sem
/// `dart:io`, roda no web). Igualdade pelo id: nunca comparar bytes.
class ReviewPhoto extends Equatable {
  const ReviewPhoto({required this.id, required this.bytes, this.video = false});

  final String id;

  /// Bytes da foto; vazio no vídeo (o protótipo não decodifica quadro).
  final Uint8List bytes;
  final bool video;

  @override
  List<Object?> get props => [id];
}

/// Avaliação de uma saída (E-08, D-09, D-30): 0,5 a 5 estrelas pro rolê e,
/// se houve, pro transfer; motivos rápidos (chips da faixa da nota) e, se
/// ela quiser, texto e fotos.
class OutingRating extends Equatable {
  const OutingRating({
    required this.roleId,
    required this.roleName,
    this.roleStars,
    this.transferStars,
    this.tags = const [],
    this.text,
    this.photos = const [],
  });

  final String roleId;

  /// Nome curto do rolê (histórico da carteira). Vem de quem chama: o rolê
  /// pode ser só do Explorar, fora do `TravelMock`.
  final String roleName;

  /// 0,5 a 5, de meia em meia estrela. Null = não respondeu.
  final double? roleStars;
  final double? transferStars;

  /// Motivos rápidos escolhidos (chips da faixa da nota).
  final List<String> tags;
  final String? text;
  final List<ReviewPhoto> photos;

  /// Quantas notas ela deu (rolê, transfer).
  int get answered =>
      (roleStars != null ? 1 : 0) + (transferStars != null ? 1 : 0);

  /// Contou mais: escreveu ou mandou foto.
  bool get detailed =>
      (text?.trim().isNotEmpty ?? false) || photos.isNotEmpty;

  OutingRating copyWith({
    double? roleStars,
    double? transferStars,
    List<String>? tags,
    String? text,
    List<ReviewPhoto>? photos,
  }) =>
      OutingRating(
        roleId: roleId,
        roleName: roleName,
        roleStars: roleStars ?? this.roleStars,
        transferStars: transferStars ?? this.transferStars,
        tags: tags ?? this.tags,
        text: text ?? this.text,
        photos: photos ?? this.photos,
      );

  @override
  List<Object?> get props =>
      [roleId, roleName, roleStars, transferStars, tags, text, photos];
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

  /// Aviso depois da segunda ação ("Aplicado no próximo transfer").
  String get actionNotice => switch (kind) {
        CouponKind.transporte => 'Abrindo a $partner com o código',
        CouponKind.servico => 'Aplicado $title',
        CouponKind.role => 'Mostre o código no balcão',
      };
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
