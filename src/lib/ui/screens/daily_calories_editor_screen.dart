import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:intl/intl.dart";
import "package:openeatsjournal/domain/kcal_settings.dart";
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
    required int dailyCalories,
    required int originalDailyTargetCalories,
  }) : _dailyCaloriesEditorScreenViewModel = dailyCaloriesEditorScreenViewModel,
       _dailyCalories = dailyCalories,
       _originalDailyTargetCalories = originalDailyTargetCalories,
       _kCalMondayController = TextEditingController(),
       _kCalTuesdayController = TextEditingController(),
       _kCalWednesdayController = TextEditingController(),
       _kCalThursdayController = TextEditingController(),
       _kCalFridayController = TextEditingController(),
       _kCalSaturdayController = TextEditingController(),
       _kCalSundayController = TextEditingController();

  final DailyCaloriesEditorScreenViewModel _dailyCaloriesEditorScreenViewModel;
  final int _dailyCalories;
  final int _originalDailyTargetCalories;
  final TextEditingController _kCalMondayController;
  final TextEditingController _kCalTuesdayController;
  final TextEditingController _kCalWednesdayController;
  final TextEditingController _kCalThursdayController;
  final TextEditingController _kCalFridayController;
  final TextEditingController _kCalSaturdayController;
  final TextEditingController _kCalSundayController;

  @override
  Widget build(BuildContext context) {
    final String languageCode = Localizations.localeOf(context).languageCode;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String thousandSeparator = NumberFormat.decimalPattern(languageCode).symbols.GROUP_SEP;

    final NumberFormat formatter = NumberFormat(null, languageCode);

    _kCalMondayController.text = formatter.format(_dailyCaloriesEditorScreenViewModel.kCalsMonday.value);
    _kCalTuesdayController.text = formatter.format(_dailyCaloriesEditorScreenViewModel.kCalsTuesday.value);
    _kCalWednesdayController.text = formatter.format(_dailyCaloriesEditorScreenViewModel.kCalsWednesday.value);
    _kCalThursdayController.text = formatter.format(_dailyCaloriesEditorScreenViewModel.kCalsThursday.value);
    _kCalFridayController.text = formatter.format(_dailyCaloriesEditorScreenViewModel.kCalsFriday.value);
    _kCalSaturdayController.text = formatter.format(_dailyCaloriesEditorScreenViewModel.kCalsSaturday.value);
    _kCalSundayController.text = formatter.format(_dailyCaloriesEditorScreenViewModel.kCalsSunday.value);

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
              Expanded(
                flex: 1,
                child: Text(AppLocalizations.of(context)!.daily_target_new, style: textTheme.titleMedium),
              ),
              Flexible(
                flex: 1,
                child: ValueListenableBuilder(
                  valueListenable: _dailyCaloriesEditorScreenViewModel.kCalsTargetDaily,
                  builder: (_, _, _) {
                    return Text(
                      AppLocalizations.of(
                        context,
                      )!.amount_kcal(_dailyCaloriesEditorScreenViewModel.kCalsTargetDaily.value),
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
              Expanded(
                flex: 1,
                child: Text(AppLocalizations.of(context)!.daily_target_original, style: textTheme.bodySmall),
              ),
              Flexible(
                flex: 1,
                child: Text(
                  AppLocalizations.of(context)!.amount_kcal(_originalDailyTargetCalories),
                  style: textTheme.bodySmall,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Text(AppLocalizations.of(context)!.daily_need_calories, style: textTheme.bodySmall),
              ),
              Flexible(
                flex: 1,
                child: Text(
                  AppLocalizations.of(context)!.amount_kcal(_dailyCalories),
                  style: textTheme.bodySmall,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.monday_kcals, style: textTheme.titleMedium)),
              Flexible(
                flex: 1,
                child: SettingsTextField(
                  controller: _kCalMondayController,
                  keyboardType: TextInputType.numberWithOptions(signed: false),
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final String text = newValue.text;
                      return text.isEmpty
                          ? TextEditingValue(text: "1")
                          : ConvertValidate.validateCalories(kCals: text, thousandSeparator: thousandSeparator) &&
                                ConvertValidate.convertLocalStringToDouble(
                                      numberString: text,
                                      languageCode: languageCode,
                                    )! >=
                                    1
                          ? newValue
                          : oldValue;
                    }),
                  ],
                  onChanged: (value) {
                    kCalMondayDebouncer.run(
                      callback: () {
                        _dailyCaloriesEditorScreenViewModel.kCalsMonday.value = ConvertValidate.convertLocalStringToInt(
                          numberString: value,
                          languageCode: languageCode,
                        )!;
                        _kCalMondayController.text = formatter.format(_dailyCaloriesEditorScreenViewModel.kCalsMonday.value);
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
                  controller: _kCalTuesdayController,
                  keyboardType: TextInputType.numberWithOptions(signed: false),
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final String text = newValue.text;
                      return text.isEmpty
                          ? TextEditingValue(text: "1")
                          : ConvertValidate.validateCalories(kCals: text, thousandSeparator: thousandSeparator) &&
                                ConvertValidate.convertLocalStringToDouble(
                                      numberString: text,
                                      languageCode: languageCode,
                                    )! >=
                                    1
                          ? newValue
                          : oldValue;
                    }),
                  ],
                  onChanged: (value) {
                    kCalTuesdayDebouncer.run(
                      callback: () {
                        _dailyCaloriesEditorScreenViewModel.kCalsTuesday.value = ConvertValidate.convertLocalStringToInt(
                          numberString: value,
                          languageCode: languageCode,
                        )!;
                        _kCalTuesdayController.text = formatter.format(
                          _dailyCaloriesEditorScreenViewModel.kCalsTuesday.value,
                        );
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
              Expanded(
                flex: 1,
                child: Text(AppLocalizations.of(context)!.wednesday_kcals, style: textTheme.titleMedium),
              ),
              Flexible(
                flex: 1,
                child: SettingsTextField(
                  controller: _kCalWednesdayController,
                  keyboardType: TextInputType.numberWithOptions(signed: false),
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final String text = newValue.text;
                      return text.isEmpty
                          ? TextEditingValue(text: "1")
                          : ConvertValidate.validateCalories(kCals: text, thousandSeparator: thousandSeparator) &&
                                ConvertValidate.convertLocalStringToDouble(
                                      numberString: text,
                                      languageCode: languageCode,
                                    )! >=
                                    1
                          ? newValue
                          : oldValue;
                    }),
                  ],
                  onChanged: (value) {
                    kCalWednesdayDebouncer.run(
                      callback: () {
                        _dailyCaloriesEditorScreenViewModel.kCalsWednesday.value = ConvertValidate.convertLocalStringToInt(
                          numberString: value,
                          languageCode: languageCode,
                        )!;
                        _kCalWednesdayController.text = formatter.format(
                          _dailyCaloriesEditorScreenViewModel.kCalsWednesday.value,
                        );
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
              Expanded(
                flex: 1,
                child: Text(AppLocalizations.of(context)!.thursday_kcals, style: textTheme.titleMedium),
              ),
              Flexible(
                flex: 1,
                child: SettingsTextField(
                  controller: _kCalThursdayController,
                  keyboardType: TextInputType.numberWithOptions(signed: false),
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final String text = newValue.text;
                      return text.isEmpty
                          ? TextEditingValue(text: "1")
                          : ConvertValidate.validateCalories(kCals: text, thousandSeparator: thousandSeparator) &&
                                ConvertValidate.convertLocalStringToDouble(
                                      numberString: text,
                                      languageCode: languageCode,
                                    )! >=
                                    1
                          ? newValue
                          : oldValue;
                    }),
                  ],
                  onChanged: (value) {
                    kCalThursdayDebouncer.run(
                      callback: () {
                        _dailyCaloriesEditorScreenViewModel.kCalsThursday.value = ConvertValidate.convertLocalStringToInt(
                          numberString: value,
                          languageCode: languageCode,
                        )!;
                        _kCalThursdayController.text = formatter.format(
                          _dailyCaloriesEditorScreenViewModel.kCalsThursday.value,
                        );
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
                  controller: _kCalFridayController,
                  keyboardType: TextInputType.numberWithOptions(signed: false),
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final String text = newValue.text;
                      return text.isEmpty
                          ? TextEditingValue(text: "1")
                          : ConvertValidate.validateCalories(kCals: text, thousandSeparator: thousandSeparator) &&
                                ConvertValidate.convertLocalStringToDouble(
                                      numberString: text,
                                      languageCode: languageCode,
                                    )! >=
                                    1
                          ? newValue
                          : oldValue;
                    }),
                  ],
                  onChanged: (value) {
                    kCalFridayDebouncer.run(
                      callback: () {
                        _dailyCaloriesEditorScreenViewModel.kCalsFriday.value = ConvertValidate.convertLocalStringToInt(
                          numberString: value,
                          languageCode: languageCode,
                        )!;
                        _kCalFridayController.text = formatter.format(_dailyCaloriesEditorScreenViewModel.kCalsFriday.value);
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
              Expanded(
                flex: 1,
                child: Text(AppLocalizations.of(context)!.saturday_kcals, style: textTheme.titleMedium),
              ),
              Flexible(
                flex: 1,
                child: SettingsTextField(
                  controller: _kCalSaturdayController,
                  keyboardType: TextInputType.numberWithOptions(signed: false),
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final String text = newValue.text;
                      return text.isEmpty
                          ? TextEditingValue(text: "1")
                          : ConvertValidate.validateCalories(kCals: text, thousandSeparator: thousandSeparator) &&
                                ConvertValidate.convertLocalStringToDouble(
                                      numberString: text,
                                      languageCode: languageCode,
                                    )! >=
                                    1
                          ? newValue
                          : oldValue;
                    }),
                  ],
                  onChanged: (value) {
                    kCalSaturdayDebouncer.run(
                      callback: () {
                        _dailyCaloriesEditorScreenViewModel.kCalsSaturday.value = ConvertValidate.convertLocalStringToInt(
                          numberString: value,
                          languageCode: languageCode,
                        )!;
                        _kCalSaturdayController.text = formatter.format(
                          _dailyCaloriesEditorScreenViewModel.kCalsSaturday.value,
                        );
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
                  controller: _kCalSundayController,
                  keyboardType: TextInputType.numberWithOptions(signed: false),
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final String text = newValue.text;
                      return text.isEmpty
                          ? TextEditingValue(text: "1")
                          : ConvertValidate.validateCalories(kCals: text, thousandSeparator: thousandSeparator) &&
                                ConvertValidate.convertLocalStringToDouble(
                                      numberString: text,
                                      languageCode: languageCode,
                                    )! >=
                                    1
                          ? newValue
                          : oldValue;
                    }),
                  ],
                  onChanged: (value) {
                    kCalSundayDebouncer.run(
                      callback: () {
                        _dailyCaloriesEditorScreenViewModel.kCalsSunday.value = ConvertValidate.convertLocalStringToInt(
                          numberString: value,
                          languageCode: languageCode,
                        )!;
                        _kCalSundayController.text = formatter.format(_dailyCaloriesEditorScreenViewModel.kCalsSunday.value);
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
              await ErrorHandlers.showException(
                context: navigatorKey.currentContext!,
                exception: exc,
                stackTrace: stack,
              );
            } on Error catch (error, stack) {
              await ErrorHandlers.showException(context: navigatorKey.currentContext!, error: error, stackTrace: stack);
            }
          },
        ),
        TextButton(
          child: Text(AppLocalizations.of(context)!.ok),

          onPressed: () async {
            try {
              KCalSettings kCalSettings = KCalSettings(
                kCalsMonday: ConvertValidate.convertLocalStringToInt(
                  numberString: _kCalMondayController.text,
                  languageCode: languageCode,
                )!,
                kCalsTuesday: ConvertValidate.convertLocalStringToInt(
                  numberString: _kCalTuesdayController.text,
                  languageCode: languageCode,
                )!,
                kCalsWednesday: ConvertValidate.convertLocalStringToInt(
                  numberString: _kCalWednesdayController.text,
                  languageCode: languageCode,
                )!,
                kCalsThursday: ConvertValidate.convertLocalStringToInt(
                  numberString: _kCalThursdayController.text,
                  languageCode: languageCode,
                )!,
                kCalsFriday: ConvertValidate.convertLocalStringToInt(
                  numberString: _kCalFridayController.text,
                  languageCode: languageCode,
                )!,
                kCalsSaturday: ConvertValidate.convertLocalStringToInt(
                  numberString: _kCalSaturdayController.text,
                  languageCode: languageCode,
                )!,
                kCalsSunday: ConvertValidate.convertLocalStringToInt(
                  numberString: _kCalSundayController.text,
                  languageCode: languageCode,
                )!,
              );

              Navigator.pop(context, kCalSettings);
            } on Exception catch (exc, stack) {
              await ErrorHandlers.showException(
                context: navigatorKey.currentContext!,
                exception: exc,
                stackTrace: stack,
              );
            } on Error catch (error, stack) {
              await ErrorHandlers.showException(context: navigatorKey.currentContext!, error: error, stackTrace: stack);
            }
          },
        ),
      ],
    );
  }
}
