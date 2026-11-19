import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/core/components/glass/app_glass.dart';
import 'package:studio_app/features/explore/data/explore_mock.dart';
import 'package:studio_app/features/explore/domain/explore_entities.dart';
import 'package:studio_app/features/explore/presentation/views/role_page.dart';
import 'package:studio_app/features/explore/presentation/widgets/explore_ui.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/mare_mark.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';
import 'package:studio_app/features/traveler/presentation/widgets/account_sheet.dart';

/// Abre o feed de vídeos curtos no vídeo [index] (tile da home).
void openShorts(BuildContext context, int index) {
  Navigator.of(context).push(exploreRoute(
    context,
    withExplore(context, ShortsFeedPage(initialIndex: index)),
  ));
}

/// Vídeos curtos em tela cheia, rolando na vertical (ref. Shorts), mas
/// **finitos** (D-29, F-06): a fila curada acaba numa página de fim com um
/// recado de se cuidar. Placeholder de design: o "vídeo" é a foto do lugar
/// com Ken Burns (sem dependência de vídeo). Tocar pausa; o X fecha (o
/// arrastar vertical é da fila, não do fechar).
class ShortsFeedPage extends StatefulWidget {
  const ShortsFeedPage({this.initialIndex = 0, super.key});

  final int initialIndex;

  @override
  State<ShortsFeedPage> createState() => _ShortsFeedPageState();
}

class _ShortsFeedPageState extends State<ShortsFeedPage> {
  late final _pages = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;
  bool _muted = true;

