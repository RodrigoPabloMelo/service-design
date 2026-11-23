import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/features/travel_agent/data/travel_agent_mock.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/photo_viewer.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';
import 'package:studio_app/features/traveler/data/traveler_mock.dart';
import 'package:studio_app/features/traveler/domain/traveler_entities.dart';
import 'package:studio_app/features/traveler/presentation/view_models/traveler_cubit.dart';
import 'package:studio_app/features/traveler/presentation/widgets/mare_sheet.dart';
import 'package:studio_app/features/traveler/presentation/widgets/rating_sheet.dart';
import 'package:studio_app/features/traveler/presentation/widgets/star_rating.dart';

/// Quantas avaliações aparecem no card antes de "Ver todas".
const _kShown = 3;

bool _sameRating(TravelerState a, TravelerState b, String roleId) =>
    a.ratingFor(roleId) == b.ratingFor(roleId) &&
    a.drafts[roleId] == b.drafts[roleId];

/// Notas do rolê: as das outras viajantes + a dela, se enviou.
List<num> _starsOf(String roleId, TravelerState s) => [
      for (final r in TravelMock.reviewsFor(roleId)) r.stars,
      if (s.ratingFor(roleId)?.roleStars case final mine?) mine,
    ];

String _count(int n) => n == 1 ? '1 avaliação' : '$n avaliações';

String _avg(List<num> stars) => TravelMock.averageOf(stars)
    .toStringAsFixed(1)
    .replaceAll('.', ',');

/// Nota no cabeçalho do card do rolê (D-18): estrela + "4,7 (6)". Some
/// quando ainda não há avaliação.
class RoleRatingMeta extends StatelessWidget {
  const RoleRatingMeta({required this.roleId, super.key});

  final String roleId;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return BlocBuilder<TravelerCubit, TravelerState>(
      bloc: travelerCubit(),
      buildWhen: (a, b) => !_sameRating(a, b, roleId),
      builder: (context, s) {
        final stars = _starsOf(roleId, s);
        if (stars.isEmpty) return const SizedBox.shrink();
        return Semantics(
          label: 'Nota ${_avg(stars)}, ${_count(stars.length)}',
          excludeSemantics: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(TravelIcons.star, size: 12, color: p.star),
              const SizedBox(width: 5),
              Text(
                '${_avg(stars)} (${stars.length})',
                style: TravelType.footnote.copyWith(
                    color: p.inkMuted, fontFeatures: TravelType.tabular),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Seção "Avaliações" do card do rolê (D-30), depois das fotos: o card
/// "Como foi pra você?" com a média ao lado do título e as estrelas pra ela
/// avaliar (abre o sheet já com a nota), a avaliação dela e as mais
/// recentes das outras — nunca ordenadas por nota.
class RoleReviewsSection extends StatelessWidget {
  const RoleReviewsSection({required this.role, super.key});

  final Role role;

  void _rate(BuildContext context, {double? stars, bool detail = false}) =>
      showRatingSheet(
        context,
        roleId: role.id,
        roleName: role.shortName,
        photo: role.photos.isEmpty ? null : role.photos.first.asset,
        initialStars: stars,
        openDetail: detail,
      );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TravelerCubit, TravelerState>(
      bloc: travelerCubit(),
      buildWhen: (a, b) => !_sameRating(a, b, role.id),
      builder: (context, s) {
        final others = TravelMock.reviewsFor(role.id);
        final mine = s.ratingFor(role.id);
        final draft = s.drafts[role.id];
        final stars = _starsOf(role.id, s);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card dela sempre no topo: a média (ou "Sem avaliações") ao
            // lado do título; as estrelas mostram a nota dela, se já deu.
            _RateCard(
              average: stars.isEmpty ? null : _avg(stars),
              count: stars.length,
              value: mine?.roleStars ?? draft?.roleStars,
              draftSaved: mine == null && draft?.roleStars != null,
              onStars: (v) => _rate(context, stars: v),
              onContinue: () => _rate(context),
            ),
            if (mine != null) ...[
              const SizedBox(height: TravelSpace.sm),
              _ReviewTile(
                view: _ReviewView.mine(mine),
                action: mine.detailed
                    ? null
                    : SecondaryButton(
                        label: 'Contar mais',
                        icon: TravelIcons.pen,
                        onPressed: () => _rate(context, detail: true),
                      ),
              ),
            ],
            for (final r in others.take(_kShown)) ...[
              const SizedBox(height: TravelSpace.sm),
              _ReviewTile(view: _ReviewView.of(r)),
            ],
            if (others.length > _kShown) ...[
              const SizedBox(height: TravelSpace.sm),
              // Mesmo total do card (conta a dela); o sheet lista a dela
              // primeiro.
              SecondaryButton(
                label: 'Ver todas as ${stars.length}',
                onPressed: () => _showAll(context, [
                  if (mine != null) _ReviewView.mine(mine),
                  for (final r in others) _ReviewView.of(r),
                ]),
              ),
            ],
          ],
        );
      },
    );
  }

  /// Lista completa num sheet. A lista rola sob a barra com um véu `s0`
  /// em rampa (sem borda dura, sem ShaderMask — regras 11 e 14).
  void _showAll(BuildContext context, List<_ReviewView> reviews) =>
      showMareSheet<void>(
        context,
        builder: (sheet) {
          final p = TravelPalette.of(sheet);
          const bar = TravelSpace.sm + 44.0;
          return ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(sheet).height * 0.86),
            child: Stack(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(TravelSpace.gutter,
                      bar + TravelSpace.sm, TravelSpace.gutter, TravelSpace.xl),
                  itemCount: reviews.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: TravelSpace.sm),
                  itemBuilder: (_, i) =>
                      _ReviewTile(view: reviews[i], maxLines: null),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: bar + 20,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            p.s0,
                            p.s0,
                            p.s0.withValues(alpha: 0.85),
                            p.s0.withValues(alpha: 0.5),
                            p.s0.withValues(alpha: 0.15),
                            p.s0.withValues(alpha: 0),
                          ],
                          stops: const [0, 0.7, 0.78, 0.86, 0.94, 1],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(TravelSpace.gutter,
                      TravelSpace.sm, TravelSpace.gutter, 0),
                  child: SheetBar(
                    title: 'Avaliações',
                    onClose: Navigator.of(sheet).maybePop,
                  ),
                ),
              ],
            ),
          );
        },
      );
}

