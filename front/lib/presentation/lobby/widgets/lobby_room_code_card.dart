import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/web/join_invite_url.dart';
import '../../../domain/entities/room_session.dart';

class LobbyRoomCodeCard extends StatelessWidget {
  const LobbyRoomCodeCard({super.key, required this.session});

  final RoomSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inviteUrl = buildRoomInviteUrl(session.roomCode);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.roomCodeSection, style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  session.roomCode,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  tooltip: AppStrings.copyRoomCode,
                  onPressed: () => _copy(
                    context,
                    session.roomCode,
                    AppStrings.roomCodeCopied,
                  ),
                  icon: const Icon(Icons.copy),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.inviteLinkSection,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            SelectableText(
              inviteUrl,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _copy(
                  context,
                  inviteUrl,
                  AppStrings.inviteLinkCopied,
                ),
                icon: const Icon(Icons.link, size: 18),
                label: const Text(AppStrings.copyInviteLink),
              ),
            ),
            const Divider(height: 24),
            Text(AppStrings.playingAs, style: theme.textTheme.labelLarge),
            Text(session.displayName, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              session.isHost ? AppStrings.youAreHost : AppStrings.joinedAsGuest,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copy(BuildContext context, String text, String snackMessage) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(snackMessage)),
    );
  }
}
