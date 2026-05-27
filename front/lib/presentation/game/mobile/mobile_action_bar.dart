import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../bloc/game_state.dart';

/// Sticky bottom action bar for the mobile game body. Same conditions as the
/// desktop [PlayerActionsPanel] but renders buttons in a Row so they share
/// the full width and stay within thumb reach.
class MobileActionBar extends StatelessWidget {
  const MobileActionBar({
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
    final theme = Theme.of(context);
    final busy = state.actionPending;
    final selectionCount = state.selectedCardIds.length;

    final buttons = <Widget>[];

    if (state.canYield) {
      buttons.add(
        OutlinedButton(
          onPressed: busy ? null : onYield,
          child: const Text(AppStrings.gameActionYield),
        ),
      );
    }
    if (state.isDiscardPhase) {
      buttons.add(
        FilledButton(
          onPressed: busy || !state.canDiscard ? null : onDiscard,
          child: Text(AppStrings.gameActionDiscard(selectionCount)),
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
    if (state.canPlay) {
      buttons.add(
        FilledButton(
          onPressed: busy ? null : onPlay,
          child: Text(AppStrings.gameActionPlay(selectionCount)),
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

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: Colors.black.withOpacity(0.08)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: SafeArea(
        top: false,
        child: buttons.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  state.isMyTurn
                      ? '—'
                      : AppStrings.gameWaitingTurn(state.currentTurnLabel),
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              )
            : Row(
                children: [
                  for (var i = 0; i < buttons.length; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    Expanded(child: buttons[i]),
                  ],
                ],
              ),
      ),
    );
  }
}
