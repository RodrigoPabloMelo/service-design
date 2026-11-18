import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/core/components/glass/app_glass.dart';
import 'package:studio_app/features/explore/data/explore_mock.dart';
import 'package:studio_app/features/explore/presentation/widgets/explore_ui.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/photo_viewer.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';

/// Card de categoria: foto de um lugar daqui, véu na cor da categoria e
/// ícone ilustrado + rótulo em branco por cima.
class CategoryCard extends StatelessWidget {
  const CategoryCard({required this.info, required this.onTap, super.key});

  static const width = 116.0;
  static const height = 148.0;

  final ExploreCategoryInfo info;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tone = exploreCategoryTone(info.category);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return Semantics(
      button: true,
      label: info.label,
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(TravelSpace.rCard),
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  info.photo,
                  fit: BoxFit.cover,
                  cacheWidth: (width * dpr * 1.6).round(),
                ),
                ColoredBox(
                  color:
                      tone.withValues(alpha: ExploreCategoryTones.overlayAlpha),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CategoryIcon(info.category, color: Colors.white, size: 64),
                    const SizedBox(height: 4),
                    Text(
                      info.label,
                      style: TravelType.footnoteStrong
                          .copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Card do rolê na home e nos resultados: foto, nome, onde, quem indicou e
/// por que pra você (F-02, F-13). Entorno e data ficam no detalhe.
class RoleCard extends StatelessWidget {
  const RoleCard({
    required this.role,
    required this.heroTag,
    required this.saved,
    required this.onTap,
    required this.onToggleSave,
    this.width,
    this.photoAspect = 5 / 4,
    this.meta,
    super.key,
  });

  final Role role;
  final Object heroTag;
  final bool saved;
  final VoidCallback onTap;
  final VoidCallback onToggleSave;

  /// Null = largura total (lista de resultados).
  final double? width;
  final double photoAspect;

  /// Linha de lugar; padrão "Bairro, preço".
  final String? meta;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final reason = ExploreMock.tags[role.id]?.reason;
    // "Seu Zé", "Dona Lindu": o pronome de tratamento vai junto do nome.
    final parts = role.recommender.name.split(' ');
    final firstName = parts.length > 1 && {'Seu', 'Dona'}.contains(parts[0])
        ? '${parts[0]} ${parts[1]}'
        : parts.first;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final w = width;
    final card = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: photoAspect,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: heroTag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(TravelSpace.rCard),
                  child: Image.asset(
                    role.photos.first.asset,
                    fit: BoxFit.cover,
                    cacheWidth: ((w ?? 400) * dpr).round(),
                  ),
                ),
              ),
              IgnorePointer(
                child: DecoratedBox(
                    decoration: imageOutline(p, TravelSpace.rCard)),
              ),
              Positioned(
                top: 4,
                right: 4,
                // Botão visível de 36 num alvo de 44 (HIG).
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onToggleSave,
                  child: SizedBox.square(
                    dimension: TravelSpace.tap,
                    child: Center(
                      child: AppFrostButton(
                        size: 36,
                        semanticLabel: saved ? 'Tirar dos salvos' : 'Salvar',
                        onPressed: onToggleSave,
                        icon: AnimatedSwitcher(
                          duration: exploreMotion(context, 150),
                          transitionBuilder: (child, a) =>
                              ScaleTransition(scale: a, child: child),
                          child: FaIcon(
                            saved
                                ? TravelIcons.bookmarkSolid
                                : TravelIcons.bookmark,
                            key: ValueKey(saved),
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role.shortName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TravelType.cardTitle.copyWith(color: p.ink),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        meta ?? '${role.neighborhood}, ${role.price}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TravelType.footnote.copyWith(
                            color: p.inkMuted,
                            fontFeatures: TravelType.tabular),
                      ),
                    ),
                    // Selo visível já no card (UX.md §5, Q-10).
                    const SizedBox(width: TravelSpace.sm),
                    FaIcon(TravelIcons.safety, size: 11, color: p.inkMuted),
                    const SizedBox(width: 4),
                    Text(
                      'Rolê seguro',
                      style: TravelType.footnote.copyWith(color: p.inkMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    RecommenderAvatar(role.recommender, size: 20),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Indicado por $firstName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TravelType.footnoteStrong.copyWith(color: p.ink),
                      ),
                    ),
                  ],
                ),
                if (reason != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    reason,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TravelType.footnote.copyWith(color: p.inkMuted),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
    return Semantics(
      button: true,
      label: '${role.shortName}, ${role.neighborhood}. '
          'Indicado por $firstName. Rolê seguro. ${reason ?? ''}',
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: w == null ? card : SizedBox(width: w, child: card),
      ),
    );
  }
}

/// Skeleton de um card de rolê.
class RoleCardSkeleton extends StatelessWidget {
  const RoleCardSkeleton({this.width = 248, super.key});

