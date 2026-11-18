import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:studio_app/features/explore/data/explore_mock.dart';
import 'package:studio_app/features/explore/domain/explore_entities.dart';
import 'package:studio_app/features/explore/presentation/view_models/explore_cubit.dart';
import 'package:studio_app/features/explore/presentation/view_models/search_cubit.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';

/// Curva padrão da Maré.
const kExploreEase = Cubic(0.2, 0, 0, 1);

/// Duração que respeita Reduce Motion.
Duration exploreMotion(BuildContext context, int ms) =>
    MediaQuery.disableAnimationsOf(context)
        ? const Duration(milliseconds: 1)
        : Duration(milliseconds: ms);

/// Rota com fade + escala a partir de [origin] (420 ms ida, 320 volta).
/// Com Reduce Motion a rota troca na hora (sem voo de Hero).
Route<void> exploreRoute(BuildContext context, Widget page,
        {Alignment origin = Alignment.center}) =>
    PageRouteBuilder<void>(
      transitionDuration: exploreMotion(context, 420),
      reverseTransitionDuration: exploreMotion(context, 320),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (context, animation, _, child) {
        if (MediaQuery.disableAnimationsOf(context)) return child;
        final c = CurvedAnimation(
          parent: animation,
          curve: kExploreEase,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: c,
          child: ScaleTransition(
            scale: Tween(begin: 0.94, end: 1.0).animate(c),
            alignment: origin,
            child: child,
          ),
        );
      },
    );

/// Leva os cubits e o tema da home pra uma rota nova.
Widget withExplore(BuildContext context, Widget page) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<ExploreCubit>()),
        BlocProvider.value(value: context.read<SearchCubit>()),
      ],
      child: Theme(data: travelTheme(context), child: page),
    );

/// Tag do Hero entre a pílula de busca e o primeiro card da busca.
const kSearchHero = 'explore-search-surface';

// ── Rótulos ──────────────────────────────────────────────────────────────

String companyLabel(Company c) => switch (c) {
      Company.sozinha => 'Sozinha',
      Company.amiga => 'Com amiga',
      Company.parceiro => 'Com parceiro(a)',
    };

String companyPhrase(Company c) => switch (c) {
      Company.sozinha => 'Pra ir sozinha',
      Company.amiga => 'Pra ir com uma amiga',
      Company.parceiro => 'Pra ir com parceiro(a)',
    };

String categoriesLabel(Set<ExploreCategory> cs) {
  if (cs.isEmpty) return 'Qualquer tipo';
  final labels = [
    for (final i in ExploreMock.categories)
      if (cs.contains(i.category)) i.label,
  ];
  return labels.length == 1
      ? labels.first
      : '${labels.first} e mais ${labels.length - 1}';
}

String placeLabel(SearchQuery q) => q.place ?? 'Qualquer lugar';

const _months = [
  'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
  'jul', 'ago', 'set', 'out', 'nov', 'dez',
];

/// Nome do mês por extenso, minúsculo ("novembro").
const monthNames = [
  'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
  'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
];

/// "14 a 16 nov", "28 nov a 2 dez", "14 nov", "Fim de semana em nov".
String dayLabel(SearchQuery q) {
  final s = q.start;
  if (s != null) {
    final e = q.end;
    final slack = q.slack > 0 ? ', ±${q.slack} ${q.slack == 1 ? 'dia' : 'dias'}' : '';
    if (e == null) return '${s.day} ${_months[s.month - 1]}$slack';
    final range = s.month == e.month
        ? '${s.day} a ${e.day} ${_months[e.month - 1]}'
        : '${s.day} ${_months[s.month - 1]} a ${e.day} ${_months[e.month - 1]}';
    return '$range$slack';
  }
  final stay = q.flexStay;
  if (stay != null) {
    final what = stay == FlexStay.fimDeSemana ? 'Fim de semana' : 'Uma semana';
    final m = q.flexMonth;
    return m == null ? what : '$what em ${_months[m.month - 1]}';
  }
  return 'Qualquer dia';
}

