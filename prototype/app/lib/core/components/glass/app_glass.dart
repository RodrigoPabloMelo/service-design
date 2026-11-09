import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
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

/// Pré-aquece os shaders do Liquid Glass (chamar antes do `runApp`).
Future<void> initAppGlass() =>
    LiquidGlassWidgets.initialize(enablePerformanceMonitor: false);

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
/// blur real do que está atrás + véu escuro. 44pt.
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
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
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
      ),
    );
  }
}

/// Blur gaussiano para conteúdo (ex.: itens laterais de carrossel).
class AppBlur extends StatelessWidget {
  const AppBlur({required this.sigma, required this.child, super.key});

  final double sigma;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (sigma <= 0.05) return child;
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
