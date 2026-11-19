import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/features/explore/presentation/view_models/explore_state.dart';
import 'package:studio_app/features/explore/presentation/widgets/explore_ui.dart';
import 'package:studio_app/features/travel_agent/presentation/view_models/conversations_cubit.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';

/// Gaveta de conversas do agente (☰), ref. ChatGPT no sistema Maré.
///
/// Fica por baixo da página: a conversa desliza pra direita e revela a
/// gaveta. Sem busca nem ajustes (não existem no protótipo). Linhas de 48
/// só com texto, sem divisores; a aberta em `s2` raio 16 (igual ao menu ⋯).
/// Um primário só: "Nova conversa".
class ConversationDrawer extends StatelessWidget {
  const ConversationDrawer({
    required this.state,
    required this.onOpen,
    required this.onNew,
    required this.onNavigate,
    super.key,
  });

  final ConversationsState state;
  final ValueChanged<String> onOpen;
  final VoidCallback onNew;

  /// Sai da Maré pra home, na aba tocada.
  final ValueChanged<ExploreTab> onNavigate;

  /// Mesmos ícones e rótulos da tab bar da home.
  static const _tabs = [
    (ExploreTab.explorar, 'Explorar', TravelIcons.compass),
    (ExploreTab.salvos, 'Salvos', TravelIcons.bookmark),
    (ExploreTab.perfil, 'Perfil', TravelIcons.user),
  ];

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final pad = MediaQuery.paddingOf(context);
    final pinned = state.pinned;
    final recent = state.recent;
    // Material: estilo de texto padrão fora do Scaffold da conversa.
    return Material(
      color: p.s0,
      child: Padding(
        padding: EdgeInsets.only(top: pad.top + 8, bottom: pad.bottom + 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mesma altura do cabeçalho da conversa (44).
            SizedBox(
              height: TravelSpace.tap,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: TravelSpace.content),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Maré',
                      style: TravelType.title2.copyWith(color: p.ink)),
                ),
              ),
            ),
            const SizedBox(height: TravelSpace.lg),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: TravelSpace.gutter),
              child: Column(
                children: [
                  for (final (tab, label, icon) in _tabs)
                    _DrawerRow(
                      label: label,
                      icon: icon,
                      onTap: () => onNavigate(tab),
                    ),
                ],
              ),
            ),
            const SizedBox(height: TravelSpace.sm),
            Expanded(
              // Rampa senoidal nas duas pontas: some sob as abas e sobre o
              // botão (regra 11), sem borda dura.
              child: VerticalEdgeFade(
                top: TravelSpace.lg,
                bottom: TravelSpace.xl,
                child: ListView(
                  // Topo = altura do fade: em repouso nada fica velado.
                  padding: const EdgeInsets.fromLTRB(TravelSpace.gutter,
                      TravelSpace.lg, TravelSpace.gutter, TravelSpace.xl),
                  children: [
                    if (pinned.isNotEmpty) ...[
                      const SectionHeader('Fixadas'),
                      for (final c in pinned)
                        _DrawerRow(
                          label: c.title,
                          active: c.id == state.activeId,
                          onTap: () => onOpen(c.id),
                        ),
                      const SizedBox(height: TravelSpace.xl),
                    ],
                    const SectionHeader('Recentes'),
                    if (recent.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: TravelSpace.cardPad, vertical: 12),
                        child: Text(
                          'Nenhuma conversa ainda',
                          style: TravelType.callout.copyWith(color: p.inkMuted),
                        ),
                      )
                    else
                      for (final c in recent)
                        _DrawerRow(
                          label: c.title,
                          active: c.id == state.activeId,
                          onTap: () => onOpen(c.id),
                        ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: TravelSpace.sm),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: TravelSpace.gutter),
              child: PrimaryButton(
                label: 'Nova conversa',
                icon: TravelIcons.pen,
                onPressed: onNew,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerRow extends StatefulWidget {
  const _DrawerRow({
    required this.label,
    required this.onTap,
    this.icon,
    this.active = false,
  });

  final String label;
  final FaIconData? icon;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_DrawerRow> createState() => _DrawerRowState();
}

class _DrawerRowState extends State<_DrawerRow> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final icon = widget.icon;
    return Semantics(
      button: true,
      selected: widget.active,
      label: widget.label,
      excludeSemantics: true,
      onTap: widget.onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) {
          setState(() => _down = false);
          widget.onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: TravelSpace.cardPad),
          decoration: BoxDecoration(
            color: _down || widget.active ? p.s2 : p.s0,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                SizedBox(
                  width: 20,
                  child: Center(child: FaIcon(icon, size: 18, color: p.ink)),
                ),
                const SizedBox(width: TravelSpace.md),
              ],
              Expanded(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TravelType.callout.copyWith(color: p.ink, height: 1.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
