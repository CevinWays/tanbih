import 'package:flutter/material.dart';

import '../../../../core/styles/styles.dart';

/// Section heading in the menu.
class MenuSection extends StatelessWidget {
  const MenuSection({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTextStyle.h3.copyWith(fontSize: 16));
  }
}
