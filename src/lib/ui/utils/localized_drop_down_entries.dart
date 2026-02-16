import "package:flutter/material.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/ui/utils/statistic_type.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";

class LocalizedDropDownEntries {
  LocalizedDropDownEntries._static();
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

  static List<DropdownMenuEntry<int>> getStatisticDropDownMenuEntries({required BuildContext context}) {
    List<DropdownMenuEntry<int>> entries = [];

    String label = OpenEatsJournalStrings.emptyString;
    for (var value in StatisticType.values) {
      if (value == StatisticType.energy) {
        label = AppLocalizations.of(context)!.energy;
      } else if (value == StatisticType.weight) {
        label = AppLocalizations.of(context)!.weight_capital;
      } else if (value == StatisticType.fat) {
        label = AppLocalizations.of(context)!.fat_capital;
      } else if (value == StatisticType.stauratedFat) {
        label = AppLocalizations.of(context)!.saturated_fat_capital;
      } else if (value == StatisticType.carbohydrates) {
        label = AppLocalizations.of(context)!.carbohydrates_capital;
      } else if (value == StatisticType.sugar) {
        label = AppLocalizations.of(context)!.sugar_capital;
      } else if (value == StatisticType.protein) {
        label = AppLocalizations.of(context)!.protein_capital;
      } else if (value == StatisticType.salt) {
        label = AppLocalizations.of(context)!.salt_capital;
      } else {
        label = value.name;
      }

      entries.add(DropdownMenuEntry<int>(value: value.value, label: label));
    }

    return entries;
  }
}
