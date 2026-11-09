import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Telas de demonstração do preview de design (loop design — mocks
/// hardcoded pt-BR, sem backend). Estilo genérico Loomi: violeta, cantos
/// generosos, Material 3. Existem pra popular a grade/canvas/apresentação
/// com fluxos reais de navegação.
///
/// A navegação entre elas segue o `next` declarado em feature_registry.dart —
/// no protótipo os botões levam de verdade à próxima tela. Nas miniaturas do
/// /docs nada dispara: MiniPhoneFrame envolve tudo em IgnorePointer.
///
/// **Edge cases**: cada tela que tem estado alternativo recebe um
/// `enum XScenario` e constrói o estado inicial a partir dele — a mesma
/// classe serve o protótipo (onde o estado surge por interação) e o /docs
/// (onde a variação abre direto naquele estado). As variações estão
/// registradas em `RegisteredScreen.variants`, em feature_registry.dart.

const loomiViolet = Color(0xFF6C2BD9);

/// Tema do protótipo. Montado do zero, NÃO com `Theme.of(context).copyWith`:
/// nas miniaturas do /docs a tela roda dentro do tema do chrome de
/// documentação (design_tokens.dart), e herdar dali trazia inputs, chips e
/// superfícies do design system para dentro do app — o protótipo segue o
/// design do produto. Também garante que a miniatura seja idêntica à tela
/// cheia.
ThemeData _demoTheme(BuildContext context) => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: loomiViolet,
        brightness: Theme.of(context).brightness,
      ),
    );

class _DemoScaffold extends StatelessWidget {
  const _DemoScaffold({
    required this.body,
    this.title,
    this.backRoute,
    this.safeArea = true,
  });
  final Widget body;
  final String? title;
  final String? backRoute;

  /// `false` para tela de propósito full-bleed (splash): o fundo passa por
  /// baixo do notch, só o conteúdo fica centralizado.
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _demoTheme(context),
      child: Scaffold(
        appBar: title == null
            ? null
            : AppBar(
                title: Text(title!),
                leading: backRoute == null
                    ? null
                    : IconButton(
                        icon: const Icon(HugeIcons.strokeRoundedArrowLeft01),
                        onPressed: () => context.go(backRoute!),
                      ),
              ),
        body: safeArea ? SafeArea(child: body) : body,
      ),
    );
  }
}

void _naoImplementado(BuildContext context) =>
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ainda não faz parte do protótipo.'),
        duration: Duration(seconds: 2),
      ),
    );

// ── Peças dos edge cases ────────────────────────────────────────────────
//
// Locais de propósito: são andaimes do fluxo demo, não componentes do
// produto. Componente que vire padrão sobe pra core/components/ (e aí o
// commit precisa declarar "Mudanças em outros fluxos").

/// Painel de estado terminal — vazio ou erro. Ocupa a tela toda.
class _StatePanel extends StatelessWidget {
  const _StatePanel({
    required this.icon,
    required this.title,
    required this.message,
    this.tint,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color? tint;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final color = tint ?? loomiViolet;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 42),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.4),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 28),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: loomiViolet,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                ),
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Faixa de erro no topo de um formulário — o erro que não tira a tela do ar.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: error.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: error.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(HugeIcons.strokeRoundedAlertCircle, size: 18, color: error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: error, fontSize: 13, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bloco cinza de skeleton. Estático — animação de shimmer exigiria ticker
/// por bloco e não muda o que o designer precisa validar aqui.
class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.height, this.width, this.radius = 8});

  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ── Fluxo: Onboarding ───────────────────────────────────────────────────

