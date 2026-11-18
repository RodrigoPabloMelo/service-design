import 'package:equatable/equatable.dart';

/// Categoria do rolê. Cada uma tem cor + glifo próprios (similaridade
/// gestalt: o mesmo par aparece no pin, na timeline e na tag do card).
enum RoleCategory { comida, cultura, noite, natureza, praia }

/// De onde vem o vídeo curto curado.
enum VideoSource { tiktok, instagram, local }

/// Período do dia — agrupa paradas (chunking).
enum StopPeriod { manha, tarde, noite }

/// Como a viajante chega na parada.
enum TravelMode { aPe, carro }

enum ConnectorKind { googleCalendar, googleMaps, gmail, noveNove, uber }

class GeoPoint extends Equatable {
  const GeoPoint(this.lat, this.lng);

  final double lat;
  final double lng;

  @override
  List<Object?> get props => [lat, lng];
}

/// Foto real (Wikimedia Commons) com crédito — exigência da licença.
class PhotoCredit extends Equatable {
  const PhotoCredit({
    required this.asset,
    required this.author,
    required this.license,
  });

  final String asset;
  final String author;
  final String license;

  @override
  List<Object?> get props => [asset, author, license];
}

/// Pessoa da cidade que indicou o rolê (o nome aparece no card).
class Recommender extends Equatable {
  const Recommender({
    required this.name,
    required this.tie,
    required this.quote,
    this.photo,
  });

  final String name;

  /// Retrato (asset). Sem foto → iniciais.
  final String? photo;

  /// Vínculo com o lugar: "mora no Poço da Panela há 12 anos".
  final String tie;
  final String quote;

  String get initials => name
      .split(' ')
      .where((p) => p.isNotEmpty)
      .take(2)
      .map((p) => p[0])
      .join()
      .toUpperCase();

  @override
  List<Object?> get props => [name, tie, quote, photo];
}

class ShortVideo extends Equatable {
  const ShortVideo({
    required this.id,
    required this.source,
    required this.handle,
    required this.caption,
    required this.duration,
    required this.poster,
  });

  final String id;
  final VideoSource source;
  final String handle;
  final String caption;
  final Duration duration;

  /// Placeholder: foto do lugar usada como poster animado (Ken Burns).
  final String poster;

  @override
  List<Object?> get props => [id, source, handle, caption, duration, poster];
}

/// Tipo de dica do "o que fazer" (vira ícone na apresentação).
enum TipKind {
  food,
  drink,
  music,
  dance,
  walk,
  photo,
  view,
  film,
  nature,
  shop,
  art,
  sport
}

/// Uma dica curta do que fazer no rolê.
class RoleTip extends Equatable {
  const RoleTip(this.kind, this.text);

  final TipKind kind;
  final String text;

  @override
  List<Object?> get props => [kind, text];
}

/// Selo de segurança do rolê. Nome, quem concede e critérios são
/// **(hipótese)** — Q-10 segue aberta. Descreve o que foi checado, nunca
/// promete segurança.
class RoleSeal extends Equatable {
  const RoleSeal({
    this.by = 'Moradoras e curadoria',
    this.checks = const ['Ir sozinha', 'Chegar e sair à noite'],
  });

  /// Quem avaliou.
  final String by;

  /// Situações avaliadas.
  final List<String> checks;

  static const standard = RoleSeal();

  @override
  List<Object?> get props => [by, checks];
}

/// Informação de acesso no trajeto sugerido (ex.: alagamento na chuva).
/// Descreve a rota, com fonte e data — não garante nada. A fonte do dado é
/// **(hipótese)**: Q-39.
class RouteAccess extends Equatable {
  const RouteAccess({
    required this.text,
    required this.source,
    required this.checkedAt,
  });

  final String text;
  final String source;
  final String checkedAt;

  @override
  List<Object?> get props => [text, source, checkedAt];
}

/// Um rolê indicado por local, curado pela equipe.
class Role extends Equatable {
  const Role({
    required this.id,
    required this.name,
    required this.shortName,
    required this.neighborhood,
    required this.category,
    required this.location,
    required this.price,
    required this.hours,
    required this.photos,
    required this.recommender,
    required this.about,
    required this.whatToDo,
    required this.bestTime,
    required this.cost,
    required this.surroundings,
    required this.verifiedAt,
    required this.videos,
    this.tips = const [],
    this.covered = false,
    this.seal = RoleSeal.standard,
    this.access,
  });

  final String id;
  final String name;

  /// Nome curto para pins e timeline.
  final String shortName;
  final String neighborhood;
  final RoleCategory category;
  final GeoPoint location;

  /// "$", "$$" ou "Grátis".
  final String price;
  final String hours;
  final List<PhotoCredit> photos;
  final Recommender recommender;

  /// O rolê em si — o que é.
  final String about;

  /// O que fazer/pedir.
  final String whatToDo;
  final String bestTime;
  final String cost;

  /// Entorno: iluminação, transporte, segurança.
  final List<String> surroundings;
  final String verifiedAt;
  final List<ShortVideo> videos;

  /// "O que fazer" em cards curtos (rolagem horizontal).
  final List<RoleTip> tips;

  /// Coberto — o agente usa para trocas por chuva.
  final bool covered;

  /// Selo de segurança (hipótese, Q-10).
  final RoleSeal seal;

  /// Acesso no trajeto sugerido (só quando a curadoria tem o dado).
  final RouteAccess? access;

