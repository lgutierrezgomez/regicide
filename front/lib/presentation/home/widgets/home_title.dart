import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';

class HomeTitle extends StatelessWidget {
  const HomeTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.appTitle,
          style: theme.textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.homeSubtitle,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}
