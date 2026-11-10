import 'dart:async';
import 'dart:ui' show FontFeature, FramePhase, FrameTiming;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Selo de desempenho do preview, ligado por `?fps=1` na URL.
///
/// Dos últimos 2 s com movimento mostra: fps médio, o pior intervalo entre
/// quadros (pega travada de GPU, que atrasa o quadro seguinte) e o tempo
/// médio de build e de raster que o engine reporta. "Parado" = nada sendo
/// redesenhado, que é o ideal com a tela em repouso.
///
/// Pra comparar no celular: `/agente?fps=1` (efeitos leves) contra
/// `/agente?fps=1&efeitos=completo` (visual cheio).
class DesignPerfHud extends StatefulWidget {
  const DesignPerfHud({required this.child, super.key});

  final Widget child;

  /// `?fps=1` na URL. Ler no `main()`: o redirect de `/` descarta a query.
  static bool requested([Uri? uri]) =>
      (uri ?? Uri.base).queryParameters['fps'] == '1';

  @override
  State<DesignPerfHud> createState() => _DesignPerfHudState();
}

class _DesignPerfHudState extends State<DesignPerfHud> {
  static const _windowMicros = 2000000;

  /// Intervalo maior que isto = a tela estava parada, não um quadro lento.
  static const _idleGapMicros = 200000;

  final _timings = <FrameTiming>[];
  Timer? _refresh;
  String _label = 'medindo…';

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
    // Atualiza 2x por segundo, e só redesenha se o texto mudou: o selo não
    // pode manter a tela animando (estragaria a medida em repouso).
    _refresh = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => _update(),
    );
  }

  @override
  void dispose() {
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    _refresh?.cancel();
    super.dispose();
  }

  void _onTimings(List<FrameTiming> timings) => _timings.addAll(timings);

  static int _vsync(FrameTiming t) =>
      t.timestampInMicroseconds(FramePhase.vsyncStart);

  static String _ms(num micros) =>
      (micros / 1000).toStringAsFixed(1).replaceAll('.', ',');

  void _update() {
    if (_timings.isEmpty || !mounted) return;
    final from = _vsync(_timings.last) - _windowMicros;
    _timings.removeWhere((t) => _vsync(t) < from);

    var frames = 0, sum = 0, worst = 0, build = 0, raster = 0;
    int? prev;
    for (final t in _timings) {
      final v = _vsync(t);
      final gap = prev == null ? 0 : v - prev;
      prev = v;
      if (gap <= 0 || gap > _idleGapMicros) continue;
      frames++;
      sum += gap;
      if (gap > worst) worst = gap;
      build += t.buildDuration.inMicroseconds;
      raster += t.rasterDuration.inMicroseconds;
    }
    final label = frames == 0
        ? 'parado'
        : '${(1e6 * frames / sum).round()} fps\n'
            'pior ${_ms(worst)} ms\n'
            'build ${_ms(build / frames)}  raster ${_ms(raster / frames)}';
    if (label != _label) setState(() => _label = label);
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.maybePaddingOf(context)?.top ?? 0;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          Positioned(
            top: top + 4,
            right: 4,
            child: IgnorePointer(
              child: RepaintBoundary(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xB3000000),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    child: Text(
                      _label,
                      style: const TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontFamily: 'Inter',
                        fontSize: 11,
                        height: 1.3,
                        decoration: TextDecoration.none,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
