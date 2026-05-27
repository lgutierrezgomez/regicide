import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../domain/entities/game_public_state.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../grid/enemy_card_cell.dart';
import '../grid/game_over_panel.dart';
import '../grid/played_this_fight_cell.dart';
import '../grid/player_hand_strip.dart';
import '../grid/symbol_legend_panel.dart';
import '../grid/teammates_panel.dart';
import 'mobile_action_bar.dart';
import 'mobile_collapsible_section.dart';
import 'mobile_fight_stats_row.dart';
import 'mobile_pile_row.dart';

/// Mobile (narrow-viewport) game layout.
///
/// Vertical stack with the enemy card + pile counts + fight stats always
/// visible, secondary panels (teammates, played-this-fight, symbol legend)
/// behind collapsibles, the hand scrollable, and a sticky bottom action bar.
class MobileGameBody extends StatelessWidget {
  const MobileGameBody({super.key, required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final public = state.public!;
    final bloc = context.read<GameBloc>();
    final isGameOver = public.outcome != GameOutcome.playing;
    final playedCount = public.playedAgainstEnemy.fold<int>(
      0,
      (sum, entry) => sum + entry.cards.length,
    );

    final scroll = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 220,
            child: EnemyCardCell(public: public),
          ),
          const SizedBox(height: 8),
          MobilePileRow(public: public),
          const SizedBox(height: 12),
          MobileFightStatsRow(public: public),
          const SizedBox(height: 12),
          MobileCollapsibleSection(
            icon: Icons.people_outline,
            title: AppStrings.gameTeammatesLabel,
            count: public.playerOrder.length,
            child: TeammatesPanel(state: state),
          ),
          MobileCollapsibleSection(
            icon: Icons.layers_outlined,
            title: AppStrings.gamePlayedThisFightTitle,
            count: playedCount,
            child: PlayedThisFightCell(public: public),
          ),
          const MobileCollapsibleSection(
            icon: Icons.help_outline,
            title: AppStrings.gameSymbolLegendTitle,
            bodyHeight: 260,
            child: SymbolLegendPanel(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: PlayerHandStrip(
              state: state,
              onCardTap: (id) => bloc.add(GameCardToggled(id)),
            ),
          ),
        ],
      ),
    );

    final bottom = isGameOver
        ? GameOverPanel(
            state: state,
            onRestart: () => bloc.add(const GameRestartRequested()),
            onReturnToLobby: () => bloc.add(const GameReturnToLobbyRequested()),
          )
        : MobileActionBar(
            state: state,
            onPlay: () => bloc.add(const GamePlayRequested()),
            onYield: () => bloc.add(const GameYieldRequested()),
            onDiscard: () => bloc.add(const GameDiscardRequested()),
            onSoloJester: () => bloc.add(const GameSoloJesterRequested()),
            onClearSelection: () => bloc.add(const GameSelectionCleared()),
          );

    return Column(
      children: [
        Expanded(child: scroll),
        bottom,
      ],
    );
  }
}
