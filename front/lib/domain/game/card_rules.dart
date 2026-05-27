import '../entities/game_card.dart';

int discardValueForCard(GameCard card) {
  if (card.kind == GameCardKind.jester) {
    return 0;
  }
  if (card.kind == GameCardKind.ace) {
    return 1;
  }
  if (card.kind == GameCardKind.number) {
    return int.tryParse(card.rankLabel) ?? 0;
  }
  switch (card.rankLabel) {
    case 'JACK':
      return 10;
    case 'QUEEN':
      return 15;
    case 'KING':
      return 20;
    default:
      return 0;
  }
}

int sumDiscardValue(Iterable<GameCard> cards) =>
    cards.fold(0, (sum, c) => sum + discardValueForCard(c));
