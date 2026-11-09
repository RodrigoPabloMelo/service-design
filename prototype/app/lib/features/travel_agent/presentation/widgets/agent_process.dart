import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:studio_app/features/travel_agent/data/travel_agent_mock.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/mare_mark.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_tokens.dart';
import 'package:studio_app/features/travel_agent/presentation/widgets/travel_ui.dart';

List<ProcessStep> processFor(ThinkingKind kind) => kind == ThinkingKind.collect
    ? TravelMock.collectProcess
    : TravelMock.quickProcess;

/// O passo ativo mostra a visão de agente (recolher ou organizar)?
bool collectActive(ThinkingKind kind, int step) {
  final steps = processFor(kind);
  final s = steps[step.clamp(0, steps.length - 1)];
  return s.collect || s.organize;
}

int secondsFor(ThinkingKind kind) => ((kind == ThinkingKind.collect
                ? TravelMock.collectTimeline
                : TravelMock.quickTimeline)
            .last /
        1000)
    .round();

// ═══════════════════════════════════════════════════════════════════════════
// "Pensando" ao vivo
// ═══════════════════════════════════════════════════════════════════════════

/// Linha do tempo do agente enquanto pensa.
///
/// Estados de cada passo:
/// - pendente → ainda não aparece;
/// - ativo → símbolo animado, título com brilho correndo, detalhe e fontes;
///   no passo `collect`, a visão de agente (cursor recolhendo na pasta);
/// - feito → marcador pontual, tudo em cinza.
class AgentThinking extends StatelessWidget {
  const AgentThinking({
    required this.kind,
    required this.step,
    required this.onSkip,
    this.loop = false,
    super.key,
  });

  final ThinkingKind kind;
  final int step;
  final VoidCallback onSkip;

