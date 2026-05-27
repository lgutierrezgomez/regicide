import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/rules/game_instructions.dart';

/// Shows game rules one page at a time from [GameInstructions.assetPath].
class PaginatedInstructionsDialog extends StatefulWidget {
  const PaginatedInstructionsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => const PaginatedInstructionsDialog(),
    );
  }

  @override
  State<PaginatedInstructionsDialog> createState() =>
      _PaginatedInstructionsDialogState();
}

class _PaginatedInstructionsDialogState
    extends State<PaginatedInstructionsDialog> {
  Future<List<GameInstructionsPage>>? _pagesFuture;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _pagesFuture = GameInstructions.load();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.instructionsDialogTitle),
      content: SizedBox(
        width: 420,
        height: 360,
        child: FutureBuilder<List<GameInstructionsPage>>(
          future: _pagesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Text(AppStrings.instructionsLoadError);
            }
            final pages = snapshot.data!;
            if (pages.isEmpty) {
              return Text(AppStrings.instructionsLoadError);
            }
            final page = pages[_index.clamp(0, pages.length - 1)];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  page.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      page.body,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.instructionsPageIndicator(
                    _index + 1,
                    pages.length,
                  ),
                  style: Theme.of(context).textTheme.labelSmall,
                  textAlign: TextAlign.center,
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _index > 0 ? () => setState(() => _index--) : null,
          child: const Text(AppStrings.instructionsPrevious),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.instructionsClose),
        ),
        FutureBuilder<List<GameInstructionsPage>>(
          future: _pagesFuture,
          builder: (context, snapshot) {
            final last = (snapshot.data?.length ?? 1) - 1;
            return TextButton(
              onPressed: _index < last ? () => setState(() => _index++) : null,
              child: const Text(AppStrings.instructionsNext),
            );
          },
        ),
      ],
    );
  }
}
