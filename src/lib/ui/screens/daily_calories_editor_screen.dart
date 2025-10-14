import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:intl/intl.dart";
import "package:openeatsjournal/domain/kjoule_per_day.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/global_navigator_key.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/daily_calories_editor_screen_viewmodel.dart";
import "package:openeatsjournal/ui/utils/convert_validate.dart";
import "package:openeatsjournal/ui/utils/debouncer.dart";
import "package:openeatsjournal/ui/utils/error_handlers.dart";
import "package:openeatsjournal/ui/widgets/settings_textfield.dart";

class DailyCaloriesEditorScreen extends StatelessWidget {
  DailyCaloriesEditorScreen({
    super.key,
    required DailyCaloriesEditorScreenViewModel dailyCaloriesEditorScreenViewModel,
    required int dailyKJoule,
    required int originalDailyTargetKjoule,
  }) : _dailyCaloriesEditorScreenViewModel = dailyCaloriesEditorScreenViewModel,
       _dailyKJoule = dailyKJoule,
       _originalDailyTargetKJoule = originalDailyTargetKjoule,
       _kJouleMondayController = TextEditingController(),
       _kJouleTuesdayController = TextEditingController(),
       _kJouleWednesdayController = TextEditingController(),
       _kJouleThursdayController = TextEditingController(),
       _kJouleFridayController = TextEditingController(),
       _kJouleSaturdayController = TextEditingController(),
       _kJouleSundayController = TextEditingController();

  final DailyCaloriesEditorScreenViewModel _dailyCaloriesEditorScreenViewModel;
  final int _dailyKJoule;
  final int _originalDailyTargetKJoule;
  final TextEditingController _kJouleMondayController;
  final TextEditingController _kJouleTuesdayController;
  final TextEditingController _kJouleWednesdayController;
  final TextEditingController _kJouleThursdayController;
  final TextEditingController _kJouleFridayController;
  final TextEditingController _kJouleSaturdayController;
  final TextEditingController _kJouleSundayController;

