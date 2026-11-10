import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/features/travel_agent/data/travel_agent_mock.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';
import 'package:studio_app/features/travel_agent/presentation/view_models/travel_agent_cubit.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/agent_process.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/connector_carousel.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/mare_mark.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/ride_sheet.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/usage_sheet.dart';

/// Recuo do texto solto — alinha com o texto de dentro dos cards.
const _inset = EdgeInsets.symmetric(horizontal: TravelSpace.cardPad);

/// Conversa com a Maré dentro do sheet (fundo S0).
///
/// Grade: cards na margem de 12pt; todo texto solto a 24pt (= margem +
/// padding do card), alinhado com o texto de dentro dos cards.
class AgentConversation extends StatelessWidget {
  const AgentConversation({
    required this.state,
    required this.cubit,
    required this.scrollController,
    super.key,
  });

  final TravelAgentState state;
  final TravelAgentCubit cubit;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final msgs = state.messages;
    return ListView(
      controller: scrollController,
      // Topo 18: o conteúdo em repouso começa abaixo do fade da alça.
      padding: EdgeInsets.fromLTRB(
        TravelSpace.gutter,
        18 + SheetTopInset.of(context),
        TravelSpace.gutter,
        // Rodapé fixo: composer + linha de sugestões (76 + 8) quando ociosa.
        state.phase == AgentPhase.idle ? 284 : 200,
      ),
      children: [
        // Começo do zero: sem bloco-resumo (nada foi salvo pela pessoa; os
        // rolês vêm da Maré).
        if (state.scenario != TravelAgentScenario.vazio) ...[
          DarkBackdrop(child: _Summary(state: state)),
          const SizedBox(height: TravelSpace.xl),
        ],
        for (var i = 0; i < msgs.length; i++)
          Padding(
            padding: EdgeInsets.only(
              top: i == 0
                  ? 0
                  : (msgs[i].author == msgs[i - 1].author
                      ? TravelSpace.md
                      : TravelSpace.xl),
            ),
            child: _Appear(
              key: ValueKey(msgs[i].id),
              child: _MessageView(message: msgs[i], state: state, cubit: cubit),
            ),
          ),
        if (state.phase == AgentPhase.thinking) ...[
          const SizedBox(height: TravelSpace.lg),
          Padding(
            padding: _inset,
            child: AgentThinking(
              kind: state.thinkingKind,
              step: state.thinkingStep,
              onSkip: cubit.skipThinking,
              loop: state.scenario == TravelAgentScenario.carregando,
            ),
          ),
          if (collectActive(state.thinkingKind, state.thinkingStep)) ...[
            const SizedBox(height: TravelSpace.md),
            AgentCollectView(
                loop: state.scenario == TravelAgentScenario.carregando),
          ],
        ],
        // Sugestões ficam presas em cima do composer (AgentInputBar.above).
      ],
    );
  }
}

// ── Bloco-resumo (cor de contraste) ───────────────────────────────────────

/// Resumo vivo da viagem no azul de contraste: frase grande com destaques
/// em branco, iniciais de quem indicou e o progresso embaixo.
/// Raio 24 / padding 16 → símbolo de 16 (raio 8) concêntrico no canto.
class _Summary extends StatelessWidget {
  const _Summary({required this.state});

  final TravelAgentState state;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final on = p.onAccent;
    final soft = on.withValues(alpha: 0.68);
    final base = TravelType.summary;
    final name = TravelMock.profile.travelerName;
    final saved = state.savedRoleIds.length;
    final stops = state.days.fold(0, (n, d) => n + d.stops.length);
    final videos = TravelMock.savedRoles
        .where((r) => state.savedRoleIds.contains(r.id))
        .fold(0, (n, r) => n + r.videos.length);
    final recommenders = [
      for (final id in state.savedRoleIds.take(3))
        TravelMock.roleById(id).recommender,
    ];

