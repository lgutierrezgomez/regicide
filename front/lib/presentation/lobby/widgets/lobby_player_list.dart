import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../domain/entities/room.dart';
import 'lobby_player_row.dart';

class LobbyPlayerList extends StatelessWidget {
  const LobbyPlayerList({
    super.key,
    required this.room,
    required this.currentPlayerId,
  });

  final Room room;
  final String currentPlayerId;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.playersSection,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              AppStrings.playerCount(room.playerCount, room.maxPlayers),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            ...room.players.map(
              (p) => LobbyPlayerRow(
                player: p,
                isHost: p.id == room.hostPlayerId,
                isSelf: p.id == currentPlayerId,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
