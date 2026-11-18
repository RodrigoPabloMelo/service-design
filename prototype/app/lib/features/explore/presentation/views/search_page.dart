import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studio_app/features/explore/data/explore_mock.dart';
import 'package:studio_app/features/explore/domain/explore_entities.dart';
import 'package:studio_app/features/explore/presentation/view_models/search_cubit.dart';
import 'package:studio_app/features/explore/presentation/views/search_results_page.dart';
import 'package:studio_app/features/explore/presentation/widgets/explore_ui.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';

/// Busca guiada (ref. Airbnb, no sistema da Maré): pergunta o que ela
/// precisa — onde, quando, com quem, que tipo — numa sanfona; um card
/// aberto por vez. Filtros finos ficam pra depois, nos resultados.
///
/// [editing] = aberta a partir dos resultados: "Buscar" só volta.
class SearchPage extends StatelessWidget {
  const SearchPage({this.editing = false, super.key});

  final bool editing;

  static const _order = SearchStep.values;

  void _advance(SearchCubit cubit, SearchStep from) {
    final i = _order.indexOf(from);
    if (i >= _order.length - 1) return;
    Future.delayed(const Duration(milliseconds: 220), () {
      if (!cubit.isClosed && cubit.state.step == from) {
        cubit.openStep(_order[i + 1]);
      }
    });
  }

  void _submit(BuildContext context) {
    if (editing) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        exploreRoute(withExplore(context, const SearchResultsPage())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final cubit = context.read<SearchCubit>();
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: p.s0,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, s) {
            final q = s.query;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: TravelSpace.gutter),
                  child: SheetBar(
                    leading: TextAction('Limpar', onTap: cubit.clearQuery),
                    onClose: () => Navigator.of(context).maybePop(),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(TravelSpace.gutter,
                        TravelSpace.sm, TravelSpace.gutter, TravelSpace.lg),
                    children: [
                      _StepCard(
                        hero: true,
                        question: 'Onde?',
                        label: 'Onde',
                        value: placeLabel(q),
                        open: s.step == SearchStep.onde,
                        onOpen: () => cubit.openStep(SearchStep.onde),
                        child: _Chips(children: [
                          for (final place in [
                            null,
                            SearchQuery.nearHotel,
                            ...ExploreMock.neighborhoods,
                          ])
                            ExploreChip(
                              label: place ?? 'Qualquer lugar',
                              selected: q.place == place,
                              onTap: () {
                                cubit.setPlace(place);
                                _advance(cubit, SearchStep.onde);
                              },
                            ),
                        ]),
                      ),
                      const SizedBox(height: TravelSpace.sm),
                      _StepCard(
                        question: 'Quando?',
                        label: 'Quando',
                        value: dayLabel(q),
                        open: s.step == SearchStep.quando,
                        onOpen: () => cubit.openStep(SearchStep.quando),
                        child: _Chips(children: [
                          for (final day in [null, 0, 1, 2])
                            ExploreChip(
                              label: day == null
                                  ? 'Qualquer dia'
                                  : ExploreMock.tripDays[day],
                              selected: q.day == day,
                              onTap: () {
                                cubit.setDay(day);
                                _advance(cubit, SearchStep.quando);
                              },
                            ),
                        ]),
                      ),
                      const SizedBox(height: TravelSpace.sm),
                      _StepCard(
                        question: 'Com quem?',
                        label: 'Com quem',
                        value: companyLabel(q.company),
                        open: s.step == SearchStep.quem,
                        onOpen: () => cubit.openStep(SearchStep.quem),
                        child: _Chips(children: [
                          for (final c in Company.values)
                            ExploreChip(
                              label: companyLabel(c),
                              selected: q.company == c,
                              onTap: () {
                                cubit.setCompany(c);
                                _advance(cubit, SearchStep.quem);
                              },
                            ),
                        ]),
                      ),
                      const SizedBox(height: TravelSpace.sm),
                      _StepCard(
                        question: 'Que tipo?',
                        label: 'Tipo',
                        value: categoriesLabel(q.categories),
                        open: s.step == SearchStep.tipo,
                        onOpen: () => cubit.openStep(SearchStep.tipo),
                        child: _Chips(children: [
                          for (final info in ExploreMock.categories)
                            ExploreChip(
                              label: info.label,
                              selected: q.categories.contains(info.category),
                              leading: CategoryIcon(info.category,
                                  color: p.ink, size: 22),
                              onTap: () => cubit.toggleCategory(info.category),
                            ),
                        ]),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(TravelSpace.gutter,
                      TravelSpace.sm, TravelSpace.gutter, TravelSpace.md + bottom),
                  child: PrimaryButton(
                    label: 'Buscar',
                    onPressed: () => _submit(context),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) =>
      Wrap(spacing: TravelSpace.sm, runSpacing: TravelSpace.sm, children: children);
}

/// Card da sanfona: fechado mostra rótulo + valor; aberto, a pergunta e as
/// opções. Troca com crossfade e o tamanho anima (`AnimatedSize`).
class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.question,
    required this.label,
    required this.value,
    required this.open,
    required this.onOpen,
    required this.child,
    this.hero = false,
  });

  final String question;
  final String label;
  final String value;
  final bool open;
  final VoidCallback onOpen;
  final Widget child;

  /// O fundo deste card recebe a pílula de busca da home (Hero).
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final surface = DecoratedBox(
      decoration: BoxDecoration(
        color: p.s1,
        borderRadius: BorderRadius.circular(TravelSpace.rCard),
      ),
    );
    final Widget body = open
        ? Padding(
            key: const ValueKey('open'),
            padding: const EdgeInsets.fromLTRB(TravelSpace.cardPad, 20,
                TravelSpace.cardPad, TravelSpace.cardPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(question,
                      style: TravelType.title1.copyWith(color: p.ink)),
                ),
                const SizedBox(height: TravelSpace.lg),
                child,
              ],
            ),
          )
        : Semantics(
            key: const ValueKey('closed'),
            button: true,
            label: '$label: $value',
            excludeSemantics: true,
            onTap: onOpen,
            child: Pressable(
              onTap: onOpen,
              child: SizedBox(
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: TravelSpace.cardPad),
                  child: Row(
                    children: [
                      Text(label,
                          style: TravelType.subhead.copyWith(color: p.inkMuted)),
                      const SizedBox(width: TravelSpace.lg),
                      Expanded(
                        child: Text(
                          value,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TravelType.subheadStrong.copyWith(color: p.ink),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
    return Stack(
      children: [
        Positioned.fill(
          child: hero ? Hero(tag: kSearchHero, child: surface) : surface,
        ),
        AnimatedSize(
          duration: exploreMotion(context, 320),
          curve: kExploreEase,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: exploreMotion(context, 200),
            switchInCurve: kExploreEase,
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topCenter,
              children: [...previous, if (current != null) current],
            ),
            child: SizedBox(
                key: ValueKey(open), width: double.infinity, child: body),
          ),
        ),
      ],
    );
  }
}
