import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import 'package:studio_app/design_browser_stub.dart'
    if (dart.library.js_interop) 'package:studio_app/design_browser_web.dart'
    as impl;

// Fronteira única com as APIs do browser usadas pelo chrome de design:
// clipboard de imagem, localStorage, abrir link e fundo da página. Web-only via
// `dart:js_interop` (SDK, sem dependência nova — Inviolável #4), atrás de
// import condicional para o build mobile continuar compilando.

/// Copia um PNG para a área de transferência do sistema.
///
/// `Clipboard.setData` do Flutter só carrega texto; imagem exige a Clipboard
/// API do browser (`navigator.clipboard.write`), então a implementação real é
/// web-only via `dart:js_interop` — SDK, sem dependência nova (Inviolável #4).
/// Fora do web cai no stub e devolve `false`, sem quebrar o build mobile.
///
/// Devolve `false` quando o browser recusa: contexto não seguro (fora de
/// https/localhost), permissão `clipboard-write` negada, ou navegador sem
/// suporte a imagem no clipboard. Chame sempre a partir de um gesto do
/// usuário — fora de gesto o Chrome nega.
///
/// Webviews embutidas (o pane de preview do Claude Code, por exemplo) negam
/// `clipboard-write` por padrão: ali falha independente do código. O Chrome
/// normal libera em mesma origem + gesto.
Future<bool> copyPngToClipboard(Uint8List bytes) =>
    impl.copyPngToClipboard(bytes);

/// Lê uma chave do localStorage. `null` fora do web ou chave ausente.
String? readLocal(String key) => impl.readLocal(key);

/// Grava no localStorage. No-op fora do web.
void writeLocal(String key, String value) => impl.writeLocal(key, value);

/// Remove uma chave do localStorage. No-op fora do web.
void removeLocal(String key) => impl.removeLocal(key);

/// Abre a URL em outra aba. Só http(s) — ver `docLinkUrl`, que valida antes.
/// No-op fora do web.
void openUrl(String url) => impl.openUrl(url);

/// URL do build de uma versão: `<origem>/v/<commit>/#<rota>`.
///
/// Sai da própria origem — o preview publicado se serve de
/// `<projeto>.design.loomi.ia.br`, e o deploy copia cada build para o prefixo
/// `v/<commit>/`. Devolve null onde não existe build publicado: fora do web e
/// em localhost (o dev server só serve o build atual).
String? versionUrl(String commit, String route) =>
    impl.versionUrl(commit, route);

/// Se existe build publicado naquele prefixo.
///
/// Pergunta ao servidor em vez de deduzir pela origem: assim vale no preview
/// hospedado e também local, quando o build antigo é posto em
/// `web/v/<commit>/`. Falso fora do web.
Future<bool> versionExists(String commit) => impl.versionExists(commit);

/// Um iframe com a URL, para mostrar o build de uma versão antiga dentro da
/// doc. Fora do web devolve null — quem chama mostra a ficha da versão.
Widget? versionFrame(String url) => impl.versionFrame(url);

/// Pinta o fundo da página (fora do canvas do Flutter) com [color].
///
/// No celular o navegador mostra esse fundo atrás das próprias barras (a de
/// status em cima e a de navegação embaixo, no Safari do iPhone): com a cor
/// do app, as barras seguem o app em vez de cortá-lo com faixas brancas.
/// Opaca; o alfa é ignorado. No-op fora do web.
void setPageColor(Color color) => impl.setPageColor(
    '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}');

/// Tira o `#` da URL (`/#/docs` vira `/docs`).
///
/// Depende de o servidor devolver o index em qualquer caminho — o dev server
/// do Flutter e o preview estático já fazem esse fallback de SPA. No-op fora
/// do web.
void usePrettyUrls() => impl.usePrettyUrls();
