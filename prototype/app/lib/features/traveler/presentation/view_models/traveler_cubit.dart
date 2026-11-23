import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studio_app/core/di/app_dependencies.dart';
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
        f.isTrip ? f.copyWith(days: _reconcileDays(f.days, trip)) : f,
    ]);
  }

  /// Encaixa os dias que ela já separou nas datas da viagem, sem perder
  /// rolê: um dia com data continua na mesma data; os "Dia N" (criados
  /// antes das datas) viram as datas na ordem. O que sobrar (mais dias que
  /// datas, ou datas fora do intervalo) fica no fim, como estava.
  static List<FolderDay> _reconcileDays(List<FolderDay> days, TripInfo trip) {
    final dated = TravelerMock.daysOf(trip);
    if (dated.isEmpty) return days;
    final byId = {for (final d in days) d.id: d};
    final undated = [for (final d in days) if (!d.id.startsWith('d')) d];
    final used = <String>{};
    var next = 0;
    final result = <FolderDay>[];
    for (final date in dated) {
      final same = byId[date.id];
      if (same != null) {
        used.add(same.id);
        result.add(date.copyWith(roleIds: same.roleIds));
      } else if (next < undated.length) {
        final manual = undated[next++];
        used.add(manual.id);
        result.add(date.copyWith(roleIds: manual.roleIds));
      } else {
        result.add(date);
      }
    }
    return [
      ...result,
      for (final d in days) if (!used.contains(d.id)) d,
    ];
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

  /// Registra a avaliação e devolve os pontos ganhos (D-30). Premia o
  /// ato, nunca a nota (Q-27): 20 por nota respondida e, uma vez por rolê,
  /// 10 por contar mais (texto ou foto — hipótese). Reenviar o mesmo rolê
  /// troca a avaliação e só paga o que for novo. O rascunho some.
  int rate(OutingRating rating) {
    if (rating.answered == 0) return 0;
    final prev = state.ratingFor(rating.roleId);
    final newAnswers = rating.answered - (prev?.answered ?? 0);
    final bonus = rating.detailed && !state.detailPaid.contains(rating.roleId)
        ? TravelerMock.pointsPerDetail
        : 0;
    final earned =
        (newAnswers > 0 ? newAnswers : 0) * TravelerMock.pointsPerRating +
            bonus;
    final what = prev == null
        ? 'Avaliou o ${rating.roleName}'
            '${rating.transferStars != null ? ' e o transfer' : ''}'
        : 'Contou mais sobre o ${rating.roleName}';
    emit(state.copyWith(
      ratings: [
        for (final r in state.ratings)
          if (r.roleId != rating.roleId) r,
        rating,
      ],
      drafts: {...state.drafts}..remove(rating.roleId),
      detailPaid: bonus > 0
          ? {...state.detailPaid, rating.roleId}
          : state.detailPaid,
      points: state.points + earned,
      history: earned == 0
          ? state.history
          : [
              PointsEntry(label: what, points: earned, date: '15 nov'),
              ...state.history,
            ],
    ));
    return earned;
  }

  /// Guarda o que ela começou e fechou sem enviar. Sem nota nem nada, apaga.
  void saveDraft(OutingRating draft) {
    final empty = draft.answered == 0 &&
        draft.tags.isEmpty &&
        !draft.detailed;
    emit(state.copyWith(
      drafts: empty
          ? ({...state.drafts}..remove(draft.roleId))
          : {...state.drafts, draft.roleId: draft},
    ));
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
