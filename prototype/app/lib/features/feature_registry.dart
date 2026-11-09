import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
// Só para os exemplos da Biblioteca (as telas de demo não são registradas).
import 'package:studio_app/features/demo/demo_screens.dart';
import 'package:studio_app/features/travel_agent/data/travel_agent_mock.dart';
import 'package:studio_app/features/travel_agent/presentation/views/travel_agent_page.dart';

/// Registro das telas visíveis no loop de design.
///
/// Cada tela criada via /vibe-create-ui entra aqui — o hub
/// (design_hub_page.dart) e o router de main_design.dart leem desta lista.
/// Na branch `develop`, uma feature só permanece registrada após o PR do
/// refactor ser aprovado.
///
/// `flow` agrupa telas na grade e no canvas do preview; `next` são as rotas
/// de destino da navegação (viram as setas do canvas). Ambos opcionais.
///
/// `variants` são os edge cases da tela (erro, vazio, carregando). Cada
/// variação aponta para um cenário do eixo global `designScenarios` — é o
/// que permite pré-selecionar um cenário no /docs e ver TODAS as telas que
/// o cobrem mudarem de uma vez.
class RegisteredScreen {
  const RegisteredScreen({
    required this.title,
    required this.route,
    required this.builder,
    this.flow = 'Geral',
    this.next = const [],
    this.variants = const [],
    this.descricao,
    this.links = const [],
    this.version = 'v1',
    this.previousVersions = const [],
  });

  final String title;
  final String route;
  final WidgetBuilder builder;
  final String flow;
  final List<String> next;
  final List<ScreenVariant> variants;

  /// Descrição da tela e links de referência (Figma, ticket, spec) que vão
  /// para o handoff do dev.
  ///
  /// No /docs o designer edita esses campos e o rascunho fica no
  /// localStorage do browser dele. Ao fechar o fluxo (`[ready]`), o rascunho
  /// é movido para cá — é o que entra no repo e chega no dev.
  final String? descricao;
  final List<DocLink> links;

  /// Rótulo da versão que está no ar. `builder` é SEMPRE ela: o protótipo e o
  /// device_preview nunca mostram versão antiga.
  final String version;

  /// Versões fechadas, da mais nova para a mais antiga. Não carregam widget:
  /// carregam a identidade no git. Ver [ScreenVersion].
  final List<ScreenVersion> previousVersions;
}

/// Uma versão fechada de uma tela.
///
/// Não guarda widget nem imagem: guarda o commit. A tela daquele dia é o build
/// daquele commit, publicado pelo deploy em `/v/<commit>/` — a doc mostra esse
/// build num iframe, então a versão antiga é interativa e congelada de verdade,
/// sem duplicar código no repo nem carregar PNG.
///
/// Versão sem build publicado (qualquer uma anterior a essa mudança no deploy)
/// aparece como ficha com commit e link do diff.
class ScreenVersion {
  const ScreenVersion({
    required this.label,
    required this.date,
    required this.commit,
    this.note,
  });

  /// Rótulo curto: `v1`, `v2`.
  final String label;

  /// Data de fechamento, absoluta (`2026-08-20`).
  final String date;

  /// SHA curto do commit — a identidade da versão e o caminho do build.
  final String commit;

  /// O que mudou depois dela.
  final String? note;
}

/// Link de referência de uma tela.
class DocLink {
  const DocLink(this.nome, this.url);

  final String nome;
  final String url;
}

/// Um edge case de uma tela: o mesmo widget num estado diferente.
///
/// O builder deve construir a MESMA classe de tela passando o cenário como
/// estado inicial (padrão `enum XScenario` do loop de design) — nunca uma
/// tela nova só para o erro. `note` explica como a pessoa chega nesse
/// estado; é o que o dev lê no handoff.
class ScreenVariant {
  const ScreenVariant({
    required this.scenario,
    required this.builder,
    this.note,
  });

  final String scenario;
  final WidgetBuilder builder;
  final String? note;
}

/// Cenário base: toda tela existe nele, e ele não é um `ScreenVariant`.
const kScenarioDefault = 'Padrão';

/// Eixos de cenário do preview, na ordem em que aparecem no seletor.
///
/// Lista explícita e não derivada das telas: a ordem importa (erro primeiro,
/// é o que se olha antes) e um cenário novo deve ser uma decisão, não um
/// efeito colateral de registrar uma variação. O teste
/// `scenarios_test.dart` falha se alguma tela declarar cenário fora daqui.
const designScenarios = ['Erro', 'Vazio', 'Carregando'];