  /// Repete a visão de agente (cenário "Carregando" do hub).
  final bool loop;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final steps = processFor(kind);
    final current = step.clamp(0, steps.length - 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: TravelSpace.tap,
          child: Row(
            children: [
              const MareMark(size: 20, mood: MareMood.thinking),
              const SizedBox(width: TravelSpace.md),
              Shimmer(
                child: Text('Pensando',
                    style: TravelType.subheadStrong.copyWith(color: p.ink)),
              ),
              const Spacer(),
              Semantics(
                button: true,
                label: 'Pular e responder agora',
                excludeSemantics: true,
                onTap: onSkip,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onSkip,
                  child: SizedBox(
                    height: TravelSpace.tap,
                    child: Center(
                      child: Text(
                        'Pular',
                        style: TravelType.footnoteStrong
                            .copyWith(color: p.accentText),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: TravelSpace.xs),
        for (var i = 0; i <= current; i++)
          _StepTile(
            step: steps[i],
            active: i == current,
            last: i == current,
            loop: loop,
          ),
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.step,
    required this.active,
    required this.last,
    this.loop = false,
  });

  final ProcessStep step;
  final bool active;
  final bool last;
  final bool loop;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final titleStyle = active
        ? TravelType.subheadStrong.copyWith(color: p.ink)
        : TravelType.subhead.copyWith(color: p.inkMuted);
    final Widget marker = !active
        ? Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: p.inkMuted.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          )
        : step.writing
            ? const TypingDots()
            : const MareMark(size: 16, mood: MareMood.thinking);

    return Stack(
      children: [
        // Trilho vertical ligando os passos (conectividade).
        if (!last)
          Positioned(
            left: 9.5,
            top: 28,
            bottom: 2,
            child: Container(width: 1, color: p.ink.withValues(alpha: 0.12)),
          ),
        Padding(
          padding: EdgeInsets.only(bottom: last ? 0 : TravelSpace.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 20, height: 24, child: Center(child: marker)),
              const SizedBox(width: TravelSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 24,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: active
                            ? Shimmer(
                                child: Text(step.title, style: titleStyle))
                            : Text(step.title, style: titleStyle),
                      ),
                    ),
                    if (step.detail.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        step.detail,
                        style: TravelType.footnote.copyWith(
                          color:
                              p.inkMuted.withValues(alpha: active ? 1 : 0.75),
                        ),
                      ),
                    ],
                    if (step.sources.isNotEmpty) ...[
                      const SizedBox(height: TravelSpace.sm),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final s in step.sources)
                            _SourceChip(s, muted: !active)
                        ],
                      ),
                    ],
                    if (step.collect && !active) ...[
                      const SizedBox(height: TravelSpace.sm),
                      const FolderSummary(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Fonte consultada: pílula com contorno, sem preenchimento.
class _SourceChip extends StatelessWidget {
  const _SourceChip(this.label, {this.muted = false});

  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TravelSpace.rPill),
        border: Border.all(color: p.ink.withValues(alpha: muted ? 0.08 : 0.14)),
      ),
      // widthFactor 1: a pílula abraça o texto (não estica no Wrap).
      child: Center(
        widthFactor: 1,
        child: Text(
          label,
          style: TravelType.caption.copyWith(
            color: p.inkMuted.withValues(alpha: muted ? 0.75 : 1),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Visão de agente — cursor recolhendo rolês do catálogo na pasta
// ═══════════════════════════════════════════════════════════════════════════

/// Mini-tela do agente em duas fases contínuas (mesmo card, sem corte):
///
/// **Recolher** (passo `collect`) — grade do catálogo; o cursor "Maré" leva
/// cada rolê até a pasta. Cada rolê leva [_perItemMs]:
/// 1. mover (0–38%) — cursor vai até o card;
/// 2. clicar (38–48%) — cursor encolhe, card ganha anel azul;
/// 3. arrastar (48–86%) — miniatura segue o cursor até a boca da pasta;
/// 4. soltar (86–100%) — a frente da pasta abre, a foto entra, contador sobe.
///
/// **Organizar** (passo `organize`) — a grade vira um mini calendário
/// Sex/Sáb/Dom; o cursor tira cada rolê da pasta e encaixa no horário real
/// do roteiro ([_placeMs] por rolê).
///
/// A pasta é skeuomórfica (pedido do designer): fundo com aba, fotos
/// impressas aparecendo e frente que inclina ao receber/entregar.
/// Reduce Motion → estado final (calendário cheio), parado.
class AgentCollectView extends StatefulWidget {
  const AgentCollectView({this.loop = false, super.key});

  final bool loop;

  @override
  State<AgentCollectView> createState() => _AgentCollectViewState();
}

const _perItemMs = 500;
const _holdMs = 150;
const _swapMs = 400;
const _placeMs = 330;
const _settleMs = 250;
const _loopPauseMs = 900;

/// Posição de cada rolê salvo na grade 4×3 (o resto são outros itens do
/// catálogo) — espalhado para o cursor percorrer a tela.
const _slotOf = [5, 0, 10, 3, 8, 1, 6, 11];
const _fillerSlots = [2, 4, 7, 9];

/// "16h30" → 16.5.
double _hourOf(String time) {
  final m = RegExp(r'(\d+)h(\d+)?').firstMatch(time);
  if (m == null) return 12;
  return int.parse(m.group(1)!) + int.parse(m.group(2) ?? '0') / 60;
}

/// Lugar de cada rolê no calendário, na ordem do roteiro.
final _placements = [
  for (final (d, day) in TravelMock.itinerary.indexed)
    for (final s in day.stops)
      (role: TravelMock.roleById(s.roleId), day: d, hour: _hourOf(s.time)),
];

/// "Sexta, 14 nov" → "14".
String _dayNumber(ItineraryDay d) =>
    RegExp(r'\d+').firstMatch(d.title)?.group(0) ?? '';

class _AgentCollectViewState extends State<AgentCollectView>
    with SingleTickerProviderStateMixin {
  late final int _n = TravelMock.collectOrder.length;
  late final int _m = _placements.length;
  late final int _placeStart = _n * _perItemMs + _holdMs + _swapMs;
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(
      milliseconds: _placeStart +
          _m * _placeMs +
          (widget.loop ? _loopPauseMs : _settleMs),
    ),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.value = 1;
    } else if (!_c.isAnimating && _c.value == 0) {
      widget.loop ? _c.repeat() : _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final roles = [
      for (final id in TravelMock.collectOrder) TravelMock.roleById(id)
    ];
    const ease = Curves.easeInOutCubic;
    return Container(
      padding: const EdgeInsets.all(TravelSpace.cardPad),
      decoration: BoxDecoration(
        color: p.s1,
        borderRadius: BorderRadius.circular(TravelSpace.rCard),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          const gap = 6.0;
          final w = box.maxWidth;
          final cell = (w - gap * 3) / 4;
          const gridTop = 30.0;
          final gridH = cell * 3 + gap * 2;
          final folderTop = gridTop + gridH + 12;
          const folderW = 104.0;
          const folderH = 84.0;
          // Boca da pasta: onde as fotos entram e de onde saem.
          final mouth = Offset(folderW / 2, folderTop + folderH * 0.3);
          Offset slotOrigin(int slot) => Offset(
              (slot % 4) * (cell + gap), gridTop + (slot ~/ 4) * (cell + gap));
          Offset slotCenter(int slot) =>
              slotOrigin(slot) + Offset(cell / 2, cell / 2);

          // Calendário: 3 colunas no lugar da grade.
          final colW = (w - gap * 2) / 3;
          const headH = 24.0;
          const chipH = 28.0;
          const bodyTop = gridTop + headH;
          final bodyH = gridH - headH;
          Offset chipOrigin(int j) {
            final pl = _placements[j];
            final y = bodyTop +
                4 +
                ((pl.hour - 9) / (23 - 9)).clamp(0.0, 1.0) *
                    (bodyH - 8 - chipH);
            return Offset(pl.day * (colW + gap) + 4, y);
          }

          Offset chipCenter(int j) =>
              chipOrigin(j) + Offset((colW - 8) / 2, chipH / 2);

          return SizedBox(
            height: folderTop + folderH,
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) {
                final ms = _c.value * _c.duration!.inMilliseconds;

                // ── Fase 1: recolher ─────────────────────────────────────
                final collectTotal = _n * _perItemMs;
                final t = ms.clamp(0, collectTotal).toDouble();
                final k = math.min((t / _perItemMs).floor(), _n);
                final u = k >= _n ? 1.0 : (t - k * _perItemMs) / _perItemMs;
                final collecting = k < _n;
                bool collected(int j) => j < k || (j == k && u >= 0.48);
                final count = collecting ? k + (u >= 0.9 ? 1 : 0) : _n;
                final target = collecting && u >= 0.38 && u < 0.48 ? k : -1;

                // ── Troca grade → calendário ─────────────────────────────
                final swapStart = collectTotal + _holdMs;
                final swap = ease
                    .transform(((ms - swapStart) / _swapMs).clamp(0.0, 1.0));

                // ── Fase 2: organizar ────────────────────────────────────
                final pt = ms - _placeStart;
                final pk = pt < 0 ? -1 : math.min((pt / _placeMs).floor(), _m);
                final pu =
                    pk < 0 || pk >= _m ? 0.0 : (pt - pk * _placeMs) / _placeMs;
                final organizing = pk >= 0 && pk < _m;
                bool placed(int j) => j < pk || (j == pk && pu >= 0.8);
                final placedCount =
                    pk < 0 ? 0 : (pk >= _m ? _m : pk + (pu >= 0.8 ? 1 : 0));
                final done = pk >= _m;

                // Cursor, miniatura arrastada e abertura da pasta.
                var cursor = Offset(w / 2, gridTop - 8);
                var press = 1.0;
                var ghost = 0.0;
                var flap = 0.0;
                String? ghostAsset;
                var ghostChip = false;
                if (collecting) {
                  final prev = k == 0 ? Offset(w / 2, gridTop - 8) : mouth;
                  final cellC = slotCenter(_slotOf[k]);
                  ghostAsset = roles[k].photos.first.asset;
                  if (u < 0.38) {
                    cursor =
                        Offset.lerp(prev, cellC, ease.transform(u / 0.38))!;
                  } else if (u < 0.48) {
                    cursor = cellC;
                    press = 1 - 0.12 * math.sin(math.pi * (u - 0.38) / 0.10);
                  } else if (u < 0.86) {
                    cursor = Offset.lerp(
                        cellC, mouth, ease.transform((u - 0.48) / 0.38))!;
                    ghost = 1;
                    flap = ((u - 0.7) / 0.16).clamp(0.0, 1.0);
                  } else {
                    cursor = mouth;
                    final d = (u - 0.86) / 0.14;
                    ghost = 1 - d;
                    flap = math.sin(math.pi * (0.5 + d / 2));
                  }
                } else if (organizing) {
                  final prev = pk == 0 ? mouth : chipCenter(pk - 1);
                  final slot = chipCenter(pk);
                  ghostAsset = _placements[pk].role.photos.first.asset;
                  ghostChip = true;
                  if (pu < 0.25) {
                    cursor =
                        Offset.lerp(prev, mouth, ease.transform(pu / 0.25))!;
                    flap = pu / 0.25;
                  } else if (pu < 0.35) {
                    cursor = mouth;
                    press = 1 - 0.12 * math.sin(math.pi * (pu - 0.25) / 0.10);
                    flap = 1;
                  } else if (pu < 0.8) {
                    final d = (pu - 0.35) / 0.45;
                    cursor = Offset.lerp(mouth, slot, ease.transform(d))!;
                    ghost = 1;
                    flap = (1 - d * 2).clamp(0.0, 1.0);
                  } else {
                    cursor = slot;
                  }
                } else {
                  // Entre fases e no fim: cursor descansa ao lado da pasta.
                  cursor = done
                      ? chipCenter(_m - 1) + const Offset(10, 6)
                      : mouth + const Offset(30, -4);
                }

                // Fotos dentro da pasta: as últimas recolhidas; esvazia
                // conforme o calendário enche.
                final inFolder = [
                  for (var j = math.max(0, count - 3); j < count; j++)
                    roles[j].photos.first.asset,
                ];
                final left = _m - placedCount;
                final folderPhotos = pk < 0
                    ? inFolder
                    : inFolder.take(math.min(3, left)).toList();

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Cabeçalho da mini-tela.
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      height: 20,
                      child: Row(
                        children: [
                          for (var d = 0; d < 3; d++)
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: p.ink.withValues(alpha: 0.14),
                                shape: BoxShape.circle,
                              ),
                            ),
                          const SizedBox(width: 4),
                          Text(
                            swap < 0.5 ? 'catálogo' : 'calendário',
                            style:
                                TravelType.caption.copyWith(color: p.inkMuted),
                          ),
                          const Spacer(),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: done ? p.inkMuted : p.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            done ? 'concluído' : 'ao vivo',
                            style: TravelType.caption.copyWith(
                              color: done ? p.inkMuted : p.accentText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Grade do catálogo (some na troca).
                    if (swap < 1)
                      Positioned.fill(
                        child: Opacity(
                          opacity: 1 - swap,
                          child: Transform.scale(
                            scale: 1 - 0.04 * swap,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                for (var j = 0; j < _n; j++)
                                  _gridCell(
                                    origin: slotOrigin(_slotOf[j]),
                                    size: cell,
                                    asset: roles[j].photos.first.asset,
                                    collected: collected(j),
                                    target: target == j,
                                    p: p,
                                  ),
                                for (final (i, slot) in _fillerSlots.indexed)
                                  _gridCell(
                                    origin: slotOrigin(slot),
                                    size: cell,
                                    asset: TravelMock.catalogFillers[i],
                                    collected: false,
                                    target: false,
                                    p: p,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    // Calendário (entra na troca).
                    if (swap > 0)
                      Positioned.fill(
                        child: Opacity(
                          opacity: swap,
                          child: Transform.scale(
                            scale: 0.96 + 0.04 * swap,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                for (final (d, day)
                                    in TravelMock.itinerary.indexed) ...[
                                  Positioned(
                                    left: d * (colW + gap),
                                    width: colW,
                                    top: gridTop,
                                    height: headH - 4,
                                    child: Center(
                                      child: Text(
                                        '${day.tab} ${_dayNumber(day)}',
                                        style: TravelType.caption
                                            .weight(FontWeight.w500)
                                            .copyWith(
                                              color: p.ink,
                                              fontFeatures: TravelType.tabular,
                                            ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: d * (colW + gap),
                                    width: colW,
                                    top: bodyTop,
                                    height: bodyH,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: p.s0,
                                        borderRadius: BorderRadius.circular(
                                            TravelSpace.rInner),
                                      ),
                                    ),
                                  ),
                                ],
                                for (var j = 0; j < _m; j++)
                                  if (placed(j))
                                    Positioned(
                                      left: chipOrigin(j).dx,
                                      top: chipOrigin(j).dy,
                                      width: colW - 8,
                                      height: chipH,
                                      child: _PopIn(
                                        child: _EventChip(
                                          asset: _placements[j]
                                              .role
                                              .photos
                                              .first
                                              .asset,
                                          label: _placements[j].role.shortName,
                                        ),
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    // Pasta skeuomórfica + legenda.
                    Positioned(
                      left: 0,
                      right: 0,
                      top: folderTop,
                      height: folderH,
                      child: Row(
                        children: [
                          SizedBox(
                            width: folderW,
                            height: folderH,
                            child:
                                _SkeuoFolder(open: flap, photos: folderPhotos),
                          ),
                          const SizedBox(width: TravelSpace.md),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Fim de semana em Recife',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TravelType.footnoteStrong
                                      .copyWith(color: p.ink),
                                ),
                                Text(
                                  pk < 0
                                      ? '$count de $_n rolês'
                                      : '$placedCount de $_m no calendário',
                                  style: TravelType.caption.copyWith(
                                    color: p.inkMuted,
                                    fontFeatures: TravelType.tabular,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Miniatura arrastada (foto na fase 1, evento na fase 2).
                    if (ghost > 0 && ghostAsset != null)
                      ghostChip
                          ? Positioned(
                              left: cursor.dx - (colW - 8) / 2,
                              top: cursor.dy - chipH / 2,
                              width: colW - 8,
                              height: chipH,
                              child: _EventChip(
                                asset: ghostAsset,
                                label: _placements[pk].role.shortName,
                              ),
                            )
                          : Positioned(
                              left: cursor.dx - cell * 0.31 - 6,
                              top: cursor.dy - cell * 0.31 - 6,
                              width: cell * 0.62,
                              height: cell * 0.62,
                              child: Opacity(
                                opacity: ghost.clamp(0, 1),
                                child: Transform.scale(
                                  scale: 0.4 + 0.6 * ghost,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        TravelSpace.rTight),
                                    child: Image.asset(ghostAsset,
                                        fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                            ),
                    // Cursor do agente.
                    Positioned(
                      left: cursor.dx,
                      top: cursor.dy,
                      child: Transform.scale(
                        scale: press,
                        alignment: Alignment.topLeft,
                        child: _AgentCursor(
                          color: p.accent,
                          label: p.onAccent,
                          labelLeft: cursor.dx > w * 0.6,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _gridCell({
    required Offset origin,
    required double size,
    required String asset,
    required bool collected,
    required bool target,
    required TravelPalette p,
  }) {
    return Positioned(
      left: origin.dx,
      top: origin.dy,
      width: size,
      height: size,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: p.s2,
          borderRadius: BorderRadius.circular(TravelSpace.rInner),
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TravelSpace.rInner),
          border: Border.all(
            color: target
                ? p.accent
                : (p.isDark ? Colors.white : Colors.black)
                    .withValues(alpha: 0.1),
            width: target ? 2 : 1,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Recolhido: a foto some para o cinza e fica só o ✓ neutro.
            AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: collected ? 0.18 : 1,
              child: Image.asset(asset, fit: BoxFit.cover),
            ),
            if (collected)
              Center(child: FaIcon(TravelIcons.check, size: 14, color: p.ink)),
          ],
        ),
      ),
    );
  }
}

/// Evento no mini calendário: foto 20 + nome curto. Coluna 12 − 4 = 8.
class _EventChip extends StatelessWidget {
  const _EventChip({required this.asset, required this.label});

  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: p.s1,
        borderRadius: BorderRadius.circular(TravelSpace.rTight),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(TravelSpace.xs),
            child: SizedBox.square(
              dimension: 20,
              child: Image.asset(asset, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TravelType.caption.copyWith(color: p.ink, height: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}

/// Entrada do evento no calendário: cresce com leve passada do ponto.
class _PopIn extends StatelessWidget {
  const _PopIn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.7, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      builder: (context, s, child) => Transform.scale(scale: s, child: child),
      child: child,
    );
  }
}

/// Pasta skeuomórfica no azul da marca: fundo com aba, fotos impressas
/// (borda branca) aparecendo e frente que inclina pra frente ao abrir.
/// Profundidade só com degradê e brilho de borda — sem sombra.
class _SkeuoFolder extends StatelessWidget {
  const _SkeuoFolder({required this.open, required this.photos});

  /// 0 fechada, 1 aberta.
  final double open;

  /// Até 3 fotos visíveis dentro da pasta (as mais recentes).
  final List<String> photos;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final back = Color.lerp(p.accent, Colors.black, 0.3)!;
    final frontTop = Color.lerp(p.accent, Colors.white, 0.2)!;
    return ExcludeSemantics(
      child: LayoutBuilder(builder: (context, box) {
        final fw = box.maxWidth;
        final fh = box.maxHeight;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _FolderBackPainter(back)),
            ),
            // Fotos impressas dentro da pasta.
            for (final (i, asset) in photos.indexed)
              Positioned(
                left: 12 + i * 10.0,
                top: 10 - i * 2.0,
                width: fw * 0.5,
                height: fh * 0.52,
                child: Transform.rotate(
                  angle: (i - 1) * 0.07,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(1.5),
                      child: Image.asset(asset, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            // Frente: inclina a partir da base.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: fh * 0.68,
              child: Transform(
                alignment: Alignment.bottomCenter,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.003)
                  ..rotateX(-0.6 * open),
                child: CustomPaint(
                  painter: _FolderFrontPainter(top: frontTop, bottom: p.accent),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _FolderBackPainter extends CustomPainter {
  _FolderBackPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color.lerp(color, Colors.white, 0.1)!, color],
      ).createShader(Offset.zero & size);
    // Aba no canto superior esquerdo + corpo.
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width * 0.42, 16),
            const Radius.circular(5)),
        paint,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 8, size.width, size.height - 8),
            const Radius.circular(9)),
        paint,
      );
  }

  @override
  bool shouldRepaint(_FolderBackPainter old) => old.color != color;
}

class _FolderFrontPainter extends CustomPainter {
  _FolderFrontPainter({required this.top, required this.bottom});

  final Color top;
  final Color bottom;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: const Radius.circular(5),
      topRight: const Radius.circular(5),
      bottomLeft: const Radius.circular(9),
      bottomRight: const Radius.circular(9),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(rect),
    );
    // Brilho da borda de cima (papel-cartão dobrado).
    canvas.drawLine(
      const Offset(5, 1),
      Offset(size.width - 5, 1),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..strokeWidth = 1,
    );
    // Porta-etiqueta: papel branco com duas linhas.
    final label = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.12, size.height * 0.5, size.width * 0.42,
          size.height * 0.22),
      const Radius.circular(2),
    );
    canvas.drawRRect(
        label, Paint()..color = Colors.white.withValues(alpha: 0.9));
    final line = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final lx = label.left + 4;
    final ly = label.top + label.height * 0.38;
    canvas
      ..drawLine(Offset(lx, ly), Offset(label.right - 6, ly), line)
      ..drawLine(Offset(lx, ly + label.height * 0.3),
          Offset(label.right - 14, ly + label.height * 0.3), line);
  }

  @override
  bool shouldRepaint(_FolderFrontPainter old) =>
      old.top != top || old.bottom != bottom;
}

class _ThumbStack extends StatelessWidget {
  const _ThumbStack({required this.roles, required this.ring});

  final List<Role> roles;
  final Color ring;

  @override
  Widget build(BuildContext context) {
    const d = 30.0;
    if (roles.isEmpty) return const SizedBox(width: d, height: d);
    return SizedBox(
      width: d + (roles.length - 1) * 16,
      height: d,
      child: Stack(
        children: [
          for (final (i, r) in roles.indexed)
            Positioned(
              left: i * 16.0,
              child: Container(
                width: d,
                height: d,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: ring,
                  borderRadius: BorderRadius.circular(TravelSpace.rTight + 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(TravelSpace.rTight),
                  child: Image.asset(r.photos.first.asset, fit: BoxFit.cover),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Cursor do agente: seta flat em azul + etiqueta "Maré".
class _AgentCursor extends StatelessWidget {
  const _AgentCursor(
      {required this.color, required this.label, this.labelLeft = false});

  final Color color;
  final Color label;

  /// Perto da borda direita a etiqueta vai para a esquerda da seta.
  final bool labelLeft;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: 64,
        height: 40,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
                size: const Size(15, 19), painter: _ArrowPainter(color)),
            Positioned(
              left: labelLeft ? -44 : 12,
              top: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(TravelSpace.rPill),
                ),
                child: Text(
                  'Maré',
                  style: TravelType.caption
                      .weight(FontWeight.w500)
                      .copyWith(color: label),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width * 0.32, size.height * 0.72)
      ..lineTo(size.width * 0.55, size.height)
      ..lineTo(size.width * 0.72, size.height * 0.9)
      ..lineTo(size.width * 0.5, size.height * 0.64)
      ..lineTo(size.width, size.height * 0.62)
      ..close();
    canvas
      ..drawPath(
        path,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeJoin = StrokeJoin.round,
      )
      ..drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => old.color != color;
}

/// Linha "8 rolês na pasta" — o que sobra do passo de recolher.
class FolderSummary extends StatelessWidget {
  const FolderSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final roles = [
      for (final id in TravelMock.collectOrder) TravelMock.roleById(id)
    ];
    return Row(
      children: [
        FaIcon(TravelIcons.folder, size: 13, color: p.inkMuted),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            '${roles.length} rolês na pasta Fim de semana em Recife',
            overflow: TextOverflow.ellipsis,
            style: TravelType.footnote.copyWith(color: p.inkMuted),
          ),
        ),
        const SizedBox(width: TravelSpace.sm),
        _ThumbStack(roles: roles.take(3).toList(), ring: p.s0),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Resumo recolhível depois da resposta
// ═══════════════════════════════════════════════════════════════════════════

/// "Pensou por 8s · 8 rolês na pasta" — toca para rever o processo.
class AgentProcessSummary extends StatefulWidget {
  const AgentProcessSummary({required this.kind, super.key});

  final ThinkingKind kind;

  @override
  State<AgentProcessSummary> createState() => _AgentProcessSummaryState();
}

class _AgentProcessSummaryState extends State<AgentProcessSummary> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    final steps = processFor(widget.kind).where((s) => !s.writing).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          button: true,
          expanded: _open,
          label: 'Ver o processo da Maré',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _open = !_open),
            child: SizedBox(
              height: TravelSpace.tap,
              child: Row(
                children: [
                  const MareMark(size: 20),
                  const SizedBox(width: TravelSpace.md),
                  Text(
                    'Pensou por ${secondsFor(widget.kind)}s',
                    style: TravelType.subheadStrong.copyWith(color: p.ink),
                  ),
                  const Spacer(),
                  FaIcon(
                    _open ? TravelIcons.chevronUp : TravelIcons.chevronDown,
                    size: 11,
                    color: p.inkMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: const Cubic(0.2, 0, 0, 1),
          alignment: Alignment.topCenter,
          child: !_open
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: TravelSpace.xs),
                  child: Column(
                    children: [
                      for (final (i, s) in steps.indexed)
                        _StepTile(
                            step: s,
                            active: false,
                            last: i == steps.length - 1),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Micro-animações
// ═══════════════════════════════════════════════════════════════════════════

/// Brilho que corre pelo texto do passo ativo. Reduce Motion → estático.
class Shimmer extends StatefulWidget {
  const Shimmer({required this.child, super.key});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    final p = TravelPalette.of(context);
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final x = -0.4 + 1.8 * _c.value;
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (rect) => LinearGradient(
            colors: [
              p.ink.withValues(alpha: 0.45),
              p.ink,
              p.ink.withValues(alpha: 0.45),
            ],
            stops: [
              (x - 0.25).clamp(0.0, 1.0),
              x.clamp(0.0, 1.0),
              (x + 0.25).clamp(0.0, 1.0),
            ],
          ).createShader(rect),
          child: child,
        );
      },
    );
  }
}

/// Três pontinhos de "escrevendo".
class TypingDots extends StatefulWidget {
  const TypingDots({super.key});

  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = TravelPalette.of(context);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++)
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: p.ink.withValues(
                  alpha: 0.25 +
                      0.75 *
                          (0.5 +
                              0.5 *
                                  math.sin(
                                      (_c.value - i * 0.18) * 2 * math.pi)),
                ),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
