import 'package:flutter/material.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';

/// Tokens visuais da Maré — flat, neutros cinza (iOS) e UMA cor de contraste.
///
/// Cor de contraste: **azul maré `#006FD6`** (matiz 209°) — da família do azul
/// da referência (220°), puxado na direção do tiffany da marca (178°) para
/// harmonia análoga. Branco sobre ele: 4,95:1 (AA); branco 68% em texto
/// grande: 3,1:1. Usado no bloco-resumo, ação principal, rota e seleção.
/// O tiffany `#0ABAB5` segue como cor de marca (orb, água, aurora).
///
/// Separação gestalt por camadas SÓLIDAS (S0 → S1 → S2), sem sombras nem
/// divisores. Vidro (Liquid Glass) só nos controles flutuantes sobre o mapa.
@immutable
class TravelPalette {
  const TravelPalette({
    required this.brightness,
    required this.s0,
    required this.s1,
    required this.s2,
    required this.inverse,
    required this.onInverse,
    required this.ink,
    required this.inkMuted,
    required this.accentText,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.piscina,
    required this.onPiscina,
    required this.espuma,
    required this.deep,
    required this.ocean,
    required this.oceanDeep,
    required this.caustic,
    required this.reef,
    required this.land,
    required this.landEdge,
    required this.park,
    required this.river,
    required this.road,
    required this.roadMajor,
    required this.mapLabel,
    required this.coral,
    required this.sol,
    required this.noite,
    required this.mata,
    required this.cultura,
    required this.danger,
  });

  final Brightness brightness;

  /// S0 — fundo neutro (sheet, tela).
  final Color s0;

  /// S1 — cards.
  final Color s1;

  /// S2 — grupos (chips, extras, trilho de abas).
  final Color s2;

  /// Superfície forte neutra: bolha da usuária, pins numerados, rota.
  final Color inverse;
  final Color onInverse;

  final Color ink;
  final Color inkMuted;

  /// Texto/ícone de destaque sobre neutros (≥ 4.5:1).
  final Color accentText;

  /// Cor de contraste (azul maré) e o texto sobre ela.
  final Color accent;
  final Color onAccent;

  /// Tint do azul para estado selecionado.
  final Color accentSoft;

  /// Tiffany — cor de marca (orb, água, aurora). Texto sobre ele: [onPiscina].
  final Color piscina;
  final Color onPiscina;

  /// Tint do tiffany.
  final Color espuma;

  /// Teal profundo da marca (orb, gradientes).
  final Color deep;

  // Mapa
  final Color ocean;
  final Color oceanDeep;
  final Color caustic;
  final Color reef;
  final Color land;
  final Color landEdge;
  final Color park;
  final Color river;
  final Color road;
  final Color roadMajor;
  final Color mapLabel;

  // Categorias
  final Color coral;
  final Color sol;
  final Color noite;
  final Color mata;
  final Color cultura;

  final Color danger;

  bool get isDark => brightness == Brightness.dark;

  static const light = TravelPalette(
    brightness: Brightness.light,
    s0: Color(0xFFF2F2F5),
    s1: Color(0xFFFFFFFF),
    s2: Color(0xFFE6E6EB),
    inverse: Color(0xFF131416),
    onInverse: Color(0xFFFFFFFF),
    ink: Color(0xFF131416),
    inkMuted: Color(0xFF6A6E75),
    accentText: Color(0xFF0A62C2),
    accent: Color(0xFF006FD6),
    onAccent: Color(0xFFFFFFFF),
    accentSoft: Color(0xFFE0ECFA),
    piscina: Color(0xFF0ABAB5),
    onPiscina: Color(0xFF062B2A),
    espuma: Color(0xFFD4F2F0),
    deep: Color(0xFF0E5A63),
    // Mapa monocromático (ref. Uber): cinzas quase neutros.
    ocean: Color(0xFFD8DEE2),
    oceanDeep: Color(0xFFD8DEE2),
    caustic: Color(0xFFE2E7EA),
    reef: Color(0xFFC9CFD3),
    land: Color(0xFFE8E8EB),
    landEdge: Color(0xFFDCDCE0),
    park: Color(0xFFDDE3DC),
    river: Color(0xFFD8DEE2),
    road: Color(0xFFFFFFFF),
    roadMajor: Color(0xFFFFFFFF),
    mapLabel: Color(0xFF9B9DA2),
    coral: Color(0xFFE8603F),
    sol: Color(0xFFE2A21F),
    noite: Color(0xFF4B4FC4),
    mata: Color(0xFF2E7D4F),
    cultura: Color(0xFF0E7C86),
    danger: Color(0xFFD13B2E),
  );

