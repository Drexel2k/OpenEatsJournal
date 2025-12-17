import 'package:flutter/material.dart';

class OpenEatsJournalColors extends ThemeExtension<OpenEatsJournalColors> {
  const OpenEatsJournalColors({
    required Color userFoodColor,
    required Color standardFoodColor,
    required Color openFoodFactsFoodColor,
    required Color quickEntryColor,
  }) : _userFoodColor = userFoodColor,
       _standardFoodColor = standardFoodColor,
       _openFoodFactsFoodColor = openFoodFactsFoodColor,
       _quickEntryColor = quickEntryColor;

  final Color? _userFoodColor;
  final Color? _standardFoodColor;
  final Color? _openFoodFactsFoodColor;
  final Color? _quickEntryColor;

  Color? get userFoodColor => _userFoodColor;
  Color? get standardFoodColor => _standardFoodColor;
  Color? get openFoodFactsFoodColor => _openFoodFactsFoodColor;
  Color? get quickEntryColor => _quickEntryColor;

  @override
  OpenEatsJournalColors copyWith({Color? userFoodColor, Color? standardFoodColor, Color? openFoodFactsFoodColor, Color? quickEntryColor}) {
    return OpenEatsJournalColors(
      userFoodColor: userFoodColor ?? _userFoodColor!,
      standardFoodColor: standardFoodColor ?? _standardFoodColor!,
      openFoodFactsFoodColor: openFoodFactsFoodColor ?? _openFoodFactsFoodColor!,
      quickEntryColor: quickEntryColor ?? _quickEntryColor!,
    );
  }

  @override
  OpenEatsJournalColors lerp(OpenEatsJournalColors? other, double t) {
    if (other is! OpenEatsJournalColors) {
      return this;
    }
    return OpenEatsJournalColors(
      userFoodColor: Color.lerp(_userFoodColor, other.userFoodColor, t)!,
      standardFoodColor: Color.lerp(_standardFoodColor, other.standardFoodColor, t)!,
      openFoodFactsFoodColor: Color.lerp(_openFoodFactsFoodColor, other.openFoodFactsFoodColor, t)!,
      quickEntryColor: Color.lerp(_quickEntryColor, other.quickEntryColor, t)!,
    );
  }
}
