import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/game_public_state.dart';
import '../../shared/widgets/communication_reminder_card.dart';
import '../../shared/widgets/instructions_launch_button.dart';
import '../../shared/widgets/connection_status_banner.dart';
import '../bloc/game_state.dart';

/// App bar: connection (left), turn header + phase step (center), icons (right).
/// Action buttons live in the bottom-right grid cell, not here.
class GameTurnAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GameTurnAppBar({
    super.key,
    required this.state,
    this.onReconnect,
  });

  final GameState state;
  final VoidCallback? onReconnect;

  static const _turnHeaderFontSize = 18.0;
  static const _phaseStepFontSize = 15.0;
  static const _toolbarHeight = 80.0;

  @override
  Size get preferredSize => const Size.fromHeight(_toolbarHeight);

  @override
  Widget build(BuildContext context) {
    final public = state.public;
    if (public == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    final turnHeaderStyle = theme.textTheme.titleMedium?.copyWith(
      fontSize: _turnHeaderFontSize,
      fontWeight: FontWeight.w600,
      height: 1.15,
      color: theme.colorScheme.onSurface,
    );
    final phaseStepStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: _phaseStepFontSize,
      fontWeight: FontWeight.w500,
      height: 1.25,
      color: AppColors.seed,
    );

    final Widget centerContent;
    if (public.outcome != GameOutcome.playing) {
      centerContent = Text(
        _outcomeLabel(public),
        style: turnHeaderStyle,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      centerContent = _TurnStatusColumn(
        turnHeader: _turnHeaderText(state),
        phaseStep: _phaseStepText(public, state),
        turnHeaderStyle: turnHeaderStyle,
        phaseStepStyle: phaseStepStyle,
      );
    }

    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: _toolbarHeight,
      centerTitle: true,
      titleSpacing: 8,
      leading: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Center(
          child: ConnectionStatusBanner(
            forAppBar: true,
            isConnecting:
                state.connectionStatus == GameConnectionStatus.connecting,
            isConnected:
                state.connectionStatus == GameConnectionStatus.connected,
            isFailed: state.connectionStatus == GameConnectionStatus.failed,
            connectingLabel: AppStrings.gameConnecting,
            connectedLabel: AppStrings.gameConnected,
            failedLabel: state.errorMessage ?? AppStrings.gameConnectionFailed,
            onReconnect: onReconnect,
          ),
        ),
      ),
      leadingWidth: 120,
      actions: const [
        InstructionsLaunchButton(iconOnly: true),
        CommunicationReminderCard(forAppBar: true),
      ],
      title: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [centerContent],
            ),
          );
        },
      ),
    );
  }

  String _turnHeaderText(GameState state) {
    if (state.isMultiplayer) {
      return AppStrings.gameCurrentTurn(state.currentTurnLabel);
    }
    if (state.isMyTurn) {
      return AppStrings.gameYourTurn;
    }
    return AppStrings.gameCurrentTurn(state.currentTurnLabel);
  }

  String _phaseStepText(GamePublicState public, GameState state) {
    if (!state.isMyTurn) {
      return AppStrings.gameWaitingTurn(state.currentTurnLabel);
    }
    return _phaseLabel(public, state);
  }

  String _outcomeLabel(GamePublicState public) {
    if (public.outcome == GameOutcome.won) {
      return AppStrings.gameOutcomeWon(public.victoryTier);
    }
    return AppStrings.gameOutcomeLost;
  }

  String _phaseLabel(GamePublicState public, GameState state) {
    switch (public.phase) {
      case GamePhase.step1PlayOrYield:
        return AppStrings.gamePhaseStep1;
      case GamePhase.step4Discard:
        return AppStrings.gamePhaseDiscard(
          state.requiredDiscardTotal,
          state.selectedDiscardTotal,
        );
      case GamePhase.chooseNextPlayer:
        return public.isSolo
            ? AppStrings.gamePhaseChooseNextSolo
            : AppStrings.gamePhaseChooseNextMulti;
      case GamePhase.gameOver:
        return AppStrings.gamePhaseOver;
    }
  }
}

class _TurnStatusColumn extends StatelessWidget {
  const _TurnStatusColumn({
    required this.turnHeader,
    required this.phaseStep,
    required this.turnHeaderStyle,
    required this.phaseStepStyle,
  });

  final String turnHeader;
  final String phaseStep;
  final TextStyle? turnHeaderStyle;
  final TextStyle? phaseStepStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          turnHeader,
          style: turnHeaderStyle,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          phaseStep,
          style: phaseStepStyle,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