    InlineSpan t(String text) =>
        TextSpan(text: text, style: base.copyWith(color: soft));
    InlineSpan b(String text) => TextSpan(
        text: text, style: base.weight(FontWeight.w500).copyWith(color: on));
    // Ícone neutro direto na superfície (sem pastilha).
    InlineSpan icon(FaIconData i) => WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.only(left: 2, right: 6),
            child: FaIcon(i, size: 15, color: on),
          ),
        );
    InlineSpan faces() => WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.only(left: 2, right: 6),
            child: _Faces(recommenders: recommenders),
          ),
        );

    final calendarOn = state.calendarStatus == CalendarStatus.connected;
    final spans = <InlineSpan>[
      if (state.phase == AgentPhase.error) ...[
        t('A Maré está '),
        b('fora do ar'),
        t('. Seus '),
        icon(TravelIcons.bookmark),
        b('$saved rolês'),
        t(' continuam salvos.'),
      ] else if (saved == 0) ...[
        t('Oi, '),
        b(name),
        t('. Você ainda '),
        b('não salvou rolês'),
        t(' — me conta o que curte e eu trago indicações de '),
        b('gente daqui.'),
      ] else if (state.phase == AgentPhase.thinking) ...[
        t('Organizando seus '),
        icon(TravelIcons.bookmark),
        b('$saved rolês'),
        t(' por '),
        icon(TravelIcons.route),
        b('dia e distância'),
        t('…'),
      ] else if (state.hasItinerary) ...[
        t('Seu fim de semana tem '),
        b('${state.days.length} dias'),
        t(' e '),
        b('$stops paradas'),
        t(' de '),
        faces(),
        b('gente daqui'),
        t('. '),
        if (calendarOn) ...[
          icon(TravelIcons.calendar),
          b('$stops eventos'),
          t(' na agenda'),
        ] else ...[
          t('Falta '),
          icon(TravelIcons.calendar),
          b('salvar na agenda'),
        ],
        if (state.swapStatus == SwapStatus.proposed) ...[
          t(' e '),
          icon(TravelIcons.rain),
          b('1 ajuste'),
          t(' pelo clima'),
        ],
        t('.'),
      ] else ...[
        t('Oi, '),
        b(name),
        t('. Você salvou '),
        icon(TravelIcons.bookmark),
        b('$saved rolês'),
        t(' de '),
        faces(),
        b('gente daqui'),
        t(' pra '),
        icon(TravelIcons.calendar),
        b('${TravelMock.profile.dates}.'),
      ],
    ];

    final meta = state.hasItinerary
        ? [
            const _Meta(TravelIcons.route, 'Roteiro', done: true),
            _Meta(TravelIcons.calendar, 'Agenda', done: calendarOn),
            _Meta(TravelIcons.taxi, 'Extras',
                done: state.addedExtras.isNotEmpty),
          ]
        : [
            const _Meta(TravelIcons.clock, 'agora'),
            _Meta(TravelIcons.bookmark, '$saved salvos'),
            _Meta(TravelIcons.circlePlay, '$videos vídeos'),
          ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TravelSpace.lg),
      decoration: BoxDecoration(
        color: p.accent,
        borderRadius: BorderRadius.circular(TravelSpace.rCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MareMark(
                size: 16,
                inverted: true,
                mood: state.phase == AgentPhase.thinking
                    ? MareMood.thinking
                    : MareMood.idle,
              ),
              const SizedBox(width: TravelSpace.sm),
              Text('Maré',
                  style: TravelType.footnoteStrong.copyWith(color: on)),
              const Spacer(),
              Text(
                state.phase == AgentPhase.thinking ? 'pensando…' : '',
                style: TravelType.footnote.copyWith(color: soft),
              ),
            ],
          ),
          const SizedBox(height: TravelSpace.md),
          Text.rich(TextSpan(children: spans)),
          const SizedBox(height: TravelSpace.lg),
          CustomPaint(
            size: const Size(double.infinity, 1),
            painter: _DottedLine(on.withValues(alpha: 0.35)),
          ),
          const SizedBox(height: TravelSpace.md),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...meta,
            ],
          ),
        ],
      ),
    );
  }
}

/// Item da linha de meta: contagem ou passo do progresso (goal-gradient).
class _Meta extends StatelessWidget {
  const _Meta(this.icon, this.label, {this.done});

  final FaIconData icon;
  final String label;

  /// null = informativo; true/false = passo do progresso.
  final bool? done;

