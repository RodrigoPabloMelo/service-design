import 'package:flutter/material.dart';
import 'package:studio_app/features/explore/data/explore_mock.dart';
import 'package:studio_app/features/explore/presentation/views/shorts_feed_page.dart';
import 'package:studio_app/features/explore/presentation/widgets/explore_ui.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';

/// Prateleira "Vídeos curtos" da home (ref. Shorts, D-29): tiles 9:16 com a
/// legenda sobre a foto. Tocar abre o feed vertical naquele vídeo.
class ShortsShelf extends StatelessWidget {
  const ShortsShelf({super.key});

  static const tileW = 136.0;
  static const tileH = tileW * 16 / 9;

  @override
  Widget build(BuildContext context) {
    final shorts = ExploreMock.shorts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ExploreSectionTitle('Vídeos curtos'),
        const SizedBox(height: TravelSpace.md),
        EdgeFadeScroll(
          height: tileH,
          spacing: TravelSpace.sm,
          itemCount: shorts.length,
          itemBuilder: (context, i) => _ShortTile(index: i),
        ),
      ],
    );
  }
}

class _ShortTile extends StatelessWidget {
  const _ShortTile({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final (role, video) = ExploreMock.shorts[index];
    final dpr = MediaQuery.devicePixelRatioOf(context);
    void onTap() => openShorts(context, index);
    return Semantics(
      button: true,
      label: 'Vídeo sobre ${role.shortName}: ${video.caption}',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: SizedBox(
          width: ShortsShelf.tileW,
          height: ShortsShelf.tileH,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(TravelSpace.rCard),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'short-${video.id}',
                  child: Image.asset(
                    video.poster,
                    fit: BoxFit.cover,
                    cacheWidth: (ShortsShelf.tileW * dpr).round(),
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00000000), Color(0xB3000000)],
                      stops: [0.45, 1],
                    ),
                  ),
                ),
                Positioned(
                  left: TravelSpace.md,
                  right: TravelSpace.md,
                  bottom: TravelSpace.md,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        video.caption,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TravelType.footnoteStrong
                            .copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        role.shortName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TravelType.caption
                            .copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
