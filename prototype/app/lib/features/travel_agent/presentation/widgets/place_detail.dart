import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/core/components/glass/app_glass.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/photo_viewer.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';

/// Altura reservada no topo da lista para o cabeçalho flutuante.
const kDetailHeaderSpace = 18.0 + 44 + 8;

/// Card do rolê — abre DENTRO do sheet (sem empilhar sheets).
///
/// Ordem: hero de fotos → título + texto do rolê → por que é rolê →
/// o que fazer (cards horizontais) → horário e preço → vídeos curtos →
/// selo e entorno → fotos (carrossel). Listas horizontais sangram até a
/// borda do sheet; o resto respeita a margem de 12pt. O cabeçalho
/// ([DetailHeader]) fica fora da lista, flutuando sobre o fade do sheet.
class PlaceDetail extends StatelessWidget {
  const PlaceDetail({
    required this.role,
    required this.scrollController,
    required this.onPlayVideo,
    super.key,
  });

  final Role role;
  final ScrollController scrollController;

  /// Índice do vídeo + contexto do tile (para a transição de expansão).
  final void Function(int index, BuildContext tile) onPlayVideo;

  static Widget _g(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: TravelSpace.gutter),
        child: child,
      );

  static Widget _text(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: TravelSpace.content),
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.only(
          top: kDetailHeaderSpace - 8 + SheetTopInset.of(context), bottom: 120),
      children: [
        _g(PhotoHero(photos: role.photos)),
        const SizedBox(height: TravelSpace.lg),
        _text(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Único título em Oswald: o do card visual do rolê.
              Text(
                role.name.toUpperCase(),
                style: TravelType.cardTitleLarge.copyWith(color: p.ink),
              ),
              const SizedBox(height: TravelSpace.sm),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  CategoryTag(role.category),
                  _Meta(TravelIcons.place, role.neighborhood),
                  _Meta(TravelIcons.ticket, role.price),
                  _Meta(TravelIcons.clock, role.hours),
                ],
              ),
              const SizedBox(height: TravelSpace.md),
              Text(role.about, style: TravelType.body.copyWith(color: p.ink)),
            ],
          ),
        ),
        const SizedBox(height: TravelSpace.xl),

        // Por que é rolê — quem indicou (S2).
        _g(
          SolidBlock(
            level: SurfaceLevel.s2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    RecommenderAvatar(role.recommender, size: 40),
                    const SizedBox(width: TravelSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Indicado por ${role.recommender.name}',
                            style:
                                TravelType.subheadStrong.copyWith(color: p.ink),
                          ),
                          Text(
                            role.recommender.tie,
                            style:
                                TravelType.footnote.copyWith(color: p.inkMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TravelSpace.md),
                Text(
                  '“${role.recommender.quote}”',
                  style: TravelType.callout
                      .copyWith(color: p.ink, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),

        // O que fazer — cards curtos na horizontal.
        if (role.tips.isNotEmpty) ...[
          const SizedBox(height: TravelSpace.xl),
          _g(const SectionHeader('O que fazer')),
          EdgeFadeScroll(
            height: 104,
            itemCount: role.tips.length,
            itemBuilder: (context, i) => _TipCard(tip: role.tips[i]),
          ),
        ],

        // Bom saber — lista agrupada estilo Ajustes do iPhone (escolha do
        // designer entre lista, carrossel e texto solto).
        const SizedBox(height: TravelSpace.xl),
        _g(const SectionHeader('Bom saber')),
        _g(_GroupedFacts(rows: [
          (TravelIcons.clock, 'Melhor horário', role.bestTime),
          (TravelIcons.ticket, 'Quanto custa', role.cost),
        ])),

        // Vídeos curtos.
        const SizedBox(height: TravelSpace.xl),
        _g(const SectionHeader('Vídeos curtos')),
        EdgeFadeScroll(
          height: 216,
          spacing: 10,
          itemCount: role.videos.length,
          itemBuilder: (context, i) => ShortTile(
            video: role.videos[i],
            onTap: (tile) => onPlayVideo(i, tile),
          ),
        ),

        // Selo e entorno.
        const SizedBox(height: TravelSpace.xl),
        _g(const SectionHeader('Selo e entorno')),
        _g(_SealBlock(verifiedAt: role.verifiedAt)),
        const SizedBox(height: TravelSpace.sm),
        _g(_GroupedChecks(items: role.surroundings)),

        // Fotos — carrossel M3 Expressive (multi-browse).
        const SizedBox(height: TravelSpace.xl),
        _g(const SectionHeader('Fotos')),
        _g(
          SizedBox(
            height: 196,
            child: CarouselView.weighted(
              flexWeights: const [3, 2, 1],
              itemSnapping: true,
              enableSplash: false,
              padding: const EdgeInsets.symmetric(horizontal: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(TravelSpace.rCard),
              ),
              onTap: (i) =>
                  showPhotoViewer(context, photos: role.photos, initial: i),
              children: [
                for (final ph in role.photos)
                  Image.asset(ph.asset, fit: BoxFit.cover),
              ],
            ),
          ),
        ),
        const SizedBox(height: TravelSpace.sm),
        _text(
          Text(
            'Fotos via Wikimedia Commons',
            style: TravelType.caption.copyWith(color: p.inkMuted),
          ),
        ),
      ],
    );
  }
}

