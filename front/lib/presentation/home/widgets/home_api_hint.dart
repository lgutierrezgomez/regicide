import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/app_strings.dart';

class HomeApiHint extends StatelessWidget {
  const HomeApiHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      AppStrings.serverHint(AppConfig.instance.apiBaseUrl),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
    );
  }
}
