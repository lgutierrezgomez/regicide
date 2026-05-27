import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import 'game_concede_dialog.dart';

/// Below the symbol legend — opens concede / rematch / lobby options.
class GameConcedeButton extends StatelessWidget {
  const GameConcedeButton({super.key, required this.isHost});

  final bool isHost;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: AppStrings.gameConcede,
      icon: const Icon(Icons.flag_outlined),
      onPressed: () => GameConcedeDialog.show(context, isHost: isHost),
    );
  }
}
