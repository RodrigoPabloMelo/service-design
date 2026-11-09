import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:studio_app/design_browser.dart';
import 'package:studio_app/design_canvas.dart';
import 'package:studio_app/design_doc_notes.dart';
import 'package:studio_app/design_theme.dart';
import 'package:studio_app/design_toast.dart';
import 'package:studio_app/design_tokens.dart';
import 'package:studio_app/features/feature_registry.dart';

/// Slug da tela dentro de `/docs` — deriva da rota: `/demo/splash` →
/// `demo-splash`. Estável enquanto a rota não muda.
String screenSlug(RegisteredScreen screen) =>
    screen.route.replaceAll(RegExp(r'^/|/$'), '').replaceAll('/', '-');

RegisteredScreen? _findBySlug(String slug) {
  for (final s in designScreens) {
    if (screenSlug(s) == slug) return s;
  }
  return null;
}

/// Subpágina de documentação de uma tela (`/docs/<slug>`). É documentação,
/// não protótipo: ficha da tela e preview estático, no design system
/// @loomi/ui (ver design_tokens.dart). O protótipo interativo fica na rota
/// real da tela, fora de `/docs`.
class DesignDocPage extends StatelessWidget {
  const DesignDocPage({required this.slug, super.key});

  final String slug;

  @override
  Widget build(BuildContext context) {
    final screen = _findBySlug(slug);
    final theme = Theme.of(context);
    final p = LoomiPalette.of(context);

    if (screen == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Documentação')),
        body: Center(
          child: LoomiCard(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(HugeIcons.strokeRoundedInbox,
                    size: 32, color: p.mutedForeground.withValues(alpha: 0.7)),
                const SizedBox(height: 12),
                Text('Tela não encontrada', style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  'Nenhuma tela registrada com o slug "$slug".',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: p.mutedForeground),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.go('/docs'),
                  child: const Text('Voltar à documentação'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final nextScreens = [
      for (final route in screen.next)
        for (final s in designScreens)
          if (s.route == route) s,
    ];
    final previous = [
      for (final s in designScreens)
        if (s.next.contains(screen.route)) s,
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Voltar à documentação',
          icon: const Icon(HugeIcons.strokeRoundedArrowLeft01, size: 20),
          onPressed: () => context.go('/docs/fluxo/${flowSlug(screen.flow)}'),
        ),
        // Nome da tela e fluxo na mesma linha: em duas linhas a barra crescia
        // e roubava a altura que o celular grande usa.
        titleSpacing: 8,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
                child: Text(screen.title, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                '· Fluxo ${screen.flow}',
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: p.mutedForeground,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton.icon(
              onPressed: () => context.go(screen.route),
              icon: const Icon(HugeIcons.strokeRoundedLinkSquare01, size: 16),
              label: const Text('Abrir protótipo'),
            ),
          ),
        ],
      ),
      body: Center(
        // Largo: o celular grande de um lado e a ficha do outro pedem
        // horizontal. O teto existe para não esticar em ultrawide.
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          // Sem barra de rolagem: no web o Flutter desenha uma trilha fixa à
          // direita, e nesta página ela ficava colada no conteúdo sem
          // informar nada — a página é curta e rola no scroll normal.
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              children: [
                // Palco (abas de cenário + celular grande) numa coluna fixa à
                // esquerda; descrição, ficha e navegação ao lado. Empilha em
                // tela estreita.
                LayoutBuilder(
                  builder: (context, constraints) {
                    final palco = _ScreenStage(screen: screen);
                    final dados = Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _NotesCard(screen: screen),
                        const SizedBox(height: 16),
                        _SpecCard(screen: screen),
                        const SizedBox(height: 16),
                        _NavCard(next: nextScreens, previous: previous),
                      ],
                    );

                    if (constraints.maxWidth < 860) {
                      return Column(
                        children: [palco, const SizedBox(height: 20), dados],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 430, child: palco),
                        const SizedBox(width: 24),
                        Expanded(child: dados),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Trilha vertical de estados, à esquerda do celular: só ícone, com o nome e
/// a nota do cenário no tooltip. O copiar fica no fim dela.
///
/// Visual dos tokens (`tabs.tsx` do @loomi/ui): container `bg-muted/40` com
/// borda, item ativo `bg-primary` com sombra `sm`, inativo na cor do cenário.
class _ScenarioRail extends StatelessWidget {
  const _ScenarioRail({
    required this.screen,
    required this.value,
    required this.onChanged,
    required this.onCopy,
  });

  final RegisteredScreen screen;

  /// Cenário ativo; null é o padrão.
  final String? value;
  final void Function(String? scenario) onChanged;
  final VoidCallback onCopy;

  /// Só o nome do cenário.
  ///
  /// A nota é texto de handoff: num tooltip ancorado na borda esquerda ela
  /// virava uma faixa larga que saía da tela. Ela vive no registry e no
  /// markdown do handoff.
  String _tooltip(String cenario) =>
      cenario == kScenarioDefault ? 'Padrão' : cenario;

  @override
  Widget build(BuildContext context) {
    final p = LoomiPalette.of(context);
    final cenarios = [kScenarioDefault, ...screen.scenarios];

    Widget botao({
      required IconData icone,
      required String dica,
      required Color cor,
      required bool ativo,
      required VoidCallback? onTap,
    }) {
      return Tooltip(
        message: dica,
        child: InkWell(
          borderRadius: BorderRadius.circular(LoomiTokens.radiusMd),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 38,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ativo ? p.primary : null,
              borderRadius: BorderRadius.circular(LoomiTokens.radiusMd),
              boxShadow: ativo ? LoomiTokens.shadowSm : null,
            ),
            child: Icon(
              icone,
              size: 16,
              color: ativo ? p.primaryForeground : cor,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: p.muted.withValues(alpha: 0.4),
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(LoomiTokens.radiusLg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final c in cenarios)
            botao(
              icone: scenarioIcon(c),
              dica: _tooltip(c),
              cor: scenarioColor(context, c),
              ativo: (value ?? kScenarioDefault) == c,
              onTap: (value ?? kScenarioDefault) == c
                  ? null
                  : () => onChanged(c == kScenarioDefault ? null : c),
            ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            color: p.border,
          ),
          botao(
            icone: HugeIcons.strokeRoundedCopy01,
            dica: 'Copiar tela como imagem',
            cor: p.mutedForeground,
            ativo: false,
            onTap: onCopy,
          ),
        ],
      ),
    );
  }
}

/// Palco da tela: abas de cenário e o celular grande.
///
/// As abas substituem a grade de cenários que ficava no rodapé — comparar
/// dois estados vale menos que ver um estado grande, e a grade repetia a
/// mesma tela em miniatura.
class _ScreenStage extends StatefulWidget {
  const _ScreenStage({required this.screen});

  final RegisteredScreen screen;

  @override
  State<_ScreenStage> createState() => _ScreenStageState();
}

class _ScreenStageState extends State<_ScreenStage> {
  String? _scenario;

  /// Versão anterior selecionada; null = a que está no ar (o código).
  ScreenVersion? _versao;

  /// Boundary da moldura — é dela que sai o PNG do botão de copiar.
  final _frameKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Abre na aba do cenário pré-selecionado no hub, quando esta tela o
    // cobre: vindo de "Erro" na grade, a doc não deveria voltar ao padrão.
    final global = designScenario.value;
    if (global != null && widget.screen.hasScenario(global)) {
      _scenario = global;
    }
  }

  Future<void> _copiarImagem() async {
    final ok = await copyFramePng(_frameKey);
    if (!mounted) return;
    if (ok) {
      showLoomiToast(
        context,
        'Tela copiada',
        tone: LoomiToastTone.success,
        description: 'É um PNG com a moldura, no estado que está na aba.',
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
    final versoes = widget.screen.previousVersions;
    final antiga = _versao;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (versoes.isNotEmpty) ...[
          _VersionSelect(
            screen: widget.screen,
            value: antiga,
            onChanged: (v) => setState(() => _versao = v),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A trilha de estados só existe na versão ao vivo: estado é
            // comportamento do código, e versão antiga é um build congelado.
            if (antiga == null) ...[
              _ScenarioRail(
                screen: widget.screen,
                value: _scenario,
                onChanged: (s) => setState(() => _scenario = s),
                onCopy: _copiarImagem,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: LoomiCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                child: antiga == null
                    ? Center(
                        child: RepaintBoundary(
                          key: _frameKey,
                          child: MiniPhoneFrame(
                            screen: widget.screen,
                            width: 320,
                            mode: FrameMode.ios,
                            interactive: true,
                            // Explícito: aqui o estado vem da trilha, não do
                            // seletor global do hub.
                            scenario: _scenario ?? kScenarioDefault,
                          ),
                        ),
                      )
                    : _VersionView(screen: widget.screen, version: antiga),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Seletor de versão: a que está no ar mais as fechadas.
class _VersionSelect extends StatelessWidget {
  const _VersionSelect({
    required this.screen,
    required this.value,
    required this.onChanged,
  });

  final RegisteredScreen screen;
  final ScreenVersion? value;
  final void Function(ScreenVersion? version) onChanged;

  @override
  Widget build(BuildContext context) {
    return LoomiDropdown<String>(
      tooltip: 'Versão da tela',
      value: value?.commit ?? '',
      onChanged: (commit) => onChanged(
        commit.isEmpty
            ? null
            : screen.previousVersions.firstWhere((v) => v.commit == commit),
      ),
      options: [
        LoomiOption(
          value: '',
          icon: HugeIcons.strokeRoundedFlash,
          label: '${screen.version} · no ar',
        ),
        for (final v in screen.previousVersions)
          LoomiOption(
            value: v.commit,
            icon: HugeIcons.strokeRoundedTime04,
            label: '${v.label} · ${v.date}',
          ),
      ],
    );
  }
}

/// Uma versão fechada: o build daquele commit num iframe, ou a ficha dela
/// quando aquele build não foi publicado.
class _VersionView extends StatelessWidget {
  const _VersionView({required this.screen, required this.version});

  final RegisteredScreen screen;
  final ScreenVersion version;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = LoomiPalette.of(context);
    final url = versionUrl(version.commit, screen.route);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sem repetir rótulo e data: o select acima já diz qual versão é.
        // Fica a descrição dela e, à direita, o expandir.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                version.note ?? 'Sem descrição nesta versão.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: p.mutedForeground,
                ),
              ),
            ),
            if (url != null) ...[
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Abrir em outra aba',
                icon:
                    const Icon(HugeIcons.strokeRoundedArrowExpand01, size: 15),
                visualDensity: VisualDensity.compact,
                onPressed: () => openUrl(url),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        // Pergunta ao servidor se o build existe: o iframe só entra quando
        // tem o que carregar, senão a ficha explica por quê.
        FutureBuilder<bool>(
          future: versionExists(version.commit),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const SizedBox(
                height: 80,
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }
            final frame =
                snap.data == true && url != null ? versionFrame(url) : null;
            if (frame == null) return _VersionFicha(version: version);
            // O build daquele commit, servido em /v/<commit>/ — o app inteiro
            // de então, com a moldura e o chrome que existiam.
            //
            // O iframe é mais largo que a área visível e fica centralizado no
            // OverflowBox: o chrome flutuante daquele build (os botões
            // encostados à direita) cai fora do ClipRect, e o celular, que é
            // centralizado lá dentro, continua centralizado aqui.
            //
            // Frágil por natureza: depende de o build antigo centralizar o
            // device. Versão com layout muito diferente pode recortar torto —
            // aí é só expandir em outra aba.
            // LayoutBuilder POR FORA do OverflowBox: ele solta a restrição de
            // largura, então lá dentro `maxWidth` seria infinito.
            return LayoutBuilder(
              builder: (context, c) => ClipRect(
                child: SizedBox(
                  height: 720,
                  child: OverflowBox(
                    maxWidth: double.infinity,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: c.maxWidth + 280,
                      height: 720,
                      child: frame,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Ficha da versão sem build publicado: mostra a identidade dela no git.
class _VersionFicha extends StatelessWidget {
  const _VersionFicha({required this.version});

  final ScreenVersion version;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = LoomiPalette.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: p.muted.withValues(alpha: 0.4),
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(LoomiTokens.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sem build publicado',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Esta versão é de antes do deploy passar a guardar um build por '
            'commit. Dá para ver o código dela pelo commit; renderizada, só '
            'as versões fechadas de agora em diante.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: p.mutedForeground,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                version.commit,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Copiar commit',
                icon: const Icon(HugeIcons.strokeRoundedCopy01, size: 14),
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: version.commit));
                  showLoomiToast(
                    context,
                    'Commit copiado',
                    tone: LoomiToastTone.success,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Descrição e links da tela, como estão no repositório.
///
/// Só leitura de propósito: o conteúdo vem de `RegisteredScreen.descricao` /
/// `.links` (feature_registry.dart), que é o que chega no dev. Editar aqui
/// virava rascunho preso no localStorage do browser — no lugar disso, o
/// botão de informação entrega o comando pronto para pedir a escrita ao
/// Claude, que altera o registry e entra no commit.
class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.screen});

  final RegisteredScreen screen;

  void _copiarComando(BuildContext context) {
    Clipboard.setData(ClipboardData(text: claudeNotesPrompt(screen)));
    showLoomiToast(
      context,
      'Comando copiado',
      tone: LoomiToastTone.success,
      description: 'Cole no chat do Claude e complete a descrição.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = LoomiPalette.of(context);
    final descricao = screen.descricao?.trim() ?? '';

    return LoomiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'DESCRIÇÃO',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: p.mutedForeground,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Tooltip(
                // richMessage porque o Tooltip não tem largura máxima: o
                // comando numa linha só esticaria a caixa na tela toda.
                richMessage: WidgetSpan(
                  child: _ComandoTooltip(screen: screen),
                ),
                // O card interno desenha fundo, borda e sombra.
                padding: EdgeInsets.zero,
                decoration: const BoxDecoration(),
                child: IconButton(
                  icon: const Icon(
                    HugeIcons.strokeRoundedInformationCircle,
                    size: 16,
                  ),
                  onPressed: () => _copiarComando(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            descricao.isEmpty
                ? 'Sem descrição ainda — peça ao Claude pelo comando do ⓘ.'
                : descricao,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: descricao.isEmpty ? p.mutedForeground : null,
            ),
          ),
          const SizedBox(height: 18),
          // Mesma eyebrow de DESCRIÇÃO: são duas seções do mesmo card, no
          // mesmo nível.
          Text(
            'LINKS',
            style: theme.textTheme.labelSmall?.copyWith(
              color: p.mutedForeground,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          if (screen.links.isEmpty)
            Text(
              'Figma, ticket, spec — o que ajudar quem for implementar.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: p.mutedForeground,
              ),
            )
          else
            for (final link in screen.links)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(HugeIcons.strokeRoundedLink01,
                        size: 15, color: p.primary),
                    const SizedBox(width: 8),
                    Flexible(
                      child: InkWell(
                        onTap: () => openUrl(link.url),
                        child: Text(
                          link.nome,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: p.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: p.primary.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        link.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: p.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

/// Conteúdo do tooltip do ⓘ: o comando do Claude num card do DS, estreito
/// de propósito — o texto quebra em várias linhas em vez de esticar.
class _ComandoTooltip extends StatelessWidget {
  const _ComandoTooltip({required this.screen});

  final RegisteredScreen screen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = LoomiPalette.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 260),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: p.card,
          border: Border.all(color: p.border),
          borderRadius: BorderRadius.circular(LoomiTokens.radiusLg),
          boxShadow: LoomiTokens.shadowMd,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DESCRIÇÃO E LINKS VÊM DO REPOSITÓRIO',
              style: theme.textTheme.labelSmall?.copyWith(
                color: p.mutedForeground,
                letterSpacing: 1.1,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Para mudar, cole no chat do Claude:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: p.cardForeground,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: p.muted,
                borderRadius: BorderRadius.circular(LoomiTokens.radiusSm),
              ),
              child: Text(
                claudeNotesPrompt(screen).trimRight(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: p.cardForeground,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(HugeIcons.strokeRoundedCopy01, size: 12, color: p.primary),
                const SizedBox(width: 6),
                Text(
                  'Clique para copiar',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: p.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Ficha técnica: os campos que o dev precisa no refactor, em matriz 2x2.
/// Rótulo em cima do valor, e não à esquerda: em grade a coluna de rótulos
/// dobraria e empurraria os valores para o meio do card.
class _SpecCard extends StatelessWidget {
  const _SpecCard({required this.screen});

  final RegisteredScreen screen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = LoomiPalette.of(context);
    return LoomiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FICHA',
            style: theme.textTheme.labelSmall?.copyWith(
              color: p.mutedForeground,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _Field(label: 'Fluxo', value: screen.flow)),
              Expanded(
                child: _Field(label: 'Rota', value: screen.route, mono: true),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Field(
                  label: 'Widget',
                  value: '${screen.builder(context).runtimeType}',
                  mono: true,
                ),
              ),
              Expanded(
                child: _Field(
                  label: 'Slug',
                  value: screenSlug(screen),
                  mono: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Os cenários cobertos, que antes eram badges soltas embaixo do
          // título: aqui são um campo da ficha, ao lado dos outros dados.
          Text(
            'Cenários',
            style: theme.textTheme.bodySmall?.copyWith(
              color: p.mutedForeground,
            ),
          ),
          const SizedBox(height: 6),
          if (screen.scenarios.isEmpty)
            Text('Só o padrão.', style: theme.textTheme.bodyMedium)
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final s in screen.scenarios)
                  LoomiBadge(
                    label: s,
                    color: scenarioColor(context, s),
                    icon: scenarioIcon(s),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Vizinhas no fluxo, como os chips do painel lateral do canvas — não como
/// duas listas em cards separados: são no máximo dois ou três destinos, e
/// cada um cabe num pill.
class _NavCard extends StatelessWidget {
  const _NavCard({required this.next, required this.previous});

  final List<RegisteredScreen> next;
  final List<RegisteredScreen> previous;

  @override
  Widget build(BuildContext context) {
    return LoomiCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _grupo(
            context,
            'Leva para',
            next,
            HugeIcons.strokeRoundedArrowRight01,
            'Tela final do fluxo.',
          ),
          const SizedBox(height: 16),
          _grupo(
            context,
            'Vem de',
            previous,
            HugeIcons.strokeRoundedArrowLeft01,
            'Entrada do fluxo.',
          ),
        ],
      ),
    );
  }

  Widget _grupo(
    BuildContext context,
    String titulo,
    List<RegisteredScreen> telas,
    IconData icone,
    String vazio,
  ) {
    final theme = Theme.of(context);
    final p = LoomiPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        if (telas.isEmpty)
          Text(
            vazio,
            style: theme.textTheme.bodySmall?.copyWith(
              color: p.mutedForeground,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in telas)
                ActionChip(
                  label: Text(s.title),
                  avatar: Icon(icone, size: 14),
                  onPressed: () => context.go('/docs/${screenSlug(s)}'),
                ),
            ],
          ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value, this.mono = false});

  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = LoomiPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: p.mutedForeground),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: mono
              ? theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontSize: LoomiTokens.typeCaption + 1,
                )
              : theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
