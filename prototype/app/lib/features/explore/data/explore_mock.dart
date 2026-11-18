import 'package:studio_app/features/explore/domain/explore_entities.dart';
import 'package:studio_app/features/travel_agent/data/travel_agent_mock.dart';
import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';

/// Cenários de design da home (variações do registry).
enum ExploreScenario { padrao, carregando, erro }

/// Card de categoria: foto de um lugar daqui + ícone ilustrado.
class ExploreCategoryInfo {
  const ExploreCategoryInfo({
    required this.category,
    required this.label,
    required this.icon,
    required this.photo,
  });

  final ExploreCategory category;
  final String label;

  /// SVG desenhado pela equipe (`assets/icons/categories/`).
  final String icon;

  /// Foto do Commons (`assets/images/explore/CREDITS.md`).
  final String photo;
}

/// Sugestão do "Onde?" (ref. Airbnb): ilustração + nome + uma linha.
class PlaceSuggestion {
  const PlaceSuggestion({
    required this.place,
    required this.label,
    required this.line,
    required this.icon,
  });

  /// Valor da busca ([SearchQuery.place]).
  final String place;
  final String label;
  final String line;

  /// SVG de traço (`assets/icons/places/`).
  final String icon;
}

/// Dados mockados da home. Reaproveita os rolês do agente ([TravelMock]) e
/// soma três rolês reais do Recife Antigo. Quem indica e @handles são
/// fictícios; lugares e fotos são reais.
abstract final class ExploreMock {
  static const _icons = 'assets/icons/categories';
  static const _img = 'assets/images/explore';

  static const profile = TravelMock.profile;

  static const categories = [
    ExploreCategoryInfo(
      category: ExploreCategory.restaurantes,
      label: 'Restaurantes',
      icon: '$_icons/restaurantes.svg',
      photo: '$_img/restaurantes_regional.jpg',
    ),
    ExploreCategoryInfo(
      category: ExploreCategory.cafe,
      label: 'Café',
      icon: '$_icons/cafe.svg',
      photo: '$_img/cafe_bolo_de_rolo.jpg',
    ),
    ExploreCategoryInfo(
      category: ExploreCategory.museu,
      label: 'Museu',
      icon: '$_icons/museu.svg',
      photo: '$_img/museu_paco_frevo.jpg',
    ),
    ExploreCategoryInfo(
      category: ExploreCategory.cultura,
      label: 'Cultura',
      icon: '$_icons/cultura.svg',
      photo: '$_img/cultura_santa_isabel.jpg',
    ),
    ExploreCategoryInfo(
      category: ExploreCategory.arte,
      label: 'Arte',
      icon: '$_icons/arte.svg',
      photo: '$_img/arte_torre_cristal.jpg',
    ),
    ExploreCategoryInfo(
      category: ExploreCategory.historia,
      label: 'História',
      icon: '$_icons/historia.svg',
      photo: '$_img/historia_bom_jesus.jpg',
    ),
  ];

  static ExploreCategoryInfo categoryInfo(ExploreCategory c) =>
      categories.firstWhere((i) => i.category == c);

  /// "Hoje" do protótipo: antes da viagem (14 a 16 nov), pra o calendário
  /// não riscar as datas do roteiro.
  static final today = DateTime(2026, 11, 10);

  /// Sugestões do "Onde?": só o piloto (D-10) e "Por perto".
  static const placeSuggestions = [
    PlaceSuggestion(
      place: SearchQuery.nearHotel,
      label: 'Por perto',
      line: 'Rolês perto da sua hospedagem',
      icon: 'assets/icons/places/perto.svg',
    ),
    PlaceSuggestion(
      place: 'Recife',
      label: 'Recife',
      line: 'Por lugares como o Paço do Frevo',
      icon: 'assets/icons/places/recife.svg',
    ),
    PlaceSuggestion(
      place: 'Olinda',
      label: 'Olinda',
      line: 'Ladeiras e casario do Sítio Histórico',
      icon: 'assets/icons/places/olinda.svg',
    ),
  ];

  /// Bairros de Olinda (nenhum rolê curado ainda — a busca diz isso).
  static const olindaNeighborhoods = {'Olinda', 'Carmo', 'Amparo'};

