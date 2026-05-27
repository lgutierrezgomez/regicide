import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../bloc/game_state.dart';

/// middle-left cell: teammate list + whose-turn indicator.
class TeammatesPanel extends StatelessWidget {
  const TeammatesPanel({super.key, required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final public = state.public;
    final session = state.session;
    if (public == null || session == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final order = public.playerOrder;
    final maxHand = public.maxHandSize;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Players',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: order.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, i) {
                final pid = order[i];
                final isCurrentTurn = pid == public.currentPlayerId;
                final isSelf = pid == session.playerId;
                final handCount = public.handCounts[pid] ?? 0;
                return _PlayerRow(
                  label: state.playerLabel(pid),
                  handCount: handCount,
                  maxHand: maxHand,
                  isCurrentTurn: isCurrentTurn,
                  isSelf: isSelf,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({
    required this.label,
    required this.handCount,
    required this.maxHand,
    required this.isCurrentTurn,
    required this.isSelf,
  });

  final String label;
  final int handCount;
  final int maxHand;
  final bool isCurrentTurn;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isCurrentTurn
            ? primary.withOpacity(0.12)
            : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isCurrentTurn ? primary : Colors.transparent,
          width: isCurrentTurn ? 1.5 : 0,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCurrentTurn ? Icons.play_arrow : Icons.person,
            size: 14,
            color: isCurrentTurn ? primary : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              isSelf ? '$label (${AppStrings.youBadge})' : label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isCurrentTurn ? FontWeight.w600 : FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$handCount/$maxHand',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
