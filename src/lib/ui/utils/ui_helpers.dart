import "dart:async";

import "package:flutter/material.dart";
import "package:openeatsjournal/app_global.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/food_source.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/weight_journal_entry_add_screen.dart";
import "package:openeatsjournal/ui/screens/weight_journal_entry_add_screen_viewmodel.dart";
import "package:openeatsjournal/ui/utils/entity_edited.dart";
import "package:openeatsjournal/ui/utils/open_eats_journal_colors.dart";

class UiHelpers {
  UiHelpers._static();
  static Color getFoodSourceColor({Food? food, required BuildContext context}) {
    final OpenEatsJournalColors openEatsJournalColors = Theme.of(context).extension<OpenEatsJournalColors>()!;

    //user
    Color color = openEatsJournalColors.userFoodColor!;
    if (food != null) {
      if (food.foodSource == FoodSource.openFoodFacts) {
        if (food.fromDb) {
          color = openEatsJournalColors.cacheFoodColor!;
        } else {
          color = openEatsJournalColors.openFoodFactsFoodColor!;
        }
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
        if (food.fromDb) {
          label = AppLocalizations.of(context)!.cch;
        } else {
          label = AppLocalizations.of(context)!.off;
        }
      }

      if (food.foodSource == FoodSource.standard) {
        label = AppLocalizations.of(context)!.std;
      }
    } else {
      label = AppLocalizations.of(context)!.qck;
    }

    return label;
  }

  static Future<bool> showAddWeightDialog({
    required BuildContext context,
    required DateTime initialDate,
    required double initialWeight,
    required Future<void> Function(double weight) saveCallback,
  }) async {
    double dialogHorizontalPadding = MediaQuery.sizeOf(context).width * 0.05;
    double dialogVerticalPadding = MediaQuery.sizeOf(context).height * 0.03;

    WeightJournalEntryAddScreenViewModel weightJournalEntryAddScreenViewModel = WeightJournalEntryAddScreenViewModel(initialWeight: initialWeight);

    if ((await showDialog<bool>(
      useSafeArea: true,
      barrierDismissible: false,
      context: AppGlobal.navigatorKey.currentContext!,
      builder: (BuildContext contextBuilder) {
        return Dialog(
          insetPadding: EdgeInsets.fromLTRB(dialogHorizontalPadding, dialogVerticalPadding, dialogHorizontalPadding, dialogVerticalPadding),
          child: WeightJournalEntryAddScreen(weightJournalEntryAddScreenViewModel: weightJournalEntryAddScreenViewModel, date: initialDate),
        );
      },
    ))!) {
      await saveCallback(weightJournalEntryAddScreenViewModel.lastValidWeight);
      return true;
    }

    return false;
  }

  static Future<EntityEdited?> pushQuickEntryRoute({required BuildContext context, required DateTime initialEntryDate, required Meal initialMeal}) async {
    return await Navigator.pushNamed(
          context,
          OpenEatsJournalStrings.navigatorRouteQuickEntryEdit,
          arguments: EatsJournalEntry.quick(
            entryDate: initialEntryDate,
            name: OpenEatsJournalStrings.emptyString,
            kJoule: NutritionCalculator.kJouleForOnekCal,
            meal: initialMeal,
          ),
        )
        as EntityEdited?;
  }

  static void showOverlay({required BuildContext context, required String displayText, required AnimationController animationController}) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    OverlayEntry entry = OverlayEntry(
      builder: (context) => FadeTransition(
        opacity: animationController,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(),
              Container(
                alignment: AlignmentGeometry.center,
                color: colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: EdgeInsetsGeometry.all(10),
                  child: Text(displayText, style: textTheme.bodyMedium),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    AppGlobal.navigatorKey.currentState!.overlay!.insert(entry);
    animationController.forward();
    Timer(Duration(milliseconds: 3150), () {
      animationController.reverse();
      Timer(Duration(milliseconds: 150), () {
        animationController.reverse();
        entry.remove();
      });
    });
  }
}
