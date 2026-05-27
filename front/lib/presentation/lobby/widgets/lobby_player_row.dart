import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/player.dart';

class LobbyPlayerRow extends StatelessWidget {
  const LobbyPlayerRow({
    super.key,
    required this.player,
    required this.isHost,
    required this.isSelf,
  });

  final Player player;
  final bool isHost;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dotColor =
        player.connected ? AppColors.connected : AppColors.disconnected;
    final statusLabel =
        player.connected ? AppStrings.connected : AppStrings.offline;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: dotColor.withOpacity(0.2),
            child: Icon(Icons.person, color: dotColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text(
                      player.displayName,
                      style: theme.textTheme.titleMedium,
                    ),
                    if (isSelf)
                      _Badge(
                        label: AppStrings.youBadge,
                        color: theme.colorScheme.secondaryContainer,
                      ),
                    if (isHost)
                      _Badge(
                        label: isSelf
                            ? AppStrings.hostYouBadge()
                            : AppStrings.hostBadge,
                        color: theme.colorScheme.primaryContainer,
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(statusLabel, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
