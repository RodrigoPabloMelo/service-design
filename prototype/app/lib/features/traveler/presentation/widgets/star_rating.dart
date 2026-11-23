import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/features/explore/presentation/widgets/explore_ui.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';

/// Arredonda pra meia estrela mais perto, entre 0,5 e 5.
double halfStep(num v) => ((v * 2).round() / 2).clamp(0.5, 5).toDouble();

/// Cinco estrelas de 0,5 a 5 (D-30). Tocar na metade esquerda de uma
/// estrela dá meia; **segurar e arrastar** preenche ao vivo, com um tique de
/// haptic a cada meia estrela, e só entrega a nota ao soltar — nada pula
/// no meio do gesto. Cheia em `star` (amarelo, exceção 4 da skill), vazia
/// em contorno `ink` 24%. Alvo de 44 por estrela; a estrela onde a nota
/// para dá um pulo de 150 ms (Reduce Motion: parada).
class StarRow extends StatefulWidget {
  const StarRow({
    required this.value,
    required this.onChanged,
    this.size = 30,
    this.semanticPrefix,
    super.key,
  });

  /// 0,5 a 5; null = nada escolhido.
  final double? value;
  final ValueChanged<double> onChanged;
  final double size;

  /// O que está sendo avaliado ("Transfer com Ana"), lido antes da nota
  /// quando há mais de uma fileira na tela.
  final String? semanticPrefix;

  @override
  State<StarRow> createState() => _StarRowState();
}

class _StarRowState extends State<StarRow> {
  /// Nota enquanto o dedo arrasta (null fora do gesto).
  double? _drag;

  double get _cell => widget.size + 14 < 44 ? 44 : widget.size + 14;

  /// Posição do dedo → nota: metade esquerda da estrela = meia; do
  /// centro pra direita = inteira (tocar no meio dá a estrela cheia).
  double _valueAt(double dx) {
    final x = dx / _cell;
    final i = x.floor();
    return halfStep(i + (x - i < 0.5 ? 0.5 : 1));
  }

  void _dragTo(double dx) {
    final v = _valueAt(dx);
    if (v == _drag) return;
    HapticFeedback.selectionClick();
    setState(() => _drag = v);
  }

  void _commit() {
    final v = _drag;
    setState(() => _drag = null);
    if (v != null) widget.onChanged(v);
  }

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final v = _drag ?? widget.value ?? 0;
    // Estrela onde a nota termina (recebe o pulo quando o dedo sai).
    final landing = v.ceil();
    final settled = _drag == null;
    final prefix = widget.semanticPrefix;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (d) => widget.onChanged(_valueAt(d.localPosition.dx)),
      onHorizontalDragStart: (d) => _dragTo(d.localPosition.dx),
      onHorizontalDragUpdate: (d) => _dragTo(d.localPosition.dx),
      onHorizontalDragEnd: (_) => _commit(),
      onHorizontalDragCancel: _commit,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++)
            // Leitor de tela: estrela inteira por toque (o arrastar e a
            // meia estrela são atalhos de quem vê).
            Semantics(
              button: true,
              selected: i == v,
              label: [
                if (prefix != null) prefix,
                i == 1 ? '1 estrela' : '$i estrelas',
              ].join(', '),
              excludeSemantics: true,
              onTap: () => widget.onChanged(i.toDouble()),
              child: SizedBox.square(
                dimension: _cell,
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey('star-$i-${i == landing && settled}-$v'),
                    tween: Tween(
                        begin: i == landing && settled ? 1.2 : 1, end: 1),
                    duration: exploreMotion(context, 150),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) =>
                        Transform.scale(scale: scale, child: child),
                    child: _Star(
                      fill: (v - (i - 1)).clamp(0, 1).toDouble(),
                      size: widget.size,
                      on: p.star,
                      off: p.ink.withValues(alpha: 0.24),
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

/// Uma estrela: vazia, meia (metade esquerda cheia) ou cheia.
class _Star extends StatelessWidget {
  const _Star({
    required this.fill,
    required this.size,
    required this.on,
    required this.off,
  });

  /// 0, 0,5 ou 1.
  final double fill;
  final double size;
  final Color on;
  final Color off;

  @override
  Widget build(BuildContext context) {
    if (fill >= 1) {
      return FaIcon(TravelIcons.star, size: size, color: on);
    }
    final outline = FaIcon(TravelIcons.starOutline, size: size, color: off);
    if (fill <= 0) return outline;
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        outline,
        ClipRect(
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: fill,
            child: FaIcon(TravelIcons.star, size: size, color: on),
          ),
        ),
      ],
    );
  }
}

/// Estrelas só de leitura (lista de avaliações), de meia em meia.
class StarsSmall extends StatelessWidget {
  const StarsSmall(this.stars, {this.size = 12, super.key});

  final num stars;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final v = stars <= 0 ? 0.0 : halfStep(stars);
    final spoken = v == v.roundToDouble()
        ? '${v.round()}'
        : v.toStringAsFixed(1).replaceAll('.', ',');
    return Semantics(
      label: '$spoken de 5 estrelas',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++) ...[
            if (i > 1) SizedBox(width: size * 0.18),
            _Star(
              fill: (v - (i - 1)).clamp(0, 1).toDouble(),
              size: size,
              on: p.star,
              off: p.ink.withValues(alpha: 0.24),
            ),
          ],
        ],
      ),
    );
  }
}