  @override
  Widget build(BuildContext context) {
    final on = TravelPalette.of(context).onAccent;
    final strong = done ?? true;
    final color = strong ? on : on.withValues(alpha: 0.62);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(
          done == null
              ? icon
              : (done! ? TravelIcons.circleCheck : TravelIcons.circle),
          size: 13,
          color: color,
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TravelType.footnoteStrong.copyWith(
            color: color,
            fontFeatures: TravelType.tabular,
          ),
        ),
      ],
    );
  }
}

/// Rostos de quem indicou, sobrepostos na frase (ref.). Sem foto → iniciais.
class _Faces extends StatelessWidget {
  const _Faces({required this.recommenders});

  final List<Recommender> recommenders;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    const d = 24.0;
    return SizedBox(
      width: d + (recommenders.length - 1) * 14,
      height: d,
      child: Stack(
        children: [
          for (final (i, r) in recommenders.indexed)
            Positioned(
              left: i * 14.0,
              // Aro azul (cor do bloco) separa os rostos sobrepostos.
              child: Container(
                width: d,
                height: d,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: p.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: p.accent, width: 2),
                  image: r.photo == null
                      ? null
                      : DecorationImage(
                          image: AssetImage(r.photo!), fit: BoxFit.cover),
                ),
                child: r.photo != null
                    ? null
                    : Text(
                        r.initials,
                        style: TravelType.caption
                            .weight(FontWeight.w500)
                            .copyWith(fontSize: 9, color: p.onAccent),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DottedLine extends CustomPainter {
  _DottedLine(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var x = 0.0; x < size.width; x += 6) {
      canvas.drawCircle(Offset(x, 0.5), 0.9, paint);
    }
  }

  @override
  bool shouldRepaint(_DottedLine old) => old.color != color;
}

// ── Mensagens ─────────────────────────────────────────────────────────────

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.message,
    required this.state,
    required this.cubit,
  });

  final AgentMessage message;
  final TravelAgentState state;
  final TravelAgentCubit cubit;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    if (message.author == MessageAuthor.user) {
      return Align(
        alignment: Alignment.centerRight,
        // Bolha escura no tema claro: o cabeçalho troca pra texto claro
        // quando ela passa por baixo.
        child: DarkBackdrop(
          enabled: !p.isDark,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 280),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: p.inverse,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(6),
              ),
            ),
            child: Text(message.text,
                style: TravelType.callout.copyWith(color: p.onInverse)),
          ),
        ),
      );
    }
    return switch (message.kind) {
      MessageKind.process => Padding(
          padding: _inset,
          child: AgentProcessSummary(
            kind: ThinkingKind.values.byName(message.text),
          ),
        ),
      MessageKind.text => Padding(
          padding: _inset,
          child:
              Text(message.text, style: TravelType.body.copyWith(color: p.ink)),
        ),
      MessageKind.savedRoles => _SavedRoles(
          ids: message.text.isEmpty
              ? state.savedRoleIds
              : message.text.split(','),
          onOpen: cubit.openRole,
        ),
      MessageKind.itinerary => _ItineraryPreview(state: state, cubit: cubit),
      MessageKind.extras => _Extras(
          title: message.text,
          added: state.addedExtras,
          rides: state.extraRides,
          onToggle: cubit.toggleExtra,
          onChooseRide: cubit.chooseRide,
        ),
      MessageKind.calendarCta => _CalendarCta(
          status: state.calendarStatus,
          events: state.days.fold(0, (n, d) => n + d.stops.length),
          onTap: cubit.openCalendar,
        ),
      MessageKind.calendarDone ||
      MessageKind.swapDone =>
        _Confirm(text: message.text),
      MessageKind.swapProposal => _Swap(
          text: message.text,
          status: state.swapStatus,
          onAccept: cubit.acceptSwap,
          onDecline: cubit.declineSwap,
        ),
      MessageKind.error => _Error(text: message.text, onRetry: cubit.retry),
    };
  }
}