  static const dark = TravelPalette(
    brightness: Brightness.dark,
    s0: Color(0xFF0B0B0D),
    s1: Color(0xFF1C1C1F),
    s2: Color(0xFF2A2A2E),
    inverse: Color(0xFFF2F2F5),
    onInverse: Color(0xFF131416),
    ink: Color(0xFFF2F2F5),
    inkMuted: Color(0xFFA1A1A8),
    accentText: Color(0xFF6AB0FF),
    accent: Color(0xFF006FD6),
    onAccent: Color(0xFFFFFFFF),
    accentSoft: Color(0xFF0D2A4A),
    piscina: Color(0xFF0ABAB5),
    onPiscina: Color(0xFF062B2A),
    espuma: Color(0xFF0F3B3B),
    deep: Color(0xFF0E5A63),
    ocean: Color(0xFF25292C),
    oceanDeep: Color(0xFF25292C),
    caustic: Color(0xFF2C3134),
    reef: Color(0xFF33383B),
    land: Color(0xFF18181A),
    landEdge: Color(0xFF111112),
    park: Color(0xFF1E2220),
    river: Color(0xFF25292C),
    road: Color(0xFF222225),
    roadMajor: Color(0xFF2E2E32),
    mapLabel: Color(0xFF6F7176),
    coral: Color(0xFFFF8A6B),
    sol: Color(0xFFF2B33D),
    noite: Color(0xFF9EA3FF),
    mata: Color(0xFF7CC08F),
    cultura: Color(0xFF5FD0CB),
    danger: Color(0xFFFF7B6B),
  );

  static TravelPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

/// Escala tipográfica do HIG (iOS).
///
/// **Plus Jakarta Sans em 99% da interface.** Oswald 700 (condensada pesada)
/// fica restrita aos títulos de cards visuais (`cardTitle*`) — ex.: nome do
/// rolê no card. As fontes são variáveis: o peso vai em `fontVariations`
/// (use `.weight()` para trocar — `copyWith(fontWeight:)` não basta).
///
/// Pesos: bold (700) só em títulos; médio (500) para ênfase; regular (400)
/// no resto. Sem semibold.
abstract final class TravelType {
  static const _display = 'Oswald';
  static const _body = 'PlusJakartaSans';

  static TextStyle _d(double size, double height, {double tracking = 0}) =>
      TextStyle(
        fontFamily: _display,
        fontSize: size,
        height: height / size,
        fontWeight: FontWeight.w700,
        fontVariations: const [FontVariation('wght', 700)],
        letterSpacing: tracking,
      );

  static TextStyle _b(
    double size,
    double height, {
    FontWeight weight = FontWeight.w400,
    double tracking = 0,
  }) =>
      TextStyle(
        fontFamily: _body,
        fontSize: size,
        height: height / size,
        fontWeight: weight,
        fontVariations: [FontVariation('wght', weight.value.toDouble())],
        letterSpacing: tracking,
      );

  // Títulos de cards visuais — Oswald (único uso).
  static final cardTitleLarge = _d(30, 34, tracking: 0.2);
  static final cardTitle = _d(19, 23, tracking: 0.3);

  // Interface — Plus Jakarta Sans.
  static final title1 = _b(28, 34, weight: FontWeight.w700, tracking: -0.4);
  static final title2 = _b(22, 28, weight: FontWeight.w700, tracking: -0.3);
  static final title3 = _b(20, 25, weight: FontWeight.w500, tracking: -0.2);

  /// Frase-resumo do bloco de contraste: regular; os destaques ganham cor
  /// e peso médio (ver `_Summary`).
  static final summary = _b(21, 28, tracking: -0.3);

  static final headline = _b(17, 22, weight: FontWeight.w500);
  // Texto corrido: entrelinha de 150%.
  static final body = _b(17, 25.5);
  static final callout = _b(16, 24);
  static final calloutStrong = _b(16, 22, weight: FontWeight.w500);
  static final subhead = _b(15, 22.5);
  static final subheadStrong = _b(15, 20, weight: FontWeight.w500);
  static final footnote = _b(13, 18);
  static final footnoteStrong = _b(13, 18, weight: FontWeight.w500);
  static final caption = _b(12, 16);

  /// Rótulo de seção (sentence case).
  static final section = _b(13, 18, weight: FontWeight.w500, tracking: 0.1);

