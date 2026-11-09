import 'package:studio_app/features/travel_agent/domain/entities/travel_entities.dart';

/// Cenários de design da tela do agente (variações do registry).
enum TravelAgentScenario { padrao, vazio, erro, carregando }

/// Dados mockados — rolês reais de Recife indicados por moradores (pessoas
/// e @handles são fictícios). Fotos: Wikimedia Commons, ver
/// `assets/images/roles/CREDITS.md`.
abstract final class TravelMock {
  static const _img = 'assets/images/roles';
  static const _people = 'assets/images/people';

  static const profile = TripProfile(
    travelerName: 'Marina',
    dates: '14–16 nov',
    stay: 'Hotel em Boa Viagem',
    stayLocation: GeoPoint(-8.1180, -34.8952),
    company: 'com as amigas',
  );

  static const messageLimit = 20;
  static const messagesUsed = 8;

  // Plano (sheet de limite, ref. app do Claude).
  static const freePlan = true;
  static const limitResetsAt = 'segunda, 00h';
  static const upgradeName = 'Maré+';
  static const upgradePrice = r'R$ 14,90/mês';
  static const upgradePerks = [
    'Mensagens ilimitadas com a Maré',
    'Roteiros de mais de 3 dias',
    '10% off nos transfers com motorista mulher',
    'Acesso antecipado a rolês novos',
  ];

  /// Processo longo: recolhe os rolês no catálogo e monta o roteiro.
  static const collectProcess = [
    ProcessStep(
      title: 'Lendo seus rolês salvos',
      detail: '8 rolês em 6 bairros',
      sources: ['Salvos', 'Perfil da viagem'],
    ),
    ProcessStep(
      title: 'Recolhendo rolês no catálogo',
      detail: 'Só indicações de quem mora aqui',
      sources: ['Catálogo local', 'Selo Rolê Seguro'],
      collect: true,
    ),
    ProcessStep(
      title: 'Agrupando por dia e distância',
      detail: 'Um bairro por dia, sem travessias longas',
      sources: ['Mapa'],
      organize: true,
    ),
    ProcessStep(
      title: 'Conferindo horários e entorno',
      detail: 'Casa Astral abre às 21h',
      sources: ['Horários', 'Clima'],
    ),
    ProcessStep(title: 'Escrevendo o roteiro', writing: true),
  ];

  /// Início de cada passo (ms) — o último valor é a resposta.
  /// "Recolhendo" dura a fase 1 da visão de agente (8 × 500ms + 150);
  /// "Agrupando" dura a fase 2 (troca 400 + 8 × 330ms + 250). Ver
  /// `AgentCollectView`.
  static const collectTimeline = [0, 900, 5050, 8340, 9240, 9940];

  /// Processo curto (filtros e ajustes).
  static const quickProcess = [
    ProcessStep(
      title: 'Lendo seus rolês salvos',
      detail: 'Filtrando pelo que você pediu',
      sources: ['Salvos'],
    ),
    ProcessStep(title: 'Escrevendo resposta', writing: true),
  ];
  static const quickTimeline = [0, 700, 1400];

  /// Ordem em que o cursor recolhe os rolês (a ordem do roteiro).
  static const collectOrder = [
    'dona-lindu',
    'casa-de-bamba',
    'mercado-encruzilhada',
    'sitio-trindade',
    'poco-da-panela',
    'casa-astral',
    'mercado-boa-vista',
    'cinema-sao-luiz',
  ];

  /// Outros itens do catálogo (só preenchem a grade da visão de agente).
  static const catalogFillers = [
    '$_img/samba_3.jpg',
    '$_img/forro_2.jpg',
    '$_img/rua_da_aurora_2.jpg',
    '$_img/casa_amarela_1.jpg',
  ];

  /// Só as de maior valor (pedido do designer): organizar (a principal),
  /// noite com segurança e logística a partir do hotel. Comida e "de graça"
  /// seguem respondidas se a pessoa digitar.
  static const suggestions = [
    'Organizar meus 8 rolês',
    'Noite com as amigas',
    'Perto do hotel',
  ];

  // ── Começo do zero (cenário Vazio) ───────────────────────────────────
  // Uma de cada sorteada por visita: a abertura muda um pouco cada vez.

  static const blankGreetings = [
    'O que você quer viver em Recife?',
    'Pra onde a maré te leva hoje?',
    'Que Recife você quer conhecer?',
    'Me conta o que você curte.',
  ];

  /// Um chip só, suave (sem o azul de contraste).
  static const blankSuggestions = [
    'Rolês de gente daqui',
    'Noite com as amigas',
    'Comer bem perto do hotel',
  ];