  final _shorts = ExploreMock.shorts;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context).maybePop();

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final atEnd = _index >= _shorts.length;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Builder(
        builder: (context) => Stack(
          children: [
            // Mouse também arrasta (preview no desktop); no celular é toque.
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: PointerDeviceKind.values.toSet(),
              ),
              child: PageView.builder(
              controller: _pages,
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(
                  parent: PageScrollPhysics()),
              itemCount: _shorts.length + 1,
              onPageChanged: (i) {
                setState(() => _index = i);
                if (i == _shorts.length) HapticFeedback.lightImpact();
              },
              itemBuilder: (context, i) {
                if (i == _shorts.length) {
                  return _EndOfQueue(
                    active: _index == i,
                    onBack: _close,
                  );
                }
                final (role, video) = _shorts[i];
                return _ShortPage(
                  key: ValueKey(video.id),
                  role: role,
                  video: video,
                  active: _index == i,
                  heroTag: 'short-${video.id}',
                );
              },
              ),
            ),
            // Topo: som + fechar (o progresso fica no pé de cada vídeo).
            Positioned(
              top: pad.top + 8,
              right: TravelSpace.gutter,
              child: Row(
                children: [
                  AnimatedOpacity(
                    opacity: atEnd ? 0 : 1,
                    duration: exploreMotion(context, 150),
                    child: IgnorePointer(
                      ignoring: atEnd,
                      child: AppFrostButton(
                        icon: FaIcon(
                            _muted ? TravelIcons.muted : TravelIcons.sound),
                        semanticLabel: _muted ? 'Ativar som' : 'Silenciar',
                        onPressed: () => setState(() => _muted = !_muted),
                      ),
                    ),
                  ),
                  const SizedBox(width: TravelSpace.sm),
                  AppFrostButton(
                    icon: const FaIcon(TravelIcons.close),
                    semanticLabel: 'Fechar vídeos',
                    onPressed: _close,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Um vídeo da fila: Ken Burns enquanto ativo, tocar pausa, e no pé quem
/// indicou, a legenda e o atalho pro rolê (F-02, F-13).
class _ShortPage extends StatefulWidget {
  const _ShortPage({
    required this.role,
    required this.video,
    required this.active,
    required this.heroTag,
    super.key,
  });

  final Role role;
  final ShortVideo video;
  final bool active;
  final Object heroTag;

  @override
  State<_ShortPage> createState() => _ShortPageState();
}

class _ShortPageState extends State<_ShortPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(
        seconds: widget.video.duration.inSeconds.clamp(8, 30)),
  );
  bool _paused = false;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.active) _c.repeat();
  }

  @override
  void didUpdateWidget(covariant _ShortPage old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) {
      _paused = false;
      _c.repeat();
    } else if (!widget.active && old.active) {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _togglePause() {
    setState(() => _paused = !_paused);
    _paused ? _c.stop() : _c.repeat();
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.role;
    final v = widget.video;
    final pad = MediaQuery.paddingOf(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final km = formatKm(
        distanceKm(ExploreMock.profile.stayLocation, role.location));
    return Semantics(
      label: 'Vídeo de ${v.handle} sobre ${role.shortName}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _togglePause,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: widget.heroTag,
              child: ClipRect(
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (context, child) {
                    final k = reduceMotion
                        ? 0.0
                        : Curves.easeInOut
                            .transform(1 - (2 * _c.value - 1).abs());
                    return Transform.scale(
                      scale: 1.04 + 0.1 * k,
                      alignment: Alignment(-0.3 + 0.6 * k, -0.1),
                      child: child,
                    );
                  },
                  child: Image.asset(v.poster, fit: BoxFit.cover),
                ),
              ),
            ),
            const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x66000000),
                      Color(0x00000000),
                      Color(0x00000000),
                      Color(0xD9000000),
                    ],
                    stops: [0, 0.18, 0.5, 1],
                  ),
                ),
              ),
            ),
            if (_paused)
              const IgnorePointer(
                child: Center(
                  child: FaIcon(TravelIcons.circlePause,
                      size: 64, color: Colors.white70),
                ),
              ),
            Positioned(
              left: TravelSpace.lg,
              right: TravelSpace.lg,
              bottom: pad.bottom + 24,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            RecommenderAvatar(role.recommender, size: 28),
                            const SizedBox(width: TravelSpace.sm),
                            Flexible(
                              child: Text(
                                'Indicado por ${role.recommender.name}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TravelType.subheadStrong
                                    .copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            FaIcon(videoSourceIcon(v.source),
                                size: 12, color: Colors.white70),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                v.handle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TravelType.footnote
                                    .copyWith(color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: TravelSpace.sm),
                        GestureDetector(
                          onTap: () => setState(() => _expanded = !_expanded),
                          child: Text(
                            v.caption,
                            maxLines: _expanded ? 6 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: TravelType.callout
                                .copyWith(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: TravelSpace.md),
                        AppFrostButton(
                          icon: FaIcon(categoryIcon(role.category)),
                          label: '${role.shortName} a $km',
                          semanticLabel: 'Ver rolê ${role.shortName}',
                          onPressed: () =>
                              openRole(context, role, 'short-role-${v.id}'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: TravelSpace.md),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SaveFrostButton(roleId: role.id),
                      const SizedBox(height: TravelSpace.sm),
                      AppFrostButton(
                        icon: const FaIcon(TravelIcons.share),
                        semanticLabel: 'Compartilhar',
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Progresso do vídeo: linha fina no pé.
            Positioned(
              left: 0,
              right: 0,
              bottom: pad.bottom,
              child: SizedBox(
                height: 2,
                child: ColoredBox(
                  color: Colors.white.withValues(alpha: 0.2),
                  child: AnimatedBuilder(
                    animation: _c,
                    builder: (context, _) => FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _c.value,
                      child: const ColoredBox(color: Colors.white),
                    ),
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

/// Fim da fila: a Maré aparece com as ondas se abrindo (uma vez), um
/// toque leve de haptic e um recado curto. Sem "carregar mais".
class _EndOfQueue extends StatefulWidget {
  const _EndOfQueue({required this.active, required this.onBack});

  final bool active;
  final VoidCallback onBack;

  @override
  State<_EndOfQueue> createState() => _EndOfQueueState();
}

class _EndOfQueueState extends State<_EndOfQueue>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _play();
  }

  @override
  void didUpdateWidget(covariant _EndOfQueue old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) _play();
  }

  void _play() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.value = 1;
    } else {
      _c.forward(from: 0);
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
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TravelSpace.xxl),
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final pop = Curves.elasticOut
                  .transform((_c.value / 0.6).clamp(0.0, 1.0));
              final text = Curves.easeOut
                  .transform(((_c.value - 0.35) / 0.5).clamp(0.0, 1.0));
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox.square(
                    dimension: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Ondas que se abrem a partir do símbolo (uma vez).
                        for (final d in const [0.0, 0.18])
                          Builder(builder: (context) {
                            final r = ((_c.value - d) / 0.7).clamp(0.0, 1.0);
                            return Container(
                              width: 44 + 76 * r,
                              height: 44 + 76 * r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: p.piscina
                                      .withValues(alpha: 0.6 * (1 - r)),
                                  width: 1.5,
                                ),
                              ),
                            );
                          }),
                        Transform.scale(
                          scale: 0.5 + 0.5 * pop,
                          child: const MareMark(
                              size: 44, mood: MareMood.success),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: TravelSpace.lg),
                  Opacity(
                    opacity: text,
                    child: Transform.translate(
                      offset: Offset(0, 8 * (1 - text)),
                      child: Column(
                        children: [
                          Text(
                            'Você viu tudo por hoje',
                            textAlign: TextAlign.center,
                            style: TravelType.title2
                                .copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: TravelSpace.sm),
                          Text(
                            'Se cuida e bom rolê.',
                            textAlign: TextAlign.center,
                            style: TravelType.body
                                .copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: TravelSpace.xl),
                          AppFrostButton(
                            icon: const FaIcon(TravelIcons.compass),
                            label: 'Voltar pro Explorar',
                            semanticLabel: 'Voltar pro Explorar',
                            onPressed: widget.onBack,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
