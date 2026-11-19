import 'package:flutter/material.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';

/// Folha modal da Maré (mesma configuração da folha de corridas): raio 36,
/// fundo `s0`, sem elevação, véu 35%.
Future<T?> showMareSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  final p = TravelPalette.of(context);
  return showModalBottomSheet<T>(
    context: context,
    sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
        ? AnimationStyle.noAnimation
        : const AnimationStyle(
            duration: Duration(milliseconds: 420),
            reverseDuration: Duration(milliseconds: 420),
          ),
    useRootNavigator: false,
    clipBehavior: Clip.antiAlias,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: p.s0,
    elevation: 0,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    shape: const RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(TravelSpace.rSheet)),
    ),
    builder: (_) => Theme(data: Theme.of(context), child: builder(context)),
  );
}

/// Aviso curto no rodapé ("Salvo em Recife, nov"). Camada sólida, sem
/// sombra.
void showMareNotice(BuildContext context, String text) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  final p = TravelPalette.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(text, style: TravelType.subhead.copyWith(color: p.s0)),
      backgroundColor: p.ink,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(
          TravelSpace.gutter, 0, TravelSpace.gutter, 96),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TravelSpace.rInner),
      ),
      duration: const Duration(seconds: 2),
    ));
}
