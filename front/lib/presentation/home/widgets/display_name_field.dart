import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';

class DisplayNameField extends StatelessWidget {
  const DisplayNameField({
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
        labelText: AppStrings.displayNameLabel,
        hintText: AppStrings.displayNameHint,
      ),
      textInputAction: TextInputAction.next,
      onChanged: onChanged,
    );
  }
}
