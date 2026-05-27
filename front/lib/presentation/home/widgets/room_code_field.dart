import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';

class RoomCodeField extends StatelessWidget {
  const RoomCodeField({
    super.key,
    required this.controller,
    required this.enabled,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: const InputDecoration(
        labelText: AppStrings.roomCodeLabel,
        hintText: AppStrings.roomCodeHint,
      ),
      textCapitalization: TextCapitalization.characters,
      onChanged: onChanged,
    );
  }
}
