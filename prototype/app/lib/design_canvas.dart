import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter/rendering.dart';
import 'package:studio_app/design_browser.dart';
import 'package:studio_app/design_presentation.dart';
import 'package:studio_app/design_theme.dart';
import 'package:studio_app/design_toast.dart';
import 'package:studio_app/design_tokens.dart';
import 'package:studio_app/features/feature_registry.dart';

/// Canvas tipo-Figma do loop de design: telas reais em miniatura, dispostas
/// por um autolayout "em espinha" e ligadas por setas derivadas de
/// `RegisteredScreen.next`. Pan/zoom via InteractiveViewer (nativo).
/// Visual portado da visão de protótipos do studio-vmqa: fundo pontilhado,
/// molduras plano/iOS/Android, controles de zoom, fit inicial e painel
/// lateral de preview. Spec: docs/specs/2026-08-15-design-canvas.md.

// ── Constantes de layout ────────────────────────────────────────────────
const kNodeW = 180.0;
const kPhoneAspect = 9 / 19.5;
const kPhoneH = kNodeW / kPhoneAspect;

/// Altura reservada ao rótulo: nome da tela + descrição, duas linhas com
/// folga. É o que o canvas do portal mostra sob cada celular.
const kLabelH = 56.0;
const kNodeH = kPhoneH + kLabelH;
const kGapX = 120.0;

/// Corredor vertical largo: a linha do edge case desce, contorna e volta —
/// com pouco espaço a curva passava por cima do celular de baixo.
const kGapY = 120.0;
const kCanvasPad = 64.0;

/// Limites da escala aplicada pelos botões. O piso é baixo porque com muitos
/// fluxos o "ver todo o fluxo" chega perto de 10%.
const kMinZoom = 0.08;
const kMaxZoom = 2.2;

/// Moldura da miniatura — mesmo trio do vmqa; "plano" (tela pura) é o
/// default, como lá.
enum FrameMode { plano, ios, android }

/// A moldura escolhida no hub fica no browser: selecionar uma vez vale para
/// as próximas visitas, sem voltar para `plano` a cada reload.
const _frameKey = 'loomi.hub.frame.v1';

/// Moldura salva, ou `plano` quando não há nada (ou o valor não existe mais).
FrameMode readFrameMode() {
  final salvo = readLocal(_frameKey);
  for (final modo in FrameMode.values) {
    if (modo.name == salvo) return modo;
  }
  return FrameMode.plano;
}

void saveFrameMode(FrameMode modo) => writeLocal(_frameKey, modo.name);

// ── Autolayout "em espinha" (puro, testável) ────────────────────────────
//
// BFS a partir das telas sem aresta de entrada: o primeiro destino segue na
// mesma linha (a espinha), destinos extras descem para novas linhas;
// back-edges não reposicionam; telas órfãs caem em linhas novas na coluna 0.
Map<String, math.Point<int>> spineLayout(List<RegisteredScreen> screens) {
  final routes = {for (final s in screens) s.route};
  final byRoute = {for (final s in screens) s.route: s};
  final incoming = <String, int>{for (final r in routes) r: 0};
  for (final s in screens) {
    for (final n in s.next) {
      if (routes.contains(n) && n != s.route) {
        incoming[n] = incoming[n]! + 1;
      }
    }
  }

  final cells = <String, math.Point<int>>{};
  final occupied = <math.Point<int>>{};
  var maxRow = -1;

  void place(String route, int col, int row) {
    var r = row;
    while (occupied.contains(math.Point(col, r))) {
      r++;
    }
    cells[route] = math.Point(col, r);
    occupied.add(math.Point(col, r));
    maxRow = math.max(maxRow, r);
  }

  void walk(String root) {
    place(root, 0, maxRow + 1);
    final queue = <String>[root];
    while (queue.isNotEmpty) {
      final route = queue.removeAt(0);
      final cell = cells[route]!;
      var branch = 0;
      for (final n in byRoute[route]!.next) {
        if (!routes.contains(n) || cells.containsKey(n)) continue;
        // Primeiro destino segue a espinha; extras descem.
        place(n, cell.x + 1, cell.y + branch);
        branch++;
        queue.add(n);
      }
    }
  }

  final roots = [
    for (final s in screens)
      if ((incoming[s.route] ?? 0) == 0) s.route,
  ];
  if (roots.isEmpty && screens.isNotEmpty) roots.add(screens.first.route);
  for (final root in roots) {
    if (!cells.containsKey(root)) walk(root);
  }
  // Órfãs alcançáveis só por ciclos.
  for (final s in screens) {
    if (!cells.containsKey(s.route)) place(s.route, 0, maxRow + 1);
  }
  return cells;
}

/// Portas de saída do recorte: destino declarado em `next` que existe no
/// registro mas não está entre as telas desenhadas — a próxima jornada.
///
/// Cada destino ganha uma célula à direita da tela de origem, na primeira
/// linha livre. Chave = rota do destino. Puro e testável, como o spineLayout.
Map<String, math.Point<int>> exitLayout(
  List<RegisteredScreen> desenhadas,
  Map<String, math.Point<int>> cells,
  Set<String> rotasConhecidas,
) {
  final noRecorte = {for (final s in desenhadas) s.route};
  final ocupadas = {...cells.values};
  final out = <String, math.Point<int>>{};
  for (final s in desenhadas) {
    final from = cells[s.route];
    if (from == null) continue;
    for (final n in s.next) {
      if (noRecorte.contains(n) || !rotasConhecidas.contains(n)) continue;
      if (out.containsKey(n)) continue;
      var row = from.y;
      while (ocupadas.contains(math.Point(from.x + 1, row))) {
        row++;
      }
      final cell = math.Point(from.x + 1, row);
      ocupadas.add(cell);
      out[n] = cell;
    }
  }
  return out;
}

