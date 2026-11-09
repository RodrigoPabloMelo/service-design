import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:studio_app/design_canvas.dart';
import 'package:studio_app/design_theme.dart';
import 'package:studio_app/design_toast.dart';
import 'package:studio_app/design_tokens.dart';
import 'package:studio_app/features/feature_registry.dart';

/// Biblioteca de componentes — o Widgetbook do projeto, com a cara do
/// portal: navegação à esquerda, o componente vivo no palco pontilhado e os
/// controles (knobs) à direita.
///
/// Cada componente vem de `designComponents` (feature_registry.dart). Os
/// knobs mexem no componente em tempo real; as variantes são os estados
/// fixos que ele precisa cobrir (desabilitado, carregando, erro).
class DesignSystemPage extends StatefulWidget {
  const DesignSystemPage({this.slug, super.key});

  /// Componente aberto pela URL (`/docs/design-system/<slug>`).
  final String? slug;

  @override
  State<DesignSystemPage> createState() => _DesignSystemPageState();
}

class _DesignSystemPageState extends State<DesignSystemPage> {
  late RegisteredComponent _atual = _doSlug(widget.slug);
  late KnobValues _knobs = KnobValues.iniciais(_atual.knobs);
  bool _fundoClaro = true;

  @override
  void didUpdateWidget(DesignSystemPage old) {
    super.didUpdateWidget(old);
    // Voltar/avançar do browser troca o slug sem remontar a página.
    if (widget.slug != old.slug) _abrir(_doSlug(widget.slug));
  }

  RegisteredComponent _doSlug(String? slug) {
    for (final c in designComponents) {
      if (c.slug == slug) return c;
    }
    return designComponents.first;
  }

  void _abrir(RegisteredComponent c) {
    setState(() {
      _atual = c;
      // Knobs voltam ao início a cada componente: valor de um não faz
      // sentido no outro.
      _knobs = KnobValues.iniciais(c.knobs);
    });
  }

  void _selecionar(RegisteredComponent c) {
    _abrir(c);
    try {
      context.go('/docs/design-system/${c.slug}');
    } catch (_) {}
  }