  static const tabular = [FontFeature.tabularFigures()];
}

/// Troca o peso de um estilo de fonte variável (peso + eixo `wght`).
extension TravelWeight on TextStyle {
  TextStyle weight(FontWeight w) => copyWith(
        fontWeight: w,
        fontVariations: [FontVariation('wght', w.value.toDouble())],
      );
}

/// Espaçamento em grade de 4/8pt e raios CONCÊNTRICOS:
/// raio externo = raio interno + padding.
///
///   sheet 36 ─(margem 12)→ card 24 ─(padding 12)→ interno 12 ─(4)→ 8
///   composer 28 ─(padding 8)→ botão circular 40 (raio 20)
///   sheet de agenda 36 ─(padding 20)→ superfícies 16
///   lista segmentada (M3 Expressive): sheet 36 ─(margem 12)→ cantos de
///   fora 24, cantos entre itens 8, itens separados por 2
///
/// Linha de conteúdo: margem 12 + padding 12 = texto a 24pt da borda.
abstract final class TravelSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  /// Margem lateral do conteúdo do sheet.
  static const gutter = 12.0;

  /// Padding interno de cards.
  static const cardPad = 12.0;

  /// Recuo do texto solto (alinha com o texto dentro dos cards).
  static const content = gutter + cardPad;

  static const rSheet = 36.0;
  static const rCard = 24.0;
  static const rInner = 12.0;
  static const rTight = 8.0;
  static const rComposer = 28.0;
  static const rPill = 999.0;

  /// Espaço entre itens de uma lista segmentada (o fundo aparece entre
  /// eles; sem divisor).
  static const segmentGap = 2.0;

  /// Alvo mínimo de toque (HIG).
  static const tap = 44.0;
}

/// Tema mínimo da tela — flat: sem ripple, sem sombras, sem tint de
/// elevação. Montado do zero (não herda o tema do chrome de docs).
ThemeData travelTheme(BuildContext context) {
  final p = TravelPalette.of(context);
  const flatButton = ButtonStyle(
    splashFactory: NoSplash.splashFactory,
    elevation: WidgetStatePropertyAll(0),
    shadowColor: WidgetStatePropertyAll(Colors.transparent),
  );
  return ThemeData(
    useMaterial3: true,
    brightness: p.brightness,
    fontFamily: 'PlusJakartaSans',
    scaffoldBackgroundColor: p.s0,
    colorScheme: ColorScheme.fromSeed(
      seedColor: p.accent,
      brightness: p.brightness,
      surface: p.s0,
      primary: p.accent,
      onPrimary: p.onAccent,
      surfaceTint: Colors.transparent,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    hoverColor: p.ink.withValues(alpha: 0.04),
    shadowColor: Colors.transparent,
    filledButtonTheme: const FilledButtonThemeData(style: flatButton),
    textButtonTheme: const TextButtonThemeData(style: flatButton),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: p.accentText,
      selectionColor: p.accent.withValues(alpha: 0.3),
    ),
  );
}

/// Tom de categoria pros blocos de evento (calendário, guia do dia): fundo
/// com cor de verdade — suave mas sem ficar lavado — e texto no tom escuro
/// da mesma cor. Música/noite roxo, arte/cultura amarelo, comida laranja,
/// natureza verde, praia azul-água.
class CategoryTone {
  const CategoryTone(this.fill, this.ink);

  final Color fill;
  final Color ink;
}

abstract final class TravelCategoryTones {
  static const light = {
    RoleCategory.comida: CategoryTone(Color(0xFFFFD2BE), Color(0xFF8A2D0A)),
    RoleCategory.cultura: CategoryTone(Color(0xFFFFE194), Color(0xFF684800)),
    RoleCategory.noite: CategoryTone(Color(0xFFDCCCFF), Color(0xFF4A22A8)),
    RoleCategory.natureza: CategoryTone(Color(0xFFC6EAC0), Color(0xFF1D5922)),
    RoleCategory.praia: CategoryTone(Color(0xFFBAE9EC), Color(0xFF0A585E)),
  };

  static const dark = {
    RoleCategory.comida: CategoryTone(Color(0xFF5C2A15), Color(0xFFFFCDB6)),
    RoleCategory.cultura: CategoryTone(Color(0xFF55420C), Color(0xFFFFE08A)),
    RoleCategory.noite: CategoryTone(Color(0xFF3C2A78), Color(0xFFDACCFF)),
    RoleCategory.natureza: CategoryTone(Color(0xFF1E4624), Color(0xFFBFE8BA)),
    RoleCategory.praia: CategoryTone(Color(0xFF0E4549), Color(0xFFB3ECEF)),
  };

  static CategoryTone of(BuildContext context, RoleCategory c) =>
      (TravelPalette.of(context).isDark ? dark : light)[c]!;
}