/// Cabeçalho do card do rolê, fixo sobre o conteúdo.
///
/// Em repouso: voltar + título à esquerda. Ao rolar: o voltar vira um botão
/// flutuante fosco (o conteúdo passa por baixo, sob o fade do sheet) e o
/// título faz um fade transitório até o centro.
class DetailHeader extends StatelessWidget {
  const DetailHeader({
    required this.scroll,
    required this.title,
    required this.onBack,
    super.key,
  });

  final ScrollController scroll;
  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final style = TravelType.subheadStrong;
    // Foto/vídeo escuro sob o desfoque: título em claro (iOS).
    return OnDarkBuilder(
      scroll: scroll,
      builder: (context, onDark) => AnimatedBuilder(
        animation: scroll,
        builder: (context, _) {
          final offset = scroll.hasClients && scroll.positions.length == 1
              ? scroll.offset
              : 0.0;
          final t = Curves.easeOut.transform((offset / 48).clamp(0.0, 1.0));
          return SizedBox(
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Título em repouso (esquerda) → some deslizando.
                Positioned(
                  left: 56,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 1 - t,
                      child: Transform.translate(
                        offset: Offset(12 * t, 0),
                        child: Text(title,
                            style: style.copyWith(
                                color: onDark ? Colors.white70 : p.inkMuted)),
                      ),
                    ),
                  ),
                ),
                // Título rolado (centro) → entra com fade.
                IgnorePointer(
                  child: Opacity(
                    opacity: t,
                    child: Transform.translate(
                      offset: Offset(0, 6 * (1 - t)),
                      child: Text(title,
                          style: style.copyWith(
                              color: onDark ? Colors.white : p.ink)),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Semantics(
                    button: true,
                    label: 'Voltar pra conversa',
                    excludeSemantics: true,
                    onTap: onBack,
                    child: Pressable(
                      onTap: onBack,
                      child: AppBackdropBlur(
                        sigma: 12 * t,
                        circle: true,
                        liteColor: p.s1.withValues(alpha: 0.6 * t),
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: p.s1.withValues(alpha: 1 - 0.25 * t),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: p.ink.withValues(alpha: 0.06 * t),
                            ),
                          ),
                          child:
                              FaIcon(TravelIcons.back, size: 16, color: p.ink),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta(this.icon, this.text);

  final FaIconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(icon, size: 12, color: p.inkMuted),
        const SizedBox(width: 5),
        Text(text, style: TravelType.footnote.copyWith(color: p.inkMuted)),
      ],
    );
  }
}

/// Ícone de linha no estilo Ajustes do iPhone: glifo maior (20) em `ink`,
/// centrado na linha numa coluna de 30 — sem quadrado de fundo (pedido do
/// designer).
class _RowIcon extends StatelessWidget {
  const _RowIcon(this.icon);

  final FaIconData icon;

  static const size = 30.0;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return SizedBox.square(
      dimension: size,
      child: Center(child: FaIcon(icon, size: 20, color: p.ink)),
    );
  }
}

/// Divisor recuado (começa no texto, não sob o ícone), 1 pixel físico.
class _InsetDivider extends StatelessWidget {
  const _InsetDivider();

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: _RowIcon.size + TravelSpace.md),
      child: Container(
        height: 1 / MediaQuery.devicePixelRatioOf(context),
        color: p.ink.withValues(alpha: 0.12),
      ),
    );
  }
}

