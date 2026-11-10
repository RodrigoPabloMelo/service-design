import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/core/components/glass/app_glass.dart';
import 'package:studio_app/core/components/widgets/app_activity_indicator.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';

/// Ícones da Maré — Font Awesome (fontawesome.com), num só lugar.
/// Regular (contorno) onde existe no plano grátis; sólido no resto.
abstract final class TravelIcons {
  // Constantes próprias (não as de FontAwesomeIcons): o tree-shaker de
  // ícones do `flutter build web` ignora as instâncias canônicas da classe
  // anotada com @staticIconProvider e cortava os glifos usados fora da
  // página (viravam quadrados). `fontFamilyFallback` torna cada constante
  // distinta, então ela é registrada aqui. Ícone novo: copie o codepoint de
  // FontAwesomeIcons.<nome> e rode `tool/check_icons.sh`.
  static const _pkg = 'font_awesome_flutter';
  static const _solid = 'FontAwesomeSolid';
  static const _regular = 'FontAwesomeRegular';
  static const _brands = 'FontAwesomeBrands';
  static const _keep = <String>['FontAwesomeSolid'];
  // Categorias
  static const food = FaIconData(IconData(0xf2e7,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // utensils
  static const culture = FaIconData(IconData(0xf53f,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // palette
  static const music = FaIconData(IconData(0xf001,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // music
  static const tree = FaIconData(IconData(0xf1bb,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // tree
  static const beach = FaIconData(IconData(0xf5ca,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // umbrellaBeach

  // Origem dos vídeos
  static const tiktok = FaIconData(IconData(0xe07b,
      fontFamily: _brands,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // tiktok
  static const instagram = FaIconData(IconData(0xf16d,
      fontFamily: _brands,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // instagram
  static const camera = FaIconData(IconData(0xf030,
      fontFamily: _regular,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // camera

  // Interface
  static const back = FaIconData(IconData(0xf053,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // chevronLeft
  static const chevronRight = FaIconData(IconData(0xf054,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // chevronRight
  static const arrowRight = FaIconData(IconData(0xf061,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // arrowRight
  static const close = FaIconData(IconData(0xf00d,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // xmark
  static const check = FaIconData(IconData(0xf00c,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // check
  static const circleCheck = FaIconData(IconData(0xf058,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // solidCircleCheck
  static const circle = FaIconData(IconData(0xf111,
      fontFamily: _regular,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // circle
  static const badge = FaIconData(IconData(0xf058,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // solidCircleCheck
  static const calendar = FaIconData(IconData(0xf133,
      fontFamily: _regular,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // calendar
  static const bookmark = FaIconData(IconData(0xf02e,
      fontFamily: _regular,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // bookmark
  static const clock = FaIconData(IconData(0xf017,
      fontFamily: _regular,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // clock
  static const place = FaIconData(IconData(0xf3c5,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // locationDot
  static const mapPin = FaIconData(IconData(0xf5a0,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // mapLocationDot
  static const route = FaIconData(IconData(0xf4d7,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // route
  static const car = FaIconData(IconData(0xf1b9,
      fontFamily: _solid, fontPackage: _pkg, fontFamilyFallback: _keep)); // car
  static const taxi = FaIconData(IconData(0xf1ba,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // taxi
  static const walk = FaIconData(IconData(0xf554,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // personWalking
  static const pen = FaIconData(IconData(0xf304,
      fontFamily: _solid, fontPackage: _pkg, fontFamilyFallback: _keep)); // pen
  static const minus = FaIconData(IconData(0xf068,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // minus
  // Dicas ("O que fazer")
  static const drink = FaIconData(IconData(0xf0fc,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // beerMugEmpty
  static const guitar = FaIconData(IconData(0xf7a6,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // guitar
  static const cameraRetro = FaIconData(IconData(0xf083,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // cameraRetro
  static const sun = FaIconData(IconData(0xf185,
      fontFamily: _regular,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // sun
  static const film = FaIconData(IconData(0xf008,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // film
  static const leaf = FaIconData(IconData(0xf06c,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // leaf
  static const shop = FaIconData(IconData(0xf291,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // basketShopping
  static const skate = FaIconData(IconData(0xf7c5,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // personSkating
  static const group = FaIconData(IconData(0xf500,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // userGroup
  static const ticket = FaIconData(IconData(0xf145,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // ticket
  static const shield = FaIconData(IconData(0xf3ed,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // shieldHalved
  static const safety = FaIconData(IconData(0xf3ed,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // shieldHalved
  static const rain = FaIconData(IconData(0xf73d,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // cloudRain
  static const home = FaIconData(IconData(0xf015,
      fontFamily: _regular,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // house
  static const recenter = FaIconData(IconData(0xf124,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // locationArrow
  static const layers = FaIconData(IconData(0xf5fd,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // layerGroup
  static const more = FaIconData(IconData(0xf141,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // ellipsis
  static const map = FaIconData(IconData(0xf279,
      fontFamily: _regular,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // map
  static const gauge = FaIconData(IconData(0xf625,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // gaugeHigh
  static const chat = FaIconData(IconData(0xf27a,
      fontFamily: _regular,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // message
  static const share = FaIconData(IconData(0xf14d,
      fontFamily: _regular,
      fontPackage: _pkg,
      fontFamilyFallback:
          _keep)); // shareFromSquare // contorno (coeso com salvar)
  static const magic = FaIconData(IconData(0xe2ca,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // wandMagicSparkles
  static const mic = FaIconData(IconData(0xf130,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // microphone
  static const send = FaIconData(IconData(0xf062,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // arrowUp
  static const image = FaIconData(IconData(0xf03e,
      fontFamily: _regular,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // image
  static const plus = FaIconData(IconData(0x2b,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // plus
  static const folder = FaIconData(IconData(0xf07c,
      fontFamily: _regular,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // folderOpen
  static const chevronDown = FaIconData(IconData(0xf078,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // chevronDown
  static const chevronUp = FaIconData(IconData(0xf077,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // chevronUp

  // Player
  static const circlePlay = FaIconData(IconData(0xf144,
      fontFamily: _regular,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // circlePlay
  static const play = FaIconData(IconData(0xf04b,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // play
  static const circlePause = FaIconData(IconData(0xf28b,
      fontFamily: _regular,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // circlePause
  static const pause = FaIconData(IconData(0xf04c,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // pause
  static const sound = FaIconData(IconData(0xf028,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // volumeHigh
  static const muted = FaIconData(IconData(0xf6a9,
      fontFamily: _solid,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // volumeXmark

  // Marcas
  static const uber = FaIconData(IconData(0xf402,
      fontFamily: _brands,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // uber
  static const google = FaIconData(IconData(0xf1a0,
      fontFamily: _brands,
      fontPackage: _pkg,
      fontFamilyFallback: _keep)); // google
}

// ── Categoria: mesma cor + glifo + rótulo em todo lugar (similaridade) ─────

Color categoryColor(TravelPalette p, RoleCategory c) => switch (c) {
      RoleCategory.comida => p.coral,
      RoleCategory.cultura => p.cultura,
      RoleCategory.noite => p.noite,
      RoleCategory.natureza => p.mata,
      RoleCategory.praia => p.sol,
    };

FaIconData categoryIcon(RoleCategory c) => switch (c) {
      RoleCategory.comida => TravelIcons.food,
      RoleCategory.cultura => TravelIcons.culture,
      RoleCategory.noite => TravelIcons.music,
      RoleCategory.natureza => TravelIcons.tree,
      RoleCategory.praia => TravelIcons.beach,
    };

String categoryLabel(RoleCategory c) => switch (c) {
      RoleCategory.comida => 'Comida',
      RoleCategory.cultura => 'Cultura',
      RoleCategory.noite => 'Noite',
      RoleCategory.natureza => 'Natureza',
      RoleCategory.praia => 'Praia',
    };

FaIconData videoSourceIcon(VideoSource s) => switch (s) {
      VideoSource.tiktok => TravelIcons.tiktok,
      VideoSource.instagram => TravelIcons.instagram,
      VideoSource.local => TravelIcons.camera,
    };

FaIconData tipIcon(TipKind k) => switch (k) {
      TipKind.food => TravelIcons.food,
      TipKind.drink => TravelIcons.drink,
      TipKind.music => TravelIcons.guitar,
      TipKind.dance => TravelIcons.music,
      TipKind.walk => TravelIcons.walk,
      TipKind.photo => TravelIcons.cameraRetro,
      TipKind.view => TravelIcons.sun,
      TipKind.film => TravelIcons.film,
      TipKind.nature => TravelIcons.leaf,
      TipKind.shop => TravelIcons.shop,
      TipKind.art => TravelIcons.culture,
      TipKind.sport => TravelIcons.skate,
    };

String videoSourceLabel(VideoSource s) => switch (s) {
      VideoSource.tiktok => 'TikTok',
      VideoSource.instagram => 'Instagram',
      VideoSource.local => 'Gravado por local',
    };

String periodLabel(StopPeriod d) => switch (d) {
      StopPeriod.manha => 'Manhã',
      StopPeriod.tarde => 'Tarde',
      StopPeriod.noite => 'Noite',
    };

// ── Blocos sólidos (região comum) ─────────────────────────────────────────

enum SurfaceLevel { s1, s2, accent }

/// Bloco sólido: separa grupos por preenchimento, sem borda nem divisor.
class SolidBlock extends StatelessWidget {
  const SolidBlock({
    required this.child,
    this.level = SurfaceLevel.s1,
    this.padding = const EdgeInsets.all(TravelSpace.cardPad),
    this.radius = TravelSpace.rCard,
    super.key,
  });

  final Widget child;
  final SurfaceLevel level;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final color = switch (level) {
      SurfaceLevel.s1 => p.s1,
      SurfaceLevel.s2 => p.s2,
      SurfaceLevel.accent => p.accent,
    };
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}

/// Categoria: glifo + rótulo neutros, direto na superfície (sem pílula
/// colorida). A cor da categoria fica só nos pins do mapa.
class CategoryTag extends StatelessWidget {
  const CategoryTag(this.category, {this.compact = false, super.key});

  final RoleCategory category;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(categoryIcon(category),
            size: compact ? 11 : 12, color: p.inkMuted),
        const SizedBox(width: 5),
        Text(
          categoryLabel(category),
          style: (compact ? TravelType.caption : TravelType.footnote)
              .copyWith(color: p.inkMuted),
        ),
      ],
    );
  }
}

/// Avatar com iniciais de quem indicou.
class RecommenderAvatar extends StatelessWidget {
  const RecommenderAvatar(this.recommender, {this.size = 40, super.key});

  final Recommender recommender;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    if (recommender.photo != null) {
      return Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        foregroundDecoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color:
                (p.isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
          ),
        ),
        child: Image.asset(recommender.photo!, fit: BoxFit.cover),
      );
    }
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: p.s2, shape: BoxShape.circle),
      child: Text(
        recommender.initials,
        style: TravelType.footnoteStrong.copyWith(
          color: p.ink,
          fontSize: size * 0.34,
        ),
      ),
    );
  }
}

/// Botão primário — único sólido de destaque por estado (Von Restorff).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final FaIconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: p.onAccent,
          disabledBackgroundColor: p.accent.withValues(alpha: 0.7),
          disabledForegroundColor: p.onAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TravelSpace.rInner),
          ),
          textStyle: TravelType.headline,
          splashFactory: NoSplash.splashFactory,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              AppActivityIndicator(color: p.onAccent)
            else if (icon != null)
              FaIcon(icon, size: 17),
            if (loading || icon != null) const SizedBox(width: 10),
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}

/// Botão secundário — tonal, sem competir com o primário.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
    this.selected = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final FaIconData? icon;
  final bool expand;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final button = SizedBox(
      height: 48,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: selected ? p.accent : p.s2,
          foregroundColor: selected ? p.onAccent : p.ink,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TravelSpace.rInner),
          ),
          textStyle: TravelType.subheadStrong,
        ),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              FaIcon(icon, size: 15),
              const SizedBox(width: 8)
            ],
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Título de seção (sentence case, Plus Jakarta) + ação opcional.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    // Rótulo na linha de conteúdo (24pt), alinhado ao texto dos cards.
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          TravelSpace.cardPad, 0, TravelSpace.cardPad, TravelSpace.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TravelType.section.copyWith(color: p.inkMuted),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ── Polimento (skill better-ui) ───────────────────────────────────────────

/// Feedback de toque: escala 0.96, sem ripple. Sem `onTap` → estático.
class Pressable extends StatefulWidget {
  const Pressable({required this.child, required this.onTap, super.key});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap == null || _down == v) return;
    setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      child: AnimatedScale(
        scale: _down ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        curve: const Cubic(0.2, 0, 0, 1),
        child: widget.child,
      ),
    );
  }
}

/// Contorno de 1px a 10% em imagens (preto no claro, branco no escuro).
BoxDecoration imageOutline(TravelPalette p, double radius) => BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: (p.isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
      ),
    );

// ── Segmented control em pílula (comportamento Liquid Glass) ─────────────

/// Segmented em pílula: o indicador anda numa mola, estica na direção do
/// movimento ("gelatina"), cresce 6% quando segurado e pode ser arrastado —
/// encaixa no segmento mais próximo ao soltar (considerando a velocidade).
/// Trilho 40 / padding 3 → indicador 34 (raios 20 e 17, concêntricos).
/// Sólido e flat (fica dentro de card — sem vidro sobre superfície sólida).
class PillSegmented extends StatefulWidget {
  const PillSegmented({
    required this.labels,
    required this.index,
    required this.onChanged,
    this.semanticLabels,
    this.position,
    super.key,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;
  final List<String>? semanticLabels;

  /// Posição contínua do indicador vinda de fora (ex.: páginas arrastadas
  /// por baixo). Nula = o indicador anima sozinho até [index].
  final double? position;

  @override
  State<PillSegmented> createState() => _PillSegmentedState();
}

class _PillSegmentedState extends State<PillSegmented>
    with SingleTickerProviderStateMixin {
  static const _h = 40.0;
  static const _pad = 3.0;
  static const _spring =
      SpringDescription(mass: 1, stiffness: 420, damping: 32);

  late final AnimationController _pos = AnimationController.unbounded(
      vsync: this, value: widget.position ?? widget.index.toDouble());
  bool _held = false;
  double _dragVelocity = 0;

  /// Alvo escolhido aqui enquanto a posição externa ainda não chegou.
  int? _lead;

  int get _n => widget.labels.length;

  @override
  void didUpdateWidget(PillSegmented old) {
    super.didUpdateWidget(old);
    final follow = widget.position;
    if (follow != null) {
      // Depois de um toque/arraste aqui, o indicador lidera até as páginas
      // alcançarem o alvo (sem voltar ao dia antigo por um quadro).
      final lead = _lead;
      if (lead != null) {
        if ((follow - lead).abs() > 0.01) return;
        _lead = null;
      }
      if (!_held && follow != _pos.value) {
        _pos
          ..stop()
          ..value = follow.clamp(0.0, _n - 1.0);
      }
      return;
    }
    if (old.index != widget.index &&
        !_held &&
        _pos.value.round() != widget.index) {
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
    if (widget.position != null && target != widget.index) _lead = target;
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
    return LayoutBuilder(
      builder: (context, box) {
        final segW = (box.maxWidth - _pad * 2) / _n;
        int segmentAt(double dx) =>
            ((dx - _pad) / segW).floor().clamp(0, _n - 1);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) => _commit(segmentAt(d.localPosition.dx)),
          onHorizontalDragStart: (_) {
            _pos.stop();
            setState(() => _held = true);
          },
          // O indicador segue o dedo (centro sob o toque).
          onHorizontalDragUpdate: (d) {
            _dragVelocity = d.delta.dx / segW * 60;
            _pos.value =
                ((d.localPosition.dx - _pad) / segW - 0.5).clamp(0.0, _n - 1.0);
          },
          onHorizontalDragEnd: (d) {
            final v = d.velocity.pixelsPerSecond.dx / segW;
            // Gesto lento: encaixa onde o dedo soltou; rápido: projeta a mola.
            final projected = v.abs() > 4 ? _pos.value + v * 0.08 : _pos.value;
            final target = projected.round().clamp(0, _n - 1);
            setState(() {
              _held = false;
              _dragVelocity = 0;
            });
            _commit(target, velocity: v);
          },
          child: AnimatedBuilder(
            animation: _pos,
            builder: (context, _) {
              final x = _pos.value;
              final velocity = _held ? _dragVelocity : _pos.velocity;
              final stretch = (velocity.abs() * 0.035).clamp(0.0, 0.22);
              final thumbW = segW * (1 + stretch);
              final thumbH = (_h - _pad * 2) * (1 - stretch * 0.25);
              final left = _pad + x * segW - (thumbW - segW) / 2;
              return Container(
                height: _h,
                decoration: BoxDecoration(
                  color: p.s2,
                  borderRadius: BorderRadius.circular(TravelSpace.rPill),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: left,
                      top: (_h - thumbH) / 2,
                      width: thumbW,
                      height: thumbH,
                      child: AnimatedScale(
                        scale: _held ? 1.06 : 1,
                        duration: const Duration(milliseconds: 160),
                        curve: const Cubic(0.2, 0, 0, 1),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: p.s1,
                            borderRadius:
                                BorderRadius.circular(TravelSpace.rPill),
                            border: Border.all(
                                color: p.ink.withValues(alpha: 0.06)),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < _n; i++)
                          Expanded(
                            child: Semantics(
                              button: true,
                              selected: i == widget.index,
                              label:
                                  widget.semanticLabels?[i] ?? widget.labels[i],
                              excludeSemantics: true,
                              onTap: () => _commit(i),
                              child: Center(
                                child: Text(
                                  widget.labels[i],
                                  style: TravelType.subheadStrong.copyWith(
                                    color: Color.lerp(
                                      p.inkMuted,
                                      p.ink,
                                      (1 - (x - i).abs()).clamp(0.0, 1.0),
                                    ),
                                    fontFeatures: TravelType.tabular,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ── Rolagem horizontal com fade nas bordas ────────────────────────────────

/// Lista horizontal que sangra até as bordas do sheet, com fade suave só na
/// borda que tem mais conteúdo (some em repouso no começo/fim). [padding] é a
/// margem de repouso — o primeiro item nunca nasce dentro do fade.
///
/// O fade é um véu na cor do fundo ([background], padrão `s0`) por cima da
/// lista — mesmo desenho de uma máscara, sem saveLayer a cada quadro. Use só
/// sobre fundo sólido dessa cor.
class EdgeFadeScroll extends StatefulWidget {
  const EdgeFadeScroll({
    required this.height,
    required this.itemCount,
    required this.itemBuilder,
    this.spacing = TravelSpace.sm,
    this.padding = TravelSpace.gutter,
    this.fade = 28,
    this.background,
    super.key,
  });

  final double height;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double spacing;
  final double padding;
  final double fade;

  /// Cor sólida atrás da lista (padrão: `s0`, o fundo do sheet).
  final Color? background;

  @override
  State<EdgeFadeScroll> createState() => _EdgeFadeScrollState();
}

class _EdgeFadeScrollState extends State<EdgeFadeScroll> {
  final _c = ScrollController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.background ?? TravelPalette.of(context).s0;
    return SizedBox(
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ListView.separated(
            controller: _c,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: widget.padding),
            itemCount: widget.itemCount,
            separatorBuilder: (_, __) => SizedBox(width: widget.spacing),
            itemBuilder: widget.itemBuilder,
          ),
          // Só o véu acompanha a rolagem; a lista não reconstrói.
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) {
                double left = 0, right = 0;
                if (_c.hasClients && _c.position.hasContentDimensions) {
                  left = _c.offset.clamp(0.0, widget.fade);
                  right = (_c.position.maxScrollExtent - _c.offset)
                      .clamp(0.0, widget.fade);
                }
                return CustomPaint(
                  painter: _SideVeilPainter(bg, left: left, right: right),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Véus laterais do [EdgeFadeScroll]: a mesma rampa senoidal (12 passos) da
/// antiga máscara, invertida — pinta a cor do fundo onde ela apagava.
class _SideVeilPainter extends CustomPainter {
  _SideVeilPainter(this.color, {required this.left, required this.right});

  final Color color;
  final double left;
  final double right;

  static double _smooth(double t) => 0.5 - 0.5 * math.cos(math.pi * t);
  static final _ks = [for (var i = 0; i <= 12; i++) i / 12];

  @override
  void paint(Canvas canvas, Size size) {
    if (left > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, left, size.height),
        Paint()
          ..shader = ui.Gradient.linear(
            Offset.zero,
            Offset(left, 0),
            [
              for (final k in _ks)
                color.withValues(alpha: color.a * (1 - _smooth(k))),
            ],
            _ks,
          ),
      );
    }
    if (right > 0) {
      final x = size.width - right;
      canvas.drawRect(
        Rect.fromLTWH(x, 0, right, size.height),
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(x, 0),
            Offset(size.width, 0),
            [for (final k in _ks) color.withValues(alpha: color.a * _smooth(k))],
            _ks,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(_SideVeilPainter old) =>
      old.color != color || old.left != left || old.right != right;
}

/// Recuo do topo do conteúdo rolável do sheet (status bar + cabeçalho).
/// A lista começa no topo do sheet e soma isto ao próprio padding: rola por
/// baixo da status bar e some no fade, sem borda dura onde começava.
class SheetTopInset extends InheritedWidget {
  const SheetTopInset({required this.value, required super.child, super.key});

  final double value;

  static double of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SheetTopInset>()?.value ?? 0;

  @override
  bool updateShouldNotify(SheetTopInset old) => old.value != value;
}

/// Desfoque progressivo do iOS no topo do sheet, com véu `s0` em degradê
/// pra legibilidade do cabeçalho. Faixas de `BackdropFilter` empilhadas,
/// cada uma mais curta: perto da borda o desfoque soma mais. Sem toque.
///
/// No modo leve ([AppEffects.lite], celular no navegador) são 3 faixas em
/// vez de 8 — cada faixa é uma leitura da tela na GPU, a cada quadro —, com
/// sigmas que mantêm o desfoque somado no topo (~σ 6,9) e a rampa.
class ProgressiveBlurTop extends StatelessWidget {
  const ProgressiveBlurTop({
    required this.height,
    this.steps = 8,
    super.key,
  });

  final double height;
  final int steps;

  /// Modo leve: (altura da faixa, σ). Os cortes caem onde o véu já é denso
  /// (50% da altura ≈ 43% de `s0`, 22% ≈ 76%), pra emenda entre faixas não
  /// virar costura; base fraca e topo somando √(0,6² + 2,4² + 6,4²) ≈ 6,9,
  /// como as 8 faixas.
  static const _liteStrips = [(1.0, 0.6), (0.5, 2.4), (0.22, 6.4)];

  static double _smooth(double t) => 0.5 - 0.5 * math.cos(math.pi * t);

  @override
  Widget build(BuildContext context) {
    if (height <= 0.5) return const SizedBox.shrink();
    final p = TravelPalette.of(context);
    const veilSteps = 10;
    final strips = AppEffects.lite
        ? _liteStrips
        : [for (var i = 0; i < steps; i++) (1 - i / steps, 0.4 + 0.5 * i)];
    return IgnorePointer(
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            for (final (fraction, sigma) in strips)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: height * fraction,
                child: ClipRect(
                  // Rampa: a faixa mais alta (que chega na base) desfoca
                  // pouco; as de cima somam mais — sem degrau na base.
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            // Véu: denso na borda, some em curva até o fim da faixa (também
            // esconde os degraus entre as faixas de desfoque).
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      for (var k = 0; k <= veilSteps; k++)
                        p.s0.withValues(
                            alpha: 0.86 * (1 - _smooth(k / veilSteps))),
                    ],
                    stops: [
                      for (var k = 0; k <= veilSteps; k++) k / veilSteps,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Marca conteúdo escuro (foto do rolê, bloco azul, vídeos, bolha da
/// usuária no claro). O cabeçalho sobre o desfoque progressivo troca o
/// texto pra claro quando uma dessas regiões passa por baixo (como no iOS).
/// Com [asset], conta como escura só se o topo da imagem for escuro de
/// verdade (luminância medida e guardada em cache).
class DarkBackdrop extends StatefulWidget {
  const DarkBackdrop({
    required this.child,
    this.enabled = true,
    this.asset,
    super.key,
  });

  final Widget child;
  final bool enabled;
  final String? asset;

  /// Avisa os cabeçalhos quando uma região aparece, some ou muda de tom.
  static final changed = ValueNotifier<int>(0);

  @override
  State<DarkBackdrop> createState() => _DarkBackdropState();
}

class _DarkBackdropState extends State<DarkBackdrop> {
  static final active = <_DarkBackdropState>{};
  static final _luma = <String, double>{};
  static final _pending = <String>{};

  bool get isDark {
    if (!widget.enabled) return false;
    final a = widget.asset;
    if (a == null) return true;
    final l = _luma[a];
    return l != null && l < 0.5;
  }

  void _bump() => DarkBackdrop.changed.value++;

  Future<void> _measure(String asset) async {
    if (_luma.containsKey(asset) || !_pending.add(asset)) return;
    try {
      final data = await rootBundle.load(asset);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
          targetWidth: 24);
      final image = (await codec.getNextFrame()).image;
      final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (bytes == null) return;
      // Topo (45%) da imagem: é o que passa sob o cabeçalho.
      final rows = math.max(1, (image.height * 0.45).round());
      var sum = 0.0;
      for (var y = 0; y < rows; y++) {
        for (var x = 0; x < image.width; x++) {
          final i = (y * image.width + x) * 4;
          sum += (0.2126 * bytes.getUint8(i) +
                  0.7152 * bytes.getUint8(i + 1) +
                  0.0722 * bytes.getUint8(i + 2)) /
              255;
        }
      }
      _luma[asset] = sum / (rows * image.width);
      _bump();
    } catch (_) {
      // Sem medida: trata como clara (texto escuro, o padrão).
    } finally {
      _pending.remove(asset);
    }
  }

  @override
  void initState() {
    super.initState();
    active.add(this);
    final a = widget.asset;
    if (a != null) _measure(a);
    WidgetsBinding.instance.addPostFrameCallback((_) => _bump());
  }

  @override
  void didUpdateWidget(covariant DarkBackdrop old) {
    super.didUpdateWidget(old);
    final a = widget.asset;
    if (a != old.asset || widget.enabled != old.enabled) {
      if (a != null) _measure(a);
      WidgetsBinding.instance.addPostFrameCallback((_) => _bump());
    }
  }

  @override
  void dispose() {
    active.remove(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _bump());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Há conteúdo escuro sob o centro deste widget (área do título)? No tema
/// escuro o texto já é claro: sempre false. Precisa do layout atual — use
/// [OnDarkBuilder], que mede depois de cada quadro.
bool isOverDark(BuildContext context) {
  if (TravelPalette.of(context).isDark) return false;
  final me = context.findRenderObject();
  if (me is! RenderBox || !me.attached || !me.hasSize) return false;
  final r = me.localToGlobal(Offset.zero) & me.size;
  // Metade de baixo do cabeçalho, no centro: no alto o véu do desfoque já
  // clareia o fundo, então só conta o que passa onde o véu é fraco.
  final band = Rect.fromLTRB(r.center.dx - r.width * 0.2,
      r.top + r.height * 0.5, r.center.dx + r.width * 0.2, r.bottom);
  for (final s in _DarkBackdropState.active) {
    if (!s.mounted || !s.isDark) continue;
    final box = s.context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) continue;
    final hit = (box.localToGlobal(Offset.zero) & box.size).intersect(band);
    if (hit.width >= band.width * 0.5 && hit.height >= band.height * 0.8) {
      return true;
    }
  }
  return false;
}

/// Entrega se há fundo escuro por baixo. Mede **depois** do layout de cada
/// quadro (rolagem, região nova, tom medido) — sem atraso de um quadro.
class OnDarkBuilder extends StatefulWidget {
  const OnDarkBuilder({required this.scroll, required this.builder, super.key});

  final Listenable scroll;
  final Widget Function(BuildContext context, bool onDark) builder;

  @override
  State<OnDarkBuilder> createState() => _OnDarkBuilderState();
}

class _OnDarkBuilderState extends State<OnDarkBuilder> {
  bool _dark = false;
  bool _scheduled = false;

  void _schedule() {
    if (_scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!mounted) return;
      final d = isOverDark(context);
      if (d != _dark) setState(() => _dark = d);
    });
  }

  @override
  void initState() {
    super.initState();
    widget.scroll.addListener(_schedule);
    DarkBackdrop.changed.addListener(_schedule);
  }

  @override
  void didUpdateWidget(covariant OnDarkBuilder old) {
    super.didUpdateWidget(old);
    if (old.scroll != widget.scroll) {
      old.scroll.removeListener(_schedule);
      widget.scroll.addListener(_schedule);
    }
  }

  @override
  void dispose() {
    widget.scroll.removeListener(_schedule);
    DarkBackdrop.changed.removeListener(_schedule);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _schedule();
    return widget.builder(context, _dark);
  }
}

/// Barra de sheet no padrão iOS (ref. Mobbin: ChatGPT, Photoroom): título
/// centralizado e X em círculo (36 visível, alvo 44) à direita; o espaço à
/// esquerda equilibra o título. [fill]/[ink] pra sheets de paleta própria
/// (conectores, sempre escuro).
class SheetBar extends StatelessWidget {
  const SheetBar({
    required this.onClose,
    this.title,
    this.fill,
    this.ink,
    super.key,
  });

  final String? title;
  final VoidCallback onClose;
  final Color? fill;
  final Color? ink;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final fg = ink ?? p.ink;
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          const SizedBox(width: TravelSpace.tap),
          Expanded(
            child: title == null
                ? const SizedBox.shrink()
                : Semantics(
                    header: true,
                    child: Text(
                      title!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TravelType.headline.copyWith(color: fg, height: 1.2),
                    ),
                  ),
          ),
          Semantics(
            button: true,
            label: 'Fechar',
            excludeSemantics: true,
            onTap: onClose,
            child: Pressable(
              onTap: onClose,
              child: SizedBox.square(
                dimension: TravelSpace.tap,
                child: Center(
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: fill ?? p.s1,
                      shape: BoxShape.circle,
                    ),
                    child: FaIcon(TravelIcons.close, size: 15, color: fg),
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