  static String cityOf(Role r) =>
      olindaNeighborhoods.contains(r.neighborhood) ? 'Olinda' : 'Recife';

  /// O que dá pra buscar digitando: cidades e bairros com rolê curado.
  static List<(String place, String detail)> get searchablePlaces => [
        ('Recife', 'Pernambuco'),
        ('Olinda', 'Pernambuco'),
        for (final n in {for (final r in roles) r.neighborhood})
          (n, cityOf(roleById(roles.firstWhere((r) => r.neighborhood == n).id))),
      ];

  /// Dias da viagem (14 a 16 nov) — rótulos curtos da busca.
  static const tripDays = ['Sex, 14', 'Sáb, 15', 'Dom, 16'];
  static const tripDaysShort = ['sex', 'sáb', 'dom'];

  /// Bairros com rolê curado (chips do "Onde?").
  static const neighborhoods = [
    'Recife Antigo',
    'Boa Vista',
    'Poço da Panela',
    'Casa Amarela',
    'Encruzilhada',
    'Boa Viagem',
  ];

  // ── Rolês novos (Recife Antigo) ──────────────────────────────────────
  static const pacoDoFrevo = Role(
    id: 'paco-do-frevo',
    name: 'Aula de passo no Paço do Frevo',
    shortName: 'Paço do Frevo',
    neighborhood: 'Recife Antigo',
    category: RoleCategory.cultura,
    location: GeoPoint(-8.0617, -34.8711),
    price: r'$',
    hours: 'Ter a dom, durante o dia',
    photos: [
      PhotoCredit(
        asset: '$_img/museu_paco_frevo.jpg',
        author: 'Luiz maciel silva',
        license: 'CC BY-SA 4.0',
      ),
      PhotoCredit(
        asset: '$_img/paco_frevo_2.jpg',
        author: 'Joelkaula',
        license: 'CC BY-SA 4.0',
      ),
    ],
    recommender: Recommender(
      name: 'Luana Barros',
      tie: 'passista, dança frevo desde criança',
      quote: 'Sobe até o último andar: tem sombrinha pra pegar e '
          'sempre alguém ensinando o passo.',
    ),
    about: 'Museu do frevo num casarão da Praça do Arsenal, com acervo de '
        'estandartes, discos e uma escola de dança no prédio.',
    whatToDo: 'Ver os estandartes do terceiro andar e entrar na aula de '
        'passo, se tiver turma no dia.',
    bestTime: 'Sábado, de tarde',
    cost: 'Entrada paga, meia pra estudante',
    surroundings: [
      'Praça movimentada de dia',
      'Volta de app na porta',
    ],
    verifiedAt: '09 nov',
    covered: true,
    tips: [
      RoleTip(TipKind.dance, 'Aula de passo com a escola do Paço'),
      RoleTip(TipKind.art, 'Estandartes das agremiações'),
      RoleTip(TipKind.photo, 'Foto com sombrinha na escada'),
    ],
    videos: [
      ShortVideo(
        id: 'v-pf-1',
        source: VideoSource.instagram,
        handle: '@luana.passista',
        caption: 'Primeira aula de frevo e já saí suando 😅',
        duration: Duration(seconds: 24),
        poster: '$_img/paco_frevo_2.jpg',
      ),
    ],
  );

