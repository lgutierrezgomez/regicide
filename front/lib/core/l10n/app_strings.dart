/// All user-visible strings — edit here, not in widgets.
abstract final class AppStrings {
  // App
  static const appTitle = 'Regicide';

  // Home
  static const homeSubtitle = 'Create a room or join with a code';
  static const displayNameLabel = 'Display name';
  static const displayNameHint = 'Your name at the table';
  static const roomCodeLabel = 'Room code';
  static const roomCodeHint = 'e.g. ABC123';
  static const createRoomSolo = 'Create room (solo)';
  static const creatingRoom = 'Creating…';
  static const joinRoom = 'Join room';
  static String serverHint(String url) => 'Server: $url';

  // Home errors (BLoC)
  static const errorDisplayNameRequired = 'Enter your display name';
  static const errorRoomCodeInvalid = 'Enter a valid room code';
  static const errorCreateRoomFailed =
      'Could not create room. Is the server running?';
  static const errorJoinRoomFailed =
      'Could not join room. Is the server running?';
  static const errorRoomFull = 'This room is full (max 4 players).';
  static const errorGameAlreadyStarted =
      'This game has already started. Ask the host for a new room code.';
  static const errorRoomNotFound =
      'Room not found. Check the code and try again.';
  static const errorNotHost = 'Only the host can start the game.';
  static const errorNotInRoom = 'You are not in this room.';
  static const errorInvalidName = 'Enter a display name (1–32 characters).';
  static const errorGeneric = 'Something went wrong. Try again.';
  static const errorNotYourTurn = 'It is not your turn.';
  static const errorGameAction = 'That action is not allowed right now.';
  static const errorDisconnected =
      'Disconnected from the server. Check your connection and reconnect.';
  static const reconnect = 'Reconnect';

  // Communication (Regicide table rules — UI reminder only)
  static const communicationTitle = 'Table talk';
  static const communicationBody =
      'Do not reveal or suggest cards in your hand. You may share hand counts and tavern pile size. After playing a jester, you may only give vague hints about who should go next.';

  // Lobby
  static const lobbyTitle = 'Lobby';
  static const roomCodeSection = 'Room code';
  static const inviteLinkSection = 'Invite link';
  static const copyRoomCode = 'Copy code';
  static const copyInviteLink = 'Copy invite link';
  static const roomCodeCopied = 'Room code copied';
  static const inviteLinkCopied = 'Invite link copied';
  static const playingAs = 'Playing as';
  static const youAreHost = 'You are the host';
  static const joinedAsGuest = 'Joined as guest';
  static const playersSection = 'Players';
  static String playerCount(int current, int max) => '$current / $max players';
  static const hostBadge = 'Host';
  static const youBadge = 'You';
  static String hostYouBadge() => '$youBadge · $hostBadge';
  static const connected = 'Online';
  static const offline = 'Offline';
  static const connectionConnecting = 'Connecting…';
  static const connectionLive = 'Connected to server';
  static const connectionError = 'Connection failed';
  static const startGame = 'Start game';
  static const startingGame = 'Starting…';
  static const waitingForHost = 'Waiting for host to start';
  static const lobbySoloHint = 'Solo mode: you are the host. Start when ready.';
  static const lobbyMultiplayerHint =
      'Share the invite link so others can join (2–4 players). Start when everyone is ready.';
  static const noSession = 'No session found. Return home and create a room.';

  // Lobby errors
  static const errorStartGameFailed = 'Could not start the game';
  static const errorSocketConnect =
      'Could not connect to lobby. Is the server running?';