/// Card "Como foi pra você?": título com a média à direita ("Sem
/// avaliações" quando não há) e as estrelas; tocar uma abre o sheet já com
/// ela.
class _RateCard extends StatelessWidget {
  const _RateCard({
    required this.average,
    required this.count,
    required this.value,
    required this.draftSaved,
    required this.onStars,
    this.onContinue,
  });

  /// "4,3"; null = sem avaliações.
  final String? average;
  final int count;
  final double? value;
  final bool draftSaved;
  final ValueChanged<double> onStars;

  /// Reabre o rascunho como está.
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final avg = average;
    return SolidBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text('Como foi pra você?',
                    style: TravelType.headline.copyWith(color: p.ink)),
              ),
              const SizedBox(width: TravelSpace.sm),
              if (avg == null)
                Text('Sem avaliações',
                    style: TravelType.footnote.copyWith(color: p.inkMuted))
              else
                Semantics(
                  label: 'Média $avg, ${_count(count)}',
                  excludeSemantics: true,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(TravelIcons.star, size: 14, color: p.star),
                      const SizedBox(width: 5),
                      Text(avg,
                          style: TravelType.headline.copyWith(
                              color: p.ink,
                              fontFeatures: TravelType.tabular)),
                      const SizedBox(width: 4),
                      Text('($count)',
                          style: TravelType.footnote.copyWith(
                              color: p.inkMuted,
                              fontFeatures: TravelType.tabular)),
                    ],
                  ),
                ),
            ],
          ),
          // 12 + os 7 de folga do alvo de 44 ≈ 19 visíveis entre o texto e
          // as estrelas (feedback do designer: estavam coladas).
          const SizedBox(height: TravelSpace.md),
          Row(
            children: [
              Transform.translate(
                offset: const Offset(-7, 0),
                child: StarRow(value: value, onChanged: onStars),
              ),
              const Spacer(),
              // Rascunho: pílula neutra na linha das estrelas — não muda a
              // altura do card (feedback do designer).
              if (draftSaved && onContinue != null)
                _ContinuePill(onTap: onContinue!),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Continuar" do rascunho: pílula `s2` de 32 com texto neutro, alvo 44.
class _ContinuePill extends StatelessWidget {
  const _ContinuePill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Semantics(
      button: true,
      label: 'Continuar avaliação guardada',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: SizedBox(
          height: TravelSpace.tap,
          child: Center(
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: p.s2,
                borderRadius: BorderRadius.circular(TravelSpace.rPill),
              ),
              child: Center(
                widthFactor: 1,
                child: Text('Continuar',
                    style: TravelType.footnoteStrong.copyWith(color: p.ink)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// O que uma avaliação mostra, venha da comunidade ou dela.
class _ReviewView {
  const _ReviewView({
    required this.author,
    required this.initials,
    required this.stars,
    required this.date,
    required this.tags,
    this.subtitle,
    this.text,
    this.photos = const [],
    this.ownPhotos = const [],
  });

  factory _ReviewView.of(RoleReview r) => _ReviewView(
        author: r.author,
        initials: r.initials,
        subtitle: r.situation.label,
        stars: r.stars,
        date: _date(r.date),
        tags: r.tags,
        text: r.text,
        photos: r.photos,
      );

  factory _ReviewView.mine(OutingRating r) => _ReviewView(
        author: 'Você',
        initials: TravelerMock.travelerName.isEmpty
            ? 'V'
            : TravelerMock.travelerName[0].toUpperCase(),
        stars: r.roleStars ?? 0,
        date: 'Hoje',
        tags: r.tags,
        text: r.text,
        ownPhotos: r.photos,
      );

  final String author;
  final String initials;
  final String? subtitle;
  final num stars;
  final String date;
  final List<String> tags;
  final String? text;
  final List<PhotoCredit> photos;
  final List<ReviewPhoto> ownPhotos;

  static const _months = [
    'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
    'jul', 'ago', 'set', 'out', 'nov', 'dez',
  ];

  static String _date(DateTime d) => '${d.day} ${_months[d.month - 1]}';
}

/// Uma avaliação: quem e com quem (F-02), estrelas e data (F-07), motivos,
/// texto e fotos. [action] = ação única dentro do card (secundário).
class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.view, this.action, this.maxLines = 4});

  final _ReviewView view;
  final Widget? action;

  /// 4 no card; null (inteiro) na lista completa.
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final v = view;
    return SolidBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: p.s2, shape: BoxShape.circle),
                child: Text(v.initials,
                    style: TravelType.footnoteStrong.copyWith(color: p.ink)),
              ),
              const SizedBox(width: TravelSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(v.author,
                        style:
                            TravelType.subheadStrong.copyWith(color: p.ink)),
                    if (v.subtitle case final sub?)
                      Text(sub,
                          style: TravelType.footnote
                              .copyWith(color: p.inkMuted)),
                  ],
                ),
              ),
              Text(v.date,
                  style: TravelType.footnote.copyWith(
                      color: p.inkMuted, fontFeatures: TravelType.tabular)),
            ],
          ),
          const SizedBox(height: TravelSpace.md),
          StarsSmall(v.stars, size: 13),
          if (v.tags.isNotEmpty) ...[
            const SizedBox(height: TravelSpace.md),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [for (final t in v.tags) _TagPill(t)],
            ),
          ],
          if (v.text case final text? when text.isNotEmpty) ...[
            const SizedBox(height: TravelSpace.md),
            Text(text,
                maxLines: maxLines,
                overflow: maxLines == null ? null : TextOverflow.ellipsis,
                style: TravelType.subhead.copyWith(color: p.ink)),
          ],
          if (v.photos.isNotEmpty || v.ownPhotos.isNotEmpty) ...[
            const SizedBox(height: TravelSpace.md),
            Wrap(
              spacing: TravelSpace.sm,
              runSpacing: TravelSpace.sm,
              children: [
                for (final (i, ph) in v.photos.indexed)
                  Semantics(
                    button: true,
                    label: 'Ver foto',
                    excludeSemantics: true,
                    onTap: () =>
                        showPhotoViewer(context, photos: v.photos, initial: i),
                    child: Pressable(
                      onTap: () => showPhotoViewer(context,
                          photos: v.photos, initial: i),
                      child: _photoBox(Image.asset(ph.asset,
                          fit: BoxFit.cover, cacheWidth: 192)),
                    ),
                  ),
                for (final ph in v.ownPhotos) _photoBox(ReviewMediaThumb(ph)),
              ],
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: TravelSpace.md),
            action!,
          ],
        ],
      ),
    );
  }

  static Widget _photoBox(Widget image) => ClipRRect(
        borderRadius: BorderRadius.circular(TravelSpace.rInner),
        child: SizedBox.square(dimension: 64, child: image),
      );
}

/// Motivo só de leitura: contorno fino `ink` 12% dentro do card, sem fundo.
class _TagPill extends StatelessWidget {
  const _TagPill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TravelSpace.rPill),
        border: Border.all(color: p.ink.withValues(alpha: 0.12)),
      ),
      // widthFactor 1: a pílula abraça o texto (alignment no Container
      // esticava até a largura do Wrap).
      child: Center(
        widthFactor: 1,
        child: Text(label,
            style: TravelType.footnote.copyWith(color: p.ink, height: 1.2)),
      ),
    );
  }
}