  static const parqueEsculturas = Role(
    id: 'parque-esculturas',
    name: 'Torre de Cristal no Parque das Esculturas',
    shortName: 'Esculturas Brennand',
    neighborhood: 'Recife Antigo',
    category: RoleCategory.cultura,
    location: GeoPoint(-8.0629, -34.8686),
    price: 'Grátis',
    hours: 'De dia',
    photos: [
      PhotoCredit(
        asset: '$_img/arte_torre_cristal.jpg',
        author: 'A. Júnior',
        license: 'CC BY 2.0',
      ),
      PhotoCredit(
        asset: '$_img/brennand_coluna.jpg',
        author: 'Wilfredor',
        license: 'CC0',
      ),
      PhotoCredit(
        asset: '$_img/brennand_torre_2.jpg',
        author: 'Helder da Rocha',
        license: 'CC BY-SA 2.0',
      ),
    ],
    recommender: Recommender(
      name: 'Nina Vasconcelos',
      tie: 'fotógrafa, mora no Recife Antigo',
      quote: 'Vai no fim da tarde: a luz bate na torre e o mar fica dourado.',
    ),
    about: 'Esculturas de Francisco Brennand no quebra-mar em frente ao '
        'Marco Zero, com a Torre de Cristal no meio.',
    whatToDo: 'Ver a Torre de Cristal de perto e o Marco Zero do outro lado.',
    bestTime: 'Fim de tarde, 16h às 17h30',
    cost: 'Grátis',
    surroundings: [
      'Acesso pelo Marco Zero',
      'Melhor ir de dia',
    ],
    verifiedAt: '05 nov',
    tips: [
      RoleTip(TipKind.art, 'Torre de Cristal e as esculturas'),
      RoleTip(TipKind.view, 'Pôr do sol de frente pro Marco Zero'),
      RoleTip(TipKind.photo, 'Foto com a torre e o mar'),
    ],
    videos: [
      ShortVideo(
        id: 'v-pe-1',
        source: VideoSource.local,
        handle: '@nina.fotografa',
        caption: 'Fim de tarde na torre do Brennand. Sem filtro.',
        duration: Duration(seconds: 19),
        poster: '$_img/brennand_coluna.jpg',
      ),
    ],
  );

  static const ruaDoBomJesus = Role(
    id: 'rua-do-bom-jesus',
    name: 'Domingo na Rua do Bom Jesus',
    shortName: 'Rua do Bom Jesus',
    neighborhood: 'Recife Antigo',
    category: RoleCategory.cultura,
    location: GeoPoint(-8.0618, -34.8716),
    price: 'Grátis',
    hours: 'Livre',
    photos: [
      PhotoCredit(
        asset: '$_img/historia_bom_jesus.jpg',
        author: 'A. Júnior',
        license: 'CC BY 2.0',
      ),
      PhotoCredit(
        asset: '$_img/bom_jesus_2.jpg',
        author: 'A. Júnior',
        license: 'CC BY 2.0',
      ),
    ],
    recommender: Recommender(
      name: 'Lia Moraes',
      photo: 'assets/images/people/lia.jpg',
      tie: 'historiadora, mora na Boa Vista',
      quote: 'Domingo a rua fecha pros carros e vira feira. '
          'Passa na sinagoga antes de ir.',
    ),
    about: 'Uma das ruas mais antigas do Recife, com sobrados coloridos e a '
        'Kahal Zur Israel, primeira sinagoga das Américas.',
    whatToDo: 'Andar pela feira de domingo e visitar a sinagoga.',
    bestTime: 'Domingo, 14h às 18h',
    cost: 'Grátis',
    surroundings: [
      'Rua cheia de gente no domingo',
      'Volta fácil de app pelo Marco Zero',
    ],
    verifiedAt: '09 nov',
    tips: [
      RoleTip(TipKind.walk, 'Feira de domingo na rua'),
      RoleTip(TipKind.photo, 'Sobrados coloridos'),
      RoleTip(TipKind.shop, 'Artesanato local'),
    ],
    videos: [
      ShortVideo(
        id: 'v-bj-1',
        source: VideoSource.tiktok,
        handle: '@recifeantigo.domingo',
        caption: 'Domingo no Bom Jesus: feira, música e sobrado colorido.',
        duration: Duration(seconds: 27),
        poster: '$_img/bom_jesus_2.jpg',
      ),
    ],
  );

  static const roles = [
    ...TravelMock.allRoles,
    pacoDoFrevo,
    parqueEsculturas,
    ruaDoBomJesus,
  ];

  static Role roleById(String id) => roles.firstWhere((r) => r.id == id);

  static const _all = {0, 1, 2};

