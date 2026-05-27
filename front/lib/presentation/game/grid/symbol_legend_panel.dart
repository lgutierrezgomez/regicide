import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../domain/entities/game_card.dart';
import '../widgets/suit_pip.dart';

/// middle-right cell: suit / ace / jester power summary.
class SymbolLegendPanel extends StatelessWidget {
  const SymbolLegendPanel({super.key});

  static const _entries = <_LegendEntry>[
    _LegendEntry.suit(GameSuit.hearts, AppStrings.gameSymbolHeartsPower),
    _LegendEntry.suit(GameSuit.diamonds, AppStrings.gameSymbolDiamondsPower),
    _LegendEntry.suit(GameSuit.clubs, AppStrings.gameSymbolClubsPower),
    _LegendEntry.suit(GameSuit.spades, AppStrings.gameSymbolSpadesPower),
    _LegendEntry.text(AppStrings.gameSymbolAce, AppStrings.gameSymbolAcePower),
    _LegendEntry.text(
        AppStrings.gameSymbolJester, AppStrings.gameSymbolJesterPower),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.gameSymbolLegendTitle,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: _entries.length,
              separatorBuilder: (_, i) {
                // Group break after the four suit entries (index 3),
                // before the special-card entries (A, J).
                if (i == 3) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1),
                  );
                }
                return const SizedBox(height: 12);
              },
              itemBuilder: (context, i) => _LegendRow(entry: _entries[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendEntry {
  const _LegendEntry.suit(GameSuit this.suit, this.power) : symbol = null;
  const _LegendEntry.text(String this.symbol, this.power) : suit = null;

  final GameSuit? suit;
  final String? symbol;
  final String power;
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.entry});

  final _LegendEntry entry;

  static const _symbolColumnWidth = 24.0;
  static const _pipSize = 22.0;

  Color _pipColor(GameSuit suit) {
    switch (suit) {
      case GameSuit.hearts:
      case GameSuit.diamonds:
        return Colors.red.shade700;
      case GameSuit.clubs:
      case GameSuit.spades:
        return Colors.grey.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Widget symbol = entry.suit != null
        ? SuitPip(
            suit: entry.suit!,
            size: _pipSize,
            color: _pipColor(entry.suit!),
          )
        : Text(
            entry.symbol!,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: _symbolColumnWidth,
          child: Align(alignment: Alignment.centerLeft, child: symbol),
        ),
        Expanded(
          child: Text(
            entry.power,
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
