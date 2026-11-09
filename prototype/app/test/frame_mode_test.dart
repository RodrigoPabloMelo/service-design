import 'package:flutter_test/flutter_test.dart';
import 'package:studio_app/design_browser.dart';
import 'package:studio_app/design_canvas.dart';

void main() {
  test('sem nada salvo, cai em plano', () {
    removeLocal('loomi.hub.frame.v1');
    expect(readFrameMode(), FrameMode.plano);
  });

  test('a moldura escolhida volta no próximo acesso', () {
    saveFrameMode(FrameMode.android);
    expect(readFrameMode(), FrameMode.android);
  });

  test('valor desconhecido não derruba a página', () {
    writeLocal('loomi.hub.frame.v1', 'blackberry');
    expect(readFrameMode(), FrameMode.plano);
  });
}
