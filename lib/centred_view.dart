import 'package:flutter/material.dart';

class CentredView extends StatelessWidget {
  final Widget child;
  const CentredView({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    double maxWidth = 1200;
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 24);
    if (width < 600) {
      maxWidth = width;
      padding = const EdgeInsets.symmetric(horizontal: 8);
    } else if (width < 900) {
      maxWidth = 700;
      padding = const EdgeInsets.symmetric(horizontal: 16);
    }
    return Container(
      color: theme.colorScheme.background,
      padding: padding,
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
