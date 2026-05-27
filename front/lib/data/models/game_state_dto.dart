import '../../domain/entities/game_card.dart';
import '../../domain/entities/game_public_state.dart';
import '../../domain/entities/game_state_view.dart';

class GameStateDto {
  GameStateDto({required this.public, required this.hand});

  final GamePublicStateDto public;
  final List<GameCardDto> hand;

  factory GameStateDto.fromJson(Map<String, dynamic> json) {
    final publicJson = json['public'];
    final handJson = json['hand'];
    return GameStateDto(
      public: GamePublicStateDto.fromJson(
        publicJson is Map
            ? Map<String, dynamic>.from(publicJson)
            : <String, dynamic>{},
      ),
      hand: handJson is List
          ? handJson
              .whereType<Map>()
              .map((e) => GameCardDto.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
    );
  }

  GameStateView toEntity() => GameStateView(
        public: public.toEntity(),
        hand: hand.map((c) => c.toEntity()).toList(),
      );
}

class GamePublicStateDto {
  GamePublicStateDto({
    required this.roomCode,
    required this.outcome,
    required this.phase,
    required this.currentPlayerId,
    required this.playerOrder,
    required this.maxHandSize,
    required this.handCounts,
    required this.tavernCount,
    required this.discardCount,
    required this.castleCount,
    required this.currentEnemy,
    required this.fightDamage,
    required this.fightSpadeShield,
    required this.immunityCancelled,
    required this.playedAgainstEnemy,
    required this.pendingDamage,
    required this.pendingChooseNext,
    required this.soloJestersRemaining,
    required this.canYield,
    this.victoryTier,
  });

  final String roomCode;
  final String outcome;
  final String? victoryTier;
  final String phase;
  final String currentPlayerId;
  final List<String> playerOrder;
  final int maxHandSize;
  final Map<String, int> handCounts;
  final int tavernCount;
  final int discardCount;
  final int castleCount;
  final GameCardDto? currentEnemy;
  final int fightDamage;
  final int fightSpadeShield;
  final bool immunityCancelled;
  final List<PlayedAgainstEnemyDto> playedAgainstEnemy;
  final int? pendingDamage;
  final bool pendingChooseNext;
  final int? soloJestersRemaining;
  final bool canYield;

  factory GamePublicStateDto.fromJson(Map<String, dynamic> json) {
    final handCountsRaw = json['handCounts'];
    final handCounts = <String, int>{};
    if (handCountsRaw is Map) {
      handCountsRaw.forEach((key, value) {
        if (value is int) {
          handCounts[key.toString()] = value;
        } else if (value is num) {
          handCounts[key.toString()] = value.toInt();
        }
      });
    }

    final playedRaw = json['playedAgainstEnemy'];
    final played = playedRaw is List
        ? playedRaw
            .whereType<Map>()
            .map(
              (e) => PlayedAgainstEnemyDto.fromJson(
                Map<String, dynamic>.from(e),
              ),
            )
            .toList()
        : <PlayedAgainstEnemyDto>[];

    final enemyJson = json['currentEnemy'];
    return GamePublicStateDto(
      roomCode: json['roomCode']?.toString() ?? '',
      outcome: json['outcome']?.toString() ?? 'playing',
      victoryTier: json['victoryTier']?.toString(),
      phase: json['phase']?.toString() ?? 'STEP1_PLAY_OR_YIELD',
      currentPlayerId: json['currentPlayerId']?.toString() ?? '',
      playerOrder:
          (json['playerOrder'] as List?)?.map((e) => e.toString()).toList() ??
              [],
      maxHandSize: (json['maxHandSize'] as num?)?.toInt() ?? 0,
      handCounts: handCounts,
      tavernCount: (json['tavernCount'] as num?)?.toInt() ?? 0,
      discardCount: (json['discardCount'] as num?)?.toInt() ?? 0,
      castleCount: (json['castleCount'] as num?)?.toInt() ?? 0,
      currentEnemy: enemyJson is Map
          ? GameCardDto.fromJson(Map<String, dynamic>.from(enemyJson))
          : null,
      fightDamage: (json['fightDamage'] as num?)?.toInt() ?? 0,
      fightSpadeShield: (json['fightSpadeShield'] as num?)?.toInt() ?? 0,
      immunityCancelled: json['immunityCancelled'] == true,
      playedAgainstEnemy: played,
      pendingDamage: (json['pendingDamage'] as num?)?.toInt(),
      pendingChooseNext: json['pendingChooseNext'] == true,
      soloJestersRemaining: (json['soloJestersRemaining'] as num?)?.toInt(),
      canYield: json['canYield'] != false,
    );
  }

