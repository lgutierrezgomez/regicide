import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/app_strings.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';

/// Modal list of players to receive the turn after a jester (not in app bar).
class ChooseNextPlayerDialog extends StatelessWidget {
  const ChooseNextPlayerDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BlocProvider.value(
        value: context.read<GameBloc>(),
        child: const ChooseNextPlayerDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      listenWhen: (prev, curr) => prev.canChooseNext != curr.canChooseNext,
      listener: (context, state) {
        if (!state.canChooseNext) {
          Navigator.of(context).pop();
        }
      },
      buildWhen: (prev, curr) =>
          prev.canChooseNext != curr.canChooseNext ||
          prev.actionPending != curr.actionPending ||
          prev.playerDisplayNames != curr.playerDisplayNames,
      builder: (context, state) {
        final public = state.public;
        if (public == null || !state.canChooseNext) {
          return const SizedBox.shrink();
        }

        final busy = state.actionPending;
        final candidates = public.playerOrder;

        return AlertDialog(
          title: Text(
            public.isSolo
                ? AppStrings.gameChooseNextDialogTitleSolo
                : AppStrings.gameChooseNextDialogTitle,
          ),
          content: SizedBox(
            width: 280,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (busy)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                for (var i = 0; i < candidates.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _PlayerChoiceTile(
                    label: public.isSolo
                        ? AppStrings.gameActionContinue
                        : state.playerLabel(candidates[i]),
                    enabled: !busy,
                    onTap: () {
                      context.read<GameBloc>().add(
                            GameChooseNextRequested(candidates[i]),
                          );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlayerChoiceTile extends StatelessWidget {
  const _PlayerChoiceTile({
    required this.label,
    required this.onTap,
    required this.enabled,
  });

  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: enabled
                  ? theme.colorScheme.outline
                  : theme.colorScheme.outline.withOpacity(0.4),
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: enabled
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }
}
