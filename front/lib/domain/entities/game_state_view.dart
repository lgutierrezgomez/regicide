import 'package:equatable/equatable.dart';

import 'game_card.dart';
import 'game_public_state.dart';

class GameStateView extends Equatable {
  const GameStateView({
    required this.public,
    required this.hand,
  });

  final GamePublicState public;
  final List<GameCard> hand;

  @override
  List<Object?> get props => [public, hand];
}
