import 'package:flutter/material.dart';
import 'package:studio_app/features/explore/data/explore_mock.dart';
import 'package:studio_app/features/explore/domain/explore_entities.dart';
import 'package:studio_app/features/explore/presentation/widgets/explore_ui.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/place_detail.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/short_video_player.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';

/// Detalhe do rolê aberto a partir da home ou da busca. Reaproveita o card
/// do rolê do agente ([PlaceDetail]) em tela cheia, com a foto em Hero.
class RolePage extends StatefulWidget {
  const RolePage({required this.role, required this.heroTag, super.key});

  final Role role;
  final Object heroTag;

  @override
  State<RolePage> createState() => _RolePageState();
}

class _RolePageState extends State<RolePage> {
  final _scroll = ScrollController();
  final _stack = GlobalKey();

  /// Vídeo aberto: índice + retângulo do tile de origem.
  (int, Rect?)? _player;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _play(int index, BuildContext tile) {
    Rect? origin;
    final box = tile.findRenderObject();
    final stack = _stack.currentContext?.findRenderObject();
    if (box is RenderBox && stack is RenderBox) {
      origin = box.localToGlobal(Offset.zero, ancestor: stack) & box.size;
    }
    setState(() => _player = (index, origin));
  }

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final top = MediaQuery.paddingOf(context).top;
    final role = widget.role;
    final player = _player;
    return Scaffold(
      backgroundColor: p.s0,
      body: SheetTopInset(
        value: top,
        child: Stack(
          key: _stack,
          children: [
            PlaceDetail(
              role: role,
              scrollController: _scroll,
              heroTag: widget.heroTag,
              onPlayVideo: _play,
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ProgressiveBlurTop(height: top + 64),
            ),
            Positioned(
              top: top + 8,
              left: TravelSpace.gutter,
              right: TravelSpace.gutter,
              child: DetailHeader(
                scroll: _scroll,
                title: 'Rolê de local',
                backLabel: 'Voltar',
                onBack: () => Navigator.of(context).maybePop(),
              ),
            ),
            if (player != null)
              Positioned.fill(
                child: ShortVideoPlayer(
                  key: ValueKey('${role.id}-${player.$1}'),
                  role: role,
                  initialIndex: player.$1,
                  origin: player.$2,
                  distance: formatKm(distanceKm(
                      ExploreMock.profile.stayLocation, role.location)),
                  onClose: () => setState(() => _player = null),
                  onOpenRole: () => setState(() => _player = null),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Abre o detalhe com a rota da home (Hero da foto).
void openRole(BuildContext context, Role role, Object heroTag) {
  Navigator.of(context).push(exploreRoute(
    withExplore(context, RolePage(role: role, heroTag: heroTag)),
  ));
}
