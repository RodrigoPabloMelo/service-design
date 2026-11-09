import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';

/// Tela de exemplo do loop de design — auto-contida (sem AppI18n, sem
/// bootstrap, sem services de core/). Use como referência do que uma tela
/// de design pode importar.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Boas-vindas')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(HugeIcons.strokeRoundedRocket01, size: 64),
            const SizedBox(height: 16),
            Text(
              'Seu app está no ar',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('Peça uma tela nova ao Claude para começar.'),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => context.go('/demo/splash'),
              child: const Text('Ver o fluxo demo'),
            ),
          ],
        ),
      ),
    );
  }
}