String rolesCount(int n) => n == 1 ? '1 rolê' : '$n rolês';

Color exploreCategoryTone(ExploreCategory c) => switch (c) {
      ExploreCategory.restaurantes => ExploreCategoryTones.restaurantes,
      ExploreCategory.cafe => ExploreCategoryTones.cafe,
      ExploreCategory.museu => ExploreCategoryTones.museu,
      ExploreCategory.cultura => ExploreCategoryTones.cultura,
      ExploreCategory.arte => ExploreCategoryTones.arte,
      ExploreCategory.historia => ExploreCategoryTones.historia,
    };

// ── Componentes ──────────────────────────────────────────────────────────

/// Ícone ilustrado da categoria (SVG da equipe), tingido.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon(this.category,
      {required this.color, this.size = 24, super.key});

  final ExploreCategory category;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        ExploreMock.categoryInfo(category).icon,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
}

/// Chip de escolha: pílula sem borda; selecionado fica branco (`s1`) com
/// anel `accent` — o tint azul se misturava com o fundo.
class ExploreChip extends StatelessWidget {
  const ExploreChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
    this.onCard = true,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;

  /// Dentro de card `s1` usa `s2`; solto no fundo `s0` usa `s1`.
  final bool onCard;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: exploreMotion(context, 150),
          curve: kExploreEase,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: selectionDecoration(p,
              selected: selected,
              fill: onCard ? p.s2 : p.s1,
              radius: TravelSpace.rPill),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 8)],
              Text(
                label,
                style: TravelType.subheadStrong.copyWith(color: p.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Entrada suave (fade + subida curta), escalonada por [index].
class Reveal extends StatelessWidget {
  const Reveal({required this.index, required this.child, super.key});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + 70 * index),
      curve: Interval(math.min(0.6, index * 0.12), 1, curve: kExploreEase),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child:
            Transform.translate(offset: Offset(0, 16 * (1 - t)), child: child),
      ),
      child: child,
    );
  }
}

/// Brilho que corre sobre os blocos do skeleton (Reduce Motion: parado).
class Shimmer extends StatefulWidget {
  const Shimmer({required this.child, super.key});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    const hi = Colors.white;
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (rect) {
          final x = -1.0 + 3.0 * _c.value;
          return LinearGradient(
            begin: Alignment(x - 1, 0),
            end: Alignment(x, 0),
            colors: [
              Colors.transparent,
              hi.withValues(alpha: p.isDark ? 0.06 : 0.45),
              Colors.transparent,
            ],
          ).createShader(rect);
        },
        child: child,
      ),
    );
  }
}

/// Bloco cinza do skeleton.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    required this.width,
    required this.height,
    this.radius = TravelSpace.rInner,
    super.key,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: TravelPalette.of(context).s2,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}

/// Título de seção da home (texto solto alinhado a 24).
class ExploreSectionTitle extends StatelessWidget {
  const ExploreSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: TravelSpace.content),
        child: Semantics(
          header: true,
          child: Text(
            title,
            style: TravelType.title3
                .copyWith(color: TravelPalette.of(context).ink),
          ),
        ),
      );
}