/// Porta de entrada do recorte: de onde a jornada chega.
class EntryPort {
  const EntryPort({required this.cell, required this.target});

  /// Célula do cartão, à esquerda da tela de destino.
  final math.Point<int> cell;

  /// Rota da tela desenhada que recebe a seta.
  final String target;

  EntryPort shifted(int dx) =>
      EntryPort(cell: math.Point(cell.x + dx, cell.y), target: target);
}

/// Portas de entrada do recorte: tela desenhada que é destino do `next` de
/// uma tela de fora — a jornada anterior. Espelho do [exitLayout].
///
/// Chave = rota da tela de ORIGEM (a de fora). Cada origem entra uma vez, na
/// primeira linha livre à esquerda do destino. `x` pode sair -1: quem chama
/// desloca a grade (ver `_layout`).
Map<String, EntryPort> entryLayout(
  List<RegisteredScreen> desenhadas,
  Map<String, math.Point<int>> cells,
  List<RegisteredScreen> todas,
) {
  final noRecorte = {for (final s in desenhadas) s.route};
  final ocupadas = {...cells.values};
  final out = <String, EntryPort>{};
  for (final origem in todas) {
    if (noRecorte.contains(origem.route)) continue;
    for (final n in origem.next) {
      final alvo = cells[n];
      if (alvo == null || out.containsKey(origem.route)) continue;
      var row = alvo.y;
      while (ocupadas.contains(math.Point(alvo.x - 1, row))) {
        row++;
      }
      final cell = math.Point(alvo.x - 1, row);
      ocupadas.add(cell);
      out[origem.route] = EntryPort(cell: cell, target: n);
    }
  }
  return out;
}

/// Desloca uma grade de células em `dx` colunas.
Map<String, math.Point<int>> shiftCells(
  Map<String, math.Point<int>> cells,
  int dx,
) =>
    {
      for (final e in cells.entries)
        e.key: math.Point(e.value.x + dx, e.value.y),
    };

Offset cellToOffset(math.Point<int> cell) => Offset(
      kCanvasPad + cell.x * (kNodeW + kGapX),
      kCanvasPad + cell.y * (kNodeH + kGapY),
    );

Size canvasSize(Map<String, math.Point<int>> cells) {
  var cols = 0;
  var rows = 0;
  for (final c in cells.values) {
    cols = math.max(cols, c.x + 1);
    rows = math.max(rows, c.y + 1);
  }
  return Size(
    2 * kCanvasPad + cols * kNodeW + (cols - 1).clamp(0, 999) * kGapX,
    2 * kCanvasPad + rows * kNodeH + (rows - 1).clamp(0, 999) * kGapY,
  );
}

/// Captura o que está sob [key] como PNG e copia para a área de
/// transferência. Devolve se a cópia foi aceita pelo browser.
///
/// pixelRatio 3: colar num deck ou no Slack sem imagem borrada. Vive aqui
/// porque o painel do canvas e o palco da subpágina de doc copiam a mesma
/// coisa — a moldura com a tela dentro.
Future<bool> copyFramePng(GlobalKey key) async {
  final boundary =
      key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) return false;
  final image = await boundary.toImage(pixelRatio: 3);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  if (data == null) return false;
  return copyPngToClipboard(data.buffer.asUint8List());
}

// ── Miniatura: a tela real numa moldura ─────────────────────────────────
class MiniPhoneFrame extends StatelessWidget {
  const MiniPhoneFrame({
    required this.screen,
    this.width = kNodeW,
    this.mode = FrameMode.plano,
    this.selected = false,
    this.scenario,
    this.interactive = false,
    super.key,
  });

  final RegisteredScreen screen;
  final double width;
  final FrameMode mode;
  final bool selected;

  /// Cenário fixo desta miniatura. `null` (o normal) segue o seletor global
  /// `designScenario`; a seção "Cenários" do /docs fixa o dela para mostrar
  /// todos os estados lado a lado.
  final String? scenario;

  /// Deixa a tela receber toque. Ligado no /docs e na apresentação, onde a
  /// pessoa precisa rolar a lista; desligado na miniatura do canvas, que é
  /// só imagem.
  final bool interactive;

