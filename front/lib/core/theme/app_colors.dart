import 'package:flutter/material.dart';

/// Raw palette — change colors here; [AppTheme] maps them into [ThemeData].
abstract final class AppColors {
  static const seed = Color(0xFF4A148C);
  static const onSeed = Color(0xFFFFFFFF);

  static const surface = Color(0xFFFFFBFE);

  /// Soft sage-cream behind the game table (pairs with wood + felt greens).
  static const gameScaffold = Color(0xFFE8EDE4);
  static const onSurface = Color(0xFF1D1B20);
  static const onSurfaceVariant = Color(0xFF49454F);

  static const errorContainer = Color(0xFFF9DEDC);
  static const onErrorContainer = Color(0xFF410E0B);

  static const connected = Color(0xFF2E7D32);
  static const disconnected = Color(0xFF9E9E9E);

  // Poker table (game screen)
  static const tableWoodDark = Color(0xFF3E2723);
  static const tableWoodMid = Color(0xFF5D4037);
  static const tableWoodLight = Color(0xFF8D6E63);
  static const tableFeltDark = Color(0xFF1B5E20);
  static const tableFeltMid = Color(0xFF2E7D32);
  static const tableFeltLight = Color(0xFF43A047);
  static const cardBackRed = Color(0xFFB71C1C);
  static const cardBackRedDark = Color(0xFF7F0000);
  static const cardEdge = Color(0xFFE8E8E8);
}
