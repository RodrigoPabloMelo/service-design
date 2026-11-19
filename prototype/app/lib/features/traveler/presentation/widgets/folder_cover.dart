import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/features/explore/data/explore_mock.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';

/// Capa de pasta (ref. pastas do Pinterest): uma foto grande à esquerda e
/// duas pequenas à direita, separadas por 2 px de fundo. Com menos fotos,
/// a grande ocupa tudo; sem nenhuma, um tile `s2` com a pasta.
class FolderCover extends StatelessWidget {
  const FolderCover({
    required this.roleIds,
    required this.radius,
    this.mosaic = true,
    super.key,
  });

  final List<String> roleIds;
  final double radius;

  /// false = só a primeira foto (tiles pequenos de lista).
  final bool mosaic;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final photos = [
      for (final id in roleIds.take(3))
        ExploreMock.roleById(id).photos.first.asset,
    ];
    Widget photo(String asset, double w) => Image.asset(
          asset,
          fit: BoxFit.cover,
          cacheWidth: (w * dpr).round(),
        );
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: LayoutBuilder(builder: (context, box) {
        if (photos.isEmpty) {
          return ColoredBox(
            color: p.s2,
            child: Center(
              child: FaIcon(TravelIcons.folder,
                  size: box.maxWidth > 80 ? 28 : 18, color: p.inkMuted),
            ),
          );
        }
        if (!mosaic || photos.length < 3) {
          return SizedBox.expand(child: photo(photos.first, box.maxWidth));
        }
        const gap = TravelSpace.segmentGap;
        final side = (box.maxWidth - gap) / 3;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 2, child: photo(photos[0], side * 2)),
            const SizedBox(width: gap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: photo(photos[1], side)),
                  const SizedBox(height: gap),
                  Expanded(child: photo(photos[2], side)),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
