import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../domain/entities/game_public_state.dart';
import '../../../domain/game/enemy_stats.dart';

/// Compact one-line battle stats for mobile: attack · damage dealt · shield.
/// Renders nothing meaningful when no enemy is on the table.
class MobileFightStatsRow extends StatelessWidget {
  const MobileFightStatsRow({super.key, required this.public});

  final GamePublicState public;

  @override
  Widget build(BuildContext context) {
    final enemy = public.currentEnemy;
    if (enemy == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final maxHealth = enemyHealthValue(enemy);
    final attack = enemyAttackValue(enemy);
    final shield = public.fightSpadeShield;
    final currentAttack = (attack - shield).clamp(0, attack);

    final segments = <Widget>[
      _Segment(
        label: AppStrings.gameAttackLine(currentAttack),
        emphasized: true,
      ),
      _Segment(label: AppStrings.gameDamageLine(public.fightDamage, maxHealth)),
      if (shield > 0) _Segment(label: AppStrings.gameShieldLine(shield)),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < segments.length; i++) ...[
          if (i > 0)
            Text(
              '·',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          segments[i],
        ],
        if (public.immunityCancelled)
          Text(
            AppStrings.gameImmunityCancelled,
            style: theme.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.primary,
            ),
          ),
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.label, this.emphasized = false});

  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
