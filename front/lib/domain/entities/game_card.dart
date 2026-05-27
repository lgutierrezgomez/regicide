import 'package:equatable/equatable.dart';

enum GameCardKind { number, ace, jester, enemy }

enum GameSuit { hearts, diamonds, clubs, spades }

/// Card visible to the local player (from server `CardPublic`).
class GameCard extends Equatable {
  const GameCard({
    required this.id,
    required this.kind,
    required this.suit,
    required this.rankLabel,
  });

  final String id;
  final GameCardKind kind;
  final GameSuit suit;

  /// Display label: 2–10, A, JOKER, JACK, QUEEN, KING.
  final String rankLabel;

  bool get isRedSuit => suit == GameSuit.hearts || suit == GameSuit.diamonds;

  String get suitLetter {
    switch (suit) {
      case GameSuit.hearts:
        return 'H';
      case GameSuit.diamonds:
        return 'D';
      case GameSuit.clubs:
        return 'C';
      case GameSuit.spades:
        return 'S';
    }
  }

  @override
  List<Object?> get props => [id, kind, suit, rankLabel];
}
