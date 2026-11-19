import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/features/explore/data/explore_mock.dart';
import 'package:studio_app/features/explore/presentation/widgets/explore_ui.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';

/// "Onde?" (ref. Airbnb): campo de busca de verdade. Vazio mostra as
/// sugestões (Por perto, Recife, Olinda); digitando, mostra cidades e
/// bairros com rolê curado, com o trecho buscado em negrito.
class WherePicker extends StatefulWidget {
  const WherePicker({required this.place, required this.onPick, super.key});

  final String? place;

  /// Escolheu um lugar (null = qualquer lugar).
  final ValueChanged<String?> onPick;

  @override
  State<WherePicker> createState() => _WherePickerState();
}

/// Sem acento e minúsculo, pra "poco" achar "Poço".
String _fold(String s) {
  const from = 'áàâãäéèêëíìîïóòôõöúùûüç';
  const to = 'aaaaaeeeeiiiiooooouuuuc';
  final lower = s.toLowerCase();
  final b = StringBuffer();
  for (final ch in lower.split('')) {
    final i = from.indexOf(ch);
    b.write(i < 0 ? ch : to[i]);
  }
  return b.toString();
}

class _WherePickerState extends State<WherePicker> {
  final _text = TextEditingController();

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _pick(String? place) {
    FocusScope.of(context).unfocus();
    _text.clear();
    widget.onPick(place);
  }

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final term = _fold(_text.text.trim());
    final matches = term.isEmpty
        ? const <(String, String)>[]
        : [
            for (final pl in ExploreMock.searchablePlaces)
              if (_fold(pl.$1).contains(term)) pl,
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SearchField(controller: _text),
        const SizedBox(height: TravelSpace.lg),
        if (term.isEmpty) ...[
          Text('Sugestões',
              style: TravelType.section.copyWith(color: p.inkMuted)),
          const SizedBox(height: TravelSpace.sm),
          for (final (i, s) in ExploreMock.placeSuggestions.indexed)
            _PlaceRow(
              selected: widget.place == s.place,
              tile: _IllustrationTile(icon: s.icon, tone: _tone(p, i)),
              title: Text(s.label,
                  style: TravelType.headline.copyWith(color: p.ink)),
              line: s.line,
              onTap: () =>
                  _pick(widget.place == s.place ? null : s.place),
            ),
        ] else if (matches.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: TravelSpace.sm),
            child: Text(
              'Nenhum lugar curado com esse nome.',
              style: TravelType.subhead.copyWith(color: p.inkMuted),
            ),
          )
        else
          for (final (place, detail) in matches)
            _PlaceRow(
              selected: widget.place == place,
              tile: const _PinTile(),
              title: _Highlighted(text: place, term: term, detail: detail),
              onTap: () => _pick(place),
            ),
      ],
    );
  }

  /// Tom da ilustração: azul pra "Por perto", cores de categoria depois.
  static Color _tone(TravelPalette p, int i) => switch (i) {
        0 => p.accent,
        1 => ExploreCategoryTones.restaurantes,
        _ => ExploreCategoryTones.museu,
      };
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Container(
      height: 52,
      padding: const EdgeInsets.only(left: 16, right: 4),
      // Campo em contorno, como as opções do card (regra 15).
      decoration: outlineChoiceDecoration(p,
          selected: false, radius: TravelSpace.rInner),
      child: Row(
        children: [
          FaIcon(TravelIcons.search, size: 16, color: p.ink),
          const SizedBox(width: TravelSpace.md),
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              style: TravelType.callout.copyWith(color: p.ink),
              cursorColor: p.accent,
              decoration: InputDecoration.collapsed(
                hintText: 'Buscar cidade ou bairro',
                hintStyle: TravelType.callout.copyWith(color: p.inkMuted),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            Semantics(
              button: true,
              label: 'Limpar busca',
              excludeSemantics: true,
              onTap: controller.clear,
              child: Pressable(
                onTap: controller.clear,
                child: SizedBox.square(
                  dimension: TravelSpace.tap,
                  child: Center(
                    child: Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: p.s2, shape: BoxShape.circle),
                      child: FaIcon(TravelIcons.close, size: 11, color: p.ink),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Linha da lista: ilustração/pino 56, título e linha opcional. Escolhido
/// ganha o check à direita.
class _PlaceRow extends StatelessWidget {
  const _PlaceRow({
    required this.tile,
    required this.title,
    required this.selected,
    required this.onTap,
    this.line,
  });

  final Widget tile;
  final Widget title;
  final String? line;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Semantics(
      button: true,
      selected: selected,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              tile,
              const SizedBox(width: TravelSpace.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    if (line != null)
                      Text(line!,
                          style:
                              TravelType.subhead.copyWith(color: p.inkMuted)),
                  ],
                ),
              ),
              if (selected) ...[
                const SizedBox(width: TravelSpace.sm),
                FaIcon(TravelIcons.check, size: 15, color: p.accent),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Ilustração de traço sobre um fundo claro da mesma cor (ref. Airbnb).
class _IllustrationTile extends StatelessWidget {
  const _IllustrationTile({required this.icon, required this.tone});

  final String icon;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tone.withValues(alpha: p.isDark ? 0.22 : 0.09),
        borderRadius: BorderRadius.circular(TravelSpace.rInner),
      ),
      child: SvgPicture.asset(
        icon,
        width: 40,
        height: 40,
        colorFilter: ColorFilter.mode(
            p.isDark ? Color.lerp(tone, Colors.white, 0.45)! : tone,
            BlendMode.srcIn),
      ),
    );
  }
}

class _PinTile extends StatelessWidget {
  const _PinTile();

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: p.s2,
        borderRadius: BorderRadius.circular(TravelSpace.rInner),
      ),
      child: FaIcon(TravelIcons.place, size: 20, color: p.ink),
    );
  }
}

/// "**Casa** Forte, Recife": trecho buscado em negrito.
class _Highlighted extends StatelessWidget {
  const _Highlighted({
    required this.text,
    required this.term,
    required this.detail,
  });

  final String text;
  final String term;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final base = TravelType.callout.copyWith(color: p.ink);
    final strong = TravelType.calloutStrong.copyWith(color: p.ink);
    final at = _fold(text).indexOf(term);
    final spans = at < 0
        ? [TextSpan(text: text, style: base)]
        : [
            if (at > 0) TextSpan(text: text.substring(0, at), style: base),
            TextSpan(
                text: text.substring(at, at + term.length), style: strong),
            if (at + term.length < text.length)
              TextSpan(text: text.substring(at + term.length), style: base),
          ];
    return Text.rich(TextSpan(children: [
      ...spans,
      TextSpan(
          text: ', $detail',
          style: TravelType.callout.copyWith(color: p.inkMuted)),
    ]));
  }
}
