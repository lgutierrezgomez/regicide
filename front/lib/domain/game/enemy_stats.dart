import '../entities/game_card.dart';

/// Castle enemy stats (matches `regicide_rules.json` → `enemies`).
int enemyAttackValue(GameCard? enemy) {
  if (enemy == null || enemy.kind != GameCardKind.enemy) {
    return 0;
  }
  switch (enemy.rankLabel) {
    case 'JACK':
      return 10;
    case 'QUEEN':
      return 15;
    case 'KING':
      return 20;
    default:
      return 0;
  }
}

int enemyHealthValue(GameCard? enemy) {
  if (enemy == null || enemy.kind != GameCardKind.enemy) {
    return 0;
  }
  switch (enemy.rankLabel) {
    case 'JACK':
      return 20;
    case 'QUEEN':
      return 30;
    case 'KING':
      return 40;
    default:
      return 0;
  }
}

/// Attack value hitting the player after cumulative spade shield.
int netAttackOnPlayer({
  required GameCard? enemy,
  required int fightSpadeShield,
  int? pendingDamage,
}) {
  if (pendingDamage != null) {
    return pendingDamage;
  }
  final raw = enemyAttackValue(enemy);
  final net = raw - fightSpadeShield;
  return net < 0 ? 0 : net;
}
