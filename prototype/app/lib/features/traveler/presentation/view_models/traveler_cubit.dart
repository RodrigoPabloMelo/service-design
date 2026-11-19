import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studio_app/core/di/app_dependencies.dart';
import 'package:studio_app/features/travel_agent/data/travel_agent_mock.dart';
import 'package:studio_app/features/traveler/data/traveler_mock.dart';
import 'package:studio_app/features/traveler/domain/traveler_entities.dart';

part 'traveler_state.dart';

/// Estado da viajante que atravessa as telas: conta, salvos, viagem,
/// transfer pago e pontos. Um só por app (get_it) — o Explorar, o agente,
/// Salvos e Perfil leem e escrevem aqui.
class TravelerCubit extends Cubit<TravelerState> {
  TravelerCubit([TravelerState? initial])
      : super(initial ?? const TravelerState());

  /// Já em Recife: conta criada, viagem informada (cena 5 do storyboard).
  factory TravelerCubit.inRecife() => TravelerCubit(_withTripDays(
        TravelerState(
          account: const TravelerAccount(
            name: TravelerMock.travelerName,
            provider: AccountProvider.google,
          ),
          trip: TravelerMock.trip,
          points: TravelerMock.startingPoints,
          history: TravelerMock.pointsHistory,
          redeemed: TravelerMock.startingRedeemed,
        ),
      ));

  /// Depois do rolê: transfer pago e usado, avaliação pendente (cena 8).
  factory TravelerCubit.afterOuting() => TravelerCubit(
        TravelerCubit.inRecife().state.copyWith(
          transfer: TravelerMock.bookedTransfer,
        ),
      );

  /// Com datas informadas, a pasta da viagem ganha os dias delas (se ela
  /// ainda não tiver separado nenhum).
  static TravelerState _withTripDays(TravelerState s) {
    final trip = s.trip;
    if (trip == null) return s;
    return s.copyWith(folders: [
      for (final f in s.folders)
        f.isTrip && f.days.isEmpty
            ? f.copyWith(days: TravelerMock.daysOf(trip))
            : f,
    ]);
  }

  bool get hasAccount => state.account != null;

  /// Telas do storyboard que abrem num momento da viagem (já em Recife,
  /// depois do rolê): completa o que faltar no estado compartilhado, sem
  /// apagar o que ela já fez na sessão.
  void ensureMoment({bool transferDone = false}) {
    final seed = transferDone
        ? TravelerCubit.afterOuting().state
        : TravelerCubit.inRecife().state;
    emit(_withTripDays(state.copyWith(
      account: state.account ?? seed.account,
      trip: state.trip ?? seed.trip,
      transfer: transferDone ? (state.transfer ?? seed.transfer) : null,
      points: state.history.isEmpty ? seed.points : null,
      history: state.history.isEmpty ? seed.history : null,
      redeemed: state.history.isEmpty ? seed.redeemed : null,
      outingDone: transferDone ? true : null,
    )));
  }

  void signIn(AccountProvider provider) {
    emit(state.copyWith(
      account: TravelerAccount(
        name: TravelerMock.travelerName,
        provider: provider,
      ),
    ));
  }

  /// Salvar pede conta (D-16): a view abre a conta rápida antes. Sem conta,
  /// não salva. Atalho: salva na pasta da viagem (ou tira de todas).
  void toggleSaved(String roleId) {
    if (state.isSaved(roleId)) return unsave(roleId);
    saveTo(SavedFolder.tripId, roleId);
  }

  /// Salva o rolê numa pasta (sheet "Salvar em", D-28).
  void saveTo(String folderId, String roleId) {
    if (!hasAccount) return;
    _editFolder(folderId, (f) {
      if (f.roleIds.contains(roleId)) return f;
      return f.copyWith(roleIds: [...f.roleIds, roleId]);
    });
  }