/// Confirmação: ícone neutro + texto direto na superfície.
class _Confirm extends StatelessWidget {
  const _Confirm({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Padding(
      padding: _inset,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: FaIcon(TravelIcons.circleCheck, size: 15, color: p.ink),
          ),
          const SizedBox(width: TravelSpace.sm),
          Expanded(
              child:
                  Text(text, style: TravelType.subhead.copyWith(color: p.ink))),
        ],
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.text, required this.onRetry});

  final String text;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return SolidBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(TravelIcons.rain, size: 15, color: p.ink),
              const SizedBox(width: TravelSpace.sm),
              Text('Maré fora do ar',
                  style: TravelType.headline.copyWith(color: p.ink)),
            ],
          ),
          const SizedBox(height: TravelSpace.xs),
          Text(text, style: TravelType.subhead.copyWith(color: p.inkMuted)),
          const SizedBox(height: TravelSpace.md),
          PrimaryButton(label: 'Tentar de novo', onPressed: onRetry),
        ],
      ),
    );
  }
}

// ── Rolês salvos (cards compactos) ────────────────────────────────────────

class _SavedRoles extends StatelessWidget {
  const _SavedRoles({required this.ids, required this.onOpen});

  final List<String> ids;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 224,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: ids.length,
        separatorBuilder: (_, __) => const SizedBox(width: TravelSpace.sm),
        itemBuilder: (context, i) {
          final r = TravelMock.roleById(ids[i]);
          return RoleCompactCard(role: r, onTap: () => onOpen(r.id));
        },
      ),
    );
  }
}

/// Card visual do rolê — único lugar (além do card aberto) com título em
/// Oswald. Raio 24 / padding 8 → foto com raio 16 (concêntrico).
class RoleCompactCard extends StatelessWidget {
  const RoleCompactCard({required this.role, required this.onTap, super.key});

