import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// Tokens do design system **@loomi/ui** (`loomios-ui`) portados para Flutter.
///
/// Fonte: `loomios-ui/src/globals.css` (`@theme inline`, Tailwind v4
/// CSS-first). Lá as cores são `oklch()`; aqui entram já convertidas para
/// sRGB — Flutter não tem espaço oklch, e converter em runtime seria peso
/// morto num arquivo de constantes.
///
/// **Escopo: chrome do designer, não o app.** Isto veste a documentação
/// (`/docs`) para ela parecer parte do ecossistema loomi-os. As telas do
/// protótipo seguem o design do produto, não este arquivo.
///
/// Um fork consciente da Regra de Ouro do loomios-ui ("nunca forke um
/// componente daqui"): `@loomi/ui` é React/Tailwind e não roda em Flutter.
/// Portamos só a camada de tokens — se um token mudar lá, atualize aqui.
class LoomiTokens {
  const LoomiTokens._();

  // ── Marca (não muda entre temas) ──
  static const brandPurple = Color(0xFF5B2DC4);
  static const brandPink = Color(0xFFFF3399);
  static const brandDark = Color(0xFF171717);

  // ── Raios: --radius 0.75rem, com os degraus derivados ──
  static const radiusSm = 8.0; // radius - 4px
  static const radiusMd = 10.0; // radius - 2px
  static const radiusLg = 12.0; // radius
  static const radiusXl = 16.0; // radius + 4px

  // ── Escala tipográfica (--type-*, rem → px @ 16px) ──
  static const typeEyebrow = 10.0;
  static const typeCaption = 11.0;
  static const typeBody = 13.0;
  static const typeH3 = 14.0;
  static const typeH2 = 18.0;
  static const typeH1 = 22.0;
  static const typeDisplay = 36.0;

  /// Fontes do DS. Carregadas por `<link>` do Google Fonts em
  /// `web/index.html` — sem pacote `google_fonts` (dependência nova exige
  /// aprovação, Inviolável #4) e sem arquivos de fonte no repo. Fora do web
  /// o Flutter cai no fallback do sistema, aceitável: `/docs` é web-only.
  static const sansFont = 'Manrope';
  static const displayFont = 'Sora';

  // ── Sombras (--elev-shadow-*) ──
  static const shadowSm = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
  ];
  static const shadowMd = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, 6)),
  ];
  static const shadowLg = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x29000000), blurRadius: 32, offset: Offset(0, 12)),
  ];
}

/// Paleta de um tema (`:root` ou `.dark` do globals.css).
class LoomiPalette {
  const LoomiPalette({
    required this.background,
    required this.foreground,
    required this.card,
    required this.cardForeground,
    required this.primary,
    required this.primaryForeground,
    required this.secondary,
    required this.secondaryForeground,
    required this.muted,
    required this.mutedForeground,
    required this.destructive,
    required this.success,
    required this.warning,
    required this.info,
    required this.border,
    required this.sidebar,
    required this.sidebarForeground,
    required this.sidebarAccent,
    required this.sidebarAccentForeground,
    required this.sidebarBorder,
  });

  final Color background;
  final Color foreground;
  final Color card;
  final Color cardForeground;
  final Color primary;
  final Color primaryForeground;
  final Color secondary;
  final Color secondaryForeground;
  final Color muted;
  final Color mutedForeground;
  final Color destructive;
  final Color success;
  final Color warning;
  final Color info;
  final Color border;
  final Color sidebar;
  final Color sidebarForeground;
  final Color sidebarAccent;
  final Color sidebarAccentForeground;
  final Color sidebarBorder;

  static const light = LoomiPalette(
    background: Color(0xFFFAFAFD),
    foreground: Color(0xFF0A0A0A),
    card: Color(0xFFFAFAFD),
    cardForeground: Color(0xFF0A0A0A),
    primary: Color(0xFF4E00BB),
    primaryForeground: Color(0xFFFFFFFF),
    secondary: Color(0xFFF5F5F7),
    secondaryForeground: Color(0xFF171717),
    muted: Color(0xFFF5F5F7),
    mutedForeground: Color(0xFF6C6C6C),
    destructive: Color(0xFFE7000B),
    success: Color(0xFF23A136),
    warning: Color(0xFFECAA0B),
    info: Color(0xFF0099EB),
    border: Color(0xFFE4E4E4),
    sidebar: Color(0xFFF6F6FF),
    sidebarForeground: Color(0xFF17161C),
    sidebarAccent: Color(0xFFEAE9FF),
    sidebarAccentForeground: Color(0xFF4E00BB),
    sidebarBorder: Color(0xFFDDDDE4),
  );

