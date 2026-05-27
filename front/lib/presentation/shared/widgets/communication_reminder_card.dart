import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';

/// Regicide communication rules — reminder only (not enforced server-side).
class CommunicationReminderCard extends StatelessWidget {
  const CommunicationReminderCard({
    super.key,
    this.compact = false,
    this.forAppBar = false,
  });

  /// One-line bar with tooltip (legacy game body).
  final bool compact;

  /// Icon + label in app bar trailing slot.
  final bool forAppBar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (forAppBar) {
      return IconButton(
        icon: const Icon(Icons.record_voice_over_outlined),
        iconSize: 22,
        tooltip: AppStrings.communicationTitle,
        visualDensity: VisualDensity.compact,
        onPressed: () {
          showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text(AppStrings.communicationTitle),
              content: const SingleChildScrollView(
                child: Text(AppStrings.communicationBody),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
      );
    }

    if (compact) {
      return Material(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.record_voice_over_outlined,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.communicationTitle,
                  style: theme.textTheme.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Tooltip(
                message: AppStrings.communicationBody,
                child: Icon(
                  Icons.info_outline,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.record_voice_over_outlined,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.communicationTitle,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.communicationBody,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
