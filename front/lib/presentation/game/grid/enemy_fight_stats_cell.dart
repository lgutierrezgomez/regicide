import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../domain/entities/game_public_state.dart';
import '../../../domain/game/enemy_stats.dart';

/// middle-center cell: damage dealt, shields up, and (when set) jester
/// immunity-cancelled hint. Shows nothing if there's no enemy on the table.
class EnemyFightStatsCell extends StatelessWidget {
  const EnemyFightStatsCell({super.key, required this.public});

  final GamePublicState public;

  @override
  Widget build(BuildContext context) {
    final enemy = public.currentEnemy;
    final theme = Theme.of(context);

    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final valueStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PileRow(
              icon: Icons.castle_outlined,
              label: AppStrings.gameCastleLabel,
              count: public.castleCount,
              labelStyle: labelStyle,
              valueStyle: valueStyle,
              iconColor: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 6),
            _PileRow(
              icon: Icons.local_bar_outlined,
              label: AppStrings.gameTavernLabel,
              count: public.tavernCount,
              labelStyle: labelStyle,
              valueStyle: valueStyle,
              iconColor: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 6),
            _PileRow(
              icon: Icons.delete_sweep_outlined,
              label: AppStrings.gameDiscardLabel,
              count: public.discardCount,
              labelStyle: labelStyle,
              valueStyle: valueStyle,
              iconColor: theme.colorScheme.onSurfaceVariant,
            ),
            if (enemy != null) ...[
              const SizedBox(height: 10),
              Text('Damage', style: labelStyle),
              Text(
                '${public.fightDamage} / ${enemyHealthValue(enemy)}',
                style: valueStyle,
              ),
              const SizedBox(height: 8),
              Text('Attack', style: labelStyle),
              Builder(builder: (_) {
                final attack = enemyAttackValue(enemy);
                final shield = public.fightSpadeShield;
                final currentAttack = (attack - shield).clamp(0, attack);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$currentAttack', style: valueStyle),
                    if (shield > 0)
                      Text(
                        '−$shield from shields',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                );
              }),
              if (public.immunityCancelled) ...[
                const SizedBox(height: 6),
                Text(
                  AppStrings.gameImmunityCancelled,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _PileRow extends StatelessWidget {
  const _PileRow({
    required this.icon,
    required this.label,
    required this.count,
    required this.labelStyle,
    required this.valueStyle,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final int count;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 6),
        Text(label, style: labelStyle),
        const SizedBox(width: 8),
        Text('$count', style: valueStyle),
      ],
    );
  }
}
