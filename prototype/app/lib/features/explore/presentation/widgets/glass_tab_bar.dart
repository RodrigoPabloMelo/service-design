import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/core/components/glass/app_glass.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';

class GlassTabItem {
  const GlassTabItem(this.icon, this.label);

  final FaIconData icon;
  final String label;
}

/// Tab bar flutuante em Liquid Glass (ref. Yelp): pílula de vidro, item
/// ativo marcado por uma pílula de tint SÓLIDO (nunca vidro sobre vidro)
/// que desliza na mola do segmented (rigidez 420, amortecimento 32).
/// Raios concêntricos: barra 32 → padding 6 → pílula 26.
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

  late final AnimationController _pos =
      AnimationController.unbounded(vsync: this, value: widget.index.toDouble());

  @override
  void didUpdateWidget(GlassTabBar old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _pos.value = widget.index.toDouble();
      } else {
        _pos.animateWith(SpringSimulation(_spring, _pos.value,
            widget.index.toDouble(), _pos.velocity));
      }
    }
  }

  @override
  void dispose() {
    _pos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final n = widget.items.length;
    return AppGlassSurface(
      radius: _h / 2,
      height: _h,
      padding: const EdgeInsets.all(_pad),
      child: LayoutBuilder(
        builder: (context, box) {
          final segW = box.maxWidth / n;
          return AnimatedBuilder(
            animation: _pos,
            builder: (context, _) {
              final x = _pos.value;
              final stretch = (_pos.velocity.abs() * 0.03).clamp(0.0, 0.18);
              final thumbW = segW * (1 + stretch);
              return Stack(
                children: [
                  Positioned(
                    left: x * segW - (thumbW - segW) / 2,
                    top: 0,
                    bottom: 0,
                    width: thumbW,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: p.ink.withValues(alpha: p.isDark ? 0.14 : 0.08),
                        borderRadius:
                            BorderRadius.circular(_h / 2 - _pad),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < n; i++)
                        Expanded(child: _item(context, i, x)),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _item(BuildContext context, int i, double x) {
    final p = TravelPalette.of(context);
    final item = widget.items[i];
    final near = (1 - (x - i).abs()).clamp(0.0, 1.0);
    final color = Color.lerp(p.ink.withValues(alpha: 0.62), p.ink, near)!;
    void tap() => widget.onChanged(i);
    return Semantics(
      button: true,
      selected: i == widget.index,
      label: item.label,
      excludeSemantics: true,
      onTap: tap,
      child: Pressable(
        onTap: tap,
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
      ),
    );
  }
}
