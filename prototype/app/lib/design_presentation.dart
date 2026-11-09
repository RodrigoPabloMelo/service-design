import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter/services.dart';
import 'package:studio_app/design_canvas.dart';
import 'package:studio_app/design_theme.dart';
import 'package:studio_app/design_tokens.dart';
import 'package:studio_app/features/feature_registry.dart';

/// Tela expandida / modo apresentação: overlay fullscreen com blur, header em
/// 3 colunas (nome + i/total · seletor de tela e de estado · ações), tom
/// claro/escuro local, telefone grande e atalhos ←/→ para navegar, Esc sai.
///
/// É o que o botão "Abrir tela" do painel lateral abre — daí o seletor de
/// estado: expandir uma tela sem poder ver os edge cases dela seria meio
/// caminho.
Future<void> showDesignPresentation(
  BuildContext context, {
  required List<RegisteredScreen> screens,
  required int initialIndex,
  FrameMode frameMode = FrameMode.plano,
  String? scenario,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 200),
    transitionBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
    pageBuilder: (_, __, ___) => _PresentationOverlay(
      screens: screens,
      initialIndex: initialIndex,
      frameMode: frameMode,
      scenario: scenario,
    ),
  );
}

class _PresentationOverlay extends StatefulWidget {
  const _PresentationOverlay({
    required this.screens,
    required this.initialIndex,
    required this.frameMode,
    required this.scenario,
  });

  final List<RegisteredScreen> screens;
  final int initialIndex;
  final FrameMode frameMode;
  final String? scenario;

  @override
  State<_PresentationOverlay> createState() => _PresentationOverlayState();
}

class _PresentationOverlayState extends State<_PresentationOverlay> {
  late int _index = widget.initialIndex;
  late String? _scenario = widget.scenario;

  /// Abre no tom do preview (o toggle claro/escuro do hub), não sempre
  /// escuro: a tela em tela cheia tem que ser a mesma que está na grade. O
  /// pill do palco continua trocando só aqui dentro.
  late bool _dark = designThemeMode.value == ThemeMode.dark;

  RegisteredScreen get _screen => widget.screens[_index];

  void _go(int delta) {
    final next = (_index + delta).clamp(0, widget.screens.length - 1);
    if (next != _index) _select(next);
  }

