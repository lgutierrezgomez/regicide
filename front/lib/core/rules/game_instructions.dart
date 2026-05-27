import 'dart:convert';

import 'package:flutter/services.dart';

class GameInstructionsPage {
  const GameInstructionsPage({required this.title, required this.body});

  final String title;
  final String body;

  factory GameInstructionsPage.fromJson(Map<String, dynamic> json) {
    return GameInstructionsPage(
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }
}

/// Loads paginated rules from bundled asset (not full markdown at once in UI).
abstract final class GameInstructions {
  static const assetPath = 'assets/instructions/rules_pages.json';

  static Future<List<GameInstructionsPage>> load() async {
    final raw = await rootBundle.loadString(assetPath);
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => GameInstructionsPage.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
