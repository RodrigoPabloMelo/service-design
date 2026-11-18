import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Liquid Glass do app — wrappers finos sobre `liquid_glass_widgets`.
///
/// Por que wrappers: as telas de design importam só `material` + `App*`;
/// a dependência fica isolada aqui e pode ser trocada sem mexer nas telas.
///
/// Regras (HIG · iOS 26):
/// - Vidro só na camada de controles flutuantes, sobre o [AppGlassScope.background].
/// - Nada de vidro sobre vidro, nem sobre superfícies sólidas: no web o vidro
///   refrata o fundo amostrado, não o que está logo atrás dele.
/// - Increase Contrast (`MediaQuery.highContrastOf`) troca vidro por sólido.
/// - Celular no navegador ([AppEffects.lite]) usa as versões leves.

/// Pré-aquece os shaders do Liquid Glass (chamar antes do `runApp`).
Future<void> initAppGlass() =>
    LiquidGlassWidgets.initialize(enablePerformanceMonitor: false);

/// Nível dos efeitos caros (desfoque, vidro, animação de fundo).
///
/// No navegador o Flutter (CanvasKit) redesenha a cena inteira a cada quadro,
/// sem cache: cada `BackdropFilter` vira uma leitura da tela na GPU, e a GPU
/// de celular sente isso muito mais que a de desktop. No celular os efeitos
/// têm versão leve — vidro minimal, menos faixas no desfoque progressivo,
/// frost sem blur e aurora a ~15 fps. O desktop fica com o visual cheio.
abstract final class AppEffects {
  static bool? _lite;

  /// Versões leves ligadas?
  static bool get lite => _lite ??= _detect(Uri.base);

  /// Lê `?efeitos=leve` ou `?efeitos=completo` da URL (o parâmetro vence a
  /// detecção). Chamar no `main()`, antes do `runApp`: o redirect de `/` pra
  /// primeira tela descarta a query.
  static void init([Uri? uri]) => _lite = _detect(uri ?? Uri.base);

  /// Força o nível em teste; `null` volta à detecção.
  @visibleForTesting
  static void debugOverride(bool? lite) => _lite = lite;

  static bool _detect(Uri uri) {
    switch (uri.queryParameters['efeitos']) {
      case 'leve':
        return true;
      case 'completo':
        return false;
    }
    // No web o Flutter deduz o sistema pelo navegador (iPad com UA de
    // desktop conta como iOS). Fora do web (testes, app nativo): cheio.
    return kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android);
  }
}

/// Desfoque do que está atrás, recortado pela forma (`BackdropFilter`).
/// No modo leve ([AppEffects.lite]) não desfoca: [liteColor] pinta atrás do
/// filho pra manter a leitura sobre o conteúdo.
class AppBackdropBlur extends StatelessWidget {
  const AppBackdropBlur({
    required this.sigma,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.circle = false,
    this.liteColor,
    super.key,
  });

  final double sigma;
  final Widget child;
  final BorderRadius borderRadius;

  /// Recorte circular em vez de [borderRadius].
  final bool circle;

  /// Véu extra só no modo leve (o blur deixava o fundo menos legível).
  final Color? liteColor;

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (AppEffects.lite || sigma <= 0.05) {
      final veil = liteColor;
      body = !AppEffects.lite || veil == null
          ? child
          : DecoratedBox(
              decoration: BoxDecoration(
                color: veil,
                shape: circle ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: circle ? null : borderRadius,
              ),
              child: child,
            );
    } else {
      body = BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: child,
      );
    }
    return circle
        ? ClipOval(child: body)
        : ClipRRect(borderRadius: borderRadius, child: body);
  }
}

/// Raiz da tela com vidro: [background] é amostrado para a refração (web via
/// CanvasKit) e continua interativo; [child] é a camada de controles.
class AppGlassScope extends StatelessWidget {
  const AppGlassScope({
    required this.background,
    required this.child,
    super.key,
  });

