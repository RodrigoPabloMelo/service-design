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
  static const transferPickup = 'Sáb, 17h30';
  static const transferBack = 'Sáb, 23h30';
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

  /// Histórico de antes desta saída.
  static const pointsHistory = [
    PointsEntry(label: 'Avaliou o Paço do Frevo', points: 20, date: '14 nov'),
    PointsEntry(label: 'Avaliou o Mercado da Boa Vista', points: 20,
        date: '14 nov'),
  ];

  static int get startingPoints =>
      pointsHistory.fold(0, (sum, e) => sum + e.points);

  /// Cupons do próprio serviço (sem parceiro inventado).
  static const coupons = [
    Coupon(
      id: 'transfer-5',
      title: r'R$ 5 no próximo transfer',
      detail: 'Com motorista parceira',
      cost: 60,
    ),
    Coupon(
      id: 'grupo-10',
      title: '10% num rolê em grupo',
      detail: 'Só com mulheres, com guia',
      cost: 100,
    ),
  ];
}
