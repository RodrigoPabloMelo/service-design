part of 'traveler_cubit.dart';

class TravelerState extends Equatable {
  const TravelerState({
    this.account,
    this.saved = const [],
    this.trip,
    this.transfer,
    this.ratings = const [],
    this.points = 0,
    this.history = const [],
    this.redeemed = const {},
    this.outingDone = false,
  });

  /// Null = ainda sem conta (navega e vê tudo sem login — D-16).
  final TravelerAccount? account;

  /// Pasta da viagem (D-24), na ordem em que salvou.
  final List<String> saved;

  /// Datas e hospedagem informadas ao agente.
  final TripInfo? trip;

  /// Transfer pago no app (D-26).
  final TransferBooking? transfer;
  final List<OutingRating> ratings;
  final int points;
  final List<PointsEntry> history;
  final Set<String> redeemed;

  /// A saída com transfer já aconteceu (cena 8): o atalho do dia some.
  final bool outingDone;

  TravelerState copyWith({
    TravelerAccount? account,
    List<String>? saved,
    TripInfo? trip,
    TransferBooking? transfer,
    List<OutingRating>? ratings,
    int? points,
    List<PointsEntry>? history,
    Set<String>? redeemed,
    bool? outingDone,
  }) =>
      TravelerState(
        account: account ?? this.account,
        saved: saved ?? this.saved,
        trip: trip ?? this.trip,
        transfer: transfer ?? this.transfer,
        ratings: ratings ?? this.ratings,
        points: points ?? this.points,
        history: history ?? this.history,
        redeemed: redeemed ?? this.redeemed,
        outingDone: outingDone ?? this.outingDone,
      );

  @override
  List<Object?> get props =>
      [
        account,
        saved,
        trip,
        transfer,
        ratings,
        points,
        history,
        redeemed,
        outingDone,
      ];
}