  final Widget background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final dark = brightness == Brightness.dark;
    final highContrast = MediaQuery.highContrastOf(context);
    return CupertinoTheme(
      // O pacote resolve claro/escuro pelo CupertinoTheme (sem Material).
      data: CupertinoThemeData(brightness: brightness),
      child: LiquidGlassScope(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: GlassBackgroundSource(
                enabled: !highContrast,
                child: background,
              ),
            ),
            Positioned.fill(
              child: AdaptiveLiquidGlassLayer(
                // Celular: minimal (tinte + aro, sem shader). Os botões
                // interativos ficam sem BackdropFilter — cada um custava uma
                // leitura da tela por quadro. Os filhos herdam a qualidade.
                quality: AppEffects.lite ? GlassQuality.minimal : null,
                settings: LiquidGlassSettings(
                  glassColor: dark
                      ? const Color(0x33061F23)
                      : const Color(0x40FFFFFF),
                  thickness: 22,
                  blur: 7,
                  lightIntensity: 0.6,
                  saturation: 1.35,
                  glowIntensity: 0.4,
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Superfície de vidro (barras, pílulas flutuantes).
class AppGlassSurface extends StatelessWidget {
  const AppGlassSurface({
    required this.child,
    this.radius = 22,
    this.padding,
    this.width,
    this.height,
    super.key,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.highContrastOf(context)) {
      return _SolidFallback(
        radius: radius,
        padding: padding,
        width: width,
        height: height,
        child: child,
      );
    }
    return GlassContainer(
      shape: LiquidRoundedSuperellipse(borderRadius: radius),
      padding: padding,
      width: width,
      height: height,
      child: child,
    );
  }
}

/// Botão circular de vidro, 44pt (alvo mínimo do HIG).
class AppGlassIconButton extends StatelessWidget {
  const AppGlassIconButton({
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.color,
    this.size = 44,
    super.key,
  });

  /// Qualquer glifo (ex.: `FaIcon`) — recebe cor e tamanho via [IconTheme].
  final Widget icon;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? Theme.of(context).colorScheme.onSurface;
    if (MediaQuery.highContrastOf(context)) {
      return Semantics(
        button: true,
        label: semanticLabel,
        child: GestureDetector(
          onTap: onPressed,
          child: _SolidFallback(
            radius: size / 2,
            width: size,
            height: size,
            child: IconTheme(data: IconThemeData(size: 18, color: fg), child: icon),
          ),
        ),
      );
    }
    return GlassIconButton(
      icon: IconTheme(data: IconThemeData(size: 18, color: fg), child: icon),
      onPressed: onPressed,
      size: size,
      semanticLabel: semanticLabel,
    );
  }
}

/// Botão "fosco" para usar SOBRE foto ou vídeo (fora do fundo amostrado):
/// blur real do que está atrás + véu escuro. 44pt. No modo leve, só o véu
/// (mais denso, sem blur).
class AppFrostButton extends StatelessWidget {
  const AppFrostButton({
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.size = 44,
    this.label,
    super.key,
  });

  /// Qualquer glifo (ex.: `FaIcon`) — recebe cor e tamanho via [IconTheme].
  final Widget icon;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final double size;

  /// Texto opcional ao lado do ícone (vira pílula).
  final String? label;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size / 2);
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      onTap: onPressed,
      child: AppBackdropBlur(
        sigma: 14,
        borderRadius: radius,
        // 0x33 sob o 0x52 do Material ≈ 0x73 de véu no total.
        liteColor: const Color(0x33000000),
        child: Material(
          color: const Color(0x52000000),
          child: InkWell(
            onTap: onPressed,
            child: Container(
              height: size,
              constraints: BoxConstraints(minWidth: size),
              padding: label == null
                  ? null
                  : const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(color: const Color(0x33FFFFFF)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconTheme(
                    data: const IconThemeData(size: 17, color: Colors.white),
                    child: icon,
                  ),
                  if (label != null) ...[
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        label!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Blur gaussiano para conteúdo (ex.: itens laterais de carrossel).
/// No modo leve não desfoca (cada item desfocado era um saveLayer).
class AppBlur extends StatelessWidget {
  const AppBlur({required this.sigma, required this.child, super.key});

  final double sigma;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (sigma <= 0.05 || AppEffects.lite) return child;
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(
        sigmaX: sigma,
        sigmaY: sigma,
        tileMode: TileMode.decal,
      ),
      child: child,
    );
  }
}

class _SolidFallback extends StatelessWidget {
  const _SolidFallback({
    required this.child,
    required this.radius,
    this.padding,
    this.width,
    this.height,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      padding: padding,
      alignment: width != null && height != null ? Alignment.center : null,
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF15393F) : Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: dark ? const Color(0xFFEAF6F4) : const Color(0xFF0B2B30),
          width: 1.5,
        ),
      ),
      child: child,
    );
  }
}
