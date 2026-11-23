part of 'traveler_cubit.dart';

class TravelerState extends Equatable {
  const TravelerState({
    this.account,
    this.folders = const [SavedFolder(id: SavedFolder.tripId, name: '')],
    this.trip,
    this.transfer,
    this.ratings = const [],
    this.drafts = const {},
    this.detailPaid = const {},
    this.points = 0,
    this.history = const [],
    this.redeemed = const {},
    this.outingDone = false,
  });

  /// Null = ainda sem conta (navega e vê tudo sem login — D-16).
  final TravelerAccount? account;

  /// Pastas de viagem (D-24, D-28). A primeira é a da viagem atual.
  final List<SavedFolder> folders;

  /// Tudo o que ela salvou, sem repetir, na ordem em que salvou.
  List<String> get saved {
    final seen = <String>{};
    return [
      for (final f in folders)
        for (final id in f.roleIds)
          if (seen.add(id)) id,
    ];
  }

  bool isSaved(String roleId) =>
      folders.any((f) => f.roleIds.contains(roleId));

  SavedFolder folderById(String id) => folders.firstWhere((f) => f.id == id);

  /// Pasta onde o rolê está (a primeira, se estiver em várias).
  SavedFolder? folderOf(String roleId) {
    for (final f in folders) {
      if (f.roleIds.contains(roleId)) return f;
    }
    return null;
  }

  /// Datas e hospedagem informadas ao agente.
  final TripInfo? trip;

  /// Transfer pago no app (D-26).
  final TransferBooking? transfer;
  final List<OutingRating> ratings;

  /// Avaliação começada e fechada sem enviar, por rolê: reabrir devolve
  /// nota, motivos, texto e fotos (fechar nunca perde nada).
  final Map<String, OutingRating> drafts;

  /// Rolês cujo bônus de "contar mais" já foi pago (uma vez por rolê).
  final Set<String> detailPaid;

  /// A avaliação que ela enviou desse rolê, se enviou.
  OutingRating? ratingFor(String roleId) {
    for (final r in ratings) {
      if (r.roleId == roleId) return r;
    }
    return null;
  }

  final int points;
  final List<PointsEntry> history;
  final Set<String> redeemed;

  /// A saída com transfer já aconteceu (cena 8): o atalho do dia some.
  final bool outingDone;

  TravelerState copyWith({
    TravelerAccount? account,
    List<SavedFolder>? folders,
    TripInfo? trip,
    TransferBooking? transfer,
    List<OutingRating>? ratings,
    Map<String, OutingRating>? drafts,
    Set<String>? detailPaid,
    int? points,
    List<PointsEntry>? history,
    Set<String>? redeemed,
    bool? outingDone,
  }) =>
      TravelerState(
        account: account ?? this.account,
        folders: folders ?? this.folders,
        trip: trip ?? this.trip,
        transfer: transfer ?? this.transfer,
        ratings: ratings ?? this.ratings,
        drafts: drafts ?? this.drafts,
        detailPaid: detailPaid ?? this.detailPaid,
        points: points ?? this.points,
        history: history ?? this.history,
        redeemed: redeemed ?? this.redeemed,
        outingDone: outingDone ?? this.outingDone,
      );

  @override
  List<Object?> get props =>
      [
        account,
        folders,
        trip,
        transfer,
        ratings,
        drafts,
        detailPaid,
        points,
        history,
        redeemed,
        outingDone,
      ];
}
