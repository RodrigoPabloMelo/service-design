import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:studio_app/design_tokens.dart';

/// Toast do chrome de documentação, no canto da página.
///
/// Substitui o SnackBar do Material, que ocupa a largura toda e não tem nada
/// a ver com o @loomi/ui. O visual segue `sonner.tsx` do DS: card com borda
/// `--border/60`, sombra `lg`, texto `--foreground`, descrição em
/// `--muted-foreground`, e borda/ícone tintados por tom (success, error,
/// warning, info). Posição bottom-right, empilhando — o default do sonner.
///
/// Só para o chrome. Dentro do protótipo o SnackBar continua sendo o certo:
/// é o comportamento real do app.

enum LoomiToastTone { neutral, success, error, warning, info }

class _ToastData {
  const _ToastData({
    required this.id,
    required this.message,
    required this.tone,
    this.description,
  });

  final int id;
  final String message;
  final String? description;
  final LoomiToastTone tone;
}

// Estado de módulo, como o `designThemeMode`: existe um preview por página,
// então uma pilha global de toasts é suficiente — e evita ter que plantar um
// provider acima do MaterialApp.
final _toasts = ValueNotifier<List<_ToastData>>(const []);
OverlayEntry? _entry;
int _seq = 0;

/// Mostra um toast. Sem Overlay disponível (widget fora de um MaterialApp,
/// como em alguns testes) não faz nada em vez de estourar.
void showLoomiToast(
  BuildContext context,
  String message, {
  LoomiToastTone tone = LoomiToastTone.neutral,
  String? description,
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  _toasts.value = [
    ..._toasts.value,
    _ToastData(
      id: _seq++,
      message: message,
      tone: tone,
      description: description,
    ),
  ];

  if (_entry == null) {
    _entry = OverlayEntry(builder: (_) => const _ToastLayer());
    overlay.insert(_entry!);
  }
}

/// Limpa a pilha e solta o OverlayEntry. Existe para os testes: o estado é
/// de módulo, e um toast sobrando de um teste referenciaria o Overlay do
/// anterior, já descartado.
@visibleForTesting
void resetLoomiToasts() {
  _toasts.value = const [];
  _entry?.remove();
  _entry = null;
}

void _dismiss(int id) {
  _toasts.value = [
    for (final t in _toasts.value)
      if (t.id != id) t,
  ];
  if (_toasts.value.isEmpty) {
    _entry?.remove();
    _entry = null;
  }
}

class _ToastLayer extends StatelessWidget {
  const _ToastLayer();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: ValueListenableBuilder<List<_ToastData>>(
        valueListenable: _toasts,
        builder: (context, toasts, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final t in toasts)
              Padding(
                // Key pelo id: sem ela, remover um toast do meio faria os
                // outros herdarem o State (e a animação) errado.
                key: ValueKey(t.id),
                padding: const EdgeInsets.only(top: 8),
                child: _ToastCard(data: t),
              ),
          ],
        ),
      ),
    );
  }
}

class _ToastCard extends StatefulWidget {
  const _ToastCard({required this.data});

  final _ToastData data;

  @override
  State<_ToastCard> createState() => _ToastCardState();
}

class _ToastCardState extends State<_ToastCard>
    with SingleTickerProviderStateMixin {
  static const _duracao = Duration(seconds: 4);

  late final AnimationController _anim = AnimationController(
    duration: const Duration(milliseconds: 180),
    vsync: this,
  );
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // forward() aqui e não no inicializador do campo: `late final` só é
    // avaliado no primeiro acesso, que acontece durante o build — a animação
    // começava no meio do frame e o fade ficava preso.
    _anim.forward();
    _timer = Timer(_duracao, _sair);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _anim.dispose();
    super.dispose();
  }

  /// Anima a saída antes de tirar da pilha — remover direto faria o toast
  /// desaparecer com um corte seco.
  Future<void> _sair() async {
    _timer?.cancel();
    if (!mounted) return;
    await _anim.reverse();
    if (mounted) _dismiss(widget.data.id);
  }

  (Color?, IconData) _tom(BuildContext context) {
    final p = LoomiPalette.of(context);
    return switch (widget.data.tone) {
      LoomiToastTone.success => (
          p.success,
          HugeIcons.strokeRoundedCheckmarkCircle01
        ),
      LoomiToastTone.error => (
          p.destructive,
          HugeIcons.strokeRoundedAlertCircle
        ),
      LoomiToastTone.warning => (p.warning, HugeIcons.strokeRoundedAlert02),
      LoomiToastTone.info => (p.info, HugeIcons.strokeRoundedInformationCircle),
      LoomiToastTone.neutral => (
          null,
          HugeIcons.strokeRoundedInformationCircle
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = LoomiPalette.of(context);
    final (tint, icon) = _tom(context);

    return FadeTransition(
      opacity: _anim,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0.12, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut)),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(LoomiTokens.radiusLg),
            onTap: _sair,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 360),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: BorderRadius.circular(LoomiTokens.radiusLg),
                border: Border.all(
                  color: (tint ?? p.border).withValues(
                    alpha: tint == null ? 0.6 : 0.3,
                  ),
                ),
                boxShadow: LoomiTokens.shadowLg,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 16, color: tint ?? p.mutedForeground),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.data.message,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: tint ?? p.foreground,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (widget.data.description != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.data.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: p.mutedForeground,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