class DemoSplashPage extends StatelessWidget {
  const DemoSplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _DemoScaffold(
      safeArea: false,
      body: GestureDetector(
        onTap: () => context.go('/demo/login'),
        child: Container(
          color: loomiViolet,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Center(
                    child: Text(
                      'L',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        color: loomiViolet,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'loomi demo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 40),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'toque para continuar',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Estados do Login. `senhaInvalida` é alcançável no protótipo: senha com
/// menos de 6 caracteres cai nele.
enum DemoLoginScenario { padrao, senhaInvalida, carregando }

class DemoLoginPage extends StatefulWidget {
  const DemoLoginPage({this.scenario = DemoLoginScenario.padrao, super.key});

  final DemoLoginScenario scenario;

  @override
  State<DemoLoginPage> createState() => _DemoLoginPageState();
}

class _DemoLoginPageState extends State<DemoLoginPage> {
  late DemoLoginScenario _estado;
  late final TextEditingController _email;
  late final TextEditingController _senha;

  @override
  void initState() {
    super.initState();
    _estado = widget.scenario;
    _email = TextEditingController(text: 'markus@loomi.com.br');
    // A variação de erro abre com o formulário já preenchido: erro em campo
    // vazio seria erro de validação, não de credencial.
    _senha = TextEditingController(
      text: _estado == DemoLoginScenario.padrao ? '' : '12345',
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    // Sem backend: senha curta é a credencial recusada do protótipo.
    if (_senha.text.length < 6) {
      setState(() => _estado = DemoLoginScenario.senhaInvalida);
      return;
    }
    setState(() => _estado = DemoLoginScenario.carregando);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    context.go('/demo/otp');
  }

  @override
  Widget build(BuildContext context) {
    final carregando = _estado == DemoLoginScenario.carregando;
    final erro = _estado == DemoLoginScenario.senhaInvalida;

    return _DemoScaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 36),
            // v3: marca no topo, antes do título. Align porque a Column é
            // `stretch` — sem ele o quadrado vira uma barra da largura toda.
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: loomiViolet,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text(
                    'L',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Bem-vindo de volta 👋',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Entre com seu e-mail corporativo.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            if (erro) ...[
              const _ErrorBanner('E-mail ou senha incorretos. Tente de novo.'),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _email,
              enabled: !carregando,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                prefixIcon: Icon(HugeIcons.strokeRoundedAt),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _senha,
              obscureText: true,
              enabled: !carregando,
              onChanged: (_) {
                // Digitar limpa o erro — não deixa a faixa vermelha presa.
                if (erro) setState(() => _estado = DemoLoginScenario.padrao);
              },
              decoration: InputDecoration(
                labelText: 'Senha',
                prefixIcon: const Icon(HugeIcons.strokeRoundedLock),
                border: const OutlineInputBorder(),
                errorText: erro ? 'Verifique sua senha' : null,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: loomiViolet,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: carregando ? null : _entrar,
              child: carregando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Entrar'),
            ),
            TextButton(
              onPressed: carregando ? null : () => _naoImplementado(context),
              child: const Text('Esqueci minha senha'),
            ),
            const Spacer(),
            // v3: caminho de conta nova, que antes não existia na tela.
            // Wrap e não Row: em tela estreita o par quebra em duas linhas em
            // vez de estourar.
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Não tem conta?',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                TextButton(
                  onPressed:
                      carregando ? null : () => _naoImplementado(context),
                  child: const Text('Criar conta'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Estados do OTP. `codigoInvalido` é alcançável no protótipo: confirmar com
/// menos de 6 dígitos cai nele.
enum DemoOtpScenario { padrao, codigoInvalido }

class DemoOtpPage extends StatefulWidget {
  const DemoOtpPage({this.scenario = DemoOtpScenario.padrao, super.key});

  final DemoOtpScenario scenario;

  @override
  State<DemoOtpPage> createState() => _DemoOtpPageState();
}

class _DemoOtpPageState extends State<DemoOtpPage> {
  late final TextEditingController _codigo;
  String? _erro;

  @override
  void initState() {
    super.initState();
    final invalido = widget.scenario == DemoOtpScenario.codigoInvalido;
    _codigo = TextEditingController(text: invalido ? '420417' : '420');
    if (invalido) _erro = 'Código inválido ou expirado.';
  }

  @override
  void dispose() {
    _codigo.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (_codigo.text.length < 6) {
      setState(() => _erro = 'Código incompleto — informe os 6 dígitos.');
      return;
    }
    context.go('/demo/home');
  }

  @override
  Widget build(BuildContext context) {
    final digitos = _codigo.text.split('');
    final erroCor = Theme.of(context).colorScheme.error;

    return _DemoScaffold(
      title: 'Verificação',
      backRoute: '/demo/login',
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Digite o código',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Enviamos 6 dígitos para ma***@loomi.com.br',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            // Caixas desenhadas + um TextField transparente por cima: o
            // teclado é o nativo, sem seis controllers e sem pacote novo.
            Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var i = 0; i < 6; i++)
                      Container(
                        width: 46,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _erro != null
                                ? erroCor
                                : i < digitos.length
                                    ? loomiViolet
                                    : Colors.grey.shade300,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          i < digitos.length ? digitos[i] : '',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                Positioned.fill(
                  child: TextField(
                    controller: _codigo,
                    autofocus: false,
                    showCursor: false,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    style: const TextStyle(color: Colors.transparent),
                    // collapsed: sem fundo, sem borda, sem padding — qualquer
                    // fill do tema pintaria por cima dos dígitos atrás.
                    decoration: const InputDecoration.collapsed(hintText: ''),
                    onChanged: (_) => setState(() => _erro = null),
                  ),
                ),
              ],
            ),
            if (_erro != null) ...[
              const SizedBox(height: 14),
              _ErrorBanner(_erro!),
            ],
            const SizedBox(height: 32),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: loomiViolet,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _confirmar,
              child: const Text('Confirmar'),
            ),
            TextButton(
              onPressed: () => _naoImplementado(context),
              child: const Text('Reenviar código'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estados da Home. `vazio` é a conta nova, sem nenhum pedido.
enum DemoHomeScenario { padrao, vazio, carregando }

class DemoHomePage extends StatelessWidget {
  const DemoHomePage({this.scenario = DemoHomeScenario.padrao, super.key});

  final DemoHomeScenario scenario;

  @override
  Widget build(BuildContext context) {
    return _DemoScaffold(
      body: switch (scenario) {
        DemoHomeScenario.padrao => _conteudo(context),
        DemoHomeScenario.vazio => _vazio(context),
        DemoHomeScenario.carregando => _carregando(),
      },
    );
  }

  Widget _saudacao() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Olá, Markus',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
          Text(
            'Terça, 15 de agosto',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      );

  Widget _conteudo(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 12),
        _saudacao(),
        const SizedBox(height: 20),
        // Card de pedidos em andamento: leva ao fluxo de Pedidos. É a ponte
        // entre as duas jornadas — está declarada em `next` no registry.
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.go('/demo/pedidos'),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [loomiViolet, Color(0xFF9D5CFF)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '3 pedidos em andamento',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '2 chegam hoje',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Icon(HugeIcons.strokeRoundedArrowRight01,
                    color: Colors.white70),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Atalhos',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _atalhos(context),
      ],
    );
  }

  Widget _atalhos(BuildContext context) {
    return Row(
      children: [
        for (final (icon, label, rota) in [
          (HugeIcons.strokeRoundedInvoice01, 'Pedidos', '/demo/pedidos'),
          (HugeIcons.strokeRoundedQrCode, 'Escanear', null),
          (HugeIcons.strokeRoundedCustomerSupport, 'Suporte', '/demo/suporte'),
        ])
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () =>
                  rota == null ? _naoImplementado(context) : context.go(rota),
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: loomiViolet.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(icon, color: loomiViolet),
                    const SizedBox(height: 6),
                    Text(label, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _vazio(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
          child: Align(alignment: Alignment.centerLeft, child: _saudacao()),
        ),
        Expanded(
          child: _StatePanel(
            icon: HugeIcons.strokeRoundedInbox,
            title: 'Nenhum pedido por aqui',
            message: 'Quando você receber um pedido, ele aparece nesta tela.',
            actionLabel: 'Escanear pedido',
            onAction: () => _naoImplementado(context),
          ),
        ),
      ],
    );
  }

  Widget _carregando() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 12),
        const _Skeleton(height: 28, width: 160),
        const SizedBox(height: 10),
        const _Skeleton(height: 14, width: 120),
        const SizedBox(height: 24),
        const _Skeleton(height: 96, radius: 20),
        const SizedBox(height: 24),
        const _Skeleton(height: 16, width: 80),
        const SizedBox(height: 14),
        Row(
          children: [
            for (var i = 0; i < 3; i++)
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: _Skeleton(height: 76, radius: 16),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ── Fluxo: Pedidos ──────────────────────────────────────────────────────

class DemoPedido {
  const DemoPedido(this.codigo, this.cliente, this.status, this.cor);
  final String codigo;
  final String cliente;
  final String status;
  final Color cor;
}

const demoPedidos = [
  DemoPedido('#1042', 'Padaria Estrela', 'Em rota', Colors.orange),
  DemoPedido('#1041', 'Mercado União', 'Entregue', Colors.green),
  DemoPedido('#1039', 'Café Central', 'Separando', loomiViolet),
  DemoPedido('#1038', 'Empório do Bairro', 'Em rota', Colors.orange),
  DemoPedido('#1037', 'Restaurante Sabor', 'Entregue', Colors.green),
  DemoPedido('#1036', 'Doceria Bem-me-quer', 'Separando', loomiViolet),
  DemoPedido('#1035', 'Hortifruti Vila Nova', 'Entregue', Colors.green),
  DemoPedido('#1034', 'Pizzaria Forno Alto', 'Em rota', Colors.orange),
  DemoPedido('#1033', 'Padaria São Jorge', 'Cancelado', Colors.redAccent),
  DemoPedido('#1032', 'Mercearia da Praça', 'Entregue', Colors.green),
  DemoPedido('#1031', 'Bistrô Aurora', 'Separando', loomiViolet),
  DemoPedido('#1030', 'Lanchonete do Zé', 'Entregue', Colors.green),
  DemoPedido('#1029', 'Confeitaria Lumiar', 'Em rota', Colors.orange),
  DemoPedido('#1028', 'Supermercado Ponto', 'Entregue', Colors.green),
  DemoPedido('#1027', 'Cantina Bella', 'Cancelado', Colors.redAccent),
  DemoPedido('#1026', 'Casa de Carnes Sul', 'Separando', loomiViolet),
  DemoPedido('#1025', 'Padaria Trigo Novo', 'Entregue', Colors.green),
  DemoPedido('#1024', 'Adega Vinho Certo', 'Em rota', Colors.orange),
];

class DemoPedidoCard extends StatelessWidget {
  const DemoPedidoCard({required this.pedido, this.onTap, super.key});
  final DemoPedido pedido;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: pedido.cor.withValues(alpha: 0.15),
          child: Icon(HugeIcons.strokeRoundedDeliveryTruck01,
              color: pedido.cor, size: 20),
        ),
        title: Text(pedido.cliente),
        subtitle: Text(pedido.codigo),
        trailing: Chip(
          label: Text(pedido.status, style: const TextStyle(fontSize: 11)),
          backgroundColor: pedido.cor.withValues(alpha: 0.12),
          side: BorderSide.none,
        ),
      ),
    );
  }
}

/// Estados da lista de pedidos. `vazio` é busca sem resultado / conta sem
/// pedido; `erro` é a falha de carregamento.
enum DemoPedidosScenario { padrao, vazio, erro, carregando }

class DemoPedidosPage extends StatefulWidget {
  const DemoPedidosPage({
    this.scenario = DemoPedidosScenario.padrao,
    super.key,
  });

  final DemoPedidosScenario scenario;

  @override
  State<DemoPedidosPage> createState() => _DemoPedidosPageState();
}

class _DemoPedidosPageState extends State<DemoPedidosPage> {
  late DemoPedidosScenario _estado;

  @override
  void initState() {
    super.initState();
    _estado = widget.scenario;
  }

  /// "Tentar de novo" no protótipo: passa por carregando e cai no happy path.
  Future<void> _recarregar() async {
    setState(() => _estado = DemoPedidosScenario.carregando);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _estado = DemoPedidosScenario.padrao);
  }

  @override
  Widget build(BuildContext context) {
    return _DemoScaffold(
      title: 'Pedidos',
      body: switch (_estado) {
        DemoPedidosScenario.padrao => _lista(context),
        DemoPedidosScenario.vazio => _StatePanel(
            icon: HugeIcons.strokeRoundedInvoice01,
            title: 'Nenhum pedido',
            message: 'Você ainda não tem pedidos registrados.',
            actionLabel: 'Voltar ao início',
            onAction: () => context.go('/demo/home'),
          ),
        DemoPedidosScenario.erro => _StatePanel(
            icon: HugeIcons.strokeRoundedNoInternet,
            title: 'Não foi possível carregar',
            message: 'Verifique sua conexão e tente novamente.',
            tint: Theme.of(context).colorScheme.error,
            actionLabel: 'Tentar de novo',
            onAction: _recarregar,
          ),
        DemoPedidosScenario.carregando => _carregando(),
      },
    );
  }

  Widget _lista(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const TextField(
          decoration: InputDecoration(
            hintText: 'Buscar pedido…',
            prefixIcon: Icon(HugeIcons.strokeRoundedSearch01),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        for (final p in demoPedidos)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: DemoPedidoCard(
              pedido: p,
              onTap: () => context.go('/demo/pedido'),
            ),
          ),
      ],
    );
  }

  Widget _carregando() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _Skeleton(height: 56, radius: 4),
        const SizedBox(height: 16),
        for (var i = 0; i < 4; i++)
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: _Skeleton(height: 72, radius: 16),
          ),
      ],
    );
  }
}

/// Estados do detalhe do pedido.
enum DemoPedidoDetalheScenario { padrao, erro }

class DemoPedidoDetalhePage extends StatefulWidget {
  const DemoPedidoDetalhePage({
    this.scenario = DemoPedidoDetalheScenario.padrao,
    super.key,
  });

  final DemoPedidoDetalheScenario scenario;

  @override
  State<DemoPedidoDetalhePage> createState() => _DemoPedidoDetalhePageState();
}

class _DemoPedidoDetalhePageState extends State<DemoPedidoDetalhePage> {
  late DemoPedidoDetalheScenario _estado;

  @override
  void initState() {
    super.initState();
    _estado = widget.scenario;
  }

  @override
  Widget build(BuildContext context) {
    return _DemoScaffold(
      title: 'Pedido #1042',
      backRoute: '/demo/pedidos',
      body: _estado == DemoPedidoDetalheScenario.erro
          ? _StatePanel(
              icon: HugeIcons.strokeRoundedAlertCircle,
              title: 'Pedido indisponível',
              message: 'Não conseguimos carregar os itens deste pedido.',
              tint: Theme.of(context).colorScheme.error,
              actionLabel: 'Tentar de novo',
              onAction: () =>
                  setState(() => _estado = DemoPedidoDetalheScenario.padrao),
            )
          : _detalhe(context),
    );
  }

  Widget _detalhe(BuildContext context) {
    const p = DemoPedido('#1042', 'Padaria Estrela', 'Em rota', Colors.orange);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const DemoPedidoCard(pedido: p),
        const SizedBox(height: 20),
        const Text(
          'Itens',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        for (final (item, qtd) in [
          ('Farinha especial 25kg', '4x'),
          ('Fermento biológico', '12x'),
          ('Açúcar refinado 5kg', '6x'),
        ])
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(HugeIcons.strokeRoundedPackage, size: 20),
            title: Text(item),
            trailing: Text(qtd),
          ),
        const Divider(),
        const SizedBox(height: 12),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: loomiViolet,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () => context.go('/demo/confirmacao'),
          child: const Text('Confirmar entrega'),
        ),
      ],
    );
  }
}

