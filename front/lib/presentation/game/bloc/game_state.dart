import 'package:equatable/equatable.dart';

import '../../../domain/entities/game_public_state.dart';
import '../../../domain/entities/game_state_view.dart';
import '../../../domain/entities/room_session.dart';
import '../../../domain/game/card_rules.dart';
import '../../../domain/game/enemy_stats.dart';

enum GameConnectionStatus { connecting, connected, failed }

enum GameStatus { loading, ready, failure, noSession, navigateToLobby }

class GameState extends Equatable {
  const GameState({
    this.status = GameStatus.loading,
    this.connectionStatus = GameConnectionStatus.connecting,
    this.session,
    this.view,
    this.playerDisplayNames = const {},
    this.selectedCardIds = const {},
    this.errorMessage,
    this.actionPending = false,
  });

  final GameStatus status;
  final GameConnectionStatus connectionStatus;
  final RoomSession? session;
  final GameStateView? view;

  /// Player id → display name from lobby room (for multiplayer labels).
  final Map<String, String> playerDisplayNames;
  final Set<String> selectedCardIds;
  final String? errorMessage;
  final bool actionPending;

  GamePublicState? get public => view?.public;

  bool get isMyTurn =>
      session != null &&
      public != null &&
      public!.currentPlayerId == session!.playerId;

  bool get isMultiplayer => public != null && public!.playerOrder.length > 1;

  String playerLabel(String playerId) {
    final name = playerDisplayNames[playerId];
    if (name != null && name.isNotEmpty) {
      return name;
    }
    if (session?.playerId == playerId) {
      return session!.displayName;
    }
    return playerId.length > 6 ? '${playerId.substring(0, 6)}…' : playerId;
  }

  String get currentTurnLabel =>
      public == null ? '' : playerLabel(public!.currentPlayerId);

  bool get canInteract =>
      status == GameStatus.ready &&
      connectionStatus == GameConnectionStatus.connected &&
      isMyTurn &&
      public!.outcome == GameOutcome.playing;

  bool get canPlay =>
      canInteract &&
      public!.phase == GamePhase.step1PlayOrYield &&
      selectedCardIds.isNotEmpty;

  bool get canYield =>
      canInteract &&
      public!.phase == GamePhase.step1PlayOrYield &&
      public!.canYield;

  /// Step 4: damage to cover (server `pendingDamage`, or derived from enemy − shield).
  int get requiredDiscardTotal {
    final public = this.public;
    if (public == null || public.phase != GamePhase.step4Discard) {
      return 0;
    }
    return netAttackOnPlayer(
      enemy: public.currentEnemy,
      fightSpadeShield: public.fightSpadeShield,
      pendingDamage: public.pendingDamage,
    );
  }

  bool get isDiscardPhase =>
      canInteract && public!.phase == GamePhase.step4Discard;

  /// Step 4: discard total ≥ required (0 when spades fully block the attack).
  bool get canDiscard {
    if (!isDiscardPhase) {
      return false;
    }
    return selectedDiscardTotal >= requiredDiscardTotal;
  }

  bool get canChooseNext =>
      canInteract &&
      public!.phase == GamePhase.chooseNextPlayer &&
      public!.pendingChooseNext;

  bool get canSoloJester {
    if (!canInteract || public == null || session == null) {
      return false;
    }
    final remaining = public!.soloJestersRemaining;
    if (remaining == null || remaining <= 0) {
      return false;
    }
    return public!.phase == GamePhase.step1PlayOrYield ||
        public!.phase == GamePhase.step4Discard;
  }

  int get selectedDiscardTotal {
    if (view == null) {
      return 0;
    }
    return sumDiscardValue(
      view!.hand.where((c) => selectedCardIds.contains(c.id)),
    );
  }

  int? get pendingDamage => public?.pendingDamage;

  GameState copyWith({
    GameStatus? status,
    GameConnectionStatus? connectionStatus,
    RoomSession? session,
    GameStateView? view,
    Map<String, String>? playerDisplayNames,
    Set<String>? selectedCardIds,
    String? errorMessage,
    bool? actionPending,
    bool clearError = false,
    bool clearSelection = false,
  }) {
    return GameState(
      status: status ?? this.status,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      session: session ?? this.session,
      view: view ?? this.view,
      playerDisplayNames: playerDisplayNames ?? this.playerDisplayNames,
      selectedCardIds:
          clearSelection ? const {} : (selectedCardIds ?? this.selectedCardIds),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      actionPending: actionPending ?? this.actionPending,
    );
  }

  @override
  List<Object?> get props => [
        status,
        connectionStatus,
        session,
        view,
        playerDisplayNames,
        selectedCardIds,
        errorMessage,
        actionPending,
      ];
}
