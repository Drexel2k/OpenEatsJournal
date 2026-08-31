import "package:flutter/material.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/repository/journal_repository.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/ui/screens/eats_journal_edit_screen.dart";
import "package:openeatsjournal/ui/screens/eats_journal_edit_screen_viewmodel.dart";
import "package:openeatsjournal/ui/screens/eats_journal_screen_viewmodel.dart";
import "package:openeatsjournal/ui/widgets/gauge_distribution.dart";
import "package:provider/provider.dart";

class EatsJournalMealButton extends StatelessWidget {
  const EatsJournalMealButton({
    super.key,
    required Meal meal,
    required double mealStartValue,
    required double mealEndValue,
    required double mealKJoule,
    required double mealPercent,
    required EatsJournalScreenViewModel eatsJournalScreenViewModel,
    required JournalRepository journalRepository,
    required SettingsRepository settingsRepository,
    required void Function({required Meal meal}) changeMealCallback,
    required Future<void> Function() pushQuickEntryScreenCallback,
  }) : _meal = meal,
       _mealStartValue = mealStartValue,
       _mealEndValue = mealEndValue,
       _mealKJoule = mealKJoule,
       _mealPercent = mealPercent,
       _eatsJournalScreenViewModel = eatsJournalScreenViewModel,
       _journalRepository = journalRepository,
       _settingsRepository = settingsRepository,
       _changeMealCallback = changeMealCallback,
       _pushQuickEntryScreenCallback = pushQuickEntryScreenCallback;

  final Meal _meal;
  final double _mealStartValue;
  final double _mealEndValue;
  final double _mealKJoule;
  final double _mealPercent;
  final EatsJournalScreenViewModel _eatsJournalScreenViewModel;
  final JournalRepository _journalRepository;
  final SettingsRepository _settingsRepository;
  final void Function({required Meal meal}) _changeMealCallback;
  final Future<void> Function() _pushQuickEntryScreenCallback;

  @override
  Widget build(BuildContext context) {
    final ConvertValidate convert = Provider.of<ConvertValidate>(context, listen: false);

    return SizedBox(
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
        onPressed: () async {
          await showDialog<void>(
            useSafeArea: true,
            barrierDismissible: false,
            context: context,
            builder: (BuildContext contextBuilder) {
              double horizontalPadding = MediaQuery.sizeOf(contextBuilder).width * 0.05;
              double verticalPadding = MediaQuery.sizeOf(contextBuilder).height * 0.03;

              return Dialog(
                insetPadding: EdgeInsets.fromLTRB(horizontalPadding, verticalPadding, horizontalPadding, verticalPadding),
                child: ChangeNotifierProvider(
                  create: (context) =>
                      EatsJournalEditScreenViewModel(journalRepository: _journalRepository, settingsRepository: _settingsRepository, meal: _meal),
                  child: EatsJournalEditScreen(),
                ),
              );
            },
          );

          _eatsJournalScreenViewModel.refreshNutritionData();
        },
        child: Row(
          children: [
            SizedBox(width: 17),
            GaugeDistribution(startValue: _mealStartValue, endValue: _mealEndValue),
            SizedBox(width: 8),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_getMealText(context)),
                    Text(
                      "${convert.getCleanDoubleString1DecimalDigit(doubleValue: _mealPercent)}% / ${convert.numberFomatterInt.format(convert.getDisplayEnergy(energyKJ: _mealKJoule))}${convert.getLocalizedEnergyUnitAbbreviated(context: context)}",
                    ),
                  ],
                ),
              ),
            ),

            IconButton.outlined(
              onPressed: () {
                _changeMealCallback(meal: _meal);
              },
              icon: Icon(Icons.check),
            ),
            IconButton.outlined(
              onPressed: () async {
                _changeMealCallback(meal: _meal);
                await _pushQuickEntryScreenCallback();
                _eatsJournalScreenViewModel.refreshCurrentJournalDateAndMeal();
                _eatsJournalScreenViewModel.refreshNutritionData();
              },
              icon: Icon(Icons.speed),
            ),
            IconButton.outlined(
              onPressed: () async {
                _changeMealCallback(meal: _meal);
                await Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteFood);
                _eatsJournalScreenViewModel.refreshCurrentJournalDateAndMeal();
                _eatsJournalScreenViewModel.refreshNutritionData();
              },
              icon: Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  String _getMealText(BuildContext context) {
    if (_meal == Meal.breakfast) {
      return AppLocalizations.of(context)!.breakfast;
    }

    if (_meal == Meal.lunch) {
      return AppLocalizations.of(context)!.lunch;
    }

    if (_meal == Meal.dinner) {
      return AppLocalizations.of(context)!.dinner;
    }

    return AppLocalizations.of(context)!.snacks;
  }
}
