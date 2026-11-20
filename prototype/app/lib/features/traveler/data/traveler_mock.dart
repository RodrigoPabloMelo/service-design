import 'package:studio_app/features/travel_agent/data/travel_agent_mock.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';
import 'package:studio_app/features/traveler/domain/traveler_entities.dart';

/// Dados da viajante (conta, viagem, transfer, pontos). Tudo mock e, onde
/// a regra ainda está aberta, **(hipótese)**: pontos e cupons (Q-27, Q-28),
/// preço do transfer (Q-02, Q-03), meio de pagamento (Q-05).
abstract final class TravelerMock {
  static const travelerName = 'Camila';

  /// Cidade do piloto e mês da viagem (nome da pasta de salvos).
  static const city = 'Recife';
  static const tripMonth = 'nov';

  /// "Recife, 14 a 16 nov" — ou "Recife, nov" antes de informar datas.
  static String folderName(TripInfo? trip) =>
      '$city, ${trip?.dates ?? tripMonth}';

  /// Nome que aparece na pasta: a da viagem segue as datas.
  static String folderLabel(SavedFolder folder, TripInfo? trip) =>
      folder.isTrip ? folderName(trip) : folder.name;

  static const _weekdays = [
    'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo', //
  ];

  /// "Sexta, 14 nov" — o calendário do mock é o de nov/2025 (sex 14 a dom
  /// 16, igual ao roteiro da Maré).
  static String dayLabel(int day) =>
      '${_weekdays[DateTime(2025, 11, day).weekday - 1]}, $day $tripMonth';

  /// Dias da viagem a partir do rótulo das datas ("14 a 16 nov").
  static List<FolderDay> daysOf(TripInfo trip) {
    final m = RegExp(r'(\d+) a (\d+)').firstMatch(trip.dates);
    if (m == null) return const [];
    final from = int.parse(m.group(1)!), to = int.parse(m.group(2)!);
    return [
      for (var d = from; d <= to; d++) FolderDay(id: 'd$d', label: dayLabel(d)),
    ];
  }

  /// Sugestão de nome para a próxima viagem no sheet "Salvar em".
  static const newFolderHint = 'Olinda, dez';

  /// Opções de datas no card do agente. Todas cobrem o fim de semana do
  /// roteiro mock (sex 14 a dom 16).
  static const dateOptions = ['13 a 16 nov', '14 a 16 nov', '14 a 17 nov'];
  static const defaultDates = '14 a 16 nov';

  /// Hospedagens genéricas (sem nome de hotel real: a escolha é dela).
  static const stays = [
    Stay(
      id: 'boa-viagem',
      name: 'Hotel em Boa Viagem',
      neighborhood: 'Boa Viagem',
      location: GeoPoint(-8.1180, -34.8952),
    ),
    Stay(
      id: 'recife-antigo',
      name: 'Pousada no Recife Antigo',
      neighborhood: 'Recife Antigo',
      location: GeoPoint(-8.0630, -34.8715),
    ),
    Stay(
      id: 'gracas',
      name: 'Apartamento nas Graças',
      neighborhood: 'Graças',
      location: GeoPoint(-8.0470, -34.8990),
    ),
  ];

  static Stay stayById(String id) => stays.firstWhere((s) => s.id == id);

  /// Viagem já informada (cenários "já em Recife" e "depois").
  static final trip = TripInfo(dates: defaultDates, stay: stays.first);

  // ── Transfer com motorista parceira (D-26) ─────────────────────────────
  /// Pessoa fictícia. Preço de mock (Q-02/Q-03): ida + volta.
  static const driverName = 'Ana Paula';
  static const driverCar = 'Sedan prata';
  static const transferPickup = 'Sex, 16h';
  static const transferBack = 'Sex, 19h';
  static const transferPrice = r'R$ 84';
  static const transferPriceDetail = r'Ida R$ 42 e volta R$ 42';
  static const paymentMethod = 'Cartão final 4242';