/// Slug de um fluxo na URL: `Login e autenticação` → `login-e-autenticacao`.
String flowSlug(String flow) {
  const acentos = {
    'á': 'a',
    'ã': 'a',
    'â': 'a',
    'à': 'a',
    'ç': 'c',
    'é': 'e',
    'ê': 'e',
    'í': 'i',
    'ó': 'o',
    'ô': 'o',
    'õ': 'o',
    'ú': 'u',
  };
  var slug = flow.toLowerCase();
  acentos.forEach((de, para) => slug = slug.replaceAll(de, para));
  return slug.replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(
        RegExp(r'^-|-$'),
        '',
      );
}

/// Fluxo cujo slug bate — null quando o slug não existe no registro.
String? flowFromSlug(String? slug, List<RegisteredScreen> screens) {
  if (slug == null) return null;
  for (final s in screens) {
    if (flowSlug(s.flow) == slug) return s.flow;
  }
  return null;
}

/// Valor do query param `?cenario=` para um cenário. `Padrão` → `padrao`.
String scenarioSlug(String scenario) {
  const accents = {'á': 'a', 'ã': 'a', 'â': 'a', 'ç': 'c', 'é': 'e', 'ê': 'e'};
  var slug = scenario.toLowerCase();
  accents.forEach((from, to) => slug = slug.replaceAll(from, to));
  return slug;
}

/// Cenário cujo slug bate com `slug`, ou null (inclui `Padrão`).
String? scenarioFromSlug(String? slug) {
  if (slug == null) return null;
  for (final s in [kScenarioDefault, ...designScenarios]) {
    if (scenarioSlug(s) == slug) return s;
  }
  return null;
}

extension RegisteredScreenVariants on RegisteredScreen {
  /// Builder da tela no cenário pedido. Cai no padrão quando o cenário é
  /// nulo, é o próprio padrão, ou a tela não tem variação para ele — é o
  /// que faz o seletor global não quebrar em tela sem edge case.
  WidgetBuilder builderFor(String? scenario) {
    if (scenario == null || scenario == kScenarioDefault) return builder;
    for (final v in variants) {
      if (v.scenario == scenario) return v.builder;
    }
    return builder;
  }

  bool hasScenario(String scenario) =>
      variants.any((v) => v.scenario == scenario);

  /// Cenários cobertos pela tela, na ordem de `designScenarios`.
  List<String> get scenarios => [
        for (final s in designScenarios)
          if (hasScenario(s)) s,
      ];
}

/// Cor de exemplo dos componentes da Biblioteca do hub.
const _libraryAccent = Color(0xFF6C2BD9);

final designScreens = <RegisteredScreen>[
  // ── Agente de roteiros "Maré" (etapa 05 do blueprint) ──
  RegisteredScreen(
    title: 'Agente de roteiros',
    route: '/agente',
    flow: 'Agente',
    descricao: 'Maré organiza os rolês de local salvos por dia e distância, '
        'mostra o roteiro no mapa, salva na Google Agenda e oferece extras.',
    builder: (_) => const TravelAgentPage(),
    variants: [
      ScreenVariant(
        scenario: 'Carregando',
        note: 'Maré montando o roteiro: passos visíveis enquanto pensa.',
        builder: (_) => const TravelAgentPage(
          scenario: TravelAgentScenario.carregando,
        ),
      ),
      ScreenVariant(
        scenario: 'Vazio',
        note: 'Começo do zero: abre no mapa com a saudação; a Maré puxa '
            'indicações da curadoria e os pins caem no mapa.',
        builder: (_) => const TravelAgentPage(
          scenario: TravelAgentScenario.vazio,
        ),
      ),
      ScreenVariant(
        scenario: 'Erro',
        note: 'Agente fora do ar: salvos preservados e tentar de novo.',
        builder: (_) => const TravelAgentPage(
          scenario: TravelAgentScenario.erro,
        ),
      ),
    ],
  ),
];