  /// Pontos da curadoria (sem nome): mostram no mapa que tem coisa ali,
  /// antes de a Maré sugerir os rolês.
  static const curationSpots = [
    GeoPoint(-8.0110, -34.8560),
    GeoPoint(-8.0150, -34.8610),
    GeoPoint(-8.0585, -34.8715),
    GeoPoint(-8.0630, -34.8760),
    GeoPoint(-8.0545, -34.8880),
    GeoPoint(-8.0590, -34.8950),
    GeoPoint(-8.0460, -34.9020),
    GeoPoint(-8.0500, -34.9090),
    GeoPoint(-8.0330, -34.9100),
    GeoPoint(-8.0230, -34.9150),
    GeoPoint(-8.0200, -34.9220),
    GeoPoint(-8.0350, -34.8960),
    GeoPoint(-8.0860, -34.8830),
    GeoPoint(-8.1080, -34.8935),
    GeoPoint(-8.1250, -34.9010),
    GeoPoint(-8.1330, -34.9060),
    GeoPoint(-8.0570, -34.9180),
    GeoPoint(-8.1040, -34.9150),
  ];

  // ── Rolês ────────────────────────────────────────────────────────────
  static const mercadoBoaVista = Role(
    id: 'mercado-boa-vista',
    name: 'Caldinho no Mercado da Boa Vista',
    shortName: 'Mercado da Boa Vista',
    neighborhood: 'Boa Vista',
    category: RoleCategory.comida,
    location: GeoPoint(-8.0619, -34.8858),
    price: r'$',
    hours: 'Aberto até 18h',
    photos: [
      PhotoCredit(
        asset: '$_img/mercado_boa_vista_1.jpg',
        author: 'Dantadd',
        license: 'CC BY-SA 3.0',
      ),
      PhotoCredit(
        asset: '$_img/caldinho_1.jpg',
        author: 'Marcelo Träsel',
        license: 'CC BY-SA 2.0',
      ),
      PhotoCredit(
        asset: '$_img/caldinho_2.jpg',
        author: 'Marcelo Träsel',
        license: 'CC BY-SA 2.0',
      ),
      PhotoCredit(
        asset: '$_img/mercado_boa_vista_2.jpg',
        author: 'Ministério Público de PE',
        license: 'CC BY 2.0',
      ),
    ],
    recommender: Recommender(
      name: 'Seu Zé Ferreira',
      photo: '$_people/seu_ze.jpg',
      tie: 'feirante no mercado há 30 anos',
      quote: 'Sábado de manhã é o melhor: caldinho, cerveja gelada e '
          'o povo do bairro conversando alto.',
    ),
    about: 'Mercado pequeno de 1820, com boxes de comida regional e bares '
        'de mesa na calçada. Quem vai é gente do centro, não turista.',
    whatToDo: 'Caldinho de feijão com charque, bolinho de bacalhau e '
        'cerveja do box do meio.',
    bestTime: 'Sábado ou domingo, 10h às 14h',
    cost: r'R$ 25 a R$ 40 por pessoa',
    surroundings: [
      'Rua movimentada de dia',
      'Táxi na esquina',
      'Feche antes das 18h'
    ],
    verifiedAt: '02 nov',
    covered: true,
    tips: [
      RoleTip(TipKind.food, 'Caldinho de feijão com charque'),
      RoleTip(TipKind.food, 'Bolinho de bacalhau'),
      RoleTip(TipKind.drink, 'Cerveja gelada no box do meio'),
    ],
    videos: [
      ShortVideo(
        id: 'v-mbv-1',
        source: VideoSource.local,
        handle: '@seuze.domercado',
        caption: 'O caldinho que meu pai servia aqui em 1990. Mesmo tempero.',
        duration: Duration(seconds: 21),
        poster: '$_img/caldinho_1.jpg',
      ),
      ShortVideo(
        id: 'v-mbv-2',
        source: VideoSource.tiktok,
        handle: '@comendoporrecife',
        caption: 'R\$ 32 e saí rolando. Mercado da Boa Vista no sábado 🥣',
        duration: Duration(seconds: 34),
        poster: '$_img/mercado_boa_vista_1.jpg',
      ),
      ShortVideo(
        id: 'v-mbv-3',
        source: VideoSource.instagram,
        handle: '@centrodorecife.vivo',
        caption: 'Boa Vista de dia: mercado, igreja matriz e cafezinho.',
        duration: Duration(seconds: 18),
        poster: '$_img/mercado_boa_vista_2.jpg',
      ),
    ],
  );