  static TransferBooking transferTo(String roleId) => TransferBooking(
        roleId: roleId,
        driverName: driverName,
        car: driverCar,
        pickup: transferPickup,
        back: transferBack,
        price: transferPrice,
        paidWith: paymentMethod,
      );

  /// Transfer já pago (cenários de depois da troca).
  static TransferBooking get bookedTransfer =>
      transferTo(TravelMock.swapToId);

  // ── Pontos (hipótese, Q-27) ────────────────────────────────────────────
  /// Pontos por avaliação respondida — premia o ato de avaliar, nunca a
  /// nota (Q-27: evitar viés).
  static const pointsPerRating = 20;

  /// Motivos opcionais (um toque).
  static const reasons = [
    'Lugar como no vídeo',
    'Entorno como descrito',
    'Volta tranquila',
    'Diferente do descrito',
  ];

  /// Histórico de antes desta saída (mais novo primeiro). Boas-vindas e a
  /// troca da 99 existem pra a carteira mostrar os três estados de cupom.
  static const pointsHistory = [
    PointsEntry(label: 'Avaliou o Paço do Frevo', points: 20, date: '14 nov'),
    PointsEntry(label: 'Avaliou o Mercado da Boa Vista', points: 20,
        date: '14 nov'),
    PointsEntry(label: 'Trocou por R\$ 8 na 99', points: -80, date: '12 nov'),
    PointsEntry(label: 'Boas-vindas', points: 160, date: '10 nov'),
  ];

  static int get startingPoints =>
      pointsHistory.fold(0, (sum, e) => sum + e.points);

  /// Cupons já trocados no começo (cenários "já em Recife" e "depois").
  static const startingRedeemed = {'99-corridas'};

  /// Cupons do serviço e de parceiros. Parceiros, valores e códigos são
  /// **(hipótese)** (Q-27, Q-28): nenhum acordo existe.
  static const coupons = [
    Coupon(
      id: 'transfer-5',
      value: r'R$ 5',
      title: 'no próximo transfer',
      detail: 'Com motorista parceira, ida ou volta. Um uso.',
      cost: 60,
      kind: CouponKind.servico,
      code: 'MARE5TRANSFER',
      validUntil: 'Até 30 dez',
      action: 'Usar no transfer',
      isNew: true,
    ),
    Coupon(
      id: 'uber-15',
      value: '15%',
      title: 'numa corrida na Uber',
      detail: 'Até R\$ 10 de desconto, em Recife e Olinda.',
      cost: 120,
      kind: CouponKind.transporte,
      partner: 'Uber',
      code: 'MAREUBER15',
      validUntil: 'Até 15 dez',
      action: 'Abrir na Uber',
      isNew: true,
    ),
    Coupon(
      id: '99-corridas',
      value: r'R$ 8',
      title: 'em 2 corridas na 99',
      detail: 'R\$ 4 em cada corrida, em qualquer cidade.',
      cost: 80,
      kind: CouponKind.transporte,
      partner: '99',
      code: 'MARE99X2',
      validUntil: 'Até 30 nov',
      action: 'Abrir na 99',
    ),
    Coupon(
      id: 'grupo-10',
      value: '10%',
      title: 'num rolê em grupo',
      detail: 'Só com mulheres, com guia.',
      cost: 100,
      kind: CouponKind.servico,
      code: 'MAREGRUPO10',
      validUntil: 'Até 31 jan',
      action: 'Usar no próximo',
    ),
    Coupon(
      id: 'casa-astral-drink',
      value: 'Drink',
      title: 'de boas-vindas na Casa Astral',
      detail: 'Mostre o código no balcão. Sexta e sábado.',
      cost: 200,
      kind: CouponKind.role,
      partner: 'Casa Astral',
      roleId: 'casa-astral',
      code: 'ASTRAL-MARE',
      validUntil: 'Até 20 dez',
      action: 'Mostrar no balcão',
    ),
  ];
}
