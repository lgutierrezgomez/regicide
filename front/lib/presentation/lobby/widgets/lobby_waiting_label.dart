import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';

class LobbyWaitingLabel extends StatelessWidget {
  const LobbyWaitingLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      AppStrings.waitingForHost,
      style: Theme.of(context).textTheme.bodyLarge,
      textAlign: TextAlign.center,
    );
  }
}
