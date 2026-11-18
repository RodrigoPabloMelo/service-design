import 'package:flutter/widgets.dart';

/// Véus (scrims) abertos agora sobre a tela, na ordem em que entraram.
///
/// No web o canvas do Flutter não alcança as barras do navegador: no iPhone a
/// barra de status é pintada com o fundo da página. Sem isto, um modal
/// escurecia a tela e a barra de status ficava clara por cima — o overlay
/// parecia cortado. Quem pinta o fundo da página (`main_design.dart`) escuta
/// esta lista e aplica os mesmos véus sobre a cor base.
final pageScrims = ValueNotifier<Map<Object, Color>>(const {});

/// Liga ([color]) ou desliga (`null`) o véu de [owner]. Chame com `null` no
/// dispose de quem ligou.
void setPageScrim(Object owner, Color? color) {
  final atual = pageScrims.value;
  if (atual[owner] == color) return;
  final novo = Map<Object, Color>.of(atual);
  if (color == null) {
    novo.remove(owner);
  } else {
    novo[owner] = color;
  }
  pageScrims.value = novo;
}

/// [base] com todos os véus abertos por cima.
Color withPageScrims(Color base) =>
    pageScrims.value.values.fold(base, (c, v) => Color.alphaBlend(v, c));

/// Liga o véu de toda rota modal com barreira (showModalBottomSheet,
/// showDialog) enquanto ela está na pilha.
class PageScrimObserver extends NavigatorObserver {
  void _on(Route<dynamic>? route) {
    if (route is! ModalRoute) return;
    final cor = route.barrierColor;
    if (cor != null && cor.a > 0) setPageScrim(route, cor);
  }

  void _off(Route<dynamic>? route) {
    if (route != null) setPageScrim(route, null);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _on(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _off(route);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _off(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _off(oldRoute);
    _on(newRoute);
  }
}
