import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/game_public_state.dart';
import '../../home/widgets/home_error_banner.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../grid/enemy_card_cell.dart';
import '../grid/enemy_fight_stats_cell.dart';
import '../grid/game_grid_layout.dart';
import '../grid/game_over_panel.dart';
import '../grid/played_this_fight_cell.dart';
import '../grid/player_actions_panel.dart';
import '../grid/player_hand_strip.dart';
import '../grid/symbol_legend_panel.dart';
import '../grid/teammates_panel.dart';
import '../mobile/mobile_game_body.dart';
import '../widgets/choose_next_player_dialog.dart';
import '../widgets/game_concede_button.dart';
import '../widgets/game_turn_app_bar.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<GameBloc, GameState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) {
            if (state.status == GameStatus.noSession) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.home,
                (_) => false,
              );
            }
            if (state.status == GameStatus.navigateToLobby) {
              Navigator.of(context).pushReplacementNamed(AppRoutes.lobby);
            }
          },
        ),
        BlocListener<GameBloc, GameState>(
          listenWhen: (prev, curr) => !prev.canChooseNext && curr.canChooseNext,
          listener: (context, state) {
            ChooseNextPlayerDialog.show(context);
          },
        ),
      ],
      child: BlocBuilder<GameBloc, GameState>(
        buildWhen: (prev, curr) =>
            prev != curr ||
            prev.selectedCardIds != curr.selectedCardIds ||
            prev.actionPending != curr.actionPending ||
            prev.connectionStatus != curr.connectionStatus ||
            prev.public?.phase != curr.public?.phase ||
            prev.public?.canYield != curr.public?.canYield ||
            prev.public?.currentPlayerId != curr.public?.currentPlayerId ||
            prev.public?.currentEnemy != curr.public?.currentEnemy ||
            prev.isMyTurn != curr.isMyTurn,
        builder: (context, state) {
          final gameScaffold = Scaffold(
            backgroundColor: AppColors.gameScaffold,
            appBar: state.public != null
                ? GameTurnAppBar(
                    state: state,
                    onReconnect:
                        state.connectionStatus == GameConnectionStatus.failed
                            ? () => context
                                .read<GameBloc>()
                                .add(const GameReconnectRequested())
                            : null,
                  )
                : null,
            body: _GameBody(state: state),
          );

          if (state.status == GameStatus.loading && state.session != null) {
            return gameScaffold;
          }

          if (state.session == null) {
            return Scaffold(
              backgroundColor: AppColors.gameScaffold,
              appBar: AppBar(automaticallyImplyLeading: false),
              body: const Center(child: Text(AppStrings.noSession)),
            );
          }

          return gameScaffold;
        },
      ),
    );
  }
}

class _GameBody extends StatelessWidget {
  const _GameBody({required this.state});

  /// Below this width the screen switches to the stacked mobile layout
  /// (Phase 5C). Above, the existing 3x3 perspective grid runs.
  static const _mobileBreakpoint = 600.0;
  static const _outerPadding = 20.0;

  final GameState state;

  @override
  Widget build(BuildContext context) {
    if (state.public == null) {
      return const Padding(
        padding: EdgeInsets.all(_outerPadding),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(_outerPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.errorMessage != null) ...[
            HomeErrorBanner(message: state.errorMessage!),
            const SizedBox(height: 8),
          ],
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < _mobileBreakpoint;
                return isMobile
                    ? MobileGameBody(state: state)
                    : _buildGrid(context, state);
              },
            ),
          ),
          if (state.actionPending) ...[
            const SizedBox(height: 8),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, GameState state) {
    final bloc = context.read<GameBloc>();
    final isHost = state.session?.isHost ?? false;
    final isGameOver = state.public!.outcome != GameOutcome.playing;

    final Widget bottomRight = isGameOver
        ? GameOverPanel(
            state: state,
            onRestart: () => bloc.add(const GameRestartRequested()),
            onReturnToLobby: () => bloc.add(const GameReturnToLobbyRequested()),
          )
        : PlayerActionsPanel(
            state: state,
            onPlay: () => bloc.add(const GamePlayRequested()),
            onYield: () => bloc.add(const GameYieldRequested()),
            onDiscard: () => bloc.add(const GameDiscardRequested()),
            onSoloJester: () => bloc.add(const GameSoloJesterRequested()),
            onClearSelection: () => bloc.add(const GameSelectionCleared()),
          );

    return GameGridLayout(
      children: {
        GameGridCell.topLeft: TeammatesPanel(state: state),
        GameGridCell.topCenter: EnemyCardCell(public: state.public!),
        GameGridCell.topRight: Padding(
          padding: const EdgeInsets.all(8),
          child: Align(
            alignment: Alignment.topRight,
            child: GameConcedeButton(isHost: isHost),
          ),
        ),
        GameGridCell.middleLeft: PlayedThisFightCell(public: state.public!),
        GameGridCell.middleCenter: EnemyFightStatsCell(public: state.public!),
        GameGridCell.middleRight: const SymbolLegendPanel(),
        GameGridCell.bottomCenter: PlayerHandStrip(
          state: state,
          onCardTap: (id) => bloc.add(GameCardToggled(id)),
        ),
        GameGridCell.bottomRight: bottomRight,
      },
    );
  }
}