  static const dark = LoomiPalette(
    background: Color(0xFF0A0A0D),
    foreground: Color(0xFFFAFAFA),
    card: Color(0xFF17161C),
    cardForeground: Color(0xFFFAFAFA),
    primary: Color(0xFF7153DD),
    primaryForeground: Color(0xFFFFFFFF),
    secondary: Color(0xFF26252B),
    secondaryForeground: Color(0xFFFAFAFA),
    muted: Color(0xFF26252B),
    mutedForeground: Color(0xFFA1A1A1),
    destructive: Color(0xFFF71721),
    success: Color(0xFF3DB44A),
    warning: Color(0xFFFFC73A),
    info: Color(0xFF00AFFF),
    border: Color(0xFF2B2B31),
    sidebar: Color(0xFF080710),
    sidebarForeground: Color(0xFFF1F1F4),
    sidebarAccent: Color(0xFF2D2457),
    sidebarAccentForeground: Color(0xFFCAC4FF),
    sidebarBorder: Color(0xFF1A1A1F),
  );

  /// Paleta do tema atual — as telas de `/docs` leem daqui.
  static LoomiPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

/// ThemeData do chrome de documentação, montado a partir dos tokens.
///
/// Só o que `/docs` usa de verdade: superfícies, tipografia (display font nos
/// títulos, sans no corpo, escala `--type-*`), botões e inputs com
/// `--radius`. Não tenta espelhar todo o shadcn.
ThemeData loomiDocsTheme(Brightness brightness) {
  final p =
      brightness == Brightness.dark ? LoomiPalette.dark : LoomiPalette.light;

  TextStyle display(double size, {FontWeight weight = FontWeight.w600}) =>
      TextStyle(
        fontFamily: LoomiTokens.displayFont,
        fontSize: size,
        fontWeight: weight,
        height: 1.25,
        letterSpacing: -0.012 * size,
        color: p.foreground,
      );

  TextStyle body(double size, {FontWeight weight = FontWeight.w400}) =>
      TextStyle(
        fontFamily: LoomiTokens.sansFont,
        fontSize: size,
        fontWeight: weight,
        height: 1.55,
        color: p.foreground,
      );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: p.background,
    canvasColor: p.background,
    dividerColor: p.border,
    fontFamily: LoomiTokens.sansFont,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: p.primary,
      onPrimary: p.primaryForeground,
      secondary: p.secondary,
      onSecondary: p.secondaryForeground,
      error: p.destructive,
      onError: Colors.white,
      surface: p.card,
      onSurface: p.cardForeground,
      surfaceContainerHighest: p.muted,
      outline: p.border,
      outlineVariant: p.border,
    ),
    textTheme: TextTheme(
      displaySmall: display(LoomiTokens.typeDisplay),
      headlineSmall: display(LoomiTokens.typeH1),
      titleLarge: display(LoomiTokens.typeH1),
      titleMedium: display(LoomiTokens.typeH2),
      titleSmall: display(LoomiTokens.typeH3),
      bodyLarge: body(LoomiTokens.typeH3),
      bodyMedium: body(LoomiTokens.typeBody),
      bodySmall: body(LoomiTokens.typeCaption),
      labelLarge: body(LoomiTokens.typeH3, weight: FontWeight.w500),
      labelMedium: body(LoomiTokens.typeBody, weight: FontWeight.w500),
      labelSmall: body(LoomiTokens.typeEyebrow, weight: FontWeight.w500),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: p.background,
      foregroundColor: p.foreground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: display(LoomiTokens.typeH2),
      shape: Border(bottom: BorderSide(color: p.border)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.primary,
        foregroundColor: p.primaryForeground,
        textStyle: body(LoomiTokens.typeBody, weight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LoomiTokens.radiusMd),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.foreground,
        side: BorderSide(color: p.border),
        textStyle: body(LoomiTokens.typeBody, weight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LoomiTokens.radiusMd),
        ),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LoomiTokens.radiusMd),
          ),
        ),
        side: WidgetStatePropertyAll(BorderSide(color: p.border)),
      ),
    ),
    // Inputs do DS: borda `--border`, raio `--radius - 2px`, foco na tinta
    // de marca. Cobre o select de estado do canvas e qualquer campo futuro
    // sem restyling widget por widget.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.card,
      isDense: true,
      hintStyle: body(LoomiTokens.typeBody).copyWith(color: p.mutedForeground),
      labelStyle: body(LoomiTokens.typeBody).copyWith(color: p.mutedForeground),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LoomiTokens.radiusMd),
        borderSide: BorderSide(color: p.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LoomiTokens.radiusMd),
        borderSide: BorderSide(color: p.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LoomiTokens.radiusMd),
        borderSide: BorderSide(color: p.primary, width: 1.6),
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(p.card),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            side: BorderSide(color: p.border),
            borderRadius: BorderRadius.circular(LoomiTokens.radiusMd),
          ),
        ),
      ),
    ),
    // Chip = badge clicável: mesma pill do badge.tsx, sem o cinza do M3.
    chipTheme: ChipThemeData(
      backgroundColor: p.primary.withValues(alpha: 0.1),
      side: BorderSide(color: p.primary.withValues(alpha: 0.2)),
      labelStyle: body(LoomiTokens.typeCaption, weight: FontWeight.w500)
          .copyWith(color: p.primary),
      iconTheme: IconThemeData(size: 14, color: p.primary),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: const StadiumBorder(),
      showCheckmark: false,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.primary,
        textStyle: body(LoomiTokens.typeBody, weight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LoomiTokens.radiusMd),
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: p.mutedForeground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LoomiTokens.radiusSm),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: p.card,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: p.border),
        borderRadius: BorderRadius.circular(LoomiTokens.radiusXl),
      ),
    ),
    // Menus do DS: card com borda e `--radius - 2px`, item compacto. Sem
    // isto o PopupMenuButton cai no default do Material (quadrado, item de
    // 48px, sem borda) — foi o que deixou o seletor de tela feio.
    popupMenuTheme: PopupMenuThemeData(
      color: p.card,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shadowColor: const Color(0x1A000000),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: p.border),
        borderRadius: BorderRadius.circular(LoomiTokens.radiusMd),
      ),
      textStyle: body(LoomiTokens.typeBody),
      labelTextStyle: WidgetStatePropertyAll(body(LoomiTokens.typeBody)),
      menuPadding: const EdgeInsets.symmetric(vertical: 6),
    ),
    tooltipTheme: TooltipThemeData(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: p.foreground,
        borderRadius: BorderRadius.circular(LoomiTokens.radiusSm),
      ),
      textStyle: TextStyle(
        fontFamily: LoomiTokens.sansFont,
        fontSize: LoomiTokens.typeCaption,
        color: p.background,
      ),
    ),
  );
}