/// Botão circular sólido `s1` (voltar, filtros, salvar) — 44, alvo HIG.
class RoundButton extends StatelessWidget {
  const RoundButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.fill,
    this.size = 44,
    super.key,
  });

  /// Diâmetro (mínimo 44, alvo HIG).
  final double size;

  final Widget icon;
  final String label;
  final VoidCallback onTap;

  /// Fundo do círculo (padrão `s1`; dentro de cápsula `s1`, use `s2`).
  final Color? fill;

  /// Contador opcional (filtros ligados).
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final n = badge ?? 0;
    return Semantics(
      button: true,
      label: n > 0 ? '$label, $n ligados' : label,
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration:
                    BoxDecoration(color: fill ?? p.s1, shape: BoxShape.circle),
                child: IconTheme(
                  data: IconThemeData(size: 16, color: p.ink),
                  child: icon,
                ),
              ),
              Positioned(
                top: -2,
                right: -2,
                child: AnimatedScale(
                  scale: n > 0 ? 1 : 0,
                  duration: exploreMotion(context, 150),
                  curve: kExploreEase,
                  child: Container(
                    width: 18,
                    height: 18,
                    alignment: Alignment.center,
                    decoration:
                        BoxDecoration(color: p.accent, shape: BoxShape.circle),
                    child: Text(
                      '$n',
                      style: TravelType.caption
                          .weight(FontWeight.w500)
                          .copyWith(
                              color: p.onAccent,
                              height: 1.2,
                              fontFeatures: TravelType.tabular),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ação de texto ("Limpar").
class TextAction extends StatelessWidget {
  const TextAction(this.label, {required this.onTap, super.key});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        onTap: onTap,
        child: Pressable(
          onTap: onTap,
          child: SizedBox(
            height: TravelSpace.tap,
            child: Center(
              widthFactor: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  label,
                  style: TravelType.subheadStrong
                      .copyWith(color: TravelPalette.of(context).ink),
                ),
              ),
            ),
          ),
        ),
      );
}

/// Fade suave (rampa senoidal) nas pontas de uma lista vertical que corre
/// entre uma barra fixa e um rodapé fixo — sem borda dura (regra 11).
/// Véus na cor do fundo por cima, nunca `ShaderMask` (regra 14: custo no
/// celular).
class VerticalEdgeFade extends StatelessWidget {
  const VerticalEdgeFade({
    required this.child,
    this.top = 16,
    this.bottom = 28,
    this.background,
    super.key,
  });

  final Widget child;
  final double top;
  final double bottom;

  /// Cor do fundo por trás da lista (padrão `s0`).
  final Color? background;

  static double _smooth(double t) => 0.5 - 0.5 * math.cos(math.pi * t);

  Widget _veil(Color bg, double h, {required bool fromTop}) {
    const steps = 10;
    final colors = [
      for (var i = 0; i <= steps; i++)
        bg.withValues(alpha: 1 - _smooth(i / steps)),
    ];
    return IgnorePointer(
      child: SizedBox(
        height: h,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: fromTop ? Alignment.topCenter : Alignment.bottomCenter,
              end: fromTop ? Alignment.bottomCenter : Alignment.topCenter,
              colors: colors,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = background ?? TravelPalette.of(context).s0;
    return Stack(
      children: [
        child,
        Positioned(
            top: 0, left: 0, right: 0, child: _veil(bg, top, fromTop: true)),
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _veil(bg, bottom, fromTop: false)),
      ],
    );
  }
}

/// Scroll edge effect do iOS 26 (estilo soft) no rodapé: o conteúdo que
/// rola sob a tab bar desfoca aos poucos e se dissolve num véu `s0` —
/// [ProgressiveBlurTop] espelhado. Fica atrás do vidro (no fundo amostrado).
class ProgressiveBlurBottom extends StatelessWidget {
  const ProgressiveBlurBottom({required this.height, super.key});

  final double height;

  @override
  Widget build(BuildContext context) =>
      RotatedBox(quarterTurns: 2, child: ProgressiveBlurTop(height: height));
}

/// Estado selecionado de chip/tile: fundo `s1` + anel `accent` de 1,5. O
/// anel existe sempre (transparente quando não selecionado) pra não mexer
/// no layout. É estado, não divisor — a regra 1 segue valendo.
BoxDecoration selectionDecoration(
  TravelPalette p, {
  required bool selected,
  required Color fill,
  required double radius,
}) =>
    BoxDecoration(
      color: selected ? p.s1 : fill,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: selected ? p.accent : p.accent.withValues(alpha: 0),
        width: 1.5,
      ),
    );