  final double width;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(
                width: width, height: width * 4 / 5, radius: TravelSpace.rCard),
            const SizedBox(height: 12),
            SkeletonBox(width: width * 0.7, height: 18),
            const SizedBox(height: 8),
            SkeletonBox(width: width * 0.45, height: 12),
            const SizedBox(height: 12),
            SkeletonBox(width: width * 0.9, height: 12),
          ],
        ),
      );
}

/// Card grande dos resultados da busca (ref. Airbnb): fotos em carrossel
/// com bolinhas, selo em pílula de frost no canto, salvar à direita;
/// embaixo nome + distância, onde e preço, quem indicou e por quê.
class RoleResultCard extends StatefulWidget {
  const RoleResultCard({
    required this.role,
    required this.heroTag,
    required this.saved,
    required this.distance,
    required this.onTap,
    required this.onToggleSave,
    super.key,
  });

  final Role role;
  final Object heroTag;
  final bool saved;

  /// "a 2,1 km do hotel".
  final String distance;
  final VoidCallback onTap;
  final VoidCallback onToggleSave;

  @override
  State<RoleResultCard> createState() => _RoleResultCardState();
}

class _RoleResultCardState extends State<RoleResultCard> {
  final _pages = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final role = widget.role;
    final reason = ExploreMock.tags[role.id]?.reason;
    final parts = role.recommender.name.split(' ');
    final firstName = parts.length > 1 && {'Seu', 'Dona'}.contains(parts[0])
        ? '${parts[0]} ${parts[1]}'
        : parts.first;
    final photos = role.photos;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final w = MediaQuery.sizeOf(context).width;
    final card = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: widget.heroTag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(TravelSpace.rCard),
                  child: PageView.builder(
                    controller: _pages,
                    itemCount: photos.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (_, i) => Image.asset(
                      photos[i].asset,
                      fit: BoxFit.cover,
                      cacheWidth: (w * dpr).round(),
                    ),
                  ),
                ),
              ),
              IgnorePointer(
                child: DecoratedBox(
                    decoration: imageOutline(p, TravelSpace.rCard)),
              ),
              // Selo no ponto de decisão (UX.md §5; nome em Q-10).
              const Positioned(top: 12, left: 12, child: _SealPill()),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onToggleSave,
                  child: SizedBox.square(
                    dimension: TravelSpace.tap + 8,
                    child: Center(
                      child: AppFrostButton(
                        size: 40,
                        semanticLabel:
                            widget.saved ? 'Tirar dos salvos' : 'Salvar',
                        onPressed: widget.onToggleSave,
                        icon: FaIcon(
                          widget.saved
                              ? TravelIcons.bookmarkSolid
                              : TravelIcons.bookmark,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (photos.length > 1)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 12,
                  child: IgnorePointer(
                    child: Center(
                        child: PhotoDots(count: photos.length, index: _page)),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: TravelSpace.md),
        ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        role.shortName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TravelType.cardTitle.copyWith(color: p.ink),
                      ),
                    ),
                    const SizedBox(width: TravelSpace.sm),
                    Text(
                      widget.distance,
                      style: TravelType.footnote.copyWith(
                          color: p.inkMuted, fontFeatures: TravelType.tabular),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${role.neighborhood}, ${role.hours}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TravelType.subhead.copyWith(color: p.inkMuted),
                ),
                const SizedBox(height: TravelSpace.xs),
                Text(
                  role.cost,
                  style: TravelType.subheadStrong.copyWith(
                      color: p.ink, fontFeatures: TravelType.tabular),
                ),
                const SizedBox(height: TravelSpace.sm),
                Row(
                  children: [
                    RecommenderAvatar(role.recommender, size: 22),
                    const SizedBox(width: TravelSpace.sm),
                    Expanded(
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: 'Indicado por $firstName',
                            style: TravelType.footnoteStrong
                                .copyWith(color: p.ink),
                          ),
                          if (reason != null)
                            TextSpan(
                              text: '. $reason',
                              style: TravelType.footnote
                                  .copyWith(color: p.inkMuted),
                            ),
                        ]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
    return Semantics(
      button: true,
      label: '${role.shortName}, ${role.neighborhood}, ${widget.distance}. '
          'Rolê seguro. Indicado por $firstName. ${reason ?? ''}',
      onTap: widget.onTap,
      child: Pressable(onTap: widget.onTap, child: card),
    );
  }
}

/// Pílula de frost sobre a foto: selo de segurança.
class _SealPill extends StatelessWidget {
  const _SealPill();

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return AppBackdropBlur(
      sigma: 14,
      borderRadius: BorderRadius.circular(TravelSpace.rPill),
      liteColor: p.s1.withValues(alpha: 0.9),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: p.s1.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(TravelSpace.rPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(TravelIcons.safety, size: 12, color: p.ink),
            const SizedBox(width: 6),
            Text('Rolê seguro',
                style: TravelType.footnoteStrong.copyWith(color: p.ink)),
          ],
        ),
      ),
    );
  }
}