  static const cinemaSaoLuiz = Role(
    id: 'cinema-sao-luiz',
    name: 'Sessão no Cinema São Luiz + pôr do sol na Rua da Aurora',
    shortName: 'Cinema São Luiz',
    neighborhood: 'Boa Vista',
    category: RoleCategory.cultura,
    location: GeoPoint(-8.0612, -34.8815),
    price: r'$',
    hours: 'Sessões a partir das 14h',
    photos: [
      PhotoCredit(
        asset: '$_img/cinema_sao_luiz_1.jpg',
        author: 'Hilary S. Carneiro dos Santos',
        license: 'CC BY-SA 4.0',
      ),
      PhotoCredit(
        asset: '$_img/cinema_sao_luiz_2.jpg',
        author: 'Direitos Urbanos',
        license: 'CC BY 2.0',
      ),
      PhotoCredit(
        asset: '$_img/rua_da_aurora_1.jpg',
        author: 'Hansfotos',
        license: 'CC BY-SA 4.0',
      ),
      PhotoCredit(
        asset: '$_img/cinema_sao_luiz_3.jpg',
        author: 'Leonaardog',
        license: 'CC BY-SA 4.0',
      ),
      PhotoCredit(
        asset: '$_img/rua_da_aurora_2.jpg',
        author: 'Pernambucanidade',
        license: 'CC BY 2.0',
      ),
    ],
    recommender: Recommender(
      name: 'Lia Moraes',
      photo: '$_people/lia.jpg',
      tie: 'cineclubista, mora na Boa Vista',
      quote: 'Pega a sessão das 16h e sai direto pra beira do rio. '
          'O sol cai atrás dos casarões.',
    ),
    about: 'Cinema de rua de 1952, com vitrais e sala enorme. Do lado, a '
        'Rua da Aurora tem o pôr do sol mais bonito do centro, refletido '
        'no Capibaribe.',
    whatToDo: 'Sessão de cinema pernambucano e caminhada na mureta do rio '
        'até a ponte da Boa Vista.',
    bestTime: 'Domingo, 16h às 18h',
    cost: r'Ingresso R$ 10 (meia R$ 5)',
    surroundings: [
      'Rua da Aurora iluminada',
      'Ponto de táxi a 200 m',
      'Policiamento até 22h'
    ],
    verifiedAt: '04 nov',
    covered: true,
    tips: [
      RoleTip(TipKind.film, 'Sessão de cinema pernambucano'),
      RoleTip(TipKind.view, 'Pôr do sol na Rua da Aurora'),
      RoleTip(TipKind.walk, 'Caminhada até a ponte da Boa Vista'),
    ],
    videos: [
      ShortVideo(
        id: 'v-csl-1',
        source: VideoSource.instagram,
        handle: '@lia.cineclube',
        caption:
            'O São Luiz por dentro. Ninguém acredita que é cinema público.',
        duration: Duration(seconds: 27),
        poster: '$_img/cinema_sao_luiz_2.jpg',
      ),
      ShortVideo(
        id: 'v-csl-2',
        source: VideoSource.tiktok,
        handle: '@recifeaopordosol',
        caption: 'Rua da Aurora 17h40. Só isso.',
        duration: Duration(seconds: 15),
        poster: '$_img/rua_da_aurora_1.jpg',
      ),
    ],
  );

