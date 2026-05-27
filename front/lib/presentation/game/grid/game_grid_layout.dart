import 'package:flutter/material.dart';

/// 9 reference slots, addressable by row + column.
enum GameGridCell {
  topLeft,
  topCenter,
  topRight,
  middleLeft,
  middleCenter,
  middleRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

/// 3x3 equal-sized grid. Pass a widget for each cell via [children]; missing
/// cells show a debug border + label so the layout is always visible.
class GameGridLayout extends StatelessWidget {
  const GameGridLayout({
    super.key,
    this.children = const {},
    this.showDebugLabels = false,
  });

  final Map<GameGridCell, Widget> children;
  final bool showDebugLabels;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row = 0; row < 3; row++)
          Expanded(
            child: Row(
              children: [
                for (var col = 0; col < 3; col++)
                  Expanded(
                    child: _GridCell(
                      cell: GameGridCell.values[row * 3 + col],
                      showDebugLabel: showDebugLabels,
                      child: children[GameGridCell.values[row * 3 + col]],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _GridCell extends StatelessWidget {
  const _GridCell({
    required this.cell,
    required this.showDebugLabel,
    this.child,
  });

  final GameGridCell cell;
  final bool showDebugLabel;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (child != null && !showDebugLabel) {
      return child!;
    }
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black.withOpacity(0.18),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          if (child != null) Positioned.fill(child: child!),
          if (showDebugLabel)
            Positioned(
              top: 4,
              left: 6,
              child: Text(
                _label(cell),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black.withOpacity(0.45),
                  fontFamily: 'monospace',
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _label(GameGridCell cell) {
    switch (cell) {
      case GameGridCell.topLeft:
        return 'top-left';
      case GameGridCell.topCenter:
        return 'top-center';
      case GameGridCell.topRight:
        return 'top-right';
      case GameGridCell.middleLeft:
        return 'middle-left';
      case GameGridCell.middleCenter:
        return 'middle-center';
      case GameGridCell.middleRight:
        return 'middle-right';
      case GameGridCell.bottomLeft:
        return 'bottom-left';
      case GameGridCell.bottomCenter:
        return 'bottom-center';
      case GameGridCell.bottomRight:
        return 'bottom-right';
    }
  }
}
