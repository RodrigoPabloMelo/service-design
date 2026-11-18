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
  factory TravelerCubit.inRecife() => TravelerCubit(TravelerState(
        account: const TravelerAccount(
          name: TravelerMock.travelerName,
          provider: AccountProvider.google,
        ),
        trip: TravelerMock.trip,
        points: TravelerMock.startingPoints,
        history: TravelerMock.pointsHistory,
      ));

  /// Depois do rolê: transfer pago e usado, avaliação pendente (cena 8).
  factory TravelerCubit.afterOuting() => TravelerCubit(
        TravelerCubit.inRecife().state.copyWith(
          transfer: TravelerMock.bookedTransfer,
        ),
      );

  bool get hasAccount => state.account != null;

  /// Telas do storyboard que abrem num momento da viagem (já em Recife,
  /// depois do rolê): completa o que faltar no estado compartilhado, sem
  /// apagar o que ela já fez na sessão.
  void ensureMoment({bool transferDone = false}) {
    final seed = transferDone
        ? TravelerCubit.afterOuting().state
        : TravelerCubit.inRecife().state;
    emit(state.copyWith(
      account: state.account ?? seed.account,
      trip: state.trip ?? seed.trip,
      transfer: transferDone ? (state.transfer ?? seed.transfer) : null,
      points: state.history.isEmpty ? seed.points : null,
      history: state.history.isEmpty ? seed.history : null,
      outingDone: transferDone ? true : null,
    ));
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
  /// não salva.
  void toggleSaved(String roleId) {
    if (!hasAccount) return;
    final saved = [...state.saved];
    if (!saved.remove(roleId)) saved.add(roleId);
    emit(state.copyWith(saved: saved));
  }

  void setTrip(TripInfo trip) => emit(state.copyWith(trip: trip));

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
            label: 'Trocou por ${coupon.title}',
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
