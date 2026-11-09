import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';
import 'package:studio_app/core/components/widgets/app_activity_indicator.dart';
import 'package:studio_app/features/travel_agent/data/travel_agent_mock.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';
import 'package:studio_app/features/travel_agent/presentation/view_models/travel_agent_cubit.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/connector_carousel.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';

/// Sheet modal "Leve o roteiro pros seus apps" — conecta a Google Agenda
/// (mock OAuth: Conectar → Verificando → Conectado) e mostra os eventos.
/// Maps, Uber e 99 conectam direto na própria linha.
/// Superfície neutra escura com aurora azul + tiffany (ref. vídeo de conectores).
class CalendarConnectSheet extends StatelessWidget {
  const CalendarConnectSheet({
    required this.status,
    required this.days,
    required this.onConnect,
    required this.onClose,
    this.appConnections = const {},
    this.onConnectApp,
    super.key,
  });

  final CalendarStatus status;
  final List<ItineraryDay> days;
  final VoidCallback onConnect;
  final VoidCallback onClose;
  final Map<ConnectorKind, CalendarStatus> appConnections;
  final ValueChanged<ConnectorKind>? onConnectApp;

  // Sheet sempre escuro (ref. conectores), independente do tema: paleta
  // própria de propósito.
  static const _bg = Color(0xFF111113); // design-lint: ignore D07
  static const _surface = Color(0xFF1F1F23); // design-lint: ignore D07
  static const _fg = Color(0xFFF2F2F5); // design-lint: ignore D07
  static const _muted = Color(0xFFA1A1A8); // design-lint: ignore D07
  static const _blue = Color(0xFF006FD6); // design-lint: ignore D07
  static const _blueText = Color(0xFF6AB0FF); // design-lint: ignore D07

