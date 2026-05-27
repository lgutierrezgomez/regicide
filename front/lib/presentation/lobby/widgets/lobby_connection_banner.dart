import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/app_strings.dart';
import '../../shared/widgets/connection_status_banner.dart';
import '../bloc/lobby_bloc.dart';
import '../bloc/lobby_event.dart';
import '../bloc/lobby_state.dart';

class LobbyConnectionBanner extends StatelessWidget {
  const LobbyConnectionBanner({super.key, required this.status});

  final LobbyConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LobbyBloc>().state;
    return ConnectionStatusBanner(
      isConnecting: status == LobbyConnectionStatus.connecting,
      isConnected: status == LobbyConnectionStatus.connected,
      isFailed: status == LobbyConnectionStatus.failed,
      connectingLabel: AppStrings.connectionConnecting,
      connectedLabel: AppStrings.connectionLive,
      failedLabel: state.errorMessage ?? AppStrings.connectionError,
      onReconnect: status == LobbyConnectionStatus.failed
          ? () => context.read<LobbyBloc>().add(const LobbyReconnectRequested())
          : null,
    );
  }
}