/// Uma release — o lançamento. Agrupa JORNADAS (fluxos), não telas: é o
/// recorte "o que entra no ar nesta leva".
///
/// Não confundir com a versão da tela (`RegisteredScreen.version`), que é o
/// histórico de UMA tela e vive só na doc dela. Aqui é o eixo do hub: o
/// designer escolhe a release e vê os fluxos daquele lançamento.
class DesignRelease {
  const DesignRelease({
    required this.label,
    required this.date,
    required this.flows,
    this.note,
  });

  /// Rótulo curto: `R1`, `R2`.
  final String label;

  /// Data prevista/­realizada, absoluta (`2026-09-30`).
  final String date;

  /// Fluxos que entram nesta release, pelo nome usado em
  /// `RegisteredScreen.flow`.
  final List<String> flows;

  final String? note;
}

/// Releases do projeto, da mais nova para a mais antiga.
const designReleases = [
  DesignRelease(
    label: 'R1',
    date: '2026-12-05',
    flows: ['Agente'],
    note: 'Agente de roteiros Maré (etapa 05 do blueprint).',
  ),
];

/// Registro da biblioteca de componentes (aba "Biblioteca" do hub — o
/// assets panel do Figma, só que vivo). Todo widget reutilizável criado em
/// `core/components/` deve ser registrado aqui com um exemplo de uso.
class RegisteredComponent {
  const RegisteredComponent({
    required this.title,
    required this.builder,
    this.group = 'Geral',
    this.descricao,
    this.knobs = const [],
    this.variants = const [],
    this.snippet,
  });

  final String title;
  final String group;

  /// Como o componente é montado. Recebe os valores dos [knobs] — sem knobs
  /// declarados, o mapa vem vazio e o builder ignora.
  final Widget Function(BuildContext context, KnobValues knobs) builder;

  /// Uma linha sobre para que serve. Aparece no cabeçalho da ficha.
  final String? descricao;

  /// Controles que a pessoa mexe no painel (texto, liga/desliga, opção).
  final List<Knob> knobs;

  /// Estados fixos do componente (Desabilitado, Carregando, Erro). São
  /// mostrados juntos abaixo do palco — é o que o Widgetbook chama de
  /// use cases.
  final List<ComponentVariant> variants;

  /// Trecho de uso para copiar. Sem ele, a ficha esconde o bloco.
  final String? snippet;

  /// Slug do componente na URL: `Botão primário` → `botao-primario`.
  String get slug => flowSlug('$group $title');
}

/// Um estado nomeado do componente.
class ComponentVariant {
  const ComponentVariant({
    required this.label,
    required this.builder,
    this.note,
  });

  final String label;
  final WidgetBuilder builder;
  final String? note;
}

/// Controle do painel da Biblioteca. Três tipos cobrem o que os componentes
/// deste projeto precisam: texto, liga/desliga e escolha entre opções.
sealed class Knob {
  const Knob(this.label);
  final String label;
}

class KnobTexto extends Knob {
  const KnobTexto(super.label, this.inicial);
  final String inicial;
}

class KnobBool extends Knob {
  const KnobBool(super.label, {this.inicial = true});
  final bool inicial;
}

class KnobOpcao extends Knob {
  const KnobOpcao(super.label, this.opcoes);
  final List<String> opcoes;
}

/// Valores atuais dos knobs, lidos pelo builder do componente.
class KnobValues {
  const KnobValues(this._valores);

  /// Valor inicial de cada knob — o estado de partida do painel.
  factory KnobValues.iniciais(List<Knob> knobs) => KnobValues({
        for (final k in knobs)
          k.label: switch (k) {
            KnobTexto() => k.inicial,
            KnobBool() => k.inicial,
            KnobOpcao() => k.opcoes.first,
          },
      });

  final Map<String, Object> _valores;

  String texto(String label, [String fallback = '']) =>
      _valores[label] is String ? _valores[label]! as String : fallback;

  bool ativo(String label, {bool fallback = true}) =>
      _valores[label] is bool ? _valores[label]! as bool : fallback;

  String opcao(String label, [String fallback = '']) =>
      _valores[label] is String ? _valores[label]! as String : fallback;

  KnobValues com(String label, Object valor) =>
      KnobValues({..._valores, label: valor});
}

