import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../domain/entities/game_card.dart';
import '../../../domain/entities/game_public_state.dart';
import '../widgets/suit_pip.dart';

/// top-center cell: just the current enemy card face (or empty-state text).
class EnemyCardCell extends StatelessWidget {
  const EnemyCardCell({super.key, required this.public});

  final GamePublicState public;

  @override
  Widget build(BuildContext context) {
    final enemy = public.currentEnemy;
    if (enemy == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            AppStrings.gameNoEnemy,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Center(
        child: AspectRatio(
          aspectRatio: 2.5 / 3.5,
          child: _EnemyCardFace(enemy: enemy),
        ),
      ),
    );
  }
}

class _EnemyCardFace extends StatelessWidget {
  const _EnemyCardFace({required this.enemy});

  final GameCard enemy;

  @override
  Widget build(BuildContext context) {
    final color = enemy.isRedSuit ? Colors.red.shade800 : Colors.black;
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(w * 0.08),
            border: Border.all(color: Colors.black.withOpacity(0.35)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                enemy.rankLabel,
                style: TextStyle(
                  fontSize: w * 0.20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: w * 0.06),
              SuitPip(
                suit: enemy.suit,
                size: w * 0.45,
                color: color,
              ),
            ],
          ),
        );
      },
    );
  }
}
