import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_app/design_doc_notes.dart';
import 'package:studio_app/features/feature_registry.dart';

final _tela = RegisteredScreen(
  title: 'Login',
  route: '/demo/login',
  flow: 'Demo',
  builder: (_) => const SizedBox.shrink(),
);

void main() {
  test('comando aponta para a tela exata e para o registry', () {
    final comando = claudeNotesPrompt(_tela);
    expect(comando, contains('"Login"'));
    expect(comando, contains('/demo/login'));
    expect(comando, contains('Demo'));
    expect(comando, contains('feature_registry.dart'));
    expect(comando.trimRight(), endsWith('Descrição:'));
  });
}