  // Game
  static const gameTitle = 'Game';
  static const gameConnecting = 'Connecting…';
  static const gameConnected = 'Connected to server';
  static const gameConnectionFailed = 'Connection failed';
  static const errorGameConnect =
      'Could not connect to game. Is the server running?';
  static String gameWaitingTurn(String playerName) =>
      'Waiting for $playerName…';
  static String gameCurrentTurn(String playerName) => 'Turn: $playerName';
  static const gameYourTurn = 'Your turn';
  static const gamePhaseStep1 = 'Play cards against the enemy or yield.';
  static String gamePhaseDiscard(int required, int selected) {
    if (required == 0) {
      return 'Spades blocked the attack — tap Discard (0) to continue.';
    }
    return 'Discard cards totaling at least $required (selected: $selected).';
  }

  static const gamePhaseChooseNextSolo = 'Continue your turn (solo).';
  static const gamePhaseChooseNextMulti =
      'Choose who plays next after the jester.';
  static String gameChooseNextPick(String name) => 'Next: $name';
  static const gameChooseNextDialogTitle = 'Who plays next?';
  static const gameChooseNextDialogTitleSolo = 'Continue your turn';
  static const gamePhaseOver = 'Game over.';
  static String gameOutcomeWon(String? tier) =>
      tier != null ? 'Victory ($tier)!' : 'Victory!';
  static const gameOutcomeLost = 'Defeat — the realm has fallen.';
  static const gameNoEnemy = 'No enemy on the table (castle empty or won).';
  static const gameImmunityCancelled = 'Enemy immunity cancelled (jester).';
  static const gameCastleLabel = 'Castle';
  static const gameDiscardLabel = 'Discard';
  static const gameTavernLabel = 'Tavern';
  static const gamePlayedThisFightTitle = 'Played this fight';
  static const gamePlayedThisFightEmpty = 'No cards played yet';
  static String gameHandTitle(int count, int max) =>
      'Your hand ($count / $max)';
  static const gameHandEmpty = 'No cards in hand';
  static String gameActionPlay(int count) => 'Play ($count)';
  static const gameActionYield = 'Yield';
  static String gameActionDiscard(int count) => 'Discard ($count)';
  static const gameActionContinue = 'Continue';
  static String gameActionSoloJester(int left) =>
      'Use solo jester ($left left)';
  static const gameClearSelection = 'Clear selection';
  static const gameConcede = 'Concede';
  static const gameConcedeDialogTitle = 'End this game?';
  static const gameConcedeDialogBody =
      'Stop the current match. You can start a fresh game with the same players or go back to the lobby.';
  static const gameConcedeNewGame = 'New game (same players)';
  static const gameConcedeReturnLobby = 'Return to lobby';
  static const gameConcedeHostOnly =
      'Only the host can end the match or start a rematch.';
  static const gameConcedeCancel = 'Cancel';

  // Instructions (paginated dialog)
  static const instructionsButton = 'How to play';
  static const instructionsDialogTitle = 'Regicide rules';
  static const instructionsPrevious = 'Previous';
  static const instructionsNext = 'Next';
  static const instructionsClose = 'Close';
  static String instructionsPageIndicator(int page, int total) =>
      'Page $page of $total';
  static const instructionsLoadError = 'Could not load rules.';

  // Symbol legend (game table)
  static const gameSymbolLegendTitle = 'Symbols';
  static const gameSymbolHearts = 'H';
  static const gameSymbolHeartsPower = 'Bury cards under tavern (no peek)';
  static const gameSymbolDiamonds = 'D';
  static const gameSymbolDiamondsPower = 'Draw for all players (attack value)';
  static const gameSymbolClubs = 'C';
  static const gameSymbolClubsPower = 'Double damage this fight';
  static const gameSymbolSpades = 'S';
  static const gameSymbolSpadesPower = 'Reduce attack when you discard';
  static const gameSymbolAce = 'A';
  static const gameSymbolAcePower = 'Animal companion (+1, special pair rules)';
  static const gameSymbolJester = 'J';
  static const gameSymbolJesterPower = 'Cancel immunity; pick next player';

  // Status labels from server
  static const statusLobby = 'lobby';
  static const statusInGame = 'in_game';
}