  @override
  Widget build(BuildContext context) {
    final String languageCode = Localizations.localeOf(context).languageCode;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String thousandSeparator = NumberFormat.decimalPattern(languageCode).symbols.GROUP_SEP;

    final NumberFormat formatter = NumberFormat(null, languageCode);

    _kJouleMondayController.text = formatter.format(NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJouleMonday.value));
    _kJouleTuesdayController.text = formatter.format(NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJouleTuesday.value));
    _kJouleWednesdayController.text = formatter.format(NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJouleWednesday.value));
    _kJouleThursdayController.text = formatter.format(NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJouleThursday.value));
    _kJouleFridayController.text = formatter.format(NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJouleFriday.value));
    _kJouleSaturdayController.text = formatter.format(NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJouleSaturday.value));
    _kJouleSundayController.text = formatter.format(NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJouleSunday.value));

    final Debouncer kCalMondayDebouncer = Debouncer();
    final Debouncer kCalTuesdayDebouncer = Debouncer();
    final Debouncer kCalWednesdayDebouncer = Debouncer();
    final Debouncer kCalThursdayDebouncer = Debouncer();
    final Debouncer kCalFridayDebouncer = Debouncer();
    final Debouncer kCalSaturdayDebouncer = Debouncer();
    final Debouncer kCalSundayDebouncer = Debouncer();

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.edit_calories_target),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.daily_target_new, style: textTheme.titleMedium)),
              Flexible(
                flex: 1,
                child: ValueListenableBuilder(
                  valueListenable: _dailyCaloriesEditorScreenViewModel.kJouleTargetDaily,
                  builder: (_, _, _) {
                    return Text(
                      AppLocalizations.of(
                        context,
                      )!.amount_kcal(NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJouleTargetDaily.value)),
                      style: textTheme.titleMedium,
                    );
                  },
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.daily_target_original, style: textTheme.bodySmall)),
              Flexible(
                flex: 1,
                child: Text(
                  AppLocalizations.of(context)!.amount_kcal(NutritionCalculator.getKCalsFromKJoules(_originalDailyTargetKJoule)),
                  style: textTheme.bodySmall,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.daily_need_calories, style: textTheme.bodySmall)),
              Flexible(
                flex: 1,
                child: Text(AppLocalizations.of(context)!.amount_kcal(NutritionCalculator.getKCalsFromKJoules(_dailyKJoule)), style: textTheme.bodySmall),
              ),
            ],
          ),
          SizedBox(height: 10),
          //TODO: for daily kJoule entries allow enter of null value (aka emptying the input Textfield), but showing a hint under the box, that the value is
          //invalid and what the currently stored value is.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.monday_kcals, style: textTheme.titleMedium)),
              Flexible(
                flex: 1,
                child: SettingsTextField(
                  controller: _kJouleMondayController,
                  keyboardType: TextInputType.numberWithOptions(signed: false),
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final String text = newValue.text;
                      return text.isEmpty
                          ? TextEditingValue(text: "1")
                          : ConvertValidate.validateKJoule(kJoule: text, thousandSeparator: thousandSeparator) &&
                                ConvertValidate.convertLocalStringToDouble(numberString: text, languageCode: languageCode)! >= 1
                          ? newValue
                          : oldValue;
                    }),
                  ],
                  onChanged: (value) {
                    kCalMondayDebouncer.run(
                      callback: () {
                        _dailyCaloriesEditorScreenViewModel.kJouleMonday.value = ConvertValidate.convertLocalStringToInt(
                          numberString: value,
                          languageCode: languageCode,
                        )!;
                        _kJouleMondayController.text = formatter.format(_dailyCaloriesEditorScreenViewModel.kJouleMonday.value);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.tuesday_kcals, style: textTheme.titleMedium)),
              Flexible(
                flex: 1,
                child: SettingsTextField(
                  controller: _kJouleTuesdayController,
                  keyboardType: TextInputType.numberWithOptions(signed: false),
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final String text = newValue.text;
                      return text.isEmpty
                          ? TextEditingValue(text: "1")
                          : ConvertValidate.validateKJoule(kJoule: text, thousandSeparator: thousandSeparator) &&
                                ConvertValidate.convertLocalStringToDouble(numberString: text, languageCode: languageCode)! >= 1
                          ? newValue
                          : oldValue;
                    }),
                  ],
                  onChanged: (value) {
                    kCalTuesdayDebouncer.run(
                      callback: () {
                        _dailyCaloriesEditorScreenViewModel.kJouleTuesday.value = ConvertValidate.convertLocalStringToInt(
                          numberString: value,
                          languageCode: languageCode,
                        )!;
                        _kJouleTuesdayController.text = formatter.format(_dailyCaloriesEditorScreenViewModel.kJouleTuesday.value);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.wednesday_kcals, style: textTheme.titleMedium)),
              Flexible(
                flex: 1,
                child: SettingsTextField(
                  controller: _kJouleWednesdayController,
                  keyboardType: TextInputType.numberWithOptions(signed: false),
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final String text = newValue.text;
                      return text.isEmpty
                          ? TextEditingValue(text: "1")
                          : ConvertValidate.validateKJoule(kJoule: text, thousandSeparator: thousandSeparator) &&
                                ConvertValidate.convertLocalStringToDouble(numberString: text, languageCode: languageCode)! >= 1
                          ? newValue
                          : oldValue;
                    }),
                  ],
                  onChanged: (value) {
                    kCalWednesdayDebouncer.run(
                      callback: () {
                        _dailyCaloriesEditorScreenViewModel.kJouleWednesday.value = ConvertValidate.convertLocalStringToInt(
                          numberString: value,
                          languageCode: languageCode,
                        )!;
                        _kJouleWednesdayController.text = formatter.format(_dailyCaloriesEditorScreenViewModel.kJouleWednesday.value);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.thursday_kcals, style: textTheme.titleMedium)),
              Flexible(
                flex: 1,
                child: SettingsTextField(
                  controller: _kJouleThursdayController,
                  keyboardType: TextInputType.numberWithOptions(signed: false),
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final String text = newValue.text;
                      return text.isEmpty
                          ? TextEditingValue(text: "1")
                          : ConvertValidate.validateKJoule(kJoule: text, thousandSeparator: thousandSeparator) &&
                                ConvertValidate.convertLocalStringToDouble(numberString: text, languageCode: languageCode)! >= 1
                          ? newValue
                          : oldValue;
                    }),
                  ],
                  onChanged: (value) {
                    kCalThursdayDebouncer.run(
                      callback: () {
                        _dailyCaloriesEditorScreenViewModel.kJouleThursday.value = ConvertValidate.convertLocalStringToInt(
                          numberString: value,
                          languageCode: languageCode,
                        )!;
                        _kJouleThursdayController.text = formatter.format(_dailyCaloriesEditorScreenViewModel.kJouleThursday.value);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.friday_kcals, style: textTheme.titleMedium)),
              Flexible(
                flex: 1,
                child: SettingsTextField(
                  controller: _kJouleFridayController,
                  keyboardType: TextInputType.numberWithOptions(signed: false),
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final String text = newValue.text;
                      return text.isEmpty
                          ? TextEditingValue(text: "1")
                          : ConvertValidate.validateKJoule(kJoule: text, thousandSeparator: thousandSeparator) &&
                                ConvertValidate.convertLocalStringToDouble(numberString: text, languageCode: languageCode)! >= 1
                          ? newValue
                          : oldValue;
                    }),
                  ],
                  onChanged: (value) {
                    kCalFridayDebouncer.run(
                      callback: () {
                        _dailyCaloriesEditorScreenViewModel.kJouleFriday.value = ConvertValidate.convertLocalStringToInt(
                          numberString: value,
                          languageCode: languageCode,
                        )!;
                        _kJouleFridayController.text = formatter.format(_dailyCaloriesEditorScreenViewModel.kJouleFriday.value);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.saturday_kcals, style: textTheme.titleMedium)),
              Flexible(
                flex: 1,
                child: SettingsTextField(
                  controller: _kJouleSaturdayController,
                  keyboardType: TextInputType.numberWithOptions(signed: false),
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final String text = newValue.text;
                      return text.isEmpty
                          ? TextEditingValue(text: "1")
                          : ConvertValidate.validateKJoule(kJoule: text, thousandSeparator: thousandSeparator) &&
                                ConvertValidate.convertLocalStringToDouble(numberString: text, languageCode: languageCode)! >= 1
                          ? newValue
                          : oldValue;
                    }),
                  ],
                  onChanged: (value) {
                    kCalSaturdayDebouncer.run(
                      callback: () {
                        _dailyCaloriesEditorScreenViewModel.kJouleSaturday.value = ConvertValidate.convertLocalStringToInt(
                          numberString: value,
                          languageCode: languageCode,
                        )!;
                        _kJouleSaturdayController.text = formatter.format(_dailyCaloriesEditorScreenViewModel.kJouleSaturday.value);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.sunday_kcals, style: textTheme.titleMedium)),
              Flexible(
                flex: 1,
                child: SettingsTextField(
                  controller: _kJouleSundayController,
                  keyboardType: TextInputType.numberWithOptions(signed: false),
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final String text = newValue.text;
                      return text.isEmpty
                          ? TextEditingValue(text: "1")
                          : ConvertValidate.validateKJoule(kJoule: text, thousandSeparator: thousandSeparator) &&
                                ConvertValidate.convertLocalStringToDouble(numberString: text, languageCode: languageCode)! >= 1
                          ? newValue
                          : oldValue;
                    }),
                  ],
                  onChanged: (value) {
                    kCalSundayDebouncer.run(
                      callback: () {
                        _dailyCaloriesEditorScreenViewModel.kJouleSunday.value = ConvertValidate.convertLocalStringToInt(
                          numberString: value,
                          languageCode: languageCode,
                        )!;
                        _kJouleSundayController.text = formatter.format(_dailyCaloriesEditorScreenViewModel.kJouleSunday.value);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text(AppLocalizations.of(context)!.cancel),
          onPressed: () async {
            try {
              Navigator.pop(context);
            } on Exception catch (exc, stack) {
              await ErrorHandlers.showException(context: navigatorKey.currentContext!, exception: exc, stackTrace: stack);
            } on Error catch (error, stack) {
              await ErrorHandlers.showException(context: navigatorKey.currentContext!, error: error, stackTrace: stack);
            }
          },
        ),
        TextButton(
          child: Text(AppLocalizations.of(context)!.ok),

          onPressed: () async {
            try {
              KJoulePerDay kJouleSettings = KJoulePerDay(
                kJouleMonday: NutritionCalculator.getKJoulesFromKCals(
                  ConvertValidate.convertLocalStringToInt(numberString: _kJouleMondayController.text, languageCode: languageCode)!,
                ),
                kJouleTuesday: NutritionCalculator.getKJoulesFromKCals(
                  ConvertValidate.convertLocalStringToInt(numberString: _kJouleTuesdayController.text, languageCode: languageCode)!,
                ),
                kJouleWednesday: NutritionCalculator.getKJoulesFromKCals(
                  ConvertValidate.convertLocalStringToInt(numberString: _kJouleWednesdayController.text, languageCode: languageCode)!,
                ),
                kJouleThursday: NutritionCalculator.getKJoulesFromKCals(
                  ConvertValidate.convertLocalStringToInt(numberString: _kJouleThursdayController.text, languageCode: languageCode)!,
                ),
                kJouleFriday: NutritionCalculator.getKJoulesFromKCals(
                  ConvertValidate.convertLocalStringToInt(numberString: _kJouleFridayController.text, languageCode: languageCode)!,
                ),
                kJouleSaturday: NutritionCalculator.getKJoulesFromKCals(
                  ConvertValidate.convertLocalStringToInt(numberString: _kJouleSaturdayController.text, languageCode: languageCode)!,
                ),
                kJouleSunday: NutritionCalculator.getKJoulesFromKCals(
                  ConvertValidate.convertLocalStringToInt(numberString: _kJouleSundayController.text, languageCode: languageCode)!,
                ),
              );

              Navigator.pop(context, kJouleSettings);
            } on Exception catch (exc, stack) {
              await ErrorHandlers.showException(context: navigatorKey.currentContext!, exception: exc, stackTrace: stack);
            } on Error catch (error, stack) {
              await ErrorHandlers.showException(context: navigatorKey.currentContext!, error: error, stackTrace: stack);
            }
          },
        ),
      ],
    );
  }
}
