import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';

class CreateRoomButton extends StatelessWidget {
  const CreateRoomButton({
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
      child: FilledButton.icon(
        onPressed: enabled && !loading ? onPressed : null,
        icon: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
        label:
            Text(loading ? AppStrings.creatingRoom : AppStrings.createRoomSolo),
      ),
    );
  }
}
