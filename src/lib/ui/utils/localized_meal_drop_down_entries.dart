import 'package:flutter/material.dart';
import 'package:openeatsjournal/domain/meal.dart';
import 'package:openeatsjournal/l10n/app_localizations.dart';
import 'package:openeatsjournal/domain/utils/open_eats_journal_strings.dart';

class LocalizedMealDropDownEntries {
  static List<DropdownMenuEntry<int>> getMealDropDownMenuEntries({required BuildContext context}) {
    List<DropdownMenuEntry<int>> entries = [];

    String label = OpenEatsJournalStrings.emptyString;
    for (var value in Meal.values) {
      if (value == Meal.breakfast) {
        label = AppLocalizations.of(context)!.breakfast;
      } else if (value == Meal.lunch) {
        label = AppLocalizations.of(context)!.lunch;
      } else if (value == Meal.dinner) {
        label = AppLocalizations.of(context)!.dinner;
      } else if (value == Meal.snacks) {
        label = AppLocalizations.of(context)!.snacks;
      } else {
        label = value.name;
      }

      entries.add(DropdownMenuEntry<int>(value: value.value, label: label));
    }

    return entries;
  }
}