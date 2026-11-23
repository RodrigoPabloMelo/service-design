import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studio_app/core/components/glass/app_glass.dart';
import 'package:studio_app/core/components/widgets/app_activity_indicator.dart';
import 'package:studio_app/features/explore/presentation/widgets/explore_ui.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';
import 'package:studio_app/features/traveler/data/traveler_mock.dart';
import 'package:studio_app/features/traveler/domain/traveler_entities.dart';
import 'package:studio_app/features/traveler/presentation/view_models/traveler_cubit.dart';
import 'package:studio_app/features/traveler/presentation/widgets/mare_sheet.dart';
import 'package:studio_app/features/traveler/presentation/widgets/star_rating.dart';

/// Escolhe até [max] fotos e devolve os bytes. Trocável nos testes (o
/// browser do preview não abre diálogo de arquivo).
typedef ReviewPhotoPicker = Future<List<ReviewPhoto>> Function(int max);

/// Seletor em uso. Padrão: `image_picker` (no web, `<input type=file>`; sem
/// `dart:io`, as fotos viram bytes e aparecem com `Image.memory`).
ReviewPhotoPicker reviewPhotoPicker = _pickWithImagePicker;

Future<List<ReviewPhoto>> _pickWithImagePicker(int max) async {
  if (max <= 0) return const [];
  final files = await ImagePicker()
      .pickMultipleMedia(imageQuality: 80, maxWidth: 1600, limit: max);
  final stamp = DateTime.now().microsecondsSinceEpoch;
  return [
    for (final (i, f) in files.take(max).indexed)
      if (_isVideo(f))
        // Vídeo: o protótipo não decodifica quadro; vira tile com play.
        ReviewPhoto(id: '$stamp-$i', bytes: Uint8List(0), video: true)
      else
        ReviewPhoto(id: '$stamp-$i', bytes: await f.readAsBytes()),
  ];
}

bool _isVideo(XFile f) {
  final mime = f.mimeType;
  if (mime != null) return mime.startsWith('video/');
  final name = f.name.toLowerCase();
  return const ['.mp4', '.mov', '.webm', '.m4v', '.3gp'].any(name.endsWith);
}

/// Miniatura de mídia dela: foto pelos bytes; vídeo = `s2` com play.
class ReviewMediaThumb extends StatelessWidget {
  const ReviewMediaThumb(this.media, {super.key});

  final ReviewPhoto media;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    if (!media.video) return Image.memory(media.bytes, fit: BoxFit.cover);
    return ColoredBox(
      color: p.s2,
      child: Center(
        child: FaIcon(TravelIcons.circlePlay, size: 20, color: p.ink),
      ),
    );
  }
}

/// Até quantas fotos ou vídeos ela anexa.
const kMaxReviewPhotos = 4;

/// Avaliação rápida (E-08, D-09, D-30): estrelas → motivos da faixa da nota
/// (opcionais) → "Enviar", ligado desde a primeira estrela. "Contar mais"
/// abre texto e fotos (bônus uma vez — hipótese, Q-27). Fechar guarda o
/// rascunho; reabrir devolve tudo. [initialStars] vem da estrela tocada no
/// card do rolê. [withTransfer] pergunta também do transfer (cena 8).
Future<void> showRatingSheet(
  BuildContext context, {
  required String roleId,
  required String roleName,
  String? photo,
  double? initialStars,
  bool withTransfer = false,
  bool openDetail = false,
  VoidCallback? onWallet,
}) =>
    showMareSheet<void>(
      context,
      builder: (_) => RatingSheet(
        roleId: roleId,
        roleName: roleName,
        photo: photo,
        initialStars: initialStars,
        withTransfer: withTransfer,
        openDetail: openDetail,
        onWallet: onWallet,
      ),
    );

class RatingSheet extends StatefulWidget {
  const RatingSheet({
    required this.roleId,
    required this.roleName,
    this.photo,
    this.initialStars,
    this.withTransfer = false,
    this.openDetail = false,
    this.onWallet,
    super.key,
  });

  final String roleId;
  final String roleName;
  final String? photo;
  final double? initialStars;
  final bool withTransfer;

  /// Abre já em "Contar mais" (completar uma avaliação enviada).
  final bool openDetail;
  final VoidCallback? onWallet;

