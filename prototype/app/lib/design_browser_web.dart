import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

// APIs do browser via dart:js_interop (SDK — sem dependência nova). Só o
// mínimo de cada: Blob/ClipboardItem/clipboard.write, localStorage e
// window.open.

@JS('navigator')
external _Navigator get _navigator;

extension type _Navigator._(JSObject _) implements JSObject {
  external _Clipboard? get clipboard;
}

@JS('localStorage')
external _Storage? get _storage;

extension type _Storage._(JSObject _) implements JSObject {
  external String? getItem(String key);
  external void setItem(String key, String value);
  external void removeItem(String key);
}

@JS('window.open')
external void _open(String url, String target);

@JS('document')
external _Document get _document;

extension type _Document._(JSObject _) implements JSObject {
  external _Element createElement(String tag);
  external _Element? querySelector(String selectors);
  external _Styled? get documentElement;
  external _Styled? get body;
}

extension type _Styled._(JSObject _) implements JSObject {
  external _Style get style;
}

extension type _Style._(JSObject _) implements JSObject {
  external set backgroundColor(String value);
}

extension type _Element._(JSObject _) implements JSObject {}

extension type _Clipboard._(JSObject _) implements JSObject {
  external JSPromise<JSAny?> write(JSArray<_ClipboardItem> data);
}

@JS('ClipboardItem')
extension type _ClipboardItem._(JSObject _) implements JSObject {
  external factory _ClipboardItem(JSObject items);
}

@JS('Blob')
extension type _Blob._(JSObject _) implements JSObject {
  external factory _Blob(JSArray<JSAny?> parts, JSObject options);
}

Future<bool> copyPngToClipboard(Uint8List bytes) async {
  final clipboard = _navigator.clipboard;
  // Safari antigo e contexto inseguro simplesmente não expõem o objeto.
  if (clipboard == null) return false;

  try {
    final options = JSObject()..setProperty('type'.toJS, 'image/png'.toJS);
    final blob = _Blob([bytes.toJS].toJS, options);
    final payload = JSObject()..setProperty('image/png'.toJS, blob);
    await clipboard.write([_ClipboardItem(payload)].toJS).toDart;
    return true;
  } catch (_) {
    // NotAllowedError (permissão / fora de gesto) e navegador sem suporte a
    // imagem no clipboard caem aqui. Quem chama avisa o usuário.
    return false;
  }
}

// localStorage estoura em modo privado antigo e quando o site está com dados
// bloqueados — daí o try/catch em toda leitura e escrita.

String? readLocal(String key) {
  try {
    return _storage?.getItem(key);
  } catch (_) {
    return null;
  }
}

void writeLocal(String key, String value) {
  try {
    _storage?.setItem(key, value);
  } catch (_) {}
}

void removeLocal(String key) {
  try {
    _storage?.removeItem(key);
  } catch (_) {}
}

/// `noopener`: aba nova sem acesso ao `window` desta — o link é digitado pelo
/// usuário, mas não custa nada fechar essa porta.
void openUrl(String url) => _open(url, '_blank noopener');

/// URL do build de uma versão. Null em localhost: o dev server serve só o
/// build atual, não existe `/v/<commit>/` para apontar.
/// `index.html` explícito no caminho, e não `/v/<commit>/`: nem o dev server
/// nem o CloudFront resolvem diretório para índice — o caminho de diretório
/// cai no fallback de SPA e carrega o app ATUAL, não a versão.
String? versionUrl(String commit, String route) =>
    '${Uri.base.origin}/v/$commit/index.html#$route';

@JS('fetch')
external JSPromise<_Response> _fetch(String url);

extension type _Response._(JSObject _) implements JSObject {
  external bool get ok;
}

/// Pergunta ao servidor se o build daquela versão está publicado.
///
/// No `flutter_bootstrap.js` do prefixo, e não no index.html: num SPA com
/// fallback o index responde 200 mesmo sem o build existir.
///
/// GET e não HEAD: o dev server do Flutter responde 404 a HEAD (verificado),
/// então o probe dava falso negativo em local. O arquivo tem ~9 KB.
Future<bool> versionExists(String commit) async {
  try {
    final r = await _fetch(
      '${Uri.base.origin}/v/$commit/flutter_bootstrap.js',
    ).toDart;
    return r.ok;
  } catch (_) {
    return false;
  }
}