/// Uma opção de [LoomiDropdown].
class LoomiOption<T> {
  const LoomiOption({
    required this.value,
    required this.label,
    this.icon,
    this.color,
    this.hint,
  });

  final T value;
  final String label;
  final IconData? icon;

  /// Tinta do ícone. Sem valor, o ícone segue a seleção (marca x muted).
  final Color? color;

  /// Texto auxiliar à direita no menu (ex.: o aparelho de cada moldura).
  final String? hint;
}

/// Menu suspenso do DS — porte do `native-select.tsx` do loomios-ui, que é o
/// componente que ele indica para "small inline selector (export filters,
/// heatmap toolbar)": gatilho `h-9 rounded-md border border-input
/// bg-background pl-3 pr-8 text-body shadow-sm`, chevron à direita a 50%.
///
/// O menu em si herda o `popupMenuTheme` do [loomiDocsTheme].
class LoomiDropdown<T> extends StatelessWidget {
  const LoomiDropdown({
    required this.options,
    required this.value,
    required this.onChanged,
    required this.tooltip,
    this.iconOnly = false,
    this.expanded = false,
    this.pill = false,
    super.key,
  });

  final List<LoomiOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;
  final String tooltip;

  /// Gatilho redondo só com o ícone da opção atual (barras compactas).
  final bool iconOnly;

  /// Gatilho ocupando a largura disponível (selects de formulário).
  final bool expanded;

  /// Gatilho em pílula cheia sobre `muted`, sem borda — o formato da barra
  /// do portal (versão, visão). Sem isto vem o campo com borda do DS.
  final bool pill;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = LoomiPalette.of(context);
    final atual = options.firstWhere(
      (o) => o.value == value,
      orElse: () => options.first,
    );