  @override
  State<RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<RatingSheet> {
  double? _role;
  double? _transfer;
  List<String> _tags = const [];
  List<ReviewPhoto> _photos = const [];
  final _text = TextEditingController();
  bool _detailOpen = false;
  bool _picking = false;
  int? _earned;

  @override
  void initState() {
    super.initState();
    final s = travelerCubit().state;
    final start = s.drafts[widget.roleId] ?? s.ratingFor(widget.roleId);
    if (start != null) {
      _role = start.roleStars;
      _transfer = start.transferStars;
      _tags = start.tags;
      _photos = start.photos;
      _text.text = start.text ?? '';
      _detailOpen = start.detailed;
    }
    if (widget.openDetail) _detailOpen = true;
    final initial = widget.initialStars;
    if (initial != null) _setRole(initial, rebuild: false);
  }

  @override
  void dispose() {
    // Fechou sem enviar: guarda o rascunho (fechar nunca perde nada).
    if (_earned == null) travelerCubit().saveDraft(_current);
    _text.dispose();
    super.dispose();
  }

  OutingRating get _current => OutingRating(
        roleId: widget.roleId,
        roleName: widget.roleName,
        roleStars: _role,
        transferStars: _transfer,
        tags: _tags,
        text: _text.text.trim().isEmpty ? null : _text.text.trim(),
        photos: _photos,
      );

  /// Trocou de faixa: os motivos que não existem na nova faixa saem.
  void _setRole(double stars, {bool rebuild = true}) {
    final allowed = TravelerMock.tagsFor(stars);
    void apply() {
      _role = stars;
      _tags = [
        for (final t in _tags)
          if (allowed.contains(t)) t
      ];
    }

    rebuild ? setState(apply) : apply();
  }

  void _toggleTag(String tag) => setState(() {
        _tags = _tags.contains(tag)
            ? [
                for (final t in _tags)
                  if (t != tag) t
              ]
            : [..._tags, tag];
      });

  Future<void> _addPhotos() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final picked = await reviewPhotoPicker(kMaxReviewPhotos - _photos.length);
      if (!mounted) return;
      setState(() =>
          _photos = [..._photos, ...picked].take(kMaxReviewPhotos).toList());
    } on Object {
      // Cancelou ou o navegador bloqueou: segue sem foto.
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _send() {
    final earned = travelerCubit().rate(_current);
    setState(() => _earned = earned);
  }

  @override
  Widget build(BuildContext context) {
    final close = Navigator.of(context).maybePop;
    final earned = _earned;
    final transfer =
        widget.withTransfer ? travelerCubit().state.transfer : null;
    final role = _role;
    final bonusOpen = !travelerCubit().state.detailPaid.contains(widget.roleId);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              TravelSpace.gutter, TravelSpace.sm, TravelSpace.gutter, 16),
          child: AnimatedSize(
            duration: exploreMotion(context, 260),
            curve: kExploreEase,
            alignment: Alignment.topCenter,
            child: earned != null
                ? _Done(
                    earned: earned,
                    onClose: close,
                    onWallet: widget.onWallet == null
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            widget.onWallet!();
                          },
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SheetBar(title: 'Como foi?', onClose: close),
                      const SizedBox(height: TravelSpace.sm),
                      _Question(
                        photo: widget.photo,
                        icon: TravelIcons.place,
                        title: widget.roleName,
                        value: role,
                        onChanged: _setRole,
                      ),
                      if (transfer != null) ...[
                        const SizedBox(height: TravelSpace.sm),
                        _Question(
                          icon: TravelIcons.car,
                          title: 'Transfer com ${transfer.driverName}',
                          value: _transfer,
                          onChanged: (v) => setState(() => _transfer = v),
                        ),
                      ],
                      if (role != null) ...[
                        const SizedBox(height: TravelSpace.lg),
                        AnimatedSwitcher(
                          duration: exploreMotion(context, 200),
                          child: _Tags(
                            key: ValueKey(TravelerMock.questionFor(role)),
                            stars: role,
                            selected: _tags,
                            onToggle: _toggleTag,
                          ),
                        ),
                        const SizedBox(height: TravelSpace.md),
                        _detailOpen
                            ? _Detail(
                                controller: _text,
                                photos: _photos,
                                picking: _picking,
                                onAddPhoto: _photos.length < kMaxReviewPhotos
                                    ? _addPhotos
                                    : null,
                                onRemovePhoto: (ph) =>
                                    setState(() => _photos = [
                                          for (final x in _photos)
                                            if (x != ph) x
                                        ]),
                              )
                            : _MoreRow(
                                bonus: bonusOpen,
                                onTap: () => setState(() => _detailOpen = true),
                              ),
                      ],
                      const SizedBox(height: TravelSpace.xl),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _text,
                        builder: (context, _, __) => PrimaryButton(
                          label: 'Enviar',
                          onPressed: _current.answered == 0 ? null : _send,
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

/// O que está sendo avaliado + 5 estrelas + rótulo da nota.
class _Question extends StatelessWidget {
  const _Question({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.icon,
    this.photo,
  });

  final String title;
  final String? photo;
  final FaIconData icon;
  final double? value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final v = value;
    return SolidBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Foto recortada; ícone direto na superfície (regra 6).
              photo != null
                  ? ClipRRect(
                      // Concêntrico: card 24 − padding 12 = 12.
                      borderRadius: BorderRadius.circular(TravelSpace.rInner),
                      child: Image.asset(photo!,
                          width: 36, height: 36, fit: BoxFit.cover),
                    )
                  : SizedBox.square(
                      dimension: 36,
                      child:
                          Center(child: FaIcon(icon, size: 18, color: p.ink)),
                    ),
              const SizedBox(width: TravelSpace.md),
              Expanded(
                child: Text(title,
                    style: TravelType.headline.copyWith(color: p.ink)),
              ),
            ],
          ),
          const SizedBox(height: TravelSpace.md),
          Row(
            children: [
              // Estrelas começam na borda do texto (alvo de 44 sangra 7).
              Transform.translate(
                offset: const Offset(-7, 0),
                child: StarRow(
                    value: v, onChanged: onChanged, semanticPrefix: title),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedSwitcher(
                    duration: exploreMotion(context, 150),
                    child: Text(
                      v == null ? '' : TravelerMock.starLabel(v),
                      key: ValueKey(v),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TravelType.subheadStrong.copyWith(color: p.ink),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Motivos rápidos da faixa da nota. Soltos no fundo do sheet: pílula `s1`,
/// escolhido com anel `accent` (regra 15).
class _Tags extends StatelessWidget {
  const _Tags({
    required this.stars,
    required this.selected,
    required this.onToggle,
    super.key,
  });

  final double stars;
  final List<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TravelSpace.cardPad),
          child: Text(TravelerMock.questionFor(stars),
              style: TravelType.section.copyWith(color: p.inkMuted)),
        ),
        const SizedBox(height: TravelSpace.sm),
        Wrap(
          spacing: TravelSpace.sm,
          runSpacing: TravelSpace.sm,
          children: [
            for (final t in TravelerMock.tagsFor(stars))
              ExploreChip(
                label: t,
                selected: selected.contains(t),
                onCard: false,
                onTap: () => onToggle(t),
              ),
          ],
        ),
      ],
    );
  }
}

/// "Contar mais" fechado: uma linha, com o bônus ao lado enquanto valer.
class _MoreRow extends StatelessWidget {
  const _MoreRow({required this.bonus, required this.onTap});

  final bool bonus;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Semantics(
      button: true,
      label: bonus
          ? 'Contar mais, mais ${TravelerMock.pointsPerDetail} pontos'
          : 'Contar mais',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: SolidBlock(
          padding: const EdgeInsets.symmetric(
              horizontal: TravelSpace.cardPad, vertical: 14),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: Center(
                    child: FaIcon(TravelIcons.pen, size: 16, color: p.ink)),
              ),
              const SizedBox(width: TravelSpace.sm),
              Expanded(
                child: Text('Contar mais',
                    style: TravelType.subheadStrong.copyWith(color: p.ink)),
              ),
              if (bonus)
                Text('+${TravelerMock.pointsPerDetail} pontos',
                    style: TravelType.footnote.copyWith(
                        color: p.inkMuted, fontFeatures: TravelType.tabular)),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Contar mais" aberto: texto livre e até 4 fotos.
class _Detail extends StatelessWidget {
  const _Detail({
    required this.controller,
    required this.photos,
    required this.picking,
    required this.onAddPhoto,
    required this.onRemovePhoto,
  });

  final TextEditingController controller;
  final List<ReviewPhoto> photos;
  final bool picking;
  final VoidCallback? onAddPhoto;
  final ValueChanged<ReviewPhoto> onRemovePhoto;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return SolidBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: p.s2,
              borderRadius: BorderRadius.circular(TravelSpace.rInner),
            ),
            child: TextField(
              controller: controller,
              minLines: 3,
              maxLines: 6,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              cursorColor: p.accent,
              style: TravelType.callout.copyWith(color: p.ink),
              decoration: InputDecoration.collapsed(
                hintText: 'O que outra mulher precisa saber?',
                hintStyle: TravelType.callout.copyWith(color: p.inkMuted),
              ).copyWith(counterText: ''),
            ),
          ),
          const SizedBox(height: TravelSpace.md),
          // Sem mídia: o tile da câmera ocupa a largura toda. Com mídia:
          // encolhe pra 64 e fica fixo à esquerda; as miniaturas rolam ao
          // lado (feedback do designer).
          SizedBox(
            height: 64,
            child: LayoutBuilder(
              builder: (context, box) {
                final empty = photos.isEmpty;
                final add = onAddPhoto;
                // Stack (não Row): enquanto o tile encolhe, a lista já
                // ocupa o resto sem estourar a largura.
                return SizedBox(
                  width: box.maxWidth,
                  child: Stack(
                    children: [
                      if (!empty)
                        Positioned.fill(
                          left: add != null ? 64 + TravelSpace.sm : 0,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            itemCount: photos.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: TravelSpace.sm),
                            itemBuilder: (_, i) => _Thumb(
                              photo: photos[i],
                              onRemove: () => onRemovePhoto(photos[i]),
                            ),
                          ),
                        ),
                      if (add != null)
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Semantics(
                            button: true,
                            label: 'Adicionar fotos ou vídeos',
                            excludeSemantics: true,
                            onTap: add,
                            child: Pressable(
                              onTap: add,
                              child: AnimatedContainer(
                                duration: exploreMotion(context, 260),
                                curve: kExploreEase,
                                width: empty ? box.maxWidth : 64,
                                height: 64,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: p.s2,
                                  borderRadius:
                                      BorderRadius.circular(TravelSpace.rInner),
                                ),
                                child: picking
                                    ? AppActivityIndicator(color: p.inkMuted)
                                    : FaIcon(TravelIcons.camera,
                                        size: 20, color: p.ink),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.photo, required this.onRemove});

  final ReviewPhoto photo;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: 64,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(TravelSpace.rInner),
                child: ReviewMediaThumb(photo),
              ),
            ),
            // Alvo de 44 centrado no canto; círculo frost de 24 (controle
            // sobre foto = frost, regra 9).
            Positioned(
              top: -6,
              right: -6,
              child: Semantics(
                button: true,
                label: 'Remover foto',
                excludeSemantics: true,
                onTap: onRemove,
                child: Pressable(
                  onTap: onRemove,
                  child: SizedBox.square(
                    dimension: TravelSpace.tap,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: AppBackdropBlur(
                          sigma: 14,
                          circle: true,
                          liteColor: Colors.black.withValues(alpha: 0.45),
                          child: Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.28),
                              shape: BoxShape.circle,
                            ),
                            child: const FaIcon(TravelIcons.close,
                                size: 10, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

/// Depois de enviar: pontos ganhos e o porquê.
class _Done extends StatelessWidget {
  const _Done({required this.earned, required this.onClose, this.onWallet});

  final int earned;
  final VoidCallback onClose;
  final VoidCallback? onWallet;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SheetBar(onClose: onClose),
        const SizedBox(height: TravelSpace.sm),
        FaIcon(TravelIcons.circleCheck, size: 32, color: p.ink),
        const SizedBox(height: TravelSpace.md),
        Text(
          earned > 0 ? '+$earned pontos' : 'Avaliação enviada',
          style: TravelType.title1
              .copyWith(color: p.ink, fontFeatures: TravelType.tabular),
        ),
        const SizedBox(height: TravelSpace.sm),
        Text(
          'Sua avaliação ajuda outras mulheres a decidir.',
          textAlign: TextAlign.center,
          style: TravelType.subhead.copyWith(color: p.inkMuted),
        ),
        const SizedBox(height: TravelSpace.xl),
        // O X fecha; um primário só (sem "Fechar" repetido).
        PrimaryButton(
          label: onWallet != null ? 'Ver carteira' : 'Pronto',
          onPressed: onWallet ?? onClose,
        ),
      ],
    );
  }
}
