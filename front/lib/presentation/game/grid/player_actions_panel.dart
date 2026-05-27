import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../bloc/game_state.dart';

/// bottom-right cell: all the local player's actions.
class PlayerActionsPanel extends StatelessWidget {
  const PlayerActionsPanel({
    super.key,
    required this.state,
    required this.onPlay,
    required this.onYield,
    required this.onDiscard,
    required this.onSoloJester,
    required this.onClearSelection,
  });

  final GameState state;
  final VoidCallback onPlay;
  final VoidCallback onYield;
  final VoidCallback onDiscard;
  final VoidCallback onSoloJester;
  final VoidCallback onClearSelection;

  @override
  Widget build(BuildContext context) {
    final busy = state.actionPending;
    final selectionCount = state.selectedCardIds.length;

    final buttons = <Widget>[];

    if (state.canPlay) {
      buttons.add(
        FilledButton(
          onPressed: busy ? null : onPlay,
          child: Text(AppStrings.gameActionPlay(selectionCount)),
        ),
      );
    }
    if (state.canYield) {
      buttons.add(
        OutlinedButton(
          onPressed: busy ? null : onYield,
          child: const Text(AppStrings.gameActionYield),
        ),
      );
    }
    if (state.isDiscardPhase) {
      final label = state.requiredDiscardTotal == 0
          ? AppStrings.gameActionContinue
          : AppStrings.gameActionDiscard(selectionCount);
      buttons.add(
        FilledButton(
          onPressed: busy || !state.canDiscard ? null : onDiscard,
          child: Text(label),
        ),
      );
    }
    if (state.canSoloJester) {
      buttons.add(
        OutlinedButton(
          onPressed: busy ? null : onSoloJester,
          child: Text(
            AppStrings.gameActionSoloJester(
              state.public!.soloJestersRemaining ?? 0,
            ),
          ),
        ),
      );
    }
    if (selectionCount > 0) {
      buttons.add(
        TextButton(
          onPressed: busy ? null : onClearSelection,
          child: const Text(AppStrings.gameClearSelection),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: buttons.isEmpty
          ? Center(
              child: Text(
                state.isMyTurn
                    ? '—'
                    : AppStrings.gameWaitingTurn(state.currentTurnLabel),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < buttons.length; i++) ...[
                  if (i > 0) const SizedBox(height: 6),
                  buttons[i],
                ],
              ],
            ),
    );
  }
}