  final Role role;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Semantics(
      button: true,
      label: '${role.name}, indicado por ${role.recommender.name}',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: Container(
          width: 188,
          padding: const EdgeInsets.all(TravelSpace.sm),
          decoration: BoxDecoration(
            color: p.s1,
            borderRadius: BorderRadius.circular(TravelSpace.rCard),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 112,
                clipBehavior: Clip.antiAlias,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(16)),
                foregroundDecoration: imageOutline(p, 16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(role.photos.first.asset, fit: BoxFit.cover),
                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: Container(
                        height: 22,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius:
                              BorderRadius.circular(TravelSpace.rPill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const FaIcon(TravelIcons.play,
                                size: 8, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(
                              '${role.videos.length} vídeos',
                              style: TravelType.caption
                                  .copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 10, 4, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.shortName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TravelType.cardTitle.copyWith(color: p.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'por ${role.recommender.name.split(' ').first}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TravelType.footnote.copyWith(color: p.inkMuted),
                    ),
                    const SizedBox(height: 6),
                    CategoryTag(role.category, compact: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Roteiro por dia (timeline ↔ mapa) ─────────────────────────────────────

/// Prévia do roteiro no chat: as primeiras paradas e o acesso ao
/// calendário completo (visão de semana).
class _ItineraryPreview extends StatelessWidget {
  const _ItineraryPreview({required this.state, required this.cubit});

  final TravelAgentState state;
  final TravelAgentCubit cubit;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final stops = [
      for (final d in state.days)
        for (final st in d.stops) (d, st),
    ];
    return SolidBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Seu roteiro',
                  style: TravelType.headline.copyWith(color: p.ink)),
              const Spacer(),
              Text(
                '${state.days.length} dias',
                style: TravelType.footnote.copyWith(color: p.inkMuted),
              ),
            ],
          ),
          const SizedBox(height: TravelSpace.sm),
          for (final (d, st) in stops.take(3))
            _PreviewRow(
              day: d.tab,
              time: st.time,
              role: TravelMock.roleById(st.roleId),
              selected: state.selectedRoleId == st.roleId,
              onTap: () => state.mapOpen
                  ? cubit.selectRole(st.roleId)
                  : cubit.openRole(st.roleId),
            ),
          const SizedBox(height: TravelSpace.sm),
          // Dois botões: empilhados.
          if (!state.mapOpen) ...[
            SecondaryButton(
              label: 'Ver no mapa',
              icon: TravelIcons.map,
              onPressed: cubit.openMap,
            ),
            const SizedBox(height: TravelSpace.sm),
          ],
          SecondaryButton(
            label: 'Ver roteiro completo',
            icon: TravelIcons.calendar,
            onPressed: cubit.openItinerary,
          ),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.day,
    required this.time,
    required this.role,
    required this.selected,
    required this.onTap,
  });

  final String day;
  final String time;
  final Role role;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? p.accentSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(TravelSpace.rInner),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(day,
                      style: TravelType.caption.copyWith(color: p.inkMuted)),
                  Text(
                    time,
                    style: TravelType.footnoteStrong.copyWith(
                      color: p.ink,
                      fontFeatures: TravelType.tabular,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 24,
              child: Center(
                  child: FaIcon(categoryIcon(role.category),
                      size: 13, color: p.inkMuted)),
            ),
            const SizedBox(width: TravelSpace.sm),
            Expanded(
              child: Text(
                role.shortName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TravelType.subheadStrong.copyWith(color: p.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Extras pagos (carrossel de cards) ─────────────────────────────────────

class _Extras extends StatelessWidget {
  const _Extras({
    required this.title,
    required this.added,
    required this.rides,
    required this.onToggle,
    required this.onChooseRide,
  });

  final String title;
  final Set<String> added;
  final Map<String, String> rides;
  final ValueChanged<String> onToggle;
  final void Function(String extraId, String rideId) onChooseRide;

  /// Transfer ainda não adicionado: "+" abre a comparação 99 × Uber.
  /// Os outros extras (e remover) seguem no toggle simples.
  Future<void> _onTap(BuildContext context, TravelExtra e) async {
    final options = TravelMock.ridesByPrice;
    if (!e.isTransfer || added.contains(e.id) || options.isEmpty) {
      onToggle(e.id);
      return;
    }
    final rideId = await showRideSheet(context, extra: e, options: options);
    if (rideId != null) onChooseRide(e.id, rideId);
  }

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: _inset,
          child: Text(title,
              style: TravelType.section.copyWith(color: p.inkMuted)),
        ),
        const SizedBox(height: TravelSpace.sm),
        EdgeFadeScroll(
          height: 172,
          padding: 0,
          itemCount: TravelMock.extras.length,
          itemBuilder: (context, i) {
            final e = TravelMock.extras[i];
            return _ExtraCard(
              extra: e,
              added: added.contains(e.id),
              ride: e.isTransfer ? TravelMock.rideById(rides[e.id]) : null,
              fromPrice:
                  e.isTransfer ? TravelMock.ridesByPrice.firstOrNull : null,
              onToggle: () => _onTap(context, e),
            );
          },
        ),
        const SizedBox(height: TravelSpace.sm),
        Padding(
          padding: _inset,
          child: Text(
            'Cancele grátis até 2h antes',
            style: TravelType.caption.copyWith(color: p.inkMuted),
          ),
        ),
      ],
    );
  }
}

/// Card 24 / padding 12. Preço em destaque e botão "+" compacto (36).
/// Transfer: antes de escolher mostra o preço do mais em conta;
/// depois, a categoria e o preço da corrida escolhida. Glifo neutro sempre
/// (mesmo estilo dos vizinhos no carrossel; o app vai no texto).
class _ExtraCard extends StatelessWidget {
  const _ExtraCard({
    required this.extra,
    required this.added,
    required this.onToggle,
    this.ride,
    this.fromPrice,
  });

  final TravelExtra extra;
  final bool added;
  final VoidCallback onToggle;

  /// Corrida escolhida (só transfer adicionado).
  final RideOption? ride;

  /// Opção mais em conta (transfer ainda sem escolha).
  final RideOption? fromPrice;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Container(
      width: 220,
      padding: const EdgeInsets.all(TravelSpace.cardPad),
      decoration: BoxDecoration(
        color: p.s1,
        borderRadius: BorderRadius.circular(TravelSpace.rCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(extra.isTransfer ? TravelIcons.taxi : TravelIcons.group,
              size: 17, color: p.ink),
          const SizedBox(height: TravelSpace.md),
          Text(
            extra.title,
            maxLines: 2,
            style: TravelType.subheadStrong.copyWith(color: p.ink, height: 1.3),
          ),
          const SizedBox(height: 2),
          Text(
            ride != null ? '${extra.detail}, ${ride!.name}' : extra.detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TravelType.footnote.copyWith(color: p.inkMuted),
          ),
          const Spacer(),
          Row(
            children: [
              // Antes de escolher: o preço da opção mais em conta, sem rótulo.
              Text(
                ride?.priceLabel ?? fromPrice?.priceLabel ?? extra.price,
                style: TravelType.title3
                    .copyWith(color: p.ink, fontFeatures: TravelType.tabular),
              ),
              const Spacer(),
              Semantics(
                button: true,
                selected: added,
                label: added
                    ? 'Remover ${extra.title}'
                    : 'Adicionar ${extra.title}',
                excludeSemantics: true,
                onTap: onToggle,
                child: Pressable(
                  onTap: onToggle,
                  // Alvo 44 com o círculo de 36 centrado.
                  child: SizedBox.square(
                    dimension: TravelSpace.tap,
                    child: Center(
                      child: AnimatedContainer(
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? const Duration(milliseconds: 1)
                            : const Duration(milliseconds: 150),
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: added ? p.accent : p.s2,
                          shape: BoxShape.circle,
                        ),
                        child: FaIcon(
                          added ? TravelIcons.check : TravelIcons.plus,
                          size: 14,
                          color: added ? p.onAccent : p.ink,
                        ),
                      ),
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

// ── CTA da agenda ─────────────────────────────────────────────────────────

class _CalendarCta extends StatelessWidget {
  const _CalendarCta(
      {required this.status, required this.events, required this.onTap});

  final CalendarStatus status;
  final int events;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final connected = status == CalendarStatus.connected;
    return SolidBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ConnectorTile(kind: ConnectorKind.googleCalendar, size: 44),
              const SizedBox(width: TravelSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      connected
                          ? '$events eventos criados'
                          : 'Salvar na Google Agenda',
                      style: TravelType.headline.copyWith(color: p.ink),
                    ),
                    Text(
                      connected
                          ? 'Com endereço e lembrete 1h antes'
                          : '$events eventos com endereço e lembrete',
                      style: TravelType.footnote.copyWith(color: p.inkMuted),
                    ),
                  ],
                ),
              ),
              if (connected)
                FaIcon(TravelIcons.circleCheck, size: 18, color: p.ink),
            ],
          ),
          if (!connected) ...[
            const SizedBox(height: TravelSpace.md),
            PrimaryButton(
              label: 'Conectar e salvar',
              icon: TravelIcons.calendar,
              onPressed: onTap,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Troca por clima (etapa 06) ────────────────────────────────────────────

class _Swap extends StatelessWidget {
  const _Swap({
    required this.text,
    required this.status,
    required this.onAccept,
    required this.onDecline,
  });

  final String text;
  final SwapStatus status;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final from = TravelMock.roleById(TravelMock.swapFromId);
    final to = TravelMock.roleById(TravelMock.swapToId);
    return SolidBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(TravelIcons.rain, size: 15, color: p.ink),
              const SizedBox(width: TravelSpace.sm),
              Text('Ajuste pelo clima',
                  style: TravelType.headline.copyWith(color: p.ink)),
            ],
          ),
          const SizedBox(height: TravelSpace.xs),
          Text(text, style: TravelType.subhead.copyWith(color: p.ink)),
          const SizedBox(height: TravelSpace.md),
          // Mesma altura nos dois cards (o nome pode quebrar em 2 linhas).
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                    child: _SwapThumb(
                        role: from, struck: status == SwapStatus.accepted)),
                SizedBox(
                  width: 32,
                  child: Center(
                    child: FaIcon(TravelIcons.arrowRight,
                        size: 13, color: p.inkMuted),
                  ),
                ),
                Expanded(child: _SwapThumb(role: to, highlight: true)),
              ],
            ),
          ),
          if (status == SwapStatus.proposed) ...[
            const SizedBox(height: TravelSpace.md),
            // Dois botões: empilhados, primário embaixo.
            SecondaryButton(label: 'Manter', onPressed: onDecline),
            const SizedBox(height: TravelSpace.sm),
            PrimaryButton(label: 'Trocar', onPressed: onAccept),
          ],
        ],
      ),
    );
  }
}

/// Miniatura 12 / padding 4 → foto 8 (concêntrico).
class _SwapThumb extends StatelessWidget {
  const _SwapThumb(
      {required this.role, this.highlight = false, this.struck = false});

  final Role role;
  final bool highlight;
  final bool struck;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Opacity(
      opacity: struck ? 0.5 : 1,
      child: Container(
        padding: const EdgeInsets.all(TravelSpace.xs),
        decoration: BoxDecoration(
          color: highlight ? p.accentSoft : p.s0,
          borderRadius: BorderRadius.circular(TravelSpace.rInner),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 64,
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(TravelSpace.rTight)),
              foregroundDecoration: imageOutline(p, TravelSpace.rTight),
              child: Image.asset(role.photos.first.asset, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 6, 4, 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.shortName,
                    maxLines: 2,
                    style: TravelType.footnoteStrong.copyWith(
                      color: p.ink,
                      decoration: struck ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Text(
                    role.covered ? 'Coberto' : 'Ao ar livre',
                    style: TravelType.caption.copyWith(color: p.inkMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sugestões (Hick: ≤5, mais relevante primeiro) ─────────────────────────

/// Cards só com borda fina, sem fundo (some na superfície), raio do
/// composer (28). Linha rolável, sem título, presa logo acima do composer
/// e sangrando até a borda da tela.
class AgentSuggestions extends StatelessWidget {
  const AgentSuggestions({required this.onTap, super.key});

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final (i, s) in TravelMock.suggestions.indexed) ...[
            if (i > 0) const SizedBox(width: TravelSpace.sm),
            _SuggestionCard(label: s, onTap: () => onTap(s)),
          ],
        ],
      ),
    );
  }
}

/// Primeira palavra em `ink` 500, resto em `inkMuted` — lê como verbo +
/// complemento, em até duas linhas.
class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final cut = label.indexOf(' ');
    final head = cut < 0 ? label : label.substring(0, cut);
    final tail = cut < 0 ? '' : label.substring(cut);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: Container(
          width: 148,
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TravelSpace.rComposer),
            border: Border.all(color: p.ink.withValues(alpha: 0.1)),
          ),
          child: Text.rich(
            TextSpan(children: [
              TextSpan(
                  text: head,
                  style: TravelType.subheadStrong.copyWith(color: p.ink)),
              TextSpan(
                  text: tail,
                  style: TravelType.subhead.copyWith(color: p.inkMuted)),
            ]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

/// Entrada de mensagem: fade + 8pt de deslocamento, ease-out.
/// Mensagens já vistas não reanimam; Reduce Motion → aparece direto.
class _Appear extends StatefulWidget {
  const _Appear({required this.child, super.key});

  final Widget child;

  @override
  State<_Appear> createState() => _AppearState();
}

class _AppearState extends State<_Appear> with SingleTickerProviderStateMixin {
  static final _seen = <Key>{};

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final key = widget.key;
    final seen = key != null && !_seen.add(key);
    if (seen || MediaQuery.disableAnimationsOf(context)) {
      _c.value = 1;
    } else if (_c.value == 0 && !_c.isAnimating) {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    return FadeTransition(
      opacity: a,
      child: AnimatedBuilder(
        animation: a,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, 8 * (1 - a.value)),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

// ── Composer ──────────────────────────────────────────────────────────────

/// Composer fixo no rodapé do sheet (ref.: composer de chat compacto).
/// Raio 28 / padding 8 → botões de 40 (raio 20) concêntricos.
/// Anel de uso ao lado do enviar (ref. app do Claude). Nada embaixo do
/// composer.
class AgentInputBar extends StatefulWidget {
  const AgentInputBar({
    required this.enabled,
    required this.used,
    required this.onSend,
    this.autofocus = false,
    this.hint = 'Peça um ajuste à Maré…',
    this.safeBottom = true,
    this.above,
    super.key,
  });

  /// Linha presa logo acima do campo (sugestões da conversa). Nunca embaixo.
  final Widget? above;

  final bool enabled;
  final int used;
  final ValueChanged<String> onSend;

  /// Placeholder do campo (a abertura do zero pede outra frase).
  final String hint;

  /// Soma a área segura de baixo (falso quando não está no rodapé).
  final bool safeBottom;

  /// Abre já com o teclado (composer chamado pelo "Pedir ajuste").
  final bool autofocus;

  @override
  State<AgentInputBar> createState() => _AgentInputBarState();
}

class _AgentInputBarState extends State<AgentInputBar> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() {
    if (_text.text.trim().isEmpty) return;
    widget.onSend(_text.text);
    _text.clear();
  }

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    // Tamanho de texto de composer de chat (ref.): 16pt regular.
    final field = TravelType.callout;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        TravelSpace.gutter,
        TravelSpace.sm,
        TravelSpace.gutter,
        6 + (widget.safeBottom ? MediaQuery.paddingOf(context).bottom : 0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.above != null) ...[
            widget.above!,
            const SizedBox(height: TravelSpace.sm),
          ],
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: p.s1,
              // Sem borda: separa do fundo só pela camada (s1 sobre s0).
              borderRadius: BorderRadius.circular(TravelSpace.rComposer),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  // Texto alinhado ao centro óptico do primeiro ícone.
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: TextField(
                    controller: _text,
                    autofocus: widget.autofocus,
                    enabled: widget.enabled,
                    minLines: 1,
                    maxLines: 3,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _submit(),
                    style: field.copyWith(color: p.ink, height: 1.35),
                    cursorColor: p.accent,
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle:
                          field.copyWith(color: p.inkMuted, height: 1.35),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ),
                const SizedBox(height: TravelSpace.xs),
                Row(
                  children: [
                    // Ações secundárias: ghost (sem fundo).
                    _RoundButton(
                      label: 'Anexar foto',
                      ghost: true,
                      onTap: widget.enabled ? () {} : null,
                      child: _AttachGlyph(
                          color: p.inkMuted, badge: p.ink, ring: p.s1),
                    ),
                    _RoundButton(
                      label: 'Falar com a Maré',
                      ghost: true,
                      onTap: widget.enabled ? () {} : null,
                      child:
                          FaIcon(TravelIcons.mic, size: 16, color: p.inkMuted),
                    ),
                    const Spacer(),
                    UsageRing(
                      used: widget.used,
                      limit: TravelMock.messageLimit,
                      onTap: () => showUsageSheet(context, used: widget.used),
                    ),
                    const SizedBox(width: TravelSpace.xs),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _text,
                      builder: (context, v, _) {
                        final ready =
                            widget.enabled && v.text.trim().isNotEmpty;
                        return _RoundButton(
                          label: 'Enviar',
                          filled: ready ? p.accent : null,
                          onTap: ready ? _submit : null,
                          child: FaIcon(
                            TravelIcons.send,
                            size: 16,
                            color: ready ? p.onAccent : p.inkMuted,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Botão circular 40pt do composer.
/// Padrão: neutro secundário (fundo cinza). [ghost]: sem fundo.
/// [filled]: cor de ação (enviar com texto).
class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.label,
    required this.child,
    required this.onTap,
    this.filled,
    this.ghost = false,
  });

  final String label;
  final Widget child;
  final VoidCallback? onTap;
  final Color? filled;
  final bool ghost;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ?? (ghost ? Colors.transparent : p.s2),
            shape: BoxShape.circle,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Glifo "foto +" (ref.): a foto fica no centro óptico; o "+" sobra.
class _AttachGlyph extends StatelessWidget {
  const _AttachGlyph(
      {required this.color, required this.badge, required this.ring});

  final Color color;
  final Color badge;
  final Color ring;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 18,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          FaIcon(TravelIcons.image, size: 16, color: color),
          Positioned(
            right: -5,
            bottom: -5,
            child: Container(
              width: 13,
              height: 13,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: ring, shape: BoxShape.circle),
              child: FaIcon(TravelIcons.plus, size: 8, color: badge),
            ),
          ),
        ],
      ),
    );
  }
}
