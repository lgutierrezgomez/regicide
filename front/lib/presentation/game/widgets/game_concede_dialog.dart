import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/app_strings.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';

class GameConcedeDialog extends StatelessWidget {
  const GameConcedeDialog({super.key, required this.isHost});

  final bool isHost;

  static Future<void> show(BuildContext context, {required bool isHost}) {
    return showDialog<void>(
      context: context,
      builder: (_) => GameConcedeDialog(isHost: isHost),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.gameConcedeDialogTitle),
      content: Text(
        isHost
            ? AppStrings.gameConcedeDialogBody
            : AppStrings.gameConcedeHostOnly,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.gameConcedeCancel),
        ),
        if (isHost) ...[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<GameBloc>().add(const GameReturnToLobbyRequested());
            },
            child: const Text(AppStrings.gameConcedeReturnLobby),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<GameBloc>().add(const GameRestartRequested());
            },
            child: const Text(AppStrings.gameConcedeNewGame),
          ),
        ],
      ],
    );
  }
}