  /// Etiquetas por rolê. `priceFrom` é gasto estimado por pessoa (mock). Café fica vazio de propósito: ainda não há café
  /// curado — a busca diz isso (D-07) em vez de inventar.
  static const tags = <String, ExploreTags>{
    'mercado-boa-vista': ExploreTags(
      categories: {ExploreCategory.restaurantes, ExploreCategory.historia},
      periods: {StopPeriod.manha, StopPeriod.tarde},
      days: _all,
      reason: 'Caldinho de sábado sem preço de turista',
      priceFrom: 30,
    ),
    'cinema-sao-luiz': ExploreTags(
      categories: {ExploreCategory.cultura, ExploreCategory.historia},
      periods: {StopPeriod.tarde, StopPeriod.noite},
      days: _all,
      reason: 'Sessão de cinema e pôr do sol na beira do rio',
      priceFrom: 12,
    ),
    'casa-de-bamba': ExploreTags(
      categories: {ExploreCategory.cultura},
      periods: {StopPeriod.noite},
      days: _all,
      reason: 'Roda de samba de quem é daqui, boa pra ir em dupla',
      priceFrom: 35,
    ),
    'casa-astral': ExploreTags(
      categories: {ExploreCategory.cultura},
      periods: {StopPeriod.noite},
      days: {0, 1},
      reason: 'Forró de raiz, cheio de gente da cidade',
      priceFrom: 45,
    ),
    'poco-da-panela': ExploreTags(
      categories: {ExploreCategory.historia},
      periods: {StopPeriod.manha, StopPeriod.tarde},
      days: _all,
      reason: 'Casario antigo e caminhada tranquila de tarde',
      priceFrom: 0,
    ),
    'sitio-trindade': ExploreTags(
      categories: {ExploreCategory.cultura, ExploreCategory.historia},
      periods: {StopPeriod.manha, StopPeriod.tarde},
      days: _all,
      reason: 'Fim de tarde verde, de graça',
      priceFrom: 0,
    ),
    'mercado-encruzilhada': ExploreTags(
      categories: {ExploreCategory.restaurantes},
      periods: {StopPeriod.manha},
      days: {0, 1},
      reason: 'Feira de bairro, comida boa e barata',
      priceFrom: 20,
    ),
    'dona-lindu': ExploreTags(
      categories: {ExploreCategory.arte},
      periods: {StopPeriod.tarde, StopPeriod.noite},
      days: _all,
      reason: 'Pôr do sol na praia, pertinho do hotel',
      priceFrom: 0,
    ),
    'mercado-casa-amarela': ExploreTags(
      categories: {ExploreCategory.restaurantes},
      periods: {StopPeriod.tarde},
      days: {0, 1},
      reason: 'Petisco de mercado com quem é do bairro',
      priceFrom: 25,
    ),
    'box-vitoria-regia': ExploreTags(
      categories: {ExploreCategory.cultura},
      periods: {StopPeriod.tarde, StopPeriod.noite},
      days: _all,
      reason: 'Bar de bairro ao ar livre, na praça do Burle Marx',
      priceFrom: 10,
    ),
    'parraxaxa-casa-forte': ExploreTags(
      categories: {ExploreCategory.restaurantes},
      periods: {StopPeriod.tarde, StopPeriod.noite},
      days: _all,
      reason: 'Comida pernambucana em salão coberto',
      priceFrom: 45,
    ),
    'paco-do-frevo': ExploreTags(
      categories: {ExploreCategory.museu, ExploreCategory.cultura},
      periods: {StopPeriod.manha, StopPeriod.tarde},
      days: _all,
      reason: 'Museu do frevo com aula de passo',
      priceFrom: 15,
    ),
    'parque-esculturas': ExploreTags(
      categories: {ExploreCategory.arte},
      periods: {StopPeriod.manha, StopPeriod.tarde},
      days: _all,
      reason: 'Esculturas do Brennand de frente pro Marco Zero',
      priceFrom: 0,
    ),
    'rua-do-bom-jesus': ExploreTags(
      categories: {ExploreCategory.historia},
      periods: {StopPeriod.manha, StopPeriod.tarde, StopPeriod.noite},
      days: _all,
      reason: 'Rua mais antiga do Recife, com feira no domingo',
      priceFrom: 0,
    ),
  };

  /// Escolha curada pra companhia do perfil ("sozinha", P-CAMILA): rolês
  /// de dia ou com movimento, sem depender de companhia.
  static const forCompany = [
    'paco-do-frevo',
    'rua-do-bom-jesus',
    'mercado-boa-vista',
    'parque-esculturas',
    'cinema-sao-luiz',
  ];
}
