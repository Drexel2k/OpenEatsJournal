import 'package:flutter/material.dart';
import 'package:openeatsjournal/domain/food.dart';
import 'package:openeatsjournal/domain/food_source.dart';
import 'package:openeatsjournal/l10n/app_localizations.dart';
import 'package:openeatsjournal/ui/utils/open_eats_journal_colors.dart';

class FoodSourceFormat {
  static Color getFoodSourceColor({Food? food, required BuildContext context}) {
    final OpenEatsJournalColors openEatsJournalColors = Theme.of(context).extension<OpenEatsJournalColors>()!;

    //user
    Color color = openEatsJournalColors.userFoodColor!;
    if (food != null) {
      if (food.foodSource == FoodSource.openFoodFacts) {
        color = openEatsJournalColors.openFoodFactsFoodColor!;
      }

      if (food.foodSource == FoodSource.standard) {
        color = openEatsJournalColors.standardFoodColor!;
      }
    } else {
      //quick
      color = openEatsJournalColors.quickEntryColor!;
    }

    return color;
  }

  static String getFoodSourceLabel({Food? food, required BuildContext context}) {
    String label = AppLocalizations.of(context)!.usr;

    if (food != null) {
      if (food.foodSource == FoodSource.openFoodFacts) {
        label = AppLocalizations.of(context)!.off;
      }

      if (food.foodSource == FoodSource.standard) {
        label = AppLocalizations.of(context)!.std;
      }
    } else {
      label = AppLocalizations.of(context)!.qck;
    }

    return label;
  }
}