/// "Bom saber": lista agrupada Ajustes — ícone centrado, rótulo pequeno em
/// cima e valor embaixo, divisor recuado.
class _GroupedFacts extends StatelessWidget {
  const _GroupedFacts({required this.rows});

  final List<(FaIconData, String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: TravelSpace.cardPad),
      decoration: BoxDecoration(
        color: p.s1,
        borderRadius: BorderRadius.circular(TravelSpace.rCard),
      ),
      child: Column(
        children: [
          for (final (i, (icon, label, value)) in rows.indexed) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: TravelSpace.md),
              child: Row(
                children: [
                  _RowIcon(icon),
                  const SizedBox(width: TravelSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style:
                                TravelType.caption.copyWith(color: p.inkMuted)),
                        const SizedBox(height: 2),
                        Text(value,
                            style: TravelType.subhead
                                .copyWith(color: p.ink, height: 1.35)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (i < rows.length - 1) const _InsetDivider(),
          ],
        ],
      ),
    );
  }
}

/// Card de dica: ícone neutro + texto curto.
class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip});

  final RoleTip tip;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Container(
      width: 140,
      padding: const EdgeInsets.all(TravelSpace.md),
      decoration: BoxDecoration(
        color: p.s1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(tipIcon(tip.kind), size: 17, color: p.ink),
          const Spacer(),
          Text(
            tip.text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TravelType.footnote.copyWith(color: p.ink, height: 1.35),
          ),
        ],
      ),
    );
  }
}

/// "Rolê seguro" — bloco próprio, separado da lista de checks.
class _SealBlock extends StatelessWidget {
  const _SealBlock({required this.verifiedAt});