  static const casaDeBamba = Role(
    id: 'casa-de-bamba',
    name: 'Samba e coco na Casa de Bamba',
    shortName: 'Casa de Bamba',
    neighborhood: 'Boa Vista',
    category: RoleCategory.noite,
    location: GeoPoint(-8.0573, -34.8878),
    price: r'$$',
    hours: 'Sex a dom, a partir das 16h',
    photos: [
      PhotoCredit(
        asset: '$_img/samba_1.jpg',
        author: 'Maria Eugenia Tita',
        license: 'CC BY 4.0',
      ),
      PhotoCredit(
        asset: '$_img/samba_2.jpg',
        author: 'Maria Eugenia Tita',
        license: 'CC BY 4.0',
      ),
      PhotoCredit(
        asset: '$_img/samba_3.jpg',
        author: 'Bahiense.7',
        license: 'CC0',
      ),
    ],
    recommender: Recommender(
      name: 'Dandara Lima',
      photo: '$_people/dandara.jpg',
      tie: 'sambista, toca na roda de sexta',
      quote: 'Chega cedo pra pegar mesa. Às 21h vira roda de coco e '
          'todo mundo entra.',
    ),
    about: 'Casarão na Rua Manoel Borba com roda de samba e coco de roda. '
        'Público do bairro, muita mulher na roda.',
    whatToDo: 'Roda de samba às 20h, coco às 21h30. Pede o escondidinho '
        'de charque.',
    bestTime: 'Sexta, a partir das 19h',
    cost: r'Couvert R$ 15, consumo R$ 50',
    surroundings: [
      'Rua com bares abertos até tarde',
      'Transfer recomendado na volta'
    ],
    verifiedAt: '01 nov',
    covered: true,
    tips: [
      RoleTip(TipKind.music, 'Roda de samba às 20h'),
      RoleTip(TipKind.dance, 'Coco de roda às 21h30'),
      RoleTip(TipKind.food, 'Escondidinho de charque'),
    ],
    videos: [
      ShortVideo(
        id: 'v-cdb-1',
        source: VideoSource.local,
        handle: '@dandara.nococo',
        caption: 'Sexta é dia de coco. Vem que a roda é de quem chega.',
        duration: Duration(seconds: 29),
        poster: '$_img/samba_1.jpg',
      ),
      ShortVideo(
        id: 'v-cdb-2',
        source: VideoSource.instagram,
        handle: '@noitepernambucana',
        caption: 'A roda mais bonita do centro, sem exagero.',
        duration: Duration(seconds: 22),
        poster: '$_img/samba_2.jpg',
      ),
    ],
  );

  static const casaAstral = Role(
    id: 'casa-astral',
    name: 'Forró de raiz na Casa Astral',
    shortName: 'Casa Astral',
    neighborhood: 'Poço da Panela',
    category: RoleCategory.noite,
    location: GeoPoint(-8.0335, -34.9205),
    price: r'$$',
    hours: 'Qui a sáb, das 21h às 2h',
    photos: [
      PhotoCredit(
        asset: '$_img/forro_1.jpg',
        author: 'ASCOM Pref. de Votuporanga',
        license: 'Domínio público',
      ),
      PhotoCredit(
        asset: '$_img/forro_2.jpg',
        author: 'Marco Aurélio Esparza',
        license: 'CC BY-SA 3.0',
      ),
      PhotoCredit(
        asset: '$_img/forro_3.jpg',
        author: 'Denapoly',
        license: 'CC BY-SA 4.0',
      ),
    ],
    recommender: Recommender(
      name: 'Joana Albuquerque',
      photo: '$_people/joana.jpg',
      tie: 'mora no Poço da Panela há 12 anos',
      quote: 'Vai no sábado, o trio começa 21h e o povo é do bairro. '
          'Ninguém te deixa parada.',
    ),
    about: 'Forró pé de serra num casarão do Poço da Panela, longe do '
        'agito turístico. Trio ao vivo, salão de chão batido.',
    whatToDo: 'Dançar xote com quem chamar, cuscuz com queijo coalho no '
        'intervalo.',
    bestTime: 'Sábado, 21h à meia-noite',
    cost: r'Entrada R$ 20, consumo R$ 40',
    surroundings: [
      'Rua de paralelepípedo pouco iluminada',
      'Volta de transfer recomendada',
      'Segurança na porta'
    ],
    verifiedAt: '03 nov',
    covered: true,
    tips: [
      RoleTip(TipKind.dance, 'Xote com quem chamar'),
      RoleTip(TipKind.music, 'Trio pé de serra ao vivo'),
      RoleTip(TipKind.food, 'Cuscuz com queijo coalho'),
    ],
    videos: [
      ShortVideo(
        id: 'v-ca-1',
        source: VideoSource.local,
        handle: '@joana.dopoco',
        caption: 'Sábado no Poço. Esse trio toca junto há 20 anos 🪗',
        duration: Duration(seconds: 24),
        poster: '$_img/forro_1.jpg',
      ),
      ShortVideo(
        id: 'v-ca-2',
        source: VideoSource.tiktok,
        handle: '@arrastape.rec',
        caption: 'POV: você foi no forró que os recifenses escondem.',
        duration: Duration(seconds: 31),
        poster: '$_img/forro_3.jpg',
      ),
      ShortVideo(
        id: 'v-ca-3',
        source: VideoSource.instagram,
        handle: '@sanfonaeafeto',
        caption: 'Xote às 23h e ninguém quer ir embora.',
        duration: Duration(seconds: 19),
        poster: '$_img/forro_2.jpg',
      ),
    ],
  );

