import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';

class ConnectionStatusBanner extends StatelessWidget {
  const ConnectionStatusBanner({
    super.key,
    this.forAppBar = false,
    required this.isConnecting,
    required this.isConnected,
    required this.isFailed,
    required this.connectingLabel,
    required this.connectedLabel,
    required this.failedLabel,
    this.onReconnect,
  });

  final bool forAppBar;
  final bool isConnecting;
  final bool isConnected;
  final bool isFailed;
  final String connectingLabel;
  final String connectedLabel;
  final String failedLabel;
  final VoidCallback? onReconnect;

  @override
  Widget build(BuildContext context) {
    final (icon, text, color) = switch ((isConnecting, isConnected, isFailed)) {
      (true, _, _) => (
          Icons.sync,
          connectingLabel,
          Theme.of(context).colorScheme.primary,
        ),
      (_, true, _) => (
          Icons.cloud_done_outlined,
          connectedLabel,
          AppColors.connected,
        ),
      _ => (
          Icons.cloud_off_outlined,
          failedLabel,
          Theme.of(context).colorScheme.error,
        ),
    };

    if (forAppBar) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isFailed && onReconnect != null)
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: onReconnect,
              child: const Text(
                AppStrings.reconnect,
                style: TextStyle(fontSize: 11),
              ),
            ),
        ],
      );
    }

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
          ),
        ),
        if (isFailed && onReconnect != null)
          TextButton(
            onPressed: onReconnect,
            child: const Text(AppStrings.reconnect),
          ),
      ],
    );
  }
}
