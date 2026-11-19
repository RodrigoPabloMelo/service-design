import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/features/explore/data/explore_mock.dart';
import 'package:studio_app/features/explore/domain/explore_entities.dart';
import 'package:studio_app/features/explore/presentation/widgets/explore_ui.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';

/// "Quando?" (ref. Airbnb): "Datas" com calendário de intervalo e folga
/// (±1, ±2 dias) ou "Flexível" (fim de semana ou semana, num mês).
/// Dias antes de hoje ficam riscados.
class WhenPicker extends StatefulWidget {
  const WhenPicker({
    required this.query,
    required this.onPickDate,
    required this.onSlack,
    required this.onFlexible,
    super.key,
  });

  final SearchQuery query;
  final ValueChanged<DateTime> onPickDate;
  final ValueChanged<int> onSlack;
  final void Function({FlexStay? stay, DateTime? month}) onFlexible;

  @override
  State<WhenPicker> createState() => _WhenPickerState();
}

class _WhenPickerState extends State<WhenPicker> {
  late int _tab = widget.query.isFlexible ? 1 : 0;

  /// Meses mostrados: o de hoje e os dois seguintes.
  List<DateTime> get _months {
    final t = ExploreMock.today;
    return [for (var i = 0; i < 3; i++) DateTime(t.year, t.month + i)];
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.query;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PillSegmented(
          labels: const ['Datas', 'Flexível'],
          index: _tab,
          onChanged: (i) {
            setState(() => _tab = i);
            if (i == 1 && !q.isFlexible) widget.onFlexible();
          },
        ),
        const SizedBox(height: TravelSpace.lg),
        AnimatedSwitcher(
          duration: exploreMotion(context, 200),
          child: _tab == 0
              ? _Dates(
                  key: const ValueKey('datas'),
                  query: q,
                  months: _months,
                  onPick: widget.onPickDate,
                  onSlack: widget.onSlack,
                )
              : _Flexible(
                  key: const ValueKey('flex'),
                  query: q,
                  months: _months,
                  onChanged: widget.onFlexible,
                ),
        ),
      ],
    );
  }
}

// ── Datas ────────────────────────────────────────────────────────────────

const _weekdays = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

DateTime _d(DateTime x) => DateTime(x.year, x.month, x.day);

class _Dates extends StatelessWidget {
  const _Dates({
    required this.query,
    required this.months,
    required this.onPick,
    required this.onSlack,
    super.key,
  });

  final SearchQuery query;
  final List<DateTime> months;
  final ValueChanged<DateTime> onPick;
  final ValueChanged<int> onSlack;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dias da semana fixos; os meses rolam por baixo.
        Row(
          children: [
            for (final w in _weekdays)
              Expanded(
                child: Center(
                  child: Text(w,
                      style: TravelType.footnote.copyWith(color: p.inkMuted)),
                ),
              ),
          ],
        ),
        const SizedBox(height: TravelSpace.sm),
        SizedBox(
          height: 320,
          child: VerticalEdgeFade(
            background: p.s1,
            top: 8,
            bottom: 24,
            child: ListView(
              padding: const EdgeInsets.only(bottom: TravelSpace.lg),
              children: [
                for (final m in months) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        4, TravelSpace.md, 4, TravelSpace.sm),
                    child: Text(
                      '${monthNames[m.month - 1][0].toUpperCase()}'
                      '${monthNames[m.month - 1].substring(1)} ${m.year}',
                      style: TravelType.headline.copyWith(color: p.ink),
                    ),
                  ),
                  _MonthGrid(month: m, query: query, onPick: onPick),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: TravelSpace.md),
        // Folga nas datas (ref. Airbnb: "Datas exatas", "± 1 dia").
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final (i, label)
                  in ['Datas exatas', '± 1 dia', '± 2 dias'].indexed) ...[
                if (i > 0) const SizedBox(width: TravelSpace.sm),
                ExploreChip(
                  label: label,
                  selected: query.hasDates && query.slack == i,
                  onTap: () {
                    if (query.hasDates) onSlack(i);
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.query,
    required this.onPick,
  });

  final DateTime month;
  final SearchQuery query;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month);
    final count = DateTime(month.year, month.month + 1, 0).day;
    final lead = first.weekday % 7; // domingo = 0
    final cells = lead + count;
    final rows = (cells / 7).ceil();
    return Column(
      children: [
        for (var r = 0; r < rows; r++)
          Row(
            children: [
              for (var c = 0; c < 7; c++)
                Expanded(
                  child: Builder(builder: (context) {
                    final day = r * 7 + c - lead + 1;
                    if (day < 1 || day > count) {
                      return const SizedBox(height: 46);
                    }
                    final date = DateTime(month.year, month.month, day);
                    return _DayCell(
                      date: date,
                      query: query,
                      firstCol: c == 0,
                      lastCol: c == 6,
                      onTap: () => onPick(date),
                    );
                  }),
                ),
            ],
          ),
      ],
    );
  }
}