  static const pocoDaPanela = Role(
    id: 'poco-da-panela',
    name: 'Caminhada no casario do Poço da Panela',
    shortName: 'Poço da Panela',
    neighborhood: 'Poço da Panela',
    category: RoleCategory.cultura,
    location: GeoPoint(-8.0322, -34.9220),
    price: 'Grátis',
    hours: 'Livre',
    photos: [
      PhotoCredit(
        asset: '$_img/poco_da_panela_1.jpg',
        author: 'Lais Castro',
        license: 'CC BY-SA 3.0',
      ),
      PhotoCredit(
        asset: '$_img/poco_da_panela_2.jpg',
        author: 'Lais Castro',
        license: 'CC BY-SA 3.0',
      ),
      PhotoCredit(
        asset: '$_img/poco_da_panela_3.jpg',
        author: 'Lais Castro',
        license: 'CC BY-SA 3.0',
      ),
    ],
    recommender: Recommender(
      name: 'Joana Albuquerque',
      photo: '$_people/joana.jpg',
      tie: 'mora no Poço da Panela há 12 anos',
      quote: 'Anda devagar, olha as portas coloridas e para na igrejinha. '
          'Depois desce pro rio.',
    ),
    about: 'Bairro de casarões coloridos e ruas de pedra à beira do '
        'Capibaribe, quase uma cidade do interior dentro do Recife.',
    whatToDo: 'Volta pela Praça do Poço, igreja de N. Sra. da Saúde e '
        'mirante do rio.',
    bestTime: 'Fim de tarde, 16h30 às 18h',
    cost: 'Grátis',
    surroundings: ['Ruas tranquilas de dia', 'Evite sozinha depois das 19h'],
    verifiedAt: '03 nov',
    tips: [
      RoleTip(TipKind.walk, 'Volta pela Praça do Poço'),
      RoleTip(TipKind.photo, 'Portas coloridas do casario'),
      RoleTip(TipKind.view, 'Mirante do Capibaribe'),
    ],
    videos: [
      ShortVideo(
        id: 'v-pp-1',
        source: VideoSource.instagram,
        handle: '@joana.dopoco',
        caption: 'Meu bairro às 17h. Dá pra entender por que não saio daqui?',
        duration: Duration(seconds: 16),
        poster: '$_img/poco_da_panela_2.jpg',
      ),
      ShortVideo(
        id: 'v-pp-2',
        source: VideoSource.tiktok,
        handle: '@recifedeportasabertas',
        caption: 'As portas coloridas do Poço da Panela 🎨',
        duration: Duration(seconds: 23),
        poster: '$_img/poco_da_panela_3.jpg',
      ),
    ],
  );

  static const sitioTrindade = Role(
    id: 'sitio-trindade',
    name: 'Fim de tarde no Sítio da Trindade',
    shortName: 'Sítio da Trindade',
    neighborhood: 'Casa Amarela',
    category: RoleCategory.natureza,
    location: GeoPoint(-8.0279, -34.9100),
    price: 'Grátis',
    hours: 'Aberto até 18h',
    photos: [
      PhotoCredit(
        asset: '$_img/sitio_trindade_2.jpg',
        author: 'NayaraRN',
        license: 'CC BY-SA 4.0',
      ),
      PhotoCredit(
        asset: '$_img/sitio_trindade_1.jpg',
        author: 'Fábio de Oliveira Geber',
        license: 'CC BY-SA 4.0',
      ),
      PhotoCredit(
        asset: '$_img/sitio_trindade_3.jpg',
        author: 'NayaraRN',
        license: 'CC BY-SA 4.0',
      ),
    ],
    recommender: Recommender(
      name: 'Bia Santos',
      photo: '$_people/bia.jpg',
      tie: 'professora, corre no Sítio todo dia',
      quote: 'Leva uma canga e fica embaixo das mangueiras. '
          'No São João vira o melhor arraial da cidade.',
    ),
    about: 'Parque histórico arborizado em Casa Amarela, com mangueiras '
        'centenárias e famílias do bairro no fim de tarde.',
    whatToDo: 'Piquenique, água de coco na entrada e volta no casarão.',
    bestTime: 'Sábado, 15h às 17h30',
    cost: 'Grátis',
    surroundings: ['Parque cercado com guarda', 'Fecha às 18h'],
    verifiedAt: '05 nov',
    tips: [
      RoleTip(TipKind.nature, 'Piquenique sob as mangueiras'),
      RoleTip(TipKind.drink, 'Água de coco na entrada'),
      RoleTip(TipKind.walk, 'Volta no casarão'),
    ],
    videos: [
      ShortVideo(
        id: 'v-st-1',
        source: VideoSource.local,
        handle: '@bia.correnosítio',
        caption: 'Meu lugar favorito do Recife, sem pensar duas vezes.',
        duration: Duration(seconds: 20),
        poster: '$_img/sitio_trindade_1.jpg',
      ),
      ShortVideo(
        id: 'v-st-2',
        source: VideoSource.tiktok,
        handle: '@arraialrecife',
        caption: 'O Sítio em junho é outro planeta 🎉',
        duration: Duration(seconds: 26),
        poster: '$_img/sitio_trindade_3.jpg',
      ),
    ],
  );

