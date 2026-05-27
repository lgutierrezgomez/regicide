import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../domain/entities/game_card.dart';
import '../bloc/game_state.dart';
import '../widgets/suit_pip.dart';

/// bottom-center cell: local player's hand as horizontal scrollable cards.
class PlayerHandStrip extends StatelessWidget {
  const PlayerHandStrip({
    super.key,
    required this.state,
    required this.onCardTap,
  });

  final GameState state;
  final void Function(String cardId) onCardTap;

  @override
  Widget build(BuildContext context) {
    final view = state.view;
    if (view == null) {
      return const SizedBox.shrink();
    }
    final hand = view.hand;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
          child: Text(
            AppStrings.gameHandTitle(hand.length, view.public.maxHandSize),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: hand.isEmpty
              ? Center(
                  child: Text(
                    AppStrings.gameHandEmpty,
                    style: theme.textTheme.bodySmall,
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minWidth: constraints.maxWidth - 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var i = 0; i < hand.length; i++) ...[
                              if (i > 0) const SizedBox(width: 6),
                              _HandCard(
                                card: hand[i],
                                selected:
                                    state.selectedCardIds.contains(hand[i].id),
                                onTap: state.canInteract
                                    ? () => onCardTap(hand[i].id)
                                    : null,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _HandCard extends StatelessWidget {
  const _HandCard({
    required this.card,
    required this.selected,
    required this.onTap,
  });

  final GameCard card;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = card.isRedSuit ? Colors.red.shade800 : Colors.black;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 62,
        transform: Matrix4.translationValues(0, selected ? -10 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.black.withOpacity(0.35),
            width: selected ? 2.5 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              card.rankLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            SuitPip(
              suit: card.suit,
              size: 28,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}