  Future<void> _copiarSnippet() async {
    final snippet = _atual.snippet;
    if (snippet == null) return;
    await Clipboard.setData(ClipboardData(text: snippet));
    if (!mounted) return;
    showLoomiToast(
      context,
      'Código copiado',
      tone: LoomiToastTone.success,
      description: 'Cole no seu widget e ajuste os valores.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = LoomiPalette.of(context);
    if (designComponents.isEmpty) {
      return Scaffold(
        backgroundColor: p.background,
        body: Center(
          child: Text(
            'Nenhum componente registrado — registre em designComponents.',
            style: TextStyle(color: p.mutedForeground),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Navegacao(atual: _atual, onSelect: _selecionar),
              const SizedBox(width: 16),
              Expanded(
                child: LoomiPanelSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _cabecalho(context),
                      Expanded(child: _palco(context)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              LoomiPanelSurface(
                child: SizedBox(
                  width: 300,
                  child: _controles(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cabecalho(BuildContext context) {
    final theme = Theme.of(context);
    final p = LoomiPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _atual.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    LoomiBadge(label: _atual.group),
                  ],
                ),
                Text(
                  _atual.descricao ?? 'Componente do design system.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: p.mutedForeground),
                ),
              ],
            ),
          ),
          // Fundo do palco: componente sobre superfície e sobre o cinza do
          // app — contraste errado só aparece trocando.
          LoomiDropdown<bool>(
            tooltip: 'Fundo do palco',
            pill: true,
            value: _fundoClaro,
            onChanged: (v) => setState(() => _fundoClaro = v),
            options: const [
              LoomiOption(
                value: true,
                label: 'Superfície',
                icon: HugeIcons.strokeRoundedSquare,
              ),
              LoomiOption(
                value: false,
                label: 'Fundo do app',
                icon: HugeIcons.strokeRoundedLayout01,
              ),
            ],
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Tema do preview (claro/escuro)',
            icon: ValueListenableBuilder<ThemeMode>(
              valueListenable: designThemeMode,
              builder: (_, mode, __) => Icon(
                mode == ThemeMode.dark
                    ? HugeIcons.strokeRoundedSun03
                    : HugeIcons.strokeRoundedMoon02,
                size: 18,
              ),
            ),
            onPressed: toggleDesignTheme,
          ),
        ],
      ),
    );
  }

  Widget _palco(BuildContext context) {
    final theme = Theme.of(context);
    final p = LoomiPalette.of(context);
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: DotsPainter(p.border))),
        ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 48),
              decoration: BoxDecoration(
                color: _fundoClaro ? p.card : p.background,
                borderRadius: BorderRadius.circular(LoomiTokens.radiusXl),
                border: Border.all(color: p.border),
              ),
              child: Center(child: _atual.builder(context, _knobs)),
            ),
            if (_atual.variants.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Estados', style: theme.textTheme.titleSmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final v in _atual.variants)
                    _EstadoCard(variant: v, fundoClaro: _fundoClaro),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _controles(BuildContext context) {
    final theme = Theme.of(context);
    final p = LoomiPalette.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Controles', style: theme.textTheme.titleSmall),
        const SizedBox(height: 12),
        if (_atual.knobs.isEmpty)
          Text(
            'Este componente não declara knobs.',
            style:
                theme.textTheme.bodySmall?.copyWith(color: p.mutedForeground),
          ),
        for (final knob in _atual.knobs) ...[
          _KnobField(
            knob: knob,
            valores: _knobs,
            onChanged: (valor) =>
                setState(() => _knobs = _knobs.com(knob.label, valor)),
          ),
          const SizedBox(height: 14),
        ],
        if (_atual.snippet != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text('Uso', style: theme.textTheme.titleSmall),
              ),
              IconButton(
                tooltip: 'Copiar código',
                icon: const Icon(HugeIcons.strokeRoundedCopy01, size: 16),
                onPressed: _copiarSnippet,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: p.muted,
              borderRadius: BorderRadius.circular(LoomiTokens.radiusLg),
            ),
            child: Text(
              _atual.snippet!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: p.foreground,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Navegação da Biblioteca: componentes por grupo e a volta ao protótipo.
class _Navegacao extends StatelessWidget {
  const _Navegacao({required this.atual, required this.onSelect});

  final RegisteredComponent atual;
  final void Function(RegisteredComponent) onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = LoomiPalette.of(context);
    final grupos = <String, List<RegisteredComponent>>{};
    for (final c in designComponents) {
      grupos.putIfAbsent(c.group, () => []).add(c);
    }

    return SizedBox(
      width: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 0, 4),
            child: Text(
              'Design system',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 8),
              children: [
                for (final grupo in grupos.keys) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 20, 12, 8),
                    child: Text(
                      grupo,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: p.mutedForeground),
                    ),
                  ),
                  for (final c in grupos[grupo]!)
                    _ItemNav(
                      label: c.title,
                      ativo: c.slug == atual.slug,
                      onTap: () => onSelect(c),
                    ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Material(
              color: p.card,
              borderRadius: BorderRadius.circular(99),
              child: InkWell(
                borderRadius: BorderRadius.circular(99),
                onTap: () => context.go('/docs'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: LoomiTokens.shadowMd,
                    color: p.card,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        HugeIcons.strokeRoundedArrowLeft01,
                        size: 16,
                        color: p.mutedForeground,
                      ),
                      const SizedBox(width: 8),
                      // Flexible + ellipsis: em janela estreita o rótulo
                      // estourava a pílula.
                      Flexible(
                        child: Text(
                          'Voltar aos protótipos',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: p.mutedForeground,
                          ),
                        ),
                      ),
                    ],
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

class _ItemNav extends StatelessWidget {
  const _ItemNav({
    required this.label,
    required this.ativo,
    required this.onTap,
  });

  final String label;
  final bool ativo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = LoomiPalette.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(LoomiTokens.radiusLg),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(LoomiTokens.radiusLg),
          color: ativo ? p.sidebarAccent : null,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: ativo ? p.primary : p.foreground.withValues(alpha: 0.8),
            fontWeight: ativo ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/// Um estado fixo do componente, com o nome e a nota do porquê.
class _EstadoCard extends StatelessWidget {
  const _EstadoCard({required this.variant, required this.fundoClaro});

  final ComponentVariant variant;
  final bool fundoClaro;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = LoomiPalette.of(context);
    return SizedBox(
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: fundoClaro ? p.card : p.background,
              borderRadius: BorderRadius.circular(LoomiTokens.radiusLg),
              border: Border.all(color: p.border),
            ),
            child: Center(child: variant.builder(context)),
          ),
          const SizedBox(height: 8),
          Text(variant.label, style: theme.textTheme.labelMedium),
          if (variant.note != null)
            Text(
              variant.note!,
              style:
                  theme.textTheme.bodySmall?.copyWith(color: p.mutedForeground),
            ),
        ],
      ),
    );
  }
}

/// Campo de um knob no painel — texto, liga/desliga ou escolha.
class _KnobField extends StatelessWidget {
  const _KnobField({
    required this.knob,
    required this.valores,
    required this.onChanged,
  });

  final Knob knob;
  final KnobValues valores;
  final void Function(Object valor) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = LoomiPalette.of(context);

    return switch (knob) {
      final KnobTexto k => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              knob.label,
              style:
                  theme.textTheme.bodySmall?.copyWith(color: p.mutedForeground),
            ),
            const SizedBox(height: 6),
            TextFormField(
              initialValue: valores.texto(k.label, k.inicial),
              style: theme.textTheme.bodyMedium,
              onChanged: onChanged,
            ),
          ],
        ),
      final KnobBool k => Row(
          children: [
            Expanded(
              child: Text(knob.label, style: theme.textTheme.bodyMedium),
            ),
            Switch(
              value: valores.ativo(k.label, fallback: k.inicial),
              onChanged: onChanged,
            ),
          ],
        ),
      final KnobOpcao k => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              knob.label,
              style:
                  theme.textTheme.bodySmall?.copyWith(color: p.mutedForeground),
            ),
            const SizedBox(height: 6),
            LoomiDropdown<String>(
              tooltip: knob.label,
              expanded: true,
              value: valores.opcao(k.label, k.opcoes.first),
              onChanged: onChanged,
              options: [
                for (final o in k.opcoes) LoomiOption(value: o, label: o),
              ],
            ),
          ],
        ),
    };
  }
}