  static const mercadoEncruzilhada = Role(
    id: 'mercado-encruzilhada',
    name: 'Feira e boteco no Mercado da Encruzilhada',
    shortName: 'Mercado da Encruzilhada',
    neighborhood: 'Encruzilhada',
    category: RoleCategory.comida,
    location: GeoPoint(-8.0372, -34.8898),
    price: r'$',
    hours: 'Aberto das 6h às 16h',
    photos: [
      PhotoCredit(
        asset: '$_img/mercado_encruzilhada_1.jpg',
        author: 'Paulo Camelo',
        license: 'CC BY 2.5',
      ),
      PhotoCredit(
        asset: '$_img/caldinho_2.jpg',
        author: 'Marcelo Träsel',
        license: 'CC BY-SA 2.0',
      ),
    ],
    recommender: Recommender(
      name: 'Rafa Cavalcanti',
      photo: '$_people/rafa.jpg',
      tie: 'cozinheiro, compra ali toda semana',
      quote: 'Faz a feira de frutas primeiro e termina no boteco do canto. '
          'Pede a carne de sol.',
    ),
    about: 'Mercado de bairro com feira de frutas, ervas e botecos que '
        'enchem no sábado de manhã.',
    whatToDo: 'Feira de frutas da estação, carne de sol com macaxeira.',
    bestTime: 'Sábado, 9h às 12h',
    cost: r'R$ 30 a R$ 50 por pessoa',
    surroundings: ['Movimentado de manhã', 'Estacionamento ao lado'],
    verifiedAt: '05 nov',
    covered: true,
    tips: [
      RoleTip(TipKind.shop, 'Feira de frutas da estação'),
      RoleTip(TipKind.food, 'Carne de sol com macaxeira'),
      RoleTip(TipKind.drink, 'Boteco do canto'),
    ],
    videos: [
      ShortVideo(
        id: 'v-me-1',
        source: VideoSource.local,
        handle: '@rafa.nacozinha',
        caption: 'Minha feira de sábado em 20 segundos.',
        duration: Duration(seconds: 20),
        poster: '$_img/mercado_encruzilhada_1.jpg',
      ),
      ShortVideo(
        id: 'v-me-2',
        source: VideoSource.tiktok,
        handle: '@comendoporrecife',
        caption: 'Caldinho de mercado > restaurante caro. Fato.',
        duration: Duration(seconds: 28),
        poster: '$_img/caldinho_2.jpg',
      ),
    ],
  );

  static const donaLindu = Role(
    id: 'dona-lindu',
    name: 'Fim de tarde no Parque Dona Lindu',
    shortName: 'Parque Dona Lindu',
    neighborhood: 'Boa Viagem',
    category: RoleCategory.praia,
    location: GeoPoint(-8.1290, -34.8995),
    price: 'Grátis',
    hours: 'Aberto até 22h',
    photos: [
      PhotoCredit(
        asset: '$_img/dona_lindu_1.jpg',
        author: 'A. Júnior',
        license: 'CC BY 2.0',
      ),
      PhotoCredit(
        asset: '$_img/dona_lindu_3.jpg',
        author: 'Abdias Jr',
        license: 'CC BY 2.0',
      ),
      PhotoCredit(
        asset: '$_img/dona_lindu_2.jpg',
        author: 'SPA das Artes Recife',
        license: 'CC BY 2.0',
      ),
    ],
    recommender: Recommender(
      name: 'Carol Menezes',
      photo: '$_people/carol.jpg',
      tie: 'skatista, cresceu em Boa Viagem',
      quote: 'Desce às 17h: pista de skate, galeria e depois pé na areia '
          'na frente do parque.',
    ),
    about: 'Parque de Niemeyer na beira-mar de Boa Viagem, com galeria, '
        'teatro e pista de skate. É o quintal de quem mora no bairro.',
    whatToDo: 'Ver a galeria, sentar na mureta da praia e tapioca no '
        'calçadão.',
    bestTime: 'Sexta, 16h30 às 18h30',
    cost: 'Grátis',
    surroundings: [
      'Calçadão iluminado',
      'A 1,3 km do seu hotel',
      'Posto policial em frente'
    ],
    verifiedAt: '06 nov',
    tips: [
      RoleTip(TipKind.art, 'Galeria de graça'),
      RoleTip(TipKind.sport, 'Pista de skate'),
      RoleTip(TipKind.view, 'Mureta da praia'),
      RoleTip(TipKind.food, 'Tapioca no calçadão'),
    ],
    videos: [
      ShortVideo(
        id: 'v-dl-1',
        source: VideoSource.local,
        handle: '@carol.sk8',
        caption: 'Sessão de fim de tarde no Dona Lindu 🛹',
        duration: Duration(seconds: 17),
        poster: '$_img/dona_lindu_1.jpg',
      ),
      ShortVideo(
        id: 'v-dl-2',
        source: VideoSource.instagram,
        handle: '@boaviagemdeboa',
        caption: 'Galeria de graça, praia na frente. Recife é isso.',
        duration: Duration(seconds: 25),
        poster: '$_img/dona_lindu_3.jpg',
      ),
    ],
  );

