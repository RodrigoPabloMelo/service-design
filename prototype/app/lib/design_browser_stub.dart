import 'dart:typed_data';

import 'package:flutter/widgets.dart';

// Fora do web não há Clipboard API, localStorage nem aba nova — o loop de
// design é web. Aqui só garantimos que o build mobile compile; o Map em
// memória mantém a lógica de rascunho testável na VM.

final _mem = <String, String>{};

Future<bool> copyPngToClipboard(Uint8List bytes) async => false;

String? readLocal(String key) => _mem[key];

void writeLocal(String key, String value) => _mem[key] = value;

void removeLocal(String key) => _mem.remove(key);

void openUrl(String url) {}

String? versionUrl(String commit, String route) => null;

Future<bool> versionExists(String commit) async => false;

Widget? versionFrame(String url) => null;

void usePrettyUrls() {}

void setPageColor(String css) {}

void enableSafeArea() {}

EdgeInsets safeAreaInsets() => EdgeInsets.zero;
