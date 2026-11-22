import 'package:flutter/material.dart';

/// The trailing "opens something" chevron.
///
/// Tinted from the surrounding text colour rather than a fixed grey, so it
/// stays visible on both the light and the dark card.
class ThemedChevron extends StatelessWidget {
  const ThemedChevron({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.chevron_right,
      color: DefaultTextStyle.of(context).style.color?.withValues(alpha: 0.6),
    );
  }
}