  /// Tira o rolê de todas as pastas (e dos dias delas).
  void unsave(String roleId) {
    emit(state.copyWith(folders: [
      for (final f in state.folders)
        f.copyWith(
          roleIds: [for (final id in f.roleIds) if (id != roleId) id],
          days: [
            for (final d in f.days)
              d.copyWith(
                  roleIds: [for (final id in d.roleIds) if (id != roleId) id]),
          ],
        ),
    ]));
  }

  /// Nova viagem. Devolve o id da pasta criada.
  String createFolder(String name) {
    final id = 'pasta-${state.folders.length}';
    emit(state.copyWith(folders: [
      ...state.folders,
      SavedFolder(id: id, name: name.trim()),
    ]));
    return id;
  }

  /// Novo dia na pasta: o dia seguinte às datas da viagem ou "Dia N".
  /// Devolve o id do dia.
  String addDay(String folderId) {
    final f = state.folderById(folderId);
    final dated = [
      for (final d in f.days)
        if (d.id.startsWith('d')) int.tryParse(d.id.substring(1)),
    ].whereType<int>().toList();
    final FolderDay day;
    if (dated.isNotEmpty) {
      final next = dated.reduce((a, b) => a > b ? a : b) + 1;
      day = FolderDay(id: 'd$next', label: TravelerMock.dayLabel(next));
    } else {
      final n = f.days.length + 1;
      day = FolderDay(id: 'n$n', label: 'Dia $n');
    }
    _editFolder(folderId, (f) => f.copyWith(days: [...f.days, day]));
    return day.id;
  }

  /// Separa rolês por dia (à mão, D-28). [dayId] null = "Sem dia".
  void moveToDay(String folderId, Iterable<String> roleIds, String? dayId) {
    final ids = roleIds.toSet();
    _editFolder(folderId, (f) => f.copyWith(days: [
          for (final d in f.days)
            d.copyWith(roleIds: [
              for (final id in d.roleIds) if (!ids.contains(id)) id,
              if (d.id == dayId)
                for (final id in f.roleIds) if (ids.contains(id)) id,
            ]),
        ]));
  }

  void _editFolder(String id, SavedFolder Function(SavedFolder) edit) {
    emit(state.copyWith(folders: [
      for (final f in state.folders) f.id == id ? edit(f) : f,
    ]));
  }

  void setTrip(TripInfo trip) =>
      emit(_withTripDays(state.copyWith(trip: trip)));

  void bookTransfer(TransferBooking booking) =>
      emit(state.copyWith(transfer: booking));

  /// Registra a avaliação e devolve os pontos ganhos (por resposta, não
  /// pela nota — Q-27). Avaliar de novo a mesma saída não soma.
  int rate(OutingRating rating) {
    if (rating.answered == 0) return 0;
    if (state.ratings.any((r) => r.roleId == rating.roleId)) return 0;
    final earned = rating.answered * TravelerMock.pointsPerRating;
    emit(state.copyWith(
      ratings: [...state.ratings, rating],
      points: state.points + earned,
      history: [
        PointsEntry(
          label: 'Avaliou o ${TravelMock.roleById(rating.roleId).shortName}'
              '${rating.transfer != null ? ' e o transfer' : ''}',
          points: earned,
          date: '15 nov',
        ),
        ...state.history,
      ],
    ));
    return earned;
  }

  /// Troca pontos por cupom. Sem saldo, não troca.
  bool redeem(Coupon coupon) {
    if (state.points < coupon.cost ||
        state.redeemed.contains(coupon.id)) {
      return false;
    }
    emit(state.copyWith(
      points: state.points - coupon.cost,
      redeemed: {...state.redeemed, coupon.id},
      history: [
        PointsEntry(
            label: 'Trocou por ${coupon.fullTitle}',
            points: -coupon.cost,
            date: '15 nov'),
        ...state.history,
      ],
    ));
    return true;
  }
}

/// A instância do app. Registrada em `setupDesignDependencies`; nos testes
/// (sem DI) nasce aqui na primeira leitura.
TravelerCubit travelerCubit() {
  try {
    return injector.get<TravelerCubit>();
  } on Object {
    final cubit = TravelerCubit();
    injector.registerSingleton<TravelerCubit>(cubit);
    return cubit;
  }
}
