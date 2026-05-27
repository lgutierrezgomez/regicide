import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import 'paginated_instructions_dialog.dart';

/// Opens the paginated rules dialog.
class InstructionsLaunchButton extends StatelessWidget {
  const InstructionsLaunchButton({
    super.key,
    this.compact = false,
    this.iconOnly = false,
  });

  final bool compact;
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    if (iconOnly) {
      return IconButton(
        icon: const Icon(Icons.menu_book_outlined),
        tooltip: AppStrings.instructionsButton,
        onPressed: () => PaginatedInstructionsDialog.show(context),
      );
    }
    if (compact) {
      return TextButton.icon(
        onPressed: () => PaginatedInstructionsDialog.show(context),
        icon: const Icon(Icons.menu_book_outlined, size: 18),
        label: const Text(AppStrings.instructionsButton),
      );
    }
    return OutlinedButton.icon(
      onPressed: () => PaginatedInstructionsDialog.show(context),
      icon: const Icon(Icons.menu_book_outlined),
      label: const Text(AppStrings.instructionsButton),
    );
  }
}