final designComponents = <RegisteredComponent>[
  RegisteredComponent(
    title: 'Botão primário',
    group: 'Ações',
    descricao: 'Ação principal da tela. Uma por tela, sempre.',
    knobs: const [
      KnobTexto('Rótulo', 'Continuar'),
      KnobBool('Habilitado'),
      KnobBool('Largura total', inicial: false),
    ],
    builder: (context, k) {
      final botao = FilledButton(
        style: FilledButton.styleFrom(backgroundColor: _libraryAccent),
        onPressed: k.ativo('Habilitado') ? () {} : null,
        child: Text(k.texto('Rótulo', 'Continuar')),
      );
      return k.ativo('Largura total', fallback: false)
          ? SizedBox(width: 280, child: botao)
          : botao;
    },
    variants: [
      ComponentVariant(
        label: 'Desabilitado',
        note: 'Sem ação disponível — o formulário ainda não está válido.',
        builder: (_) => const FilledButton(
          onPressed: null,
          child: Text('Continuar'),
        ),
      ),
      ComponentVariant(
        label: 'Carregando',
        note: 'Enquanto a ação corre: rótulo sai, indicador entra.',
        builder: (_) => FilledButton(
          style: FilledButton.styleFrom(backgroundColor: _libraryAccent),
          onPressed: () {},
          child: const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ],
    snippet:
        "FilledButton(\n  onPressed: habilitado ? _enviar : null,\n  child: const Text('Continuar'),\n)",
  ),
  RegisteredComponent(
    title: 'Campo de texto',
    group: 'Formulário',
    descricao: 'Entrada de uma linha, com rótulo e ícone opcionais.',
    knobs: const [
      KnobTexto('Rótulo', 'E-mail'),
      KnobOpcao('Estado', ['Padrão', 'Erro', 'Desabilitado']),
      KnobBool('Com ícone'),
    ],
    builder: (context, k) {
      final estado = k.opcao('Estado', 'Padrão');
      return SizedBox(
        width: 280,
        child: TextField(
          enabled: estado != 'Desabilitado',
          decoration: InputDecoration(
            labelText: k.texto('Rótulo', 'E-mail'),
            prefixIcon: k.ativo('Com ícone')
                ? const Icon(HugeIcons.strokeRoundedAt)
                : null,
            errorText: estado == 'Erro' ? 'Informe um e-mail válido' : null,
            border: const OutlineInputBorder(),
          ),
        ),
      );
    },
    snippet:
        "TextField(\n  decoration: InputDecoration(\n    labelText: 'E-mail',\n    errorText: erro,\n  ),\n)",
  ),
  RegisteredComponent(
    title: 'Chip de status',
    group: 'Dados',
    descricao: 'Estado curto de um registro. A cor carrega o significado.',
    knobs: const [
      KnobTexto('Texto', 'Entregue'),
      KnobOpcao('Tom', ['Sucesso', 'Atenção', 'Erro', 'Neutro']),
    ],
    builder: (context, k) {
      final tom = switch (k.opcao('Tom', 'Sucesso')) {
        'Atenção' => Colors.orange,
        'Erro' => Colors.red,
        'Neutro' => Colors.blueGrey,
        _ => Colors.green,
      };
      return Chip(
        label: Text(
          k.texto('Texto', 'Entregue'),
          style: const TextStyle(fontSize: 12),
        ),
        backgroundColor: tom.withValues(alpha: 0.12),
        side: BorderSide.none,
        labelStyle: TextStyle(color: tom),
        avatar: Icon(
          HugeIcons.strokeRoundedCheckmarkCircle02,
          size: 16,
          color: tom,
        ),
      );
    },
  ),
  RegisteredComponent(
    title: 'Card de pedido',
    group: 'Dados',
    descricao: 'Linha da lista de pedidos: cliente, número e status.',
    knobs: const [
      KnobTexto('Cliente', 'Padaria Estrela'),
      KnobTexto('Número', '#1042'),
      KnobOpcao('Status', ['Em rota', 'Entregue', 'Separando']),
    ],
    builder: (context, k) {
      final status = k.opcao('Status', 'Em rota');
      final cor = switch (status) {
        'Entregue' => Colors.green,
        'Separando' => _libraryAccent,
        _ => Colors.orange,
      };
      return SizedBox(
        width: 320,
        child: DemoPedidoCard(
          pedido: DemoPedido(
            k.texto('Número', '#1042'),
            k.texto('Cliente', 'Padaria Estrela'),
            status,
            cor,
          ),
        ),
      );
    },
  ),
];