  GamePublicState toEntity() => GamePublicState(
        roomCode: roomCode,
        outcome: _parseOutcome(outcome),
        victoryTier: victoryTier,
        phase: _parsePhase(phase),
        currentPlayerId: currentPlayerId,
        playerOrder: playerOrder,
        maxHandSize: maxHandSize,
        handCounts: handCounts,
        tavernCount: tavernCount,
        discardCount: discardCount,
        castleCount: castleCount,
        currentEnemy: currentEnemy?.toEntity(),
        fightDamage: fightDamage,
        fightSpadeShield: fightSpadeShield,
        immunityCancelled: immunityCancelled,
        playedAgainstEnemy:
            playedAgainstEnemy.map((e) => e.toEntity()).toList(),
        pendingDamage: pendingDamage,
        pendingChooseNext: pendingChooseNext,
        soloJestersRemaining: soloJestersRemaining,
        canYield: canYield,
      );
}

class PlayedAgainstEnemyDto {
  PlayedAgainstEnemyDto({required this.playerId, required this.cards});

  final String playerId;
  final List<GameCardDto> cards;

  factory PlayedAgainstEnemyDto.fromJson(Map<String, dynamic> json) {
    final cardsJson = json['cards'];
    return PlayedAgainstEnemyDto(
      playerId: json['playerId']?.toString() ?? '',
      cards: cardsJson is List
          ? cardsJson
              .whereType<Map>()
              .map((e) => GameCardDto.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
    );
  }

  PlayedAgainstEnemy toEntity() => PlayedAgainstEnemy(
        playerId: playerId,
        cards: cards.map((c) => c.toEntity()).toList(),
      );
}

class GameCardDto {
  GameCardDto({
    required this.id,
    required this.kind,
    required this.suit,
    required this.rankLabel,
  });

  final String id;
  final String kind;
  final String suit;
  final String rankLabel;

  factory GameCardDto.fromJson(Map<String, dynamic> json) {
    final rank = json['rank'];
    String rankLabel;
    if (rank is num) {
      rankLabel = rank.toInt().toString();
    } else {
      rankLabel = rank?.toString() ?? '?';
    }
    return GameCardDto(
      id: json['id']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'number',
      suit: json['suit']?.toString() ?? 'spades',
      rankLabel: rankLabel,
    );
  }

  GameCard toEntity() => GameCard(
        id: id,
        kind: _parseKind(kind),
        suit: _parseSuit(suit),
        rankLabel: rankLabel,
      );
}

GameCardKind _parseKind(String raw) {
  switch (raw) {
    case 'ace':
      return GameCardKind.ace;
    case 'jester':
      return GameCardKind.jester;
    case 'enemy':
      return GameCardKind.enemy;
    default:
      return GameCardKind.number;
  }
}

GameSuit _parseSuit(String raw) {
  switch (raw) {
    case 'hearts':
      return GameSuit.hearts;
    case 'diamonds':
      return GameSuit.diamonds;
    case 'clubs':
      return GameSuit.clubs;
    default:
      return GameSuit.spades;
  }
}

GameOutcome _parseOutcome(String raw) {
  switch (raw) {
    case 'won':
      return GameOutcome.won;
    case 'lost':
      return GameOutcome.lost;
    default:
      return GameOutcome.playing;
  }
}

GamePhase _parsePhase(String raw) {
  switch (raw) {
    case 'STEP4_DISCARD':
      return GamePhase.step4Discard;
    case 'CHOOSE_NEXT_PLAYER':
      return GamePhase.chooseNextPlayer;
    case 'GAME_OVER':
      return GamePhase.gameOver;
    default:
      return GamePhase.step1PlayOrYield;
  }
}