  /// Safe area simulada do device, em pontos do viewport de 390pt.
  ///
  /// Sem isto a tela desenha sob o notch e sob a barra de status falsa da
  /// moldura: a AppBar da tela ficava atrás da ilha dinâmica. Também é o que
  /// faz a miniatura mostrar o comportamento real de safe area.
  EdgeInsets get _deviceInsets => switch (mode) {
        // iPhone 14/15 em 390pt: 47 de topo, 34 do indicador de home.
        FrameMode.ios => const EdgeInsets.only(top: 47, bottom: 34),
        FrameMode.android => const EdgeInsets.only(top: 28, bottom: 16),
        // "plano" só tem o notch decorativo — folga suficiente para ele.
        FrameMode.plano => const EdgeInsets.only(top: 30),
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final height = width / kPhoneAspect;
    final fg = theme.colorScheme.onSurface;
    final hasBezel = mode != FrameMode.plano;
    final radius = width * (mode == FrameMode.android ? 0.16 : 0.2);

    // Moldura de verdade: corpo arredondado por fora, tela arredondada por
    // dentro. Antes era um Container único com `border` + clipBehavior, e o
    // clip usa o raio EXTERNO — os cantos quadrados da tela invadiam a curva
    // do bezel, que aparecia cortado.
    final bezel = hasBezel ? width * 0.022 : 1.0;
    // Viewport lógico com a proporção EXATA da área interna: mantém 390pt de
    // largura e deriva a altura, então o BoxFit.cover não corta nada.
    final viewportH = 390 * (height - 2 * bezel) / (width - 2 * bezel);
    final insets = _deviceInsets;

    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(bezel),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: selected
            ? theme.colorScheme.primary
            : hasBezel
                ? fg.withValues(alpha: 0.8)
                : theme.dividerColor,
        // Elevação do DS (--elev-shadow-md), não sombra improvisada.
        boxShadow: LoomiTokens.shadowMd,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(math.max(radius - bezel, 2)),
        child: ColoredBox(
          color: theme.colorScheme.surface,
          child: Stack(
            children: [
              // A tela REAL, renderizada em viewport de celular e reduzida.
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: 390,
                    height: viewportH,
                    child: MediaQuery(
                      data: MediaQueryData(
                        size: Size(390, viewportH),
                        devicePixelRatio: 1,
                        padding: insets,
                        viewPadding: insets,
                      ),
                      child: IgnorePointer(
                        ignoring: !interactive,
                        child: RepaintBoundary(
                          child: ValueListenableBuilder<String?>(
                            valueListenable: designScenario,
                            builder: (context, global, _) {
                              final resolved =
                                  scenario ?? global ?? kScenarioDefault;
                              // ValueKey: as telas guardam o cenário em
                              // initState, e sem key nova o Flutter reusaria o
                              // State e a variação não trocaria.
                              return Builder(
                                key: ValueKey(resolved),
                                builder: screen.builderFor(resolved),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Come o toque, deixa passar o arrasto: a lista rola, mas um
              // clique num card não dispara o `context.go` da tela e joga a
              // pessoa para fora do /docs. `translucent` para a tela continuar
              // recebendo o ponteiro; o tap daqui entra antes na arena e vence
              // o empate, e perde sozinho assim que o dedo se move.
              if (interactive)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {},
                  ),
                ),
              if (mode == FrameMode.plano)
                // Notch decorativo discreto (tela pura, como o "plano" do vmqa).
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: EdgeInsets.only(top: width * 0.05),
                    width: width * 0.3,
                    height: width * 0.035,
                    decoration: BoxDecoration(
                      color: fg.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              if (mode == FrameMode.ios) ...[
                _statusBar(fg, hour: '9:41'),
                // Dynamic Island.
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: EdgeInsets.only(top: width * 0.035),
                    width: width * 0.34,
                    height: width * 0.085,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                // Home indicator.
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: EdgeInsets.only(bottom: width * 0.03),
                    width: width * 0.38,
                    height: width * 0.022,
                    decoration: BoxDecoration(
                      color: fg.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ],
              if (mode == FrameMode.android) ...[
                _statusBar(fg, hour: '09:41'),
                // Furo da câmera.
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: EdgeInsets.only(top: width * 0.03),
                    width: width * 0.05,
                    height: width * 0.05,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Barra de navegação (voltar · home · recentes).
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: width * 0.025),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          HugeIcons.strokeRoundedArrowLeft01,
                          size: width * 0.08,
                          color: fg.withValues(alpha: 0.45),
                        ),
                        SizedBox(width: width * 0.12),
                        Icon(
                          HugeIcons.strokeRoundedCircle,
                          size: width * 0.06,
                          color: fg.withValues(alpha: 0.45),
                        ),
                        SizedBox(width: width * 0.12),
                        Icon(
                          HugeIcons.strokeRoundedSquare,
                          size: width * 0.06,
                          color: fg.withValues(alpha: 0.45),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBar(Color fg, {required String hour}) {
    final muted = fg.withValues(alpha: 0.6);
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.08,
          vertical: width * 0.035,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              hour,
              style: TextStyle(
                fontSize: width * 0.055,
                fontWeight: FontWeight.w600,
                color: muted,
                decoration: TextDecoration.none,
              ),
            ),
            Row(
              children: [
                Icon(HugeIcons.strokeRoundedSignalFull01,
                    size: width * 0.06, color: muted),
                SizedBox(width: width * 0.015),
                Icon(HugeIcons.strokeRoundedWifi01,
                    size: width * 0.06, color: muted),
                SizedBox(width: width * 0.015),
                Icon(HugeIcons.strokeRoundedBatteryFull,
                    size: width * 0.06, color: muted),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Fundo pontilhado (fixo no viewport, como no vmqa) ───────────────────
/// Fundo pontilhado do canvas — público porque a Biblioteca usa o mesmo
/// palco.
class DotsPainter extends CustomPainter {
  DotsPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 22.0;
    final paint = Paint()..color = color;
    for (var x = spacing / 2; x < size.width; x += spacing) {
      for (var y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DotsPainter old) => old.color != color;
}

// ── Arestas ─────────────────────────────────────────────────────────────
class _EdgePainter extends CustomPainter {
  _EdgePainter({
    required this.screens,
    required this.cells,
    required this.exitCells,
    required this.entryPorts,
    required this.color,
    required this.backColor,
  });

  final List<RegisteredScreen> screens;
  final Map<String, math.Point<int>> cells;
  final Map<String, math.Point<int>> exitCells;
  final Map<String, EntryPort> entryPorts;
  final Color color;
  final Color backColor;

  @override
  void paint(Canvas canvas, Size size) {
    final forward = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final back = Paint()
      ..color = backColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final s in screens) {
      final from = cells[s.route];
      if (from == null) continue;
      final a = cellToOffset(from);
      for (final n in s.next) {
        // Destino fora do recorte tem célula própria (a porta de saída).
        final to = cells[n] ?? exitCells[n];
        if (to == null) continue;
        final b = cellToOffset(to);
        if (b.dx > a.dx) {
          canvas.drawPath(_forwardPath(a, b), forward);
        } else {
          canvas.drawPath(_dashed(_backPath(a, b)), back);
        }
      }
    }

    // Porta de entrada → primeira tela do recorte: mesma seta das outras,
    // só que a origem é um cartão, não um celular.
    for (final port in entryPorts.values) {
      final to = cells[port.target];
      if (to == null) continue;
      canvas.drawPath(
        _forwardPath(cellToOffset(port.cell), cellToOffset(to)),
        forward,
      );
    }
  }

  // Direita do nó origem → cotovelo → esquerda do destino.
  Path _forwardPath(Offset a, Offset b) {
    final start = Offset(a.dx + kNodeW, a.dy + kPhoneH / 2);
    final end = Offset(b.dx, b.dy + kPhoneH / 2);
    final midX = start.dx + kGapX / 2;
    return _elbow([
      start,
      Offset(midX, start.dy),
      Offset(midX, end.dy),
      end,
    ]);
  }

  // Retorno: contorna por um canal à esquerda do destino.
  Path _backPath(Offset a, Offset b) {
    final start = Offset(a.dx, a.dy + kPhoneH / 2);
    final end = Offset(b.dx, b.dy + kPhoneH * 0.3);
    final channelX = math.min(start.dx, end.dx) - kGapX / 2;
    return _elbow([
      start,
      Offset(channelX, start.dy),
      Offset(channelX, end.dy),
      end,
    ]);
  }

  // Polilinha com cantos arredondados (mesma ideia do elbowPath do vmqa).
  Path _elbow(List<Offset> pts, {double radius = 14}) {
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length - 1; i++) {
      final prev = pts[i - 1];
      final corner = pts[i];
      final next = pts[i + 1];
      final inDir = corner - prev;
      final outDir = next - corner;
      final rIn = math.min(radius, inDir.distance / 2);
      final rOut = math.min(radius, outDir.distance / 2);
      final beforeCorner = corner - _unit(inDir) * rIn;
      final afterCorner = corner + _unit(outDir) * rOut;
      path
        ..lineTo(beforeCorner.dx, beforeCorner.dy)
        ..quadraticBezierTo(
          corner.dx,
          corner.dy,
          afterCorner.dx,
          afterCorner.dy,
        );
    }
    path.lineTo(pts.last.dx, pts.last.dy);
    return path;
  }

  Offset _unit(Offset v) => v.distance == 0 ? v : v / v.distance;

  Path _dashed(Path source, {double dash = 6, double gap = 6}) {
    final out = Path();
    for (final ui.PathMetric metric in source.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        out.addPath(
          metric.extractPath(distance, distance + dash),
          Offset.zero,
        );
        distance += dash + gap;
      }
    }
    return out;
  }

  @override
  bool shouldRepaint(covariant _EdgePainter old) =>
      old.screens != screens || old.cells != cells;
}

// ── O canvas ────────────────────────────────────────────────────────────
class DesignCanvas extends StatefulWidget {
  const DesignCanvas({
    required this.screens,
    required this.onOpenScreen,
    this.frameMode = FrameMode.plano,
    this.scenario,
    this.allScreens,
    this.onOpenFlow,
    this.selectedRoute,
    this.onSelect,
    super.key,
  });

  final List<RegisteredScreen> screens;
  final void Function(RegisteredScreen screen) onOpenScreen;
  final FrameMode frameMode;

  /// Registro completo, para saber onde vai um `next` que aponta para fora do
  /// recorte. Sem ele, não há porta de saída.
  final List<RegisteredScreen>? allScreens;

  /// Chamado ao tocar numa porta de saída: leva para o fluxo de destino.
  final void Function(String flow)? onOpenFlow;

  /// Cenário pré-selecionado na sidebar (null = Padrão). Aplicado no lugar,
  /// como na grade.
  final String? scenario;

  /// Seleção controlada de fora. Com [onSelect] preenchido o canvas não
  /// desenha o painel de preview: quem o desenha é o hub, como cartão
  /// separado ao lado. Sem ele, o canvas cuida da própria seleção.
  final String? selectedRoute;
  final void Function(RegisteredScreen screen, String? scenario)? onSelect;

  @override
  State<DesignCanvas> createState() => _DesignCanvasState();
}

class _DesignCanvasState extends State<DesignCanvas> {
  final _controller = TransformationController();
  String? _selectedRoute;

  /// Cenário do nó selecionado (null = o nó da tela padrão). O select do
  /// painel escreve aqui, e a seleção no canvas acompanha.
  String? _selectedScenario;
  Size _viewport = Size.zero;

  /// Tamanho da área para o qual o ajuste automático já foi feito. O primeiro
  /// layout do cartão pode vir menor que o final (a sidebar anima, o painel
  /// abre): ajustar uma vez só deixava o grafo minúsculo num canto.
  Size _fittedFor = Size.zero;

  /// Depois que a pessoa mexe (pan, zoom), o canvas para de se reajustar
  /// sozinho — só o botão "ajustar à tela" volta a mandar.
  bool _userMoved = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<RegisteredScreen> get _todas => widget.allScreens ?? widget.screens;

  /// Grade completa do recorte: telas, portas de saída e portas de entrada.
  ///
  /// Entrada nasce na coluna à esquerda do destino, que pode ser -1 quando o
  /// destino abre o recorte — daí o deslocamento de todas as células.
  ({
    Map<String, math.Point<int>> cells,
    Map<String, math.Point<int>> exits,
    Map<String, EntryPort> entries,
  }) get _layout {
    var cells = spineLayout(widget.screens);
    var exits = exitLayout(
      widget.screens,
      cells,
      {for (final s in _todas) s.route},
    );
    var entries = entryLayout(widget.screens, cells, _todas);

    var minX = 0;
    for (final e in entries.values) {
      minX = math.min(minX, e.cell.x);
    }
    if (minX < 0) {
      final dx = -minX;
      cells = shiftCells(cells, dx);
      exits = shiftCells(exits, dx);
      entries = {
        for (final e in entries.entries) e.key: e.value.shifted(dx),
      };
    }
    return (cells: cells, exits: exits, entries: entries);
  }

  String? get _route =>
      widget.onSelect != null ? widget.selectedRoute : _selectedRoute;

  RegisteredScreen? get _selected {
    for (final s in widget.screens) {
      if (s.route == _route) return s;
    }
    return null;
  }

  void _fit() {
    _userMoved = false;
    final l = _layout;
    final size = canvasSize({
      ...l.cells,
      ...l.exits,
      for (final e in l.entries.entries) e.key: e.value.cell,
    });
    if (_viewport == Size.zero) return;
    final scale = math.min(
      math.min(_viewport.width / size.width, _viewport.height / size.height),
      1.0,
    );
    final dx = (_viewport.width - size.width * scale) / 2;
    final dy = (_viewport.height - size.height * scale) / 2;
    _controller.value = Matrix4.identity()
      ..translateByDouble(math.max(dx, 0), math.max(dy, 0), 0, 1)
      ..scaleByDouble(scale, scale, scale, 1);
  }

  /// Zoom em passos, ancorado no centro do viewport — os botões −/+.
  ///
  /// Convive com os dois atalhos de estado ([_fit] e [_zoomToColumns]): eles
  /// levam a uma escala conhecida, este anda de pouco em pouco a partir de
  /// onde o canvas está.
  void _zoomBy(double factor) {
    if (_viewport == Size.zero) return;
    _userMoved = true;
    final center = Offset(_viewport.width / 2, _viewport.height / 2);
    final current = _controller.value.getMaxScaleOnAxis();
    final target = (current * factor).clamp(kMinZoom, kMaxZoom);
    final k = target / current;
    final m = Matrix4.identity()
      ..translateByDouble(center.dx, center.dy, 0, 1)
      ..scaleByDouble(k, k, k, 1)
      ..translateByDouble(-center.dx, -center.dy, 0, 1);
    _controller.value = m.multiplied(_controller.value);
  }

  /// Zoom de leitura: aproxima até caberem [colunas] telas na largura.
  ///
  /// O "ajustar à tela" serve pra ver o grafo inteiro — com muitos fluxos ele
  /// desce pra 10% e as telas viram tarja. Este aqui vai no outro sentido:
  /// escolhe a escala pelo número de telas que se quer conseguir ler e volta
  /// pro começo do grafo (canto superior esquerdo), que é onde o fluxo abre.
  void _zoomToColumns(int colunas) {
    if (_viewport == Size.zero) return;
    _userMoved = true;
    // Largura ocupada por N colunas + os vãos entre elas, com uma folga de
    // meio vão de cada lado pra tela não encostar na borda.
    final largura = colunas * kNodeW + (colunas - 1) * kGapX + kGapX;
    final scale = (_viewport.width / largura).clamp(kMinZoom, kMaxZoom);

    // Vertical: centraliza a PRIMEIRA linha, não o grafo inteiro — é a linha
    // que a pessoa está lendo, e com duas ou mais linhas o grafo não cabe na
    // altura, o que antes jogava tudo pro topo.
    final l = _layout;
    final conteudo = canvasSize({
      ...l.cells,
      ...l.exits,
      for (final e in l.entries.entries) e.key: e.value.cell,
    });
    final larguraConteudo = conteudo.width * scale;
    // Horizontal: fluxo curto que cabe inteiro fica no meio; fluxo longo abre
    // pelo início, com meio vão de folga na borda.
    final dx = larguraConteudo < _viewport.width
        ? (_viewport.width - larguraConteudo) / 2
        : -(kCanvasPad - kGapX / 2) * scale;
    final dy = (_viewport.height - kNodeH * scale) / 2 - kCanvasPad * scale;
    _controller.value = Matrix4.identity()
      ..translateByDouble(dx, dy, 0, 1)
      ..scaleByDouble(scale, scale, scale, 1);
  }

  /// Um nó do canvas: uma tela, no cenário selecionado na sidebar.
  ///
  /// Mesmo padrão da grade: o cenário é aplicado NO LUGAR. Tela que não cobre
  /// o cenário fica esmaecida e marcada — antes cada cenário era um nó
  /// ramificado, o que duplicava a tela no canvas.
  Widget _node(
    BuildContext context, {
    required RegisteredScreen screen,
    required math.Point<int> cell,
  }) {
    final theme = Theme.of(context);
    final p = LoomiPalette.of(context);
    final offset = cellToOffset(cell);
    final cenario = widget.scenario;
    final semVariacao = cenario != null && !screen.hasScenario(cenario);

    final node = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MiniPhoneFrame(
          screen: screen,
          mode: widget.frameMode,
          selected: screen.route == _route,
          // Sem `scenario`: segue o seletor global, como na grade.
        ),
        const SizedBox(height: 10),
        Text(
          screen.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          // Descrição no lugar da rota: é o que diz o que a tela faz no
          // fluxo. Sem descrição a rota volta, que é melhor que nada.
          semVariacao ? 'sem variação' : (screen.descricao ?? screen.route),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: p.mutedForeground,
          ),
        ),
      ],
    );

    return Positioned(
      left: offset.dx,
      top: offset.dy,
      width: kNodeW,
      child: GestureDetector(
        onTap: () {
          // O painel abre no cenário global, quando a tela o cobre.
          final estado = semVariacao ? null : cenario;
          final externo = widget.onSelect;
          if (externo != null) {
            externo(screen, estado);
          } else {
            setState(() {
              _selectedRoute = screen.route;
              _selectedScenario = estado;
            });
          }
        },
        child: semVariacao ? Opacity(opacity: 0.5, child: node) : node,
      ),
    );
  }

  /// Porta de saída: quadradinho ligado por seta, dizendo que dali o fluxo
  /// continua em outra jornada. Tocar leva ao fluxo de destino.
  /// Cartão de onde a jornada vem: a tela de fora que aponta para o recorte.
  Widget _entryNode(
    BuildContext context,
    String rota,
    math.Point<int> cell,
  ) {
    final theme = Theme.of(context);
    final p = LoomiPalette.of(context);
    final origem = _todas.firstWhere(
      (s) => s.route == rota,
      orElse: () => _todas.first,
    );
    final offset = cellToOffset(cell);

    return Positioned(
      left: offset.dx,
      // Mesma altura do nó de saída: a seta sai na horizontal.
      top: offset.dy + kPhoneH / 2 - 44,
      width: kNodeW,
      child: GestureDetector(
        onTap: () => widget.onOpenFlow?.call(origem.flow),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: p.primary.withValues(alpha: 0.06),
            border: Border.all(color: p.primary.withValues(alpha: 0.35)),
            borderRadius: BorderRadius.circular(LoomiTokens.radiusLg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(HugeIcons.strokeRoundedRoute01,
                      size: 14, color: p.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      // Curto por caber: o nó tem 140px, e 'Vem de outra
                      // jornada' truncava. Espelha 'Próxima jornada'.
                      'Jornada anterior',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: p.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                origem.flow,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium,
              ),
              Text(
                origem.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: p.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _exitNode(BuildContext context, String rota, math.Point<int> cell) {
    final theme = Theme.of(context);
    final p = LoomiPalette.of(context);
    final destino = _todas.firstWhere(
      (s) => s.route == rota,
      orElse: () => _todas.first,
    );
    final offset = cellToOffset(cell);

    return Positioned(
      left: offset.dx,
      // Centralizado na altura do celular, para a seta chegar na horizontal.
      top: offset.dy + kPhoneH / 2 - 44,
      width: kNodeW,
      child: GestureDetector(
        onTap: () => widget.onOpenFlow?.call(destino.flow),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: p.primary.withValues(alpha: 0.06),
            border: Border.all(color: p.primary.withValues(alpha: 0.35)),
            borderRadius: BorderRadius.circular(LoomiTokens.radiusLg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(HugeIcons.strokeRoundedRoute01,
                      size: 14, color: p.primary),
                  const SizedBox(width: 6),
                  // Expanded: o nó tem 140px, e o rótulo não pode estourar
                  // por causa da escala de fonte do tema.
                  Expanded(
                    child: Text(
                      'Próxima jornada',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: p.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                destino.flow,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium,
              ),
              Text(
                destino.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: p.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = _layout;
    final cells = l.cells;
    final exitCells = l.exits;
    final entryPorts = l.entries;
    final size = canvasSize({
      ...cells,
      ...exitCells,
      for (final e in entryPorts.entries) e.key: e.value.cell,
    });
    final theme = Theme.of(context);
    final selected = _selected;

    return Row(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              _viewport = constraints.biggest;
              if (!_userMoved && _viewport != _fittedFor) {
                _fittedFor = _viewport;
                // Abre no zoom de leitura: 4 telas na largura. Ver o grafo
                // inteiro é o "ajustar à tela" — com muitos fluxos ele abria
                // em 10% e nenhuma tela era legível.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  _zoomToColumns(4);
                  // _zoomToColumns marca movimento manual; na abertura não é.
                  _userMoved = false;
                });
              }
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: DotsPainter(
                        LoomiPalette.of(context).border,
                      ),
                    ),
                  ),
                  InteractiveViewer(
                    transformationController: _controller,
                    onInteractionStart: (_) => _userMoved = true,
                    constrained: false,
                    boundaryMargin: const EdgeInsets.all(600),
                    minScale: 0.35,
                    maxScale: 2.2,
                    child: SizedBox(
                      width: size.width,
                      height: size.height,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _EdgePainter(
                                screens: widget.screens,
                                cells: cells,
                                exitCells: exitCells,
                                entryPorts: entryPorts,
                                color: theme.colorScheme.primary,
                                backColor: theme.dividerColor,
                              ),
                            ),
                          ),
                          for (final screen in widget.screens)
                            if (cells[screen.route] != null)
                              _node(
                                context,
                                screen: screen,
                                cell: cells[screen.route]!,
                              ),
                          for (final entry in exitCells.entries)
                            _exitNode(context, entry.key, entry.value),
                          for (final entry in entryPorts.entries)
                            _entryNode(context, entry.key, entry.value.cell),
                        ],
                      ),
                    ),
                  ),
                  // Controles de zoom flutuantes (embaixo no centro).
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: LoomiPalette.of(context).card,
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: LoomiPalette.of(context).border,
                          ),
                          boxShadow: LoomiTokens.shadowMd,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Duas coisas na mesma barra: os atalhos de
                              // estado nas pontas (grafo inteiro / 4 telas) e
                              // o zoom em passos no meio, para o ajuste fino
                              // sem depender do scroll/pinça.
                              IconButton(
                                tooltip: 'Ver todo o fluxo',
                                icon: const Icon(
                                    HugeIcons.strokeRoundedFitToScreen,
                                    size: 18),
                                onPressed: _fit,
                              ),
                              const _ZoomBarDivider(),
                              IconButton(
                                tooltip: 'Diminuir zoom',
                                icon: const Icon(
                                    HugeIcons.strokeRoundedMinusSign,
                                    size: 18),
                                onPressed: () => _zoomBy(1 / 1.25),
                              ),
                              AnimatedBuilder(
                                animation: _controller,
                                builder: (_, __) => SizedBox(
                                  width: 44,
                                  child: Text(
                                    '${(_controller.value.getMaxScaleOnAxis() * 100).round()}%',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.labelMedium,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Aumentar zoom',
                                icon: const Icon(HugeIcons.strokeRoundedAdd01,
                                    size: 18),
                                onPressed: () => _zoomBy(1.25),
                              ),
                              const _ZoomBarDivider(),
                              IconButton(
                                tooltip: 'Ver 4 telas',
                                icon: const Icon(
                                    HugeIcons.strokeRoundedSearchFocus,
                                    size: 18),
                                onPressed: () => _zoomToColumns(4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (widget.onSelect == null && selected != null)
          DesignPreviewPanel(
            screen: selected,
            screens: widget.screens,
            frameMode: widget.frameMode,
            scenario: _selectedScenario,
            onScenario: (s) => setState(() => _selectedScenario = s),
            onClose: () => setState(() {
              _selectedRoute = null;
              _selectedScenario = null;
            }),
            onSelect: (route) => setState(() {
              _selectedRoute = route;
              _selectedScenario = null;
            }),
            onDocs: () => widget.onOpenScreen(selected),
          ),
      ],
    );
  }
}

// ── Painel lateral de preview (aside do vmqa) ───────────────────────────
//
// Público porque a grade do hub usa o mesmo painel: clicar num card abre
// aqui, com o mesmo select de estado do canvas.
/// Fio entre os grupos da barra de zoom: atalho de estado | passos | atalho.
class _ZoomBarDivider extends StatelessWidget {
  const _ZoomBarDivider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 18,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        color: LoomiPalette.of(context).border,
      );
}

class DesignPreviewPanel extends StatefulWidget {
  const DesignPreviewPanel({
    required this.screen,
    required this.screens,
    required this.frameMode,
    required this.scenario,
    required this.onScenario,
    required this.onClose,
    required this.onSelect,
    required this.onDocs,
    super.key,
  });

  final RegisteredScreen screen;
  final List<RegisteredScreen> screens;
  final FrameMode frameMode;

  /// Estado mostrado no painel (null = Padrão) e seu select.
  final String? scenario;
  final void Function(String? scenario) onScenario;
  final VoidCallback onClose;
  final void Function(String route) onSelect;

  /// Abre a ficha em `/docs/<slug>`. O botão principal do painel não usa
  /// isto: ele expande a tela ali mesmo (showDesignPresentation).
  final VoidCallback onDocs;

  @override
  State<DesignPreviewPanel> createState() => _DesignPreviewPanelState();
}

class _DesignPreviewPanelState extends State<DesignPreviewPanel> {
  /// Boundary da miniatura — é dela que sai o PNG do botão de copiar.
  /// Precisa ser Stateful: GlobalKey recriada a cada build remontaria a
  /// subárvore.
  final _frameKey = GlobalKey();

  /// Copia a miniatura como PNG.
  Future<void> _copiarImagem() async {
    final ok = await copyFramePng(_frameKey);
    if (!mounted) return;
    if (ok) {
      showLoomiToast(
        context,
        'Tela copiada',
        tone: LoomiToastTone.success,
        description: 'Cole onde quiser — é um PNG com a moldura.',
      );
    } else {
      showLoomiToast(
        context,
        'Não foi possível copiar',
        tone: LoomiToastTone.error,
        description: 'O navegador bloqueou o acesso à área de transferência.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = LoomiPalette.of(context);
    final index = widget.screens.indexOf(widget.screen);
    final titles = {for (final s in widget.screens) s.route: s.title};
    // Só destinos que existem no recorte atual: rota crua de outro fluxo
    // ("/demo/pedidos") não vira chip — não leva a lugar nenhum daqui.
    final destinos = [
      for (final n in widget.screen.next)
        if (titles.containsKey(n)) n,
    ];
    final nota = widget.scenario == null
        ? null
        : widget.screen.variants
            .where((v) => v.scenario == widget.scenario)
            .map((v) => v.note)
            .firstOrNull;
    // Subtítulo do header: fluxo · descrição. Sem descrição, cai na rota —
    // a rota some do header, então ela precisa aparecer em algum lugar.
    final subtitle = [widget.screen.flow, widget.screen.descricao]
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .join(' · ');

    return SizedBox(
      width: 360,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 10, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.screen.title,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitle.isEmpty ? widget.screen.route : subtitle,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: p.mutedForeground),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Ações viraram ícones do header — o corpo fica só com a
                // tela e a navegação.
                _HeaderAction(
                  tooltip: 'Copiar tela como imagem',
                  icon: HugeIcons.strokeRoundedCopy01,
                  onPressed: _copiarImagem,
                ),
                _HeaderAction(
                  tooltip: 'Abrir tela',
                  icon: HugeIcons.strokeRoundedArrowExpand01,
                  // Expande no lugar, com seletor de tela e de estado no
                  // header — não navega para fora do canvas/grade.
                  onPressed: () => showDesignPresentation(
                    context,
                    screens: widget.screens,
                    initialIndex: index,
                    frameMode: widget.frameMode,
                    scenario: widget.scenario,
                  ),
                ),
                _HeaderAction(
                  tooltip: 'Ver documentação',
                  icon: HugeIcons.strokeRoundedBookOpen01,
                  onPressed: widget.onDocs,
                ),
                _HeaderAction(
                  tooltip: 'Fechar',
                  icon: HugeIcons.strokeRoundedCancel01,
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    // RepaintBoundary aqui, não dentro do MiniPhoneFrame: o
                    // PNG copiado inclui a moldura, que é como a tela é vista.
                    child: RepaintBoundary(
                      key: _frameKey,
                      child: MiniPhoneFrame(
                        screen: widget.screen,
                        width: 260,
                        mode: widget.frameMode,
                        scenario: widget.scenario ?? kScenarioDefault,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.screen.variants.isNotEmpty) ...[
                    Text('Estado', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    _ScenarioSelect(
                      screen: widget.screen,
                      value: widget.scenario,
                      onChanged: widget.onScenario,
                    ),
                    if (nota != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        nota,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: p.mutedForeground),
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                  if (destinos.isNotEmpty) ...[
                    Text(
                      'Leva para',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: p.mutedForeground),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final n in destinos)
                          ActionChip(
                            label: Text(titles[n]!),
                            backgroundColor: p.primary.withValues(alpha: 0.10),
                            side: BorderSide.none,
                            shape: const StadiumBorder(),
                            labelStyle: theme.textTheme.labelMedium?.copyWith(
                              color: p.primary,
                            ),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            onPressed: () => widget.onSelect(n),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _NavPill(
                          label: 'Anterior',
                          icon: HugeIcons.strokeRoundedArrowLeft01,
                          trailing: false,
                          onPressed: index > 0
                              ? () => widget
                                  .onSelect(widget.screens[index - 1].route)
                              : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${index + 1}/${widget.screens.length}',
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: p.mutedForeground),
                        ),
                      ),
                      Expanded(
                        child: _NavPill(
                          label: 'Próxima',
                          icon: HugeIcons.strokeRoundedArrowRight01,
                          trailing: true,
                          onPressed: index < widget.screens.length - 1
                              ? () => widget
                                  .onSelect(widget.screens[index + 1].route)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < widget.screens.length; i++)
                    _ScreenRow(
                      position: i + 1,
                      title: widget.screens[i].title,
                      selected: i == index,
                      onTap: () => widget.onSelect(widget.screens[i].route),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ação em ícone do header do painel (copiar, expandir, docs, fechar).
class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon, size: 16),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        minimumSize: const Size(30, 30),
        padding: const EdgeInsets.all(7),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

/// Pílula Anterior/Próxima da navegação do painel.
class _NavPill extends StatelessWidget {
  const _NavPill({
    required this.label,
    required this.icon,
    required this.trailing,
    required this.onPressed,
  });

  final String label;
  final IconData icon;

  /// Ícone depois do texto (Próxima) em vez de antes (Anterior).
  final bool trailing;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final p = LoomiPalette.of(context);
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: p.muted,
        foregroundColor: p.foreground,
        disabledForegroundColor: p.mutedForeground.withValues(alpha: 0.6),
        disabledBackgroundColor: p.muted.withValues(alpha: 0.5),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        textStyle: Theme.of(context).textTheme.labelMedium,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!trailing) Icon(icon, size: 14),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Text(label, overflow: TextOverflow.ellipsis),
            ),
          ),
          if (trailing) Icon(icon, size: 14),
        ],
      ),
    );
  }
}

/// Linha da lista de telas do painel — `01 Splash`, a atual destacada.
class _ScreenRow extends StatelessWidget {
  const _ScreenRow({
    required this.position,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final int position;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = LoomiPalette.of(context);
    return Material(
      color: selected ? p.primary.withValues(alpha: 0.10) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                child: Text(
                  position.toString().padLeft(2, '0'),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: p.mutedForeground,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Select de estado da tela — Padrão + os cenários que ela declara, no mesmo
/// formato dos outros selects: ícone tintado, rótulo e marca na opção atual.
class _ScenarioSelect extends StatelessWidget {
  const _ScenarioSelect({
    required this.screen,
    required this.value,
    required this.onChanged,
  });

  final RegisteredScreen screen;
  final String? value;
  final void Function(String? scenario) onChanged;

  @override
  Widget build(BuildContext context) {
    return LoomiDropdown<String>(
      tooltip: 'Estado da tela',
      expanded: true,
      value: value ?? kScenarioDefault,
      // Padrão volta a null: é o estado base, não um cenário declarado.
      onChanged: (s) => onChanged(s == kScenarioDefault ? null : s),
      options: [
        for (final s in [kScenarioDefault, ...screen.scenarios])
          LoomiOption(
            value: s,
            label: s,
            icon: scenarioIcon(s),
            color: scenarioColor(context, s),
          ),
      ],
    );
  }
}
