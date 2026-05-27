import 'package:flutter/material.dart';

import '../../../domain/entities/game_card.dart';

/// Standard unicode suit pip — used on all card faces and in the symbol legend.
class SuitPip extends StatelessWidget {
  const SuitPip({
    super.key,
    required this.suit,
    this.size = 16,
    this.color = Colors.black,
  });

  final GameSuit suit;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      _pip(suit),
      style: TextStyle(
        fontSize: size,
        color: color,
        height: 1,
      ),
    );
  }

  static String _pip(GameSuit s) {
    switch (s) {
      case GameSuit.hearts:
        return '♥';
      case GameSuit.diamonds:
        return '♦';
      case GameSuit.clubs:
        return '♣';
      case GameSuit.spades:
        return '♠';
    }
  }
}