// Cada URL vira uma view factory registrada uma vez. O registro é global e
// idempotente pelo Set — registrar duas vezes o mesmo id estoura.
final _registradas = <String>{};

Widget? versionFrame(String url) {
  final id = 'versao-$url';
  if (_registradas.add(id)) {
    ui_web.platformViewRegistry.registerViewFactory(id, (int _) {
      final iframe = _document.createElement('iframe');
      iframe
        ..setProperty('src'.toJS, url.toJS)
        ..setProperty('style'.toJS, 'border:0;width:100%;height:100%'.toJS)
        // O build antigo é nosso, mesma origem — mas sandbox restringe o que
        // ele pode fazer com a página que o hospeda de qualquer forma.
        ..setProperty('sandbox'.toJS, 'allow-scripts allow-same-origin'.toJS)
        ..setProperty('loading'.toJS, 'lazy'.toJS);
      return iframe;
    });
  }
  return HtmlElementView(viewType: id);
}

@JS('getComputedStyle')
external _Computed _getComputedStyle(JSObject element);

extension type _Computed._(JSObject _) implements JSObject {
  external String get paddingTop;
  external String get paddingRight;
  external String get paddingBottom;
  external String get paddingLeft;
}

/// `viewport-fit=cover` na meta viewport: sem ele o Safari do iPhone devolve
/// zero em `env(safe-area-inset-*)`. Tem que ser aqui e não no index.html — o
/// engine apaga qualquer meta viewport da página e cria a dele (`flt-viewport`)
/// antes do `main()`.
void enableSafeArea() {
  final meta = _document.querySelector('meta[name="viewport"]');
  if (meta == null) return;
  final atual = meta.getProperty<JSString?>('content'.toJS)?.toDart ?? '';
  if (atual.contains('viewport-fit')) return;
  meta.setProperty('content'.toJS, '$atual, viewport-fit=cover'.toJS);
}

JSObject? _safeAreaProbe;

/// Safe area do navegador (notch, barra de gestos do iPhone). O engine web do
/// Flutter não lê `env(safe-area-inset-*)` — o `MediaQuery.padding` chega
/// zerado —, então medimos num elemento invisível que usa os `env()` como
/// padding.
EdgeInsets safeAreaInsets() {
  try {
    var probe = _safeAreaProbe;
    if (probe == null) {
      probe = _document.createElement('div');
      probe.setProperty(
        'style'.toJS,
        'position:fixed;top:0;left:0;width:0;height:0;visibility:hidden;'
                'pointer-events:none;'
                'padding:env(safe-area-inset-top) env(safe-area-inset-right) '
                'env(safe-area-inset-bottom) env(safe-area-inset-left)'
            .toJS,
      );
      (_document.body as JSObject?)
          ?.callMethod<JSAny?>('appendChild'.toJS, probe);
      _safeAreaProbe = probe;
    }
    final s = _getComputedStyle(probe);
    double px(String v) => double.tryParse(v.replaceAll('px', '')) ?? 0;
    return EdgeInsets.fromLTRB(
      px(s.paddingLeft),
      px(s.paddingTop),
      px(s.paddingRight),
      px(s.paddingBottom),
    );
  } catch (_) {
    return EdgeInsets.zero;
  }
}

/// URL sem hash: `usePathUrlStrategy` é do SDK (flutter_web_plugins), não é
/// dependência nova.
void usePrettyUrls() => usePathUrlStrategy();

/// Fundo do `<html>` e do `<body>`: é o que o navegador mostra fora do canvas
/// do Flutter — no Safari do iPhone, atrás da barra de status e da barra de
/// baixo. E a `theme-color` própria (`#mare-theme`, do index.html), que pinta
/// a barra do Chrome no Android: a do engine (`#flutterweb-theme`) é apagada
/// pelo MaterialApp a cada build, que manda um estilo de barra sem cor.
void setPageColor(String css) {
  _document.documentElement?.style.backgroundColor = css;
  _document.body?.style.backgroundColor = css;
  _document
      .querySelector('meta#mare-theme')
      ?.setProperty('content'.toJS, css.toJS);
}
