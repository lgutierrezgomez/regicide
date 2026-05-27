import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../domain/entities/game_card.dart';
import '../../../domain/entities/game_public_state.dart';
import '../widgets/suit_pip.dart';

/// middle-left cell: the cards played by anyone against the current enemy
/// this fight, oldest first.
class PlayedThisFightCell extends StatelessWidget {
  const PlayedThisFightCell({super.key, required this.public});

  final GamePublicState public;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cards = <GameCard>[
      for (final entry in public.playedAgainstEnemy) ...entry.cards,
    ];

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.gamePlayedThisFightTitle,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: cards.isEmpty
                ? Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      AppStrings.gamePlayedThisFightEmpty,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        for (final card in cards) _MiniCard(card: card),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({required this.card});

  final GameCard card;

  @override
  Widget build(BuildContext context) {
    final color = card.isRedSuit ? Colors.red.shade800 : Colors.black;
    return Container(
      width: 34,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.black.withOpacity(0.30)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.rankLabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          SuitPip(
            suit: card.suit,
            size: 18,
            color: color,
          ),
        ],
      ),
    );
  }
}