  final String verifiedAt;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return SolidBlock(
      child: Row(
        children: [
          const _RowIcon(TravelIcons.safety),
          const SizedBox(width: TravelSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rolê seguro',
                    style: TravelType.subheadStrong.copyWith(color: p.ink)),
                Text(
                  'Dados verificados em $verifiedAt',
                  style: TravelType.footnote.copyWith(color: p.inkMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Lista agrupada estilo Ajustes do iPhone (igual a "Bom saber"): ícone
/// em quadradinho neutro centrado, texto e divisor recuado.
class _GroupedChecks extends StatelessWidget {
  const _GroupedChecks({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: TravelSpace.cardPad),
      decoration: BoxDecoration(
        color: p.s1,
        borderRadius: BorderRadius.circular(TravelSpace.rCard),
      ),
      child: Column(
        children: [
          for (final (i, item) in items.indexed) ...[
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: TravelSpace.tap + 8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: TravelSpace.sm),
                child: Row(
                  children: [
                    const _RowIcon(TravelIcons.check),
                    const SizedBox(width: TravelSpace.md),
                    Expanded(
                      child: Text(
                        item,
                        style: TravelType.subhead
                            .copyWith(color: p.ink, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (i < items.length - 1) const _InsetDivider(),
          ],
        ],
      ),
    );
  }
}

/// Hero de fotos: toque abre em tela cheia. Só bolinhas; a contagem
/// aparece alinhada a elas depois do primeiro deslize.
class PhotoHero extends StatefulWidget {
  const PhotoHero({required this.photos, super.key});

  final List<PhotoCredit> photos;

  @override
  State<PhotoHero> createState() => _PhotoHeroState();
}

class _PhotoHeroState extends State<PhotoHero> {
  final _pc = PageController();
  int _i = 0;
  bool _touched = false;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    // Escura só se o topo da foto atual for escuro (luminância medida).
    return DarkBackdrop(
      asset: widget.photos[_i].asset,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TravelSpace.rCard)),
        foregroundDecoration: imageOutline(p, TravelSpace.rCard),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Semantics(
                button: true,
                label: 'Abrir fotos em tela cheia',
                child: GestureDetector(
                  onTap: () => showPhotoViewer(context,
                      photos: widget.photos, initial: _i),
                  child: PageView(
                    controller: _pc,
                    onPageChanged: (i) => setState(() {
                      _i = i;
                      _touched = true;
                    }),
                    children: [
                      for (final photo in widget.photos)
                        Image.asset(photo.asset, fit: BoxFit.cover),
                    ],
                  ),
                ),
              ),
              // Gradiente só para a legibilidade das bolinhas.
              const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x00000000),
                        Color(0x00000000),
                        Color(0x66000000)
                      ],
                      stops: [0, 0.7, 1],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: TravelSpace.md,
                right: TravelSpace.md,
                child: Row(
                  children: [
                    AppFrostButton(
                      icon: const FaIcon(TravelIcons.bookmark),
                      semanticLabel: 'Salvar rolê',
                      onPressed: () {},
                    ),
                    const SizedBox(width: TravelSpace.sm),
                    AppFrostButton(
                      icon: const FaIcon(TravelIcons.share),
                      semanticLabel: 'Compartilhar',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              Positioned(
                left: TravelSpace.md,
                right: TravelSpace.md,
                bottom: TravelSpace.md,
                child: IgnorePointer(
                  child: SizedBox(
                    height: 20,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PhotoDots(count: widget.photos.length, index: _i),
                        Align(
                          alignment: Alignment.centerRight,
                          child: AnimatedOpacity(
                            opacity: _touched ? 1 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              '${_i + 1}/${widget.photos.length}',
                              style: TravelType.caption.copyWith(
                                color: Colors.white,
                                fontFeatures: TravelType.tabular,
                              ),
                            ),
                          ),
                        ),
                      ],
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

/// Tile 9:16 de vídeo curto (TikTok · Instagram · gravado por local).
class ShortTile extends StatelessWidget {
  const ShortTile({
    required this.video,
    required this.onTap,
    this.width = 122,
    this.compact = false,
    super.key,
  });

  final ShortVideo video;
  final void Function(BuildContext tile) onTap;
  final double width;

  /// Versão pequena (guia do dia): só play e fonte, sem @ nem duração.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final secs = video.duration.inSeconds;
    return Semantics(
      button: true,
      label:
          'Vídeo de ${video.handle} no ${videoSourceLabel(video.source)}, $secs segundos',
      excludeSemantics: true,
      onTap: () => onTap(context),
      child: DarkBackdrop(
        child: Pressable(
          onTap: () => onTap(context),
          child: Container(
            width: width,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(TravelSpace.rInner)),
            foregroundDecoration: imageOutline(p, TravelSpace.rInner),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(video.poster, fit: BoxFit.cover),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x59000000),
                        Color(0x00000000),
                        Color(0xB3000000)
                      ],
                      stops: [0, 0.35, 1],
                    ),
                  ),
                ),
                Positioned(
                  top: compact ? 6 : 10,
                  left: compact ? 6 : 10,
                  child: FaIcon(videoSourceIcon(video.source),
                      size: compact ? 11 : 13, color: Colors.white),
                ),
                Center(
                    child: FaIcon(TravelIcons.circlePlay,
                        size: compact ? 22 : 34, color: Colors.white)),
                if (!compact)
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.handle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TravelType.caption
                              .weight(FontWeight.w500)
                              .copyWith(color: Colors.white),
                        ),
                        Text(
                          '0:${secs.toString().padLeft(2, '0')}',
                          style: TravelType.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontFeatures: TravelType.tabular,
                          ),
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