/// Dia: riscado se já passou; círculo azul no início/fim; faixa clara no
/// meio do intervalo (ref. Airbnb, na cor de destaque da Maré).
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.query,
    required this.firstCol,
    required this.lastCol,
    required this.onTap,
  });

  final DateTime date;
  final SearchQuery query;
  final bool firstCol;
  final bool lastCol;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final past = date.isBefore(_d(ExploreMock.today));
    final s = query.start;
    final e = query.end;
    final isStart = s != null && date == _d(s);
    final isEnd = e != null && date == _d(e);
    final inside =
        s != null && e != null && date.isAfter(s) && date.isBefore(e);
    final selected = isStart || isEnd;
    final hasRange = s != null && e != null;

    // Faixa: do meio da célula pra direita no início, pra esquerda no
    // fim, inteira no meio.
    // Meia faixa que cairia fora da semana (início no sábado, fim no
    // domingo) não aparece.
    final showBand = hasRange &&
        (inside || (isStart && !lastCol) || (isEnd && !firstCol));

    final label = Text(
      '${date.day}',
      style: TravelType.subheadStrong.copyWith(
        color: past
            ? p.inkMuted.withValues(alpha: 0.6)
            : selected
                ? p.onAccent
                : p.ink,
        decoration: past ? TextDecoration.lineThrough : null,
        decorationColor: p.inkMuted,
        fontFeatures: TravelType.tabular,
      ),
    );

    final cell = SizedBox(
      height: 46,
      child: LayoutBuilder(
        builder: (context, box) => Stack(
          alignment: Alignment.center,
          children: [
            if (showBand)
              Positioned(
                top: 3,
                bottom: 3,
                left: isStart ? box.maxWidth / 2 : 0,
                right: isEnd ? box.maxWidth / 2 : 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: p.accentSoft,
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(inside && firstCol ? 20 : 0),
                      right: Radius.circular(inside && lastCol ? 20 : 0),
                    ),
                  ),
                ),
              ),
            if (selected)
              Container(
                width: 40,
                height: 40,
                decoration:
                    BoxDecoration(color: p.accent, shape: BoxShape.circle),
              ),
            label,
          ],
        ),
      ),
    );

    if (past) return ExcludeSemantics(child: cell);
    return Semantics(
      button: true,
      selected: selected || inside,
      label: '${date.day} de ${monthNames[date.month - 1]}',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(onTap: onTap, child: cell),
    );
  }
}

// ── Flexível ─────────────────────────────────────────────────────────────

class _Flexible extends StatelessWidget {
  const _Flexible({
    required this.query,
    required this.months,
    required this.onChanged,
    super.key,
  });

  final SearchQuery query;
  final List<DateTime> months;
  final void Function({FlexStay? stay, DateTime? month}) onChanged;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final stay = query.flexStay ?? FlexStay.fimDeSemana;
    final month = query.flexMonth;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quanto tempo?',
            style: TravelType.headline.copyWith(color: p.ink)),
        const SizedBox(height: TravelSpace.md),
        Wrap(
          spacing: TravelSpace.sm,
          children: [
            ExploreChip(
              label: 'Fim de semana',
              selected: stay == FlexStay.fimDeSemana,
              onTap: () => onChanged(stay: FlexStay.fimDeSemana),
            ),
            ExploreChip(
              label: 'Uma semana',
              selected: stay == FlexStay.semana,
              onTap: () => onChanged(stay: FlexStay.semana),
            ),
          ],
        ),
        const SizedBox(height: TravelSpace.xl),
        Text('Em que mês?',
            style: TravelType.headline.copyWith(color: p.ink)),
        const SizedBox(height: TravelSpace.md),
        Row(
          children: [
            for (final (i, m) in months.indexed) ...[
              if (i > 0) const SizedBox(width: TravelSpace.sm),
              Expanded(
                child: _MonthCard(
                  month: m,
                  selected: month != null &&
                      month.year == m.year &&
                      month.month == m.month,
                  onTap: () => onChanged(month: m),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({
    required this.month,
    required this.selected,
    required this.onTap,
  });

  final DateTime month;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final name = monthNames[month.month - 1];
    return Semantics(
      button: true,
      selected: selected,
      label: '$name de ${month.year}',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: TravelSpace.lg),
          decoration: selectionDecoration(p,
              selected: selected, fill: p.s2, radius: TravelSpace.rInner),
          child: Column(
            children: [
              FaIcon(TravelIcons.calendar, size: 22, color: p.ink),
              const SizedBox(height: TravelSpace.sm),
              Text('${name[0].toUpperCase()}${name.substring(1)}',
                  style: TravelType.subheadStrong.copyWith(color: p.ink)),
              Text('${month.year}',
                  style: TravelType.footnote.copyWith(
                      color: p.inkMuted, fontFeatures: TravelType.tabular)),
            ],
          ),
        ),
      ),
    );
  }
}