  /// Trocar de tela mantém o estado escolhido quando a nova tela também o
  /// cobre — assim dá para percorrer o fluxo todo "no cenário de erro".
  void _select(int index) {
    setState(() {
      _index = index;
      final s = _scenario;
      if (s != null && !widget.screens[index].hasScenario(s)) _scenario = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fg = _dark ? Colors.white : Colors.black;
    final muted = fg.withValues(alpha: 0.6);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _go(-1),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => _go(1),
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).pop(),
      },
      // O overlay é uma rota de dialog empurrada acima do _DocsShell, então
      // NÃO herdaria o tema do DS — os menus caíam no default do Material.
      // Aqui ele entra explicitamente, no tom do palco.
      child: Theme(
        data: loomiDocsTheme(_dark ? Brightness.dark : Brightness.light),
        // Material transparente: o overlay de dialog não tem Material próprio
        // e os IconButton exigem um ancestral Material.
        child: Material(
          type: MaterialType.transparency,
          child: Focus(
            autofocus: true,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                color: (_dark ? Colors.black : Colors.white).withValues(
                  alpha: 0.72,
                ),
                child: DefaultTextStyle(
                  style: TextStyle(color: fg),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
                        child: Row(
                          children: [
                            // Esquerda: nome + posição.
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _screen.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: fg,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${_screen.flow} · ${_index + 1}/${widget.screens.length}',
                                    style:
                                        TextStyle(color: muted, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            // Centro: ‹ [seletor de tela] ›
                            IconButton(
                              tooltip: 'Anterior (←)',
                              onPressed: _index > 0 ? () => _go(-1) : null,
                              icon: Icon(HugeIcons.strokeRoundedArrowLeft01,
                                  color: fg),
                            ),
                            _ScreenSelect(
                              screens: widget.screens,
                              index: _index,
                              dark: _dark,
                              onSelect: _select,
                            ),
                            IconButton(
                              tooltip: 'Próxima (→)',
                              onPressed: _index < widget.screens.length - 1
                                  ? () => _go(1)
                                  : null,
                              icon: Icon(HugeIcons.strokeRoundedArrowRight01,
                                  color: fg),
                            ),
                            // Direita: estado + tom + fechar.
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _ScenarioSelect(
                                    screen: _screen,
                                    scenario: _scenario,
                                    dark: _dark,
                                    onSelect: (s) =>
                                        setState(() => _scenario = s),
                                  ),
                                  const SizedBox(width: 8),
                                  _TonePill(
                                    dark: _dark,
                                    onChanged: (d) => setState(() => _dark = d),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    tooltip: 'Sair (Esc)',
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    icon: Icon(HugeIcons.strokeRoundedCancel01,
                                        color: fg),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Corpo: telefone grande, ajustado à altura disponível.
                      Expanded(
                        child: Center(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final width =
                                  (constraints.maxHeight - 32) * kPhoneAspect;
                              return MiniPhoneFrame(
                                key: ValueKey('${_screen.route}#$_scenario'),
                                screen: _screen,
                                width: width.clamp(180.0, 420.0),
                                mode: widget.frameMode,
                                interactive: true,
                                // Explícito: aqui o estado é escolhido no
                                // header, não herdado do seletor global.
                                scenario: _scenario ?? kScenarioDefault,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Seletor central de tela (o ScreenSelect do vmqa): pill com índice + nome,
/// abre lista com check na ativa.
class _ScreenSelect extends StatelessWidget {
  const _ScreenSelect({
    required this.screens,
    required this.index,
    required this.dark,
    required this.onSelect,
  });

  final List<RegisteredScreen> screens;
  final int index;
  final bool dark;
  final void Function(int) onSelect;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : Colors.black;
    return PopupMenuButton<int>(
      tooltip: 'Escolher tela',
      onSelected: onSelect,
      itemBuilder: (_) => [
        for (var i = 0; i < screens.length; i++)
          PopupMenuItem(
            value: i,
            height: 36,
            child: Row(
              children: [
                SizedBox(
                  width: 26,
                  child: Text(
                    (i + 1).toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: LoomiTokens.typeCaption,
                      color: LoomiPalette.of(context).mutedForeground,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    screens[i].title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (i == index)
                  Icon(
                    HugeIcons.strokeRoundedTick02,
                    size: 14,
                    color: LoomiPalette.of(context).primary,
                  ),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: fg.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              (index + 1).toString().padLeft(2, '0'),
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: fg.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 240),
              child: Text(
                screens[index].title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: fg),
              ),
            ),
            Icon(HugeIcons.strokeRoundedArrowDown01, size: 16, color: fg),
          ],
        ),
      ),
    );
  }
}

/// Seletor de estado da tela, no mesmo pill do seletor de tela.
///
/// Fica visível mesmo quando a tela não tem variação: informar "Padrão" é
/// melhor que o controle aparecer e desaparecer conforme se navega o fluxo.
class _ScenarioSelect extends StatelessWidget {
  const _ScenarioSelect({
    required this.screen,
    required this.scenario,
    required this.dark,
    required this.onSelect,
  });

  final RegisteredScreen screen;
  final String? scenario;
  final bool dark;
  final void Function(String? scenario) onSelect;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : Colors.black;
    final atual = scenario ?? kScenarioDefault;
    final opcoes = [kScenarioDefault, ...screen.scenarios];

    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            scenarioIcon(atual),
            size: 15,
            color: fg.withValues(alpha: opcoes.length > 1 ? 0.9 : 0.45),
          ),
          const SizedBox(width: 8),
          Text(
            atual,
            style: TextStyle(
              color: fg.withValues(alpha: opcoes.length > 1 ? 1 : 0.45),
            ),
          ),
          if (opcoes.length > 1)
            Icon(HugeIcons.strokeRoundedArrowDown01, size: 16, color: fg),
        ],
      ),
    );

    if (opcoes.length == 1) {
      return Tooltip(
          message: 'Esta tela não tem estado alternativo', child: pill);
    }

    return PopupMenuButton<String>(
      tooltip: 'Estado da tela',
      onSelected: (s) => onSelect(s == kScenarioDefault ? null : s),
      itemBuilder: (_) => [
        for (final s in opcoes)
          PopupMenuItem(
            value: s,
            height: 36,
            child: Row(
              children: [
                Icon(scenarioIcon(s),
                    size: 15, color: scenarioColor(context, s)),
                const SizedBox(width: 10),
                Expanded(child: Text(s)),
                if (s == atual)
                  Icon(
                    HugeIcons.strokeRoundedTick02,
                    size: 14,
                    color: LoomiPalette.of(context).primary,
                  ),
              ],
            ),
          ),
      ],
      child: pill,
    );
  }
}

/// Tom claro/escuro do palco, no mesmo pill dos outros controles.
///
/// Não é SegmentedButton: aquele herda as cores do design system (lilás do
/// `primary`) e as jogava sobre o palco neutro, com o ícone não-selecionado
/// em branco 60% — ilegível. Aqui tudo é pintado a partir do `fg` do palco,
/// então funciona nos dois tons.
class _TonePill extends StatelessWidget {
  const _TonePill({required this.dark, required this.onChanged});

  final bool dark;
  final void Function(bool dark) onChanged;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : Colors.black;

    Widget half({
      required IconData icon,
      required String tooltip,
      required bool value,
    }) {
      final active = value == dark;
      return Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(99),
          onTap: active ? null : () => onChanged(value),
          child: Container(
            width: 34,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? fg.withValues(alpha: 0.18) : null,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Icon(
              icon,
              size: 16,
              color: fg.withValues(alpha: active ? 1 : 0.45),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          half(
              icon: HugeIcons.strokeRoundedSun03,
              tooltip: 'Tom claro',
              value: false),
          half(
              icon: HugeIcons.strokeRoundedMoon02,
              tooltip: 'Tom escuro',
              value: true),
        ],
      ),
    );
  }
}
