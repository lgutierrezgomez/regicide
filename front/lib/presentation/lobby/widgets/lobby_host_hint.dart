import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';

class LobbyHostHint extends StatelessWidget {
  const LobbyHostHint({super.key, required this.isSolo});

  final bool isSolo;

  @override
  Widget build(BuildContext context) {
    return Text(
      isSolo ? AppStrings.lobbySoloHint : AppStrings.lobbyMultiplayerHint,
      style: Theme.of(context).textTheme.bodyMedium,
      textAlign: TextAlign.center,
    );
  }
}