  /// Alternativa coberta usada na troca por chuva (etapa 06 do blueprint).
  static const mercadoCasaAmarela = Role(
    id: 'mercado-casa-amarela',
    name: 'Petisco no Mercado de Casa Amarela',
    shortName: 'Mercado de Casa Amarela',
    neighborhood: 'Casa Amarela',
    category: RoleCategory.comida,
    location: GeoPoint(-8.0262, -34.9172),
    price: r'$',
    hours: 'Aberto até 17h',
    photos: [
      PhotoCredit(
        asset: '$_img/casa_amarela_1.jpg',
        author: 'Paulo Camelo',
        license: 'CC BY-SA 4.0',
      ),
      PhotoCredit(
        asset: '$_img/caldinho_1.jpg',
        author: 'Marcelo Träsel',
        license: 'CC BY-SA 2.0',
      ),
    ],
    recommender: Recommender(
      name: 'Bia Santos',
      photo: '$_people/bia.jpg',
      tie: 'professora, mora em Casa Amarela',
      quote: 'Se chover, o mercado é coberto e o caldinho é igualmente bom.',
    ),
    about: 'Mercado coberto de ferro, com bares de petisco e artesanato. '
        'Plano B perfeito pra dia de chuva.',
    whatToDo: 'Petisco de bode, cocada e cerveja no box da esquina.',
    bestTime: 'Sábado, 14h às 17h',
    cost: r'R$ 30 por pessoa',
    surroundings: ['Coberto', 'A 900 m do Sítio da Trindade'],
    verifiedAt: '05 nov',
    covered: true,
    tips: [
      RoleTip(TipKind.food, 'Petisco de bode'),
      RoleTip(TipKind.food, 'Cocada da casa'),
      RoleTip(TipKind.drink, 'Cerveja no box da esquina'),
    ],
    videos: [
      ShortVideo(
        id: 'v-mca-1',
        source: VideoSource.local,
        handle: '@bia.correnosítio',
        caption: 'Chuva em Recife? Mercado de Casa Amarela resolve.',
        duration: Duration(seconds: 19),
        poster: '$_img/casa_amarela_1.jpg',
      ),
    ],
  );

  /// Os 8 rolês salvos (etapa 04 do blueprint).
  static const savedRoles = [
    casaAstral,
    mercadoBoaVista,
    cinemaSaoLuiz,
    casaDeBamba,
    pocoDaPanela,
    sitioTrindade,
    mercadoEncruzilhada,
    donaLindu,
  ];

  static const allRoles = [...savedRoles, mercadoCasaAmarela];

  static Role roleById(String id) => allRoles.firstWhere((r) => r.id == id);