  int get _events => days.fold(0, (n, d) => n + d.stops.length);

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final connected = status == CalendarStatus.connected;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(TravelSpace.rSheet),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 260,
            child: Aurora(colors: [
              _blue,
              p.piscina,
              // design-lint: ignore D07
              const Color(0xFF3B8BFF),
            ]),
          ),
          // Rolável: em telas baixas o conteúdo não estoura.
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barra iOS (mesma dos outros sheets): X à direita.
                SheetBar(
                  onClose: onClose,
                  fill: _fg.withValues(alpha: 0.1),
                  ink: _fg,
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: connected
                      ? _Success(
                          key: const ValueKey('ok'),
                          days: days,
                          events: _events)
                      : _Connect(
                          key: const ValueKey('connect'),
                          status: status,
                          events: _events,
                          appConnections: appConnections,
                          onConnectApp: onConnectApp,
                        ),
                ),
                const SizedBox(height: TravelSpace.xl),
                _MainButton(
                  label: switch (status) {
                    CalendarStatus.disconnected => 'Conectar Google Agenda',
                    CalendarStatus.verifying => 'Verificando',
                    CalendarStatus.connected => 'Ver roteiro',
                  },
                  loading: status == CalendarStatus.verifying,
                  onPressed: connected ? onClose : onConnect,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Connect extends StatelessWidget {
  const _Connect({
    required this.status,
    required this.events,
    required this.appConnections,
    required this.onConnectApp,
    super.key,
  });

  final CalendarStatus status;
  final int events;
  final Map<ConnectorKind, CalendarStatus> appConnections;
  final ValueChanged<ConnectorKind>? onConnectApp;

  /// Agenda, Maps, Uber e 99 (o Gmail fica só no carrossel).
  static final _rows = [
    for (final c in TravelMock.connectors)
      if (c.kind != ConnectorKind.gmail) c,
  ];

  @override
  Widget build(BuildContext context) {
    const fg = CalendarConnectSheet._fg;
    const muted = CalendarConnectSheet._muted;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ConnectorCarousel(connectors: TravelMock.connectors),
        const SizedBox(height: TravelSpace.md),
        Text(
          'Leve o roteiro pros seus apps',
          style: TravelType.title2.copyWith(color: fg),
        ),
        const SizedBox(height: TravelSpace.sm),
        Text(
          'A Maré cria $events eventos com endereço e lembrete.',
          style: TravelType.subhead.copyWith(color: muted),
        ),
        const SizedBox(height: TravelSpace.lg),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          // Sheet 36 / padding 20 → superfícies 16 (concêntrico).
          decoration: BoxDecoration(
            color: CalendarConnectSheet._surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              for (final c in _rows)
                c.kind == ConnectorKind.googleCalendar
                    ? _ConnectorRow(connector: c, primary: true, status: status)
                    : _ConnectorRow(
                        connector: c,
                        primary: false,
                        status: appConnections[c.kind] ??
                            CalendarStatus.disconnected,
                        onConnect: onConnectApp == null
                            ? null
                            : () => onConnectApp!(c.kind),
                      ),
            ],
          ),
        ),
        const SizedBox(height: TravelSpace.md),
        Row(
          children: [
            const FaIcon(TravelIcons.shield, size: 14, color: muted),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Só usa o que o roteiro precisa. Dá pra desconectar quando quiser.',
                style: TravelType.caption.copyWith(color: muted),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ConnectorRow extends StatelessWidget {
  const _ConnectorRow({
    required this.connector,
    required this.primary,
    required this.status,
    this.onConnect,
  });

  final Connector connector;
  final bool primary;
  final CalendarStatus status;
  final VoidCallback? onConnect;

  @override
  Widget build(BuildContext context) {
    const fg = CalendarConnectSheet._fg;
    const muted = CalendarConnectSheet._muted;
    // Slot de 44 em todas as linhas: mesmo ritmo entre os ícones.
    final trailing = SizedBox(
      height: TravelSpace.tap,
      child: primary
          ? Center(
              child: switch (status) {
                CalendarStatus.verifying =>
                  const AppActivityIndicator(color: fg),
                _ => Text('Recomendado',
                    style: TravelType.caption
                        .copyWith(color: CalendarConnectSheet._blueText)),
              },
            )
          : _RowConnect(name: connector.name, status: status, onTap: onConnect),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          ConnectorTile(kind: connector.kind, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(connector.name,
                    style: TravelType.subheadStrong.copyWith(color: fg)),
                Text(
                  connector.detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TravelType.caption.copyWith(color: muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}

/// Ação da linha (Maps, Uber, 99): pílula "Conectar" → girando →
/// check (só o ícone, à direita). Alvo de toque 44 mesmo com a pílula de 32. Slot de
/// largura fixa: o texto da linha não se reorganiza a cada estado.
class _RowConnect extends StatelessWidget {
  const _RowConnect({
    required this.name,
    required this.status,
    required this.onTap,
  });

  final String name;
  final CalendarStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const fg = CalendarConnectSheet._fg;
    final child = switch (status) {
      CalendarStatus.disconnected => Semantics(
          key: const ValueKey('off'),
          button: true,
          label: 'Conectar $name',
          excludeSemantics: true,
          onTap: onTap,
          child: Pressable(
            onTap: onTap,
            child: SizedBox(
              height: TravelSpace.tap,
              child: Center(
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: fg.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(TravelSpace.rPill),
                  ),
                  child: Text('Conectar',
                      style: TravelType.footnoteStrong
                          .copyWith(color: fg, height: 1.2)),
                ),
              ),
            ),
          ),
        ),
      CalendarStatus.verifying => Semantics(
          key: const ValueKey('wait'),
          label: 'Conectando $name',
          liveRegion: true,
          excludeSemantics: true,
          // Largura da pílula: o spinner gira onde ela estava.
          child: const SizedBox(
            height: TravelSpace.tap,
            width: 84,
            child: Center(child: AppActivityIndicator(color: fg)),
          ),
        ),
      CalendarStatus.connected => Semantics(
          key: const ValueKey('on'),
          label: '$name conectado',
          liveRegion: true,
          excludeSemantics: true,
          // Só o check, encostado à direita (sem rótulo).
          child: const SizedBox(
            height: TravelSpace.tap,
            child: Center(
              child: FaIcon(TravelIcons.circleCheck, size: 18, color: fg),
            ),
          ),
        ),
    };
    return SizedBox(
      width: 96,
      child: AnimatedSwitcher(
        duration: MediaQuery.disableAnimationsOf(context)
            ? const Duration(milliseconds: 1)
            : const Duration(milliseconds: 150),
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.centerRight,
          children: [...previous, if (current != null) current],
        ),
        child: child,
      ),
    );
  }
}

class _Success extends StatelessWidget {
  const _Success({required this.days, required this.events, super.key});

  final List<ItineraryDay> days;
  final int events;

  @override
  Widget build(BuildContext context) {
    const fg = CalendarConnectSheet._fg;
    const muted = CalendarConnectSheet._muted;
    final first = [
      for (final d in days)
        for (final s in d.stops)
          (d.tab, s.time, TravelMock.roleById(s.roleId).shortName),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: TravelSpace.md),
        const Row(
          children: [
            ConnectorTile(kind: ConnectorKind.googleCalendar, size: 52),
            SizedBox(width: 14),
            FaIcon(TravelIcons.circleCheck, size: 22, color: fg),
          ],
        ),
        const SizedBox(height: TravelSpace.lg),
        Text('$events eventos criados',
            style: TravelType.title1.copyWith(color: fg)),
        const SizedBox(height: TravelSpace.xs),
        Text(
          'Na sua Google Agenda, com endereço e lembrete 1h antes.',
          style: TravelType.subhead.copyWith(color: muted),
        ),
        const SizedBox(height: TravelSpace.lg),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: CalendarConnectSheet._surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              for (final (i, e) in first.take(4).indexed) ...[
                if (i > 0) const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                        width: 4,
                        height: 32,
                        decoration: BoxDecoration(
                            color: CalendarConnectSheet._blue,
                            borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 72,
                      child: Text(
                        '${e.$1} ${e.$2}',
                        style: TravelType.footnoteStrong.copyWith(
                          color: muted,
                          fontFeatures: TravelType.tabular,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(e.$3,
                          style: TravelType.subheadStrong.copyWith(color: fg)),
                    ),
                  ],
                ),
              ],
              if (first.length > 4) ...[
                const SizedBox(height: 10),
                Text('+ ${first.length - 4} eventos',
                    style: TravelType.caption.copyWith(color: muted)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MainButton extends StatelessWidget {
  const _MainButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: CalendarConnectSheet._blue,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              CalendarConnectSheet._blue.withValues(alpha: 0.75),
          disabledForegroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          splashFactory: NoSplash.splashFactory,
          textStyle: TravelType.headline,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading) ...[
              const AppActivityIndicator(color: Colors.white),
              const SizedBox(width: 10),
            ] else if (label.startsWith('Conectar')) ...[
              const ConnectorTile(kind: ConnectorKind.googleCalendar, size: 22),
              const SizedBox(width: 10),
            ],
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}
