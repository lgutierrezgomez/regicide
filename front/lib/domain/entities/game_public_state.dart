import 'package:equatable/equatable.dart';

import 'game_card.dart';

enum GamePhase {
  step1PlayOrYield,
  step4Discard,
  chooseNextPlayer,
  gameOver,
}

enum GameOutcome { playing, won, lost }

class PlayedAgainstEnemy extends Equatable {
  const PlayedAgainstEnemy({
    required this.playerId,
    required this.cards,
  });

  final String playerId;
  final List<GameCard> cards;

  @override
  List<Object?> get props => [playerId, cards];
}

class GamePublicState extends Equatable {
  const GamePublicState({
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
  final GameOutcome outcome;
  final String? victoryTier;
  final GamePhase phase;
  final String currentPlayerId;
  final List<String> playerOrder;
  final int maxHandSize;
  final Map<String, int> handCounts;
  final int tavernCount;
  final int discardCount;
  final int castleCount;
  final GameCard? currentEnemy;
  final int fightDamage;
  final int fightSpadeShield;
  final bool immunityCancelled;
  final List<PlayedAgainstEnemy> playedAgainstEnemy;
  final int? pendingDamage;
  final bool pendingChooseNext;
  final int? soloJestersRemaining;
  final bool canYield;

  bool get isSolo => playerOrder.length == 1;

  @override
  List<Object?> get props => [
        roomCode,
        outcome,
        victoryTier,
        phase,
        currentPlayerId,
        playerOrder,
        maxHandSize,
        handCounts,
        tavernCount,
        discardCount,
        castleCount,
        currentEnemy,
        fightDamage,
        fightSpadeShield,
        immunityCancelled,
        playedAgainstEnemy,
        pendingDamage,
        pendingChooseNext,
        soloJestersRemaining,
        canYield,
      ];
}
