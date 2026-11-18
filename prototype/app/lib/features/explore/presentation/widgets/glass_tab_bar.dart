import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/core/components/glass/app_glass.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';

class GlassTabItem {
  const GlassTabItem(this.icon, this.label);

  final FaIconData icon;
  final String label;
}

/// Tab bar flutuante em Liquid Glass (ref. Yelp + tab bar do iOS 26/27).
///
/// - Vidro com véu claro por cima (branco no claro, `s1` no escuro).
/// - Item ativo = pílula de tint SÓLIDO (nunca vidro sobre vidro) que anda
///   na mola do segmented (rigidez 420, amortecimento 32) e estica na
///   direção do movimento.
/// - **Arrastável:** segurar e deslizar leva a pílula com o dedo (ela cresce
///   6% enquanto segura, como no iOS); ao soltar encaixa na aba mais
///   próxima, projetando a velocidade, e troca a aba.
/// - Raios concêntricos: barra 32 → padding 6 → pílula 26.
class GlassTabBar extends StatefulWidget {
  const GlassTabBar({
    required this.items,
    required this.index,
    required this.onChanged,
    super.key,
  });

  final List<GlassTabItem> items;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  State<GlassTabBar> createState() => _GlassTabBarState();
}

class _GlassTabBarState extends State<GlassTabBar>
    with SingleTickerProviderStateMixin {
  static const _h = 64.0;
  static const _pad = 6.0;
  static const _spring =
      SpringDescription(mass: 1, stiffness: 420, damping: 32);

  late final AnimationController _pos = AnimationController.unbounded(
      vsync: this, value: widget.index.toDouble());

  bool _held = false;
  double _dragVelocity = 0;

  /// Última aba sob o dedo (tique de haptic ao cruzar).
  int _hover = 0;

  int get _n => widget.items.length;

  @override
  void didUpdateWidget(GlassTabBar old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index && !_held && _pos.value != widget.index) {
      _animateTo(widget.index);
    }
  }

  void _animateTo(int target, {double velocity = 0}) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _pos.value = target.toDouble();
      return;
    }
    _pos.animateWith(
        SpringSimulation(_spring, _pos.value, target.toDouble(), velocity));
  }

  void _commit(int target, {double velocity = 0}) {
    _animateTo(target, velocity: velocity);
    if (target != widget.index) widget.onChanged(target);
  }

  @override
  void dispose() {
    _pos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    // Véu claro sobre o vidro (o vidro da tab bar do iOS é leitoso).
    final veil = p.isDark
        ? p.s1.withValues(alpha: 0.42)
        : Colors.white.withValues(alpha: 0.58);
    return AppGlassSurface(
      radius: _h / 2,
      height: _h,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: veil,
                  borderRadius: BorderRadius.circular(_h / 2),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(_pad),
            child: _content(context, p),
          ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, TravelPalette p) {
    return LayoutBuilder(
      builder: (context, box) {
        final segW = box.maxWidth / _n;
        int segmentAt(double dx) => (dx / segW).floor().clamp(0, _n - 1);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) => _commit(segmentAt(d.localPosition.dx)),
          onHorizontalDragStart: (d) {
            _pos.stop();
            _hover = segmentAt(d.localPosition.dx);
            setState(() => _held = true);
          },
          // A pílula segue o dedo (centro sob o toque).
          onHorizontalDragUpdate: (d) {
            _dragVelocity = d.delta.dx / segW * 60;
            _pos.value = (d.localPosition.dx / segW - 0.5).clamp(0.0, _n - 1.0);
            final over = _pos.value.round();
            if (over != _hover) {
              _hover = over;
              HapticFeedback.selectionClick();
            }
          },
          onHorizontalDragEnd: (d) {
            final v = d.velocity.pixelsPerSecond.dx / segW;
            // Lento: encaixa onde soltou; rápido: projeta a mola.
            final projected = v.abs() > 4 ? _pos.value + v * 0.08 : _pos.value;
            final target = projected.round().clamp(0, _n - 1);
            setState(() {
              _held = false;
              _dragVelocity = 0;
            });
            _commit(target, velocity: v);
          },
          onHorizontalDragCancel: () {
            setState(() {
              _held = false;
              _dragVelocity = 0;
            });
            _animateTo(widget.index);
          },
          child: AnimatedBuilder(
            animation: _pos,
            builder: (context, _) {
              final x = _pos.value;
              final velocity = _held ? _dragVelocity : _pos.velocity;
              final stretch = (velocity.abs() * 0.03).clamp(0.0, 0.18);
              final thumbW = segW * (1 + stretch);
              return Stack(
                children: [
                  Positioned(
                    left: x * segW - (thumbW - segW) / 2,
                    top: 0,
                    bottom: 0,
                    width: thumbW,
                    child: AnimatedScale(
                      scale: _held ? 1.06 : 1,
                      duration: const Duration(milliseconds: 160),
                      curve: const Cubic(0.2, 0, 0, 1),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color:
                              p.ink.withValues(alpha: p.isDark ? 0.14 : 0.08),
                          borderRadius: BorderRadius.circular(_h / 2 - _pad),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < _n; i++)
                        Expanded(child: _item(context, i, x)),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _item(BuildContext context, int i, double x) {
    final p = TravelPalette.of(context);
    final item = widget.items[i];
    final near = (1 - (x - i).abs()).clamp(0.0, 1.0);
    final color = Color.lerp(p.ink.withValues(alpha: 0.62), p.ink, near)!;
    // Toque e arraste ficam no GestureDetector da barra; aqui só a
    // semântica (leitor de tela) — com onTap, regra D11.
    return Semantics(
      button: true,
      selected: i == widget.index,
      label: item.label,
      excludeSemantics: true,
      onTap: () => _commit(i),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(item.icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: TravelType.caption
                .weight(FontWeight.w500)
                .copyWith(color: color, height: 1.2),
          ),
        ],
      ),
    );
  }
}
