import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../domain/entities/game_public_state.dart';

/// Compact one-line pile counts for mobile: castle / tavern / discard.
class MobilePileRow extends StatelessWidget {
  const MobilePileRow({super.key, required this.public});

  final GamePublicState public;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PileChip(
            icon: Icons.castle_outlined,
            label: AppStrings.gameCastleLabel,
            count: public.castleCount,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _PileChip(
            icon: Icons.local_bar_outlined,
            label: AppStrings.gameTavernLabel,
            count: public.tavernCount,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _PileChip(
            icon: Icons.delete_sweep_outlined,
            label: AppStrings.gameDiscardLabel,
            count: public.discardCount,
          ),
        ),
      ],
    );
  }
}

class _PileChip extends StatelessWidget {
  const _PileChip({
    required this.icon,
    required this.label,
    required this.count,
  });

  final IconData icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
