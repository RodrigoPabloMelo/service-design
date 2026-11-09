import 'package:flutter/material.dart';
import 'package:studio_app/features/feature_registry.dart';

/// Tema do PREVIEW de design (claro/escuro), independente do tema do app.
/// O toggle vive na AppBar do hub; o MaterialApp de main_design.dart escuta.
final ValueNotifier<ThemeMode> designThemeMode =
    ValueNotifier<ThemeMode>(ThemeMode.light);

void toggleDesignTheme() {
  designThemeMode.value = designThemeMode.value == ThemeMode.dark
      ? ThemeMode.light
      : ThemeMode.dark;
}

/// Cenário pré-selecionado do preview (null = `Padrão`).
///
/// Global e não parâmetro: `MiniPhoneFrame` resolve a variação sozinho, então
/// grade, canvas, apresentação e subpágina de doc trocam de estado juntas sem
/// ninguém passar builder na mão. Mesmo padrão de `designThemeMode`.
final ValueNotifier<String?> designScenario = ValueNotifier<String?>(null);

/// Release pré-selecionada do hub (null = todas).
///
/// Segundo eixo global, irmão de [designScenario]: a release é o LANÇAMENTO
/// e agrupa jornadas inteiras, então escolher uma aqui recorta os fluxos
/// visíveis na sidebar, na grade e no canvas.
///
/// Versão de tela não mora aqui: ela é o histórico de uma tela só e vive na
/// doc dela (`/docs/<slug>`).
final ValueNotifier<String?> designRelease = ValueNotifier<String?>(null);

/// A release com esse rótulo, ou null (inclui "todas").
DesignRelease? releaseNamed(String? label) {
  if (label == null) return null;
  for (final r in designReleases) {
    if (r.label == label) return r;
  }
  return null;
}

/// Releases que levam esse fluxo, da mais nova para a mais antiga.
List<DesignRelease> releasesOfFlow(String flow) => [
      for (final r in designReleases)
        if (r.flows.contains(flow)) r,
    ];