  // ── Roteiro agrupado por dia e distância ─────────────────────────────
  static const itinerary = [
    ItineraryDay(
      id: 'sex',
      tab: 'Sex',
      title: 'Sexta, 14 nov',
      area: 'Zona sul e centro',
      stops: [
        ItineraryStop(
          roleId: 'dona-lindu',
          time: '16h30',
          period: StopPeriod.tarde,
          fromPrevious: '15 min a pé',
        ),
        ItineraryStop(
          roleId: 'casa-de-bamba',
          time: '20h',
          period: StopPeriod.noite,
          fromPrevious: '22 min de carro',
          mode: TravelMode.carro,
        ),
      ],
    ),
    ItineraryDay(
      id: 'sab',
      tab: 'Sáb',
      title: 'Sábado, 15 nov',
      area: 'Zona norte',
      stops: [
        ItineraryStop(
          roleId: 'mercado-encruzilhada',
          time: '10h',
          period: StopPeriod.manha,
          fromPrevious: '24 min de carro',
          mode: TravelMode.carro,
        ),
        ItineraryStop(
          roleId: 'sitio-trindade',
          time: '15h',
          period: StopPeriod.tarde,
          fromPrevious: '9 min de carro',
          mode: TravelMode.carro,
        ),
        ItineraryStop(
          roleId: 'poco-da-panela',
          time: '17h',
          period: StopPeriod.tarde,
          fromPrevious: '17 min a pé',
        ),
        ItineraryStop(
          roleId: 'casa-astral',
          time: '21h',
          period: StopPeriod.noite,
          fromPrevious: '2 min a pé',
        ),
      ],
    ),
    ItineraryDay(
      id: 'dom',
      tab: 'Dom',
      title: 'Domingo, 16 nov',
      area: 'Centro',
      stops: [
        ItineraryStop(
          roleId: 'mercado-boa-vista',
          time: '11h',
          period: StopPeriod.manha,
          fromPrevious: '18 min de carro',
          mode: TravelMode.carro,
        ),
        ItineraryStop(
          roleId: 'cinema-sao-luiz',
          time: '16h',
          period: StopPeriod.tarde,
          fromPrevious: '9 min a pé',
        ),
      ],
    ),
  ];

  /// Troca proposta por chuva: sábado 15h.
  static const swapDayId = 'sab';
  static const swapFromId = 'sitio-trindade';
  static const swapToId = 'mercado-casa-amarela';

  static const extras = [
    TravelExtra(
      id: 'transfer',
      title: 'Volta com motorista mulher',
      detail: 'Sáb, 23h30',
      price: r'R$ 42',
      isTransfer: true,
    ),
    TravelExtra(
      id: 'grupo',
      title: 'Forró em grupo com guia',
      detail: 'Sáb, 21h',
      price: r'R$ 35',
      isTransfer: false,
    ),
  ];

  /// Categorias da 99 e da Uber pro transfer de volta (só motoristas
  /// mulheres). Fora de ordem de propósito: o sheet ordena por preço.
  static const rideOptions = [
    RideOption(
      id: 'uber-x',
      provider: ConnectorKind.uber,
      name: 'UberX',
      detail: 'Econômico',
      price: 42,
    ),
    RideOption(
      id: '99-comfort',
      provider: ConnectorKind.noveNove,
      name: '99Comfort',
      detail: 'Carro mais novo e espaçoso',
      price: 49,
    ),
    RideOption(
      id: '99-pop',
      provider: ConnectorKind.noveNove,
      name: '99Pop',
      detail: 'Econômico',
      price: 38,
    ),
    RideOption(
      id: 'uber-black',
      provider: ConnectorKind.uber,
      name: 'Uber Black',
      detail: 'Executivo',
      price: 79,
    ),
    RideOption(
      id: 'uber-comfort',
      provider: ConnectorKind.uber,
      name: 'Uber Comfort',
      detail: 'Carro mais novo e espaçoso',
      price: 54,
    ),
  ];

  /// Mais em conta primeiro (desempate: ordem do mock).
  static List<RideOption> get ridesByPrice {
    final list = [...rideOptions];
    // Sort estável: List.sort não garante, então desempata pelo índice.
    final order = {for (var i = 0; i < list.length; i++) list[i].id: i};
    list.sort((a, b) {
      final byPrice = a.price.compareTo(b.price);
      return byPrice != 0 ? byPrice : order[a.id]!.compareTo(order[b.id]!);
    });
    return list;
  }

  static RideOption? rideById(String? id) {
    for (final r in rideOptions) {
      if (r.id == id) return r;
    }
    return null;
  }

  static const connectors = [
    Connector(
      kind: ConnectorKind.googleCalendar,
      name: 'Google Agenda',
      detail: 'Um evento por rolê',
    ),
    Connector(
      kind: ConnectorKind.googleMaps,
      name: 'Google Maps',
      detail: 'Rotas entre os rolês',
    ),
    Connector(
      kind: ConnectorKind.uber,
      name: 'Uber',
      detail: 'Corrida com seus cupons',
    ),
    Connector(
      kind: ConnectorKind.noveNove,
      name: '99',
      detail: 'Corrida com seus cupons',
    ),
    Connector(
      kind: ConnectorKind.gmail,
      name: 'Gmail',
      detail: 'Guarda confirmações e ingressos',
    ),
  ];
}
