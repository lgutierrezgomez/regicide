import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';

class JoinRoomButton extends StatelessWidget {
  const JoinRoomButton({
    super.key,
    required this.enabled,
    required this.loading,
    required this.onPressed,
  });

  final bool enabled;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: enabled && !loading ? onPressed : null,
        icon: const Icon(Icons.login),
        label: const Text(AppStrings.joinRoom),
      ),
    );
  }
}