    return PopupMenuButton<T>(
      tooltip: tooltip,
      onSelected: onChanged,
      position: PopupMenuPosition.under,
      itemBuilder: (_) => [
        for (final o in options)
          PopupMenuItem<T>(
            value: o.value,
            height: 36,
            child: Row(
              children: [
                if (o.icon != null) ...[
                  Icon(
                    o.icon,
                    size: 16,
                    color: o.color ??
                        (o.value == value ? p.primary : p.mutedForeground),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(child: Text(o.label)),
                if (o.hint != null) ...[
                  const SizedBox(width: 16),
                  // Flexible + ellipsis: a dica é o aparelho da moldura e
                  // estourava o menu em tela estreita.
                  Flexible(
                    child: Text(
                      o.hint!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: p.mutedForeground),
                    ),
                  ),
                ],
                if (o.value == value) ...[
                  const SizedBox(width: 12),
                  Icon(HugeIcons.strokeRoundedTick02,
                      size: 14, color: p.primary),
                ],
              ],
            ),
          ),
      ],
      child: iconOnly
          ? Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: atual.color?.withValues(alpha: 0.12),
              ),
              child: Icon(
                atual.icon,
                size: 17,
                color: atual.color ?? p.mutedForeground,
              ),
            )
          : Container(
              height: 36,
              padding:
                  EdgeInsets.only(left: pill ? 14 : 12, right: pill ? 12 : 8),
              decoration: BoxDecoration(
                color: pill ? p.muted : p.card,
                border: pill ? null : Border.all(color: p.border),
                borderRadius:
                    BorderRadius.circular(pill ? 99 : LoomiTokens.radiusMd),
                boxShadow: pill ? null : LoomiTokens.shadowSm,
              ),
              child: Row(
                mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  if (atual.icon != null) ...[
                    Icon(atual.icon,
                        size: 16, color: atual.color ?? p.foreground),
                    const SizedBox(width: 8),
                  ],
                  if (expanded)
                    Expanded(
                      child: Text(
                        atual.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  else
                    Text(atual.label, style: theme.textTheme.bodyMedium),
                  const SizedBox(width: 6),
                  Icon(
                    HugeIcons.strokeRoundedArrowDown01,
                    size: 16,
                    color: p.foreground.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Badge do DS: pill tintada 10% com borda 20% (badge.tsx do loomios-ui).
class LoomiBadge extends StatelessWidget {
  const LoomiBadge({required this.label, this.color, this.icon, super.key});

  final String label;

  /// Cor do tom; sem valor usa `primary` (variante `default`).
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final tone = color ?? LoomiPalette.of(context).primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.1),
        border: Border.all(color: tone.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: tone),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: LoomiTokens.sansFont,
              fontSize: LoomiTokens.typeCaption,
              fontWeight: FontWeight.w500,
              height: 1.2,
              color: tone,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card do DS: superfície limpa com borda + shadow token, sem glass
/// (card.tsx). `elevated` ganha a sombra média; `flat` zera borda e sombra.
enum LoomiCardVariant { normal, elevated, flat }

class LoomiCard extends StatelessWidget {
  const LoomiCard({
    required this.child,
    this.variant = LoomiCardVariant.normal,
    this.padding = const EdgeInsets.all(20),
    super.key,
  });

  final Widget child;
  final LoomiCardVariant variant;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final p = LoomiPalette.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(LoomiTokens.radiusXl),
        border: Border.all(
          color:
              variant == LoomiCardVariant.flat ? Colors.transparent : p.border,
        ),
        boxShadow: switch (variant) {
          LoomiCardVariant.normal => LoomiTokens.shadowSm,
          LoomiCardVariant.elevated => LoomiTokens.shadowMd,
          LoomiCardVariant.flat => const [],
        },
      ),
      child: child,
    );
  }
}

/// Painel flutuante do portal (`@utility panel` do studio-cosmo-teste):
/// superfície, raio 1.5rem, sombra md e sem borda. É o cartão que segura o
/// canvas e o preview no hub.
class LoomiPanelSurface extends StatelessWidget {
  const LoomiPanelSurface({required this.child, super.key});

  final Widget child;

  static const radius = 24.0;

  @override
  Widget build(BuildContext context) {
    final p = LoomiPalette.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: LoomiTokens.shadowMd,
      ),
      child: child,
    );
  }
}

/// Cabeçalho de página do DS (`PageTitle` + `PageDescription` do page.tsx):
/// título em display font, descrição em `muted-foreground`.
class LoomiPageHeader extends StatelessWidget {
  const LoomiPageHeader({
    required this.title,
    this.description,
    this.actions,
    super.key,
  });

  final String title;
  final String? description;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = LoomiPalette.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleLarge),
              if (description != null) ...[
                const SizedBox(height: 2),
                Text(
                  description!,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: p.mutedForeground),
                ),
              ],
            ],
          ),
        ),
        if (actions != null) ...[
          const SizedBox(width: 12),
          Row(mainAxisSize: MainAxisSize.min, children: actions!),
        ],
      ],
    );
  }
}

// ── Cenários (edge cases) ─────────────────────────────────────────────
//
// Não são tokens do @loomi/ui: moram aqui porque este é o módulo folha
// que hub, canvas e subpágina de doc já importam, e `scenarioColor`
// precisa da LoomiPalette.

/// Ícone de cada cenário.
IconData scenarioIcon(String scenario) => switch (scenario) {
      'Erro' => HugeIcons.strokeRoundedAlertCircle,
      'Vazio' => HugeIcons.strokeRoundedInbox,
      'Carregando' => HugeIcons.strokeRoundedHourglass,
      _ => HugeIcons.strokeRoundedCheckmarkCircle01,
    };

/// Cor do cenário no DS: erro em vermelho, o resto em tinta informativa.
Color scenarioColor(BuildContext context, String scenario) {
  final p = LoomiPalette.of(context);
  return switch (scenario) {
    'Erro' => p.destructive,
    'Vazio' => p.warning,
    'Carregando' => p.info,
    _ => p.success,
  };
}
