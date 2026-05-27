import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/router/app_routes.dart';
import '../../home/widgets/home_error_banner.dart';
import '../bloc/lobby_bloc.dart';
import '../bloc/lobby_event.dart';
import '../bloc/lobby_state.dart';
import '../widgets/lobby_connection_banner.dart';
import '../../shared/widgets/communication_reminder_card.dart';
import '../widgets/lobby_host_hint.dart';
import '../widgets/lobby_player_list.dart';
import '../widgets/lobby_room_code_card.dart';
import '../widgets/lobby_start_button.dart';
import '../widgets/lobby_waiting_label.dart';

class LobbyPage extends StatelessWidget {
  const LobbyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LobbyBloc, LobbyState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == LobbyStatus.navigateToGame) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.game);
        }
        if (state.status == LobbyStatus.noSession) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.lobbyTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocBuilder<LobbyBloc, LobbyState>(
          builder: (context, state) {
            if (state.status == LobbyStatus.loading && state.session != null) {
              return const Center(child: CircularProgressIndicator());
            }

            final session = state.session;
            if (session == null) {
              return const Center(child: Text(AppStrings.noSession));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LobbyConnectionBanner(status: state.connectionStatus),
                  const SizedBox(height: 16),
                  LobbyRoomCodeCard(session: session),
                  if (state.room != null) ...[
                    const SizedBox(height: 16),
                    LobbyPlayerList(
                      room: state.room!,
                      currentPlayerId: session.playerId,
                    ),
                  ],
                  const SizedBox(height: 16),
                  const CommunicationReminderCard(),
                  const SizedBox(height: 16),
                  if (state.isHost) ...[
                    LobbyHostHint(
                      isSolo: (state.room?.playerCount ?? 1) <= 1,
                    ),
                    const SizedBox(height: 12),
                    LobbyStartButton(
                      enabled: state.canStartGame,
                      loading: state.status == LobbyStatus.startingGame,
                      onPressed: () => context
                          .read<LobbyBloc>()
                          .add(const LobbyStartGameRequested()),
                    ),
                  ] else
                    const LobbyWaitingLabel(),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    HomeErrorBanner(message: state.errorMessage!),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
