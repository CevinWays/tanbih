import 'package:flutter/material.dart';

import '../styles/styles.dart';

/// A single-choice list in a bottom sheet.
///
/// Used for every "pick one" setting — method, madhab, high-latitude rule —
/// so they all behave identically.
class OptionPickerSheet<T> extends StatelessWidget {
  const OptionPickerSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.labelOf,
    super.key,
    this.subtitleOf,
  });

  final String title;
  final List<T> options;
  final T selected;
  final String Function(T) labelOf;
  final String? Function(T)? subtitleOf;

  /// Returns the chosen value, or null if the sheet was dismissed.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<T> options,
    required T selected,
    required String Function(T) labelOf,
    String? Function(T)? subtitleOf,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (_) => OptionPickerSheet<T>(
        title: title,
        options: options,
        selected: selected,
        labelOf: labelOf,
        subtitleOf: subtitleOf,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        // Long lists (13 calculation methods) must not push the sheet past
        // the top of the screen.
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.sm,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(title, style: AppTextStyle.h3),
              ),
            ),
            Flexible(
              child: RadioGroup<T>(
                groupValue: selected,
                onChanged: (value) => Navigator.of(context).pop(value),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final subtitle = subtitleOf?.call(option);

                    return RadioListTile<T>(
                      value: option,
                      activeColor: AppColors.brandSolid,
                      title: Text(
                        labelOf(option),
                        style: AppTextStyle.rowLabel,
                      ),
                      subtitle: subtitle == null
                          ? null
                          : Text(subtitle, style: AppTextStyle.bodySmall),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
