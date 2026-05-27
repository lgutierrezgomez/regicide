import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../domain/entities/game_public_state.dart';
import '../bloc/game_state.dart';

/// Replaces the actions panel when the match has ended.
/// Host: rematch + return to lobby. Non-host: waiting message.
class GameOverPanel extends StatelessWidget {
  const GameOverPanel({
    super.key,
    required this.state,
    required this.onRestart,
    required this.onReturnToLobby,
  });

  final GameState state;
  final VoidCallback onRestart;
  final VoidCallback onReturnToLobby;

  @override
  Widget build(BuildContext context) {
    final public = state.public;
    if (public == null) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final isHost = state.session?.isHost ?? false;
    final busy = state.actionPending;
    final won = public.outcome == GameOutcome.won;

    final titleColor =
        won ? theme.colorScheme.primary : theme.colorScheme.error;
    final title = won
        ? AppStrings.gameOutcomeWon(public.victoryTier)
        : AppStrings.gameOutcomeLost;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              color: titleColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (isHost) ...[
            FilledButton(
              onPressed: busy ? null : onRestart,
              child: const Text(AppStrings.gameConcedeNewGame),
            ),
            const SizedBox(height: 6),
            OutlinedButton(
              onPressed: busy ? null : onReturnToLobby,
              child: const Text(AppStrings.gameConcedeReturnLobby),
            ),
          ] else ...[
            Text(
              AppStrings.gameConcedeHostOnly,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