  @override
  List<Object?> get props => [id];
}

class ItineraryStop extends Equatable {
  const ItineraryStop({
    required this.roleId,
    required this.time,
    required this.period,
    this.fromPrevious,
    this.mode = TravelMode.aPe,
  });

  final String roleId;

  /// "21h", "10h30".
  final String time;
  final StopPeriod period;

  /// "900 m · 12 min a pé" — null na primeira parada do dia.
  final String? fromPrevious;
  final TravelMode mode;

  ItineraryStop copyWith({String? roleId}) => ItineraryStop(
        roleId: roleId ?? this.roleId,
        time: time,
        period: period,
        fromPrevious: fromPrevious,
        mode: mode,
      );

  @override
  List<Object?> get props => [roleId, time, period, fromPrevious, mode];
}

class ItineraryDay extends Equatable {
  const ItineraryDay({
    required this.id,
    required this.tab,
    required this.title,
    required this.area,
    required this.stops,
  });

  final String id;

  /// Rótulo curto da aba: "Sex".
  final String tab;

  /// "Sexta, 14 nov".
  final String title;

  /// Agrupamento por distância: "Zona sul · perto do hotel".
  final String area;
  final List<ItineraryStop> stops;

  ItineraryDay copyWith({List<ItineraryStop>? stops}) => ItineraryDay(
        id: id,
        tab: tab,
        title: title,
        area: area,
        stops: stops ?? this.stops,
      );

  @override
  List<Object?> get props => [id, tab, title, area, stops];
}

/// Extra pago ofertado pelo agente (transfer, rolê em grupo).
class TravelExtra extends Equatable {
  const TravelExtra({
    required this.id,
    required this.title,
    required this.detail,
    required this.price,
    required this.isTransfer,
  });

  final String id;
  final String title;
  final String detail;
  final String price;
  final bool isTransfer;

  @override
  List<Object?> get props => [id];
}

/// Categoria de corrida de um app conectado (99, Uber) pra comparar preço
/// antes de adicionar um transfer. Preço em reais inteiros (estimativa).
class RideOption extends Equatable {
  const RideOption({
    required this.id,
    required this.provider,
    required this.name,
    required this.detail,
    required this.price,
  });

  final String id;
  final ConnectorKind provider;
  final String name;
  final String detail;
  final int price;

  String get priceLabel => 'R\$ $price';

  @override
  List<Object?> get props => [id];
}

class Connector extends Equatable {
  const Connector({
    required this.kind,
    required this.name,
    required this.detail,
  });

  final ConnectorKind kind;
  final String name;
  final String detail;

  @override
  List<Object?> get props => [kind];
}

class TripProfile extends Equatable {
  const TripProfile({
    required this.travelerName,
    required this.dates,
    required this.stay,
    required this.stayLocation,
    required this.company,
  });

  final String travelerName;
  final String dates;
  final String stay;
  final GeoPoint stayLocation;
  final String company;

  @override
  List<Object?> get props => [travelerName, dates, stay, stayLocation];
}

/// Passo do processo do agente (linha do tempo "Pensando").
class ProcessStep extends Equatable {
  const ProcessStep({
    required this.title,
    this.detail = '',
    this.sources = const [],
    this.collect = false,
    this.organize = false,
    this.writing = false,
  });

  final String title;
  final String detail;

  /// Fontes consultadas (chips): "Catálogo local", "Selo Rolê Seguro"…
  final List<String> sources;

  /// Passo com a visão de agente (cursor recolhendo rolês na pasta).
  final bool collect;

  /// Passo em que a visão de agente vira calendário (encaixa os rolês).
  final bool organize;

  /// Último passo: "escrevendo" com pontinhos.
  final bool writing;

  @override
  List<Object?> get props =>
      [title, detail, sources, collect, organize, writing];
}

/// Processo longo (recolher no catálogo) ou curto (filtro rápido).
enum ThinkingKind { quick, collect }

enum MessageAuthor { agent, user }

enum MessageKind {
  /// Resumo recolhível do processo ("Pensou por 8s").
  process,
  text,
  savedRoles,
  itinerary,
  extras,
  calendarCta,
  calendarDone,
  swapProposal,
  swapDone,

  /// Pergunta de datas e hospedagem antes do roteiro (etapa 04).
  tripInfo,

  /// Oferta do transfer com motorista parceira depois da troca (D-26).
  transferOffer,

  /// Transfer pago: acompanhamento no app da parceira.
  transferBooked,
  error,
}

class AgentMessage extends Equatable {
  const AgentMessage({
    required this.id,
    required this.author,
    required this.kind,
    this.text = '',
  });

  final String id;
  final MessageAuthor author;
  final MessageKind kind;
  final String text;

  @override
  List<Object?> get props => [id, author, kind, text];
}

/// Conversa antiga com a Maré, mostrada na gaveta (☰). No protótipo é
/// reconstruída a partir do pedido que a abriu ([prompt]): a Maré responde
/// na hora, sem o processo animado. [failed] = a Maré estava fora do ar.
class ConversationSeed extends Equatable {
  const ConversationSeed({
    required this.id,
    required this.title,
    required this.prompt,
    this.pinned = false,
    this.failed = false,
  });

  final String id;
  final String title;
  final String prompt;
  final bool pinned;
  final bool failed;

  @override
  List<Object?> get props => [id, title, prompt, pinned, failed];
}