class DemoConfirmacaoPage extends StatelessWidget {
  const DemoConfirmacaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _DemoScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  HugeIcons.strokeRoundedTick02,
                  color: Colors.green,
                  size: 52,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Entrega confirmada!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'O pedido #1042 foi entregue à Padaria Estrela.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              OutlinedButton(
                onPressed: () => context.go('/demo/pedidos'),
                child: const Text('Voltar aos pedidos'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Fluxo demo: Suporte (entra só na release R2) ────────────────────────

/// Estados da lista de chamados.
enum DemoChamadosScenario { padrao, vazio }

class DemoChamadosPage extends StatefulWidget {
  const DemoChamadosPage(
      {this.scenario = DemoChamadosScenario.padrao, super.key});

  final DemoChamadosScenario scenario;

  @override
  State<DemoChamadosPage> createState() => _DemoChamadosPageState();
}

class _DemoChamadosPageState extends State<DemoChamadosPage> {
  late DemoChamadosScenario _estado = widget.scenario;

  static const _chamados = [
    ('Entrega atrasada', '#4821', 'Aberto'),
    ('Produto avariado', '#4818', 'Em análise'),
    ('Nota fiscal errada', '#4810', 'Resolvido'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _DemoScaffold(
      title: 'Suporte',
      body: switch (_estado) {
        DemoChamadosScenario.vazio => _StatePanel(
            icon: HugeIcons.strokeRoundedCustomerSupport,
            title: 'Nenhum chamado',
            message: 'Abra um chamado e acompanhe por aqui.',
            actionLabel: 'Abrir chamado',
            onAction: () => context.go('/demo/chamado'),
          ),
        DemoChamadosScenario.padrao => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final c in _chamados)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    tileColor: scheme.surfaceContainerHighest.withValues(
                      alpha: 0.4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: const Icon(
                      HugeIcons.strokeRoundedCustomerSupport,
                      size: 20,
                    ),
                    title: Text(c.$1),
                    subtitle: Text(c.$2),
                    trailing: Text(
                      c.$3,
                      style: TextStyle(fontSize: 12, color: scheme.primary),
                    ),
                    onTap: () => context.go('/demo/chamado'),
                  ),
                ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => context.go('/demo/chamado'),
                icon: const Icon(HugeIcons.strokeRoundedAdd01, size: 18),
                label: const Text('Abrir chamado'),
              ),
              TextButton(
                onPressed: () =>
                    setState(() => _estado = DemoChamadosScenario.vazio),
                child: const Text('Ver estado vazio'),
              ),
            ],
          ),
      },
    );
  }
}

/// Abertura de chamado — formulário curto, sem backend.
class DemoNovoChamadoPage extends StatelessWidget {
  const DemoNovoChamadoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _DemoScaffold(
      title: 'Novo chamado',
      backRoute: '/demo/suporte',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const TextField(
            decoration: InputDecoration(
              labelText: 'Assunto',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            minLines: 4,
            maxLines: 6,
            decoration: InputDecoration(
              labelText: 'Descrição',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => context.go('/demo/suporte'),
            child: const Text('Enviar chamado'),
          ),
        ],
      ),
    );
  }
}
