import 'package:flutter/material.dart';

/// Reusable accordion tile used in the mobile game body to keep secondary
/// info (teammates, played-this-fight cards, symbol legend) collapsed by
/// default while still reachable with one tap.
class MobileCollapsibleSection extends StatelessWidget {
  const MobileCollapsibleSection({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    this.count,
    this.initiallyExpanded = false,
    this.bodyHeight = 220,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final int? count;
  final bool initiallyExpanded;
  final double bodyHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(vertical: 3),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          visualDensity: VisualDensity.compact,
          leading: Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          title: Row(
            children: [
              Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 6),
                Text(
                  '($count)',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          children: [
            SizedBox(height: bodyHeight, child: child),
          ],
        ),
      ),
    );
  }
}
