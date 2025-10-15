import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:intl/intl.dart";
import "package:openeatsjournal/domain/kjoule_per_day.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/global_navigator_key.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/daily_calories_editor_screen_viewmodel.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
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

    _kJouleMondayController.text = ConvertValidate.numberFomatterInt.format(
      NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJouleMonday.value),
    );
    _kJouleTuesdayController.text = ConvertValidate.numberFomatterInt.format(
      NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJouleTuesday.value),
    );
    _kJouleWednesdayController.text = ConvertValidate.numberFomatterInt.format(
      NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJouleWednesday.value),
    );
    _kJouleThursdayController.text = ConvertValidate.numberFomatterInt.format(
      NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJouleThursday.value),
    );
    _kJouleFridayController.text = ConvertValidate.numberFomatterInt.format(
      NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJouleFriday.value),
    );
    _kJouleSaturdayController.text = ConvertValidate.numberFomatterInt.format(
      NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJouleSaturday.value),
    );
    _kJouleSundayController.text = ConvertValidate.numberFomatterInt.format(
      NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJouleSunday.value),
    );

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
                      AppLocalizations.of(context)!.amount_kcal(
                        ConvertValidate.numberFomatterInt.format(
                          NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJouleTargetDaily.value),
                        ),
                      ),
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
                  AppLocalizations.of(
                    context,
                  )!.amount_kcal(ConvertValidate.numberFomatterInt.format(NutritionCalculator.getKCalsFromKJoules(_originalDailyTargetKJoule))),
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
                child: Text(
                  AppLocalizations.of(context)!.amount_kcal(ConvertValidate.numberFomatterInt.format(NutritionCalculator.getKCalsFromKJoules(_dailyKJoule))),
                  style: textTheme.bodySmall,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.monday_kcals_label, style: textTheme.titleMedium)),
              Flexible(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SettingsTextField(
                      controller: _kJouleMondayController,
                      keyboardType: TextInputType.numberWithOptions(signed: false),
                      inputFormatters: [
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final String text = newValue.text;
                          if (text.isEmpty) {
                            _dailyCaloriesEditorScreenViewModel.kJouleMondayValid.value = false;
                            return newValue;
                          } else {
                            if (ConvertValidate.validateKJoule(kJoule: text, thousandSeparator: thousandSeparator) &&
                                ConvertValidate.convertLocalStringToDouble(numberString: text, languageCode: languageCode)! >= 1) {
                              _dailyCaloriesEditorScreenViewModel.kJouleMondayValid.value = true;
                              return newValue;
                            } else {
                              return oldValue;
                            }
                          }
                        }),
                      ],
                      onChanged: (value) {
                        kCalMondayDebouncer.run(
                          callback: () {
                            if (value.isNotEmpty && ConvertValidate.validateKJoule(kJoule: value, thousandSeparator: thousandSeparator)) {
                              int valueInt = ConvertValidate.convertLocalStringToInt(numberString: value, languageCode: languageCode)!;
                              if (valueInt >= 1) {
                                _dailyCaloriesEditorScreenViewModel.kJouleMonday.value = NutritionCalculator.getKJoulesFromKCals(valueInt);
                                _kJouleMondayController.text = ConvertValidate.numberFomatterInt.format(valueInt);
                              }
                            }
                          },
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: _dailyCaloriesEditorScreenViewModel.kJouleMondayValid,
                      builder: (_, _, _) {
                        if (!_dailyCaloriesEditorScreenViewModel.kJouleMondayValid.value) {
                          return Text(
                            AppLocalizations.of(context)!.input_invalid(
                              AppLocalizations.of(context)!.monday_kcals,
                              ConvertValidate.numberFomatterInt.format(
                                NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJouleMonday.value),
                              ),
                            ),
                            style: textTheme.labelMedium!.copyWith(color: Colors.red),
                          );
                        } else {
                          return SizedBox();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.tuesday_kcals_label, style: textTheme.titleMedium)),
              Flexible(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SettingsTextField(
                      controller: _kJouleTuesdayController,
                      keyboardType: TextInputType.numberWithOptions(signed: false),
                      inputFormatters: [
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final String text = newValue.text;
                          if (text.isEmpty) {
                            _dailyCaloriesEditorScreenViewModel.kJouleTuesdayValid.value = false;
                            return newValue;
                          } else {
                            if (ConvertValidate.validateKJoule(kJoule: text, thousandSeparator: thousandSeparator) &&
                                ConvertValidate.convertLocalStringToDouble(numberString: text, languageCode: languageCode)! >= 1) {
                              _dailyCaloriesEditorScreenViewModel.kJouleTuesdayValid.value = true;
                              return newValue;
                            } else {
                              return oldValue;
                            }
                          }
                        }),
                      ],
                      onChanged: (value) {
                        kCalTuesdayDebouncer.run(
                          callback: () {
                            if (value.isNotEmpty && ConvertValidate.validateKJoule(kJoule: value, thousandSeparator: thousandSeparator)) {
                              int valueInt = ConvertValidate.convertLocalStringToInt(numberString: value, languageCode: languageCode)!;
                              if (valueInt >= 1) {
                                _dailyCaloriesEditorScreenViewModel.kJouleTuesday.value = NutritionCalculator.getKJoulesFromKCals(valueInt);
                                _kJouleTuesdayController.text = ConvertValidate.numberFomatterInt.format(valueInt);
                              }
                            }
                          },
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: _dailyCaloriesEditorScreenViewModel.kJouleTuesdayValid,
                      builder: (_, _, _) {
                        if (!_dailyCaloriesEditorScreenViewModel.kJouleTuesdayValid.value) {
                          return Text(
                            AppLocalizations.of(context)!.input_invalid(
                              AppLocalizations.of(context)!.tuesday_kcals,
                              ConvertValidate.numberFomatterInt.format(
                                NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJouleTuesday.value),
                              ),
                            ),
                            style: textTheme.labelMedium!.copyWith(color: Colors.red),
                          );
                        } else {
                          return SizedBox();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.wednesday_kcals_label, style: textTheme.titleMedium)),
              Flexible(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SettingsTextField(
                      controller: _kJouleWednesdayController,
                      keyboardType: TextInputType.numberWithOptions(signed: false),
                      inputFormatters: [
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final String text = newValue.text;
                          if (text.isEmpty) {
                            _dailyCaloriesEditorScreenViewModel.kJouleWednesdayValid.value = false;
                            return newValue;
                          } else {
                            if (ConvertValidate.validateKJoule(kJoule: text, thousandSeparator: thousandSeparator) &&
                                ConvertValidate.convertLocalStringToDouble(numberString: text, languageCode: languageCode)! >= 1) {
                              _dailyCaloriesEditorScreenViewModel.kJouleWednesdayValid.value = true;
                              return newValue;
                            } else {
                              return oldValue;
                            }
                          }
                        }),
                      ],
                      onChanged: (value) {
                        kCalWednesdayDebouncer.run(
                          callback: () {
                            if (value.isNotEmpty && ConvertValidate.validateKJoule(kJoule: value, thousandSeparator: thousandSeparator)) {
                              int valueInt = ConvertValidate.convertLocalStringToInt(numberString: value, languageCode: languageCode)!;
                              if (valueInt >= 1) {
                                _dailyCaloriesEditorScreenViewModel.kJouleWednesday.value = NutritionCalculator.getKJoulesFromKCals(valueInt);
                                _kJouleWednesdayController.text = ConvertValidate.numberFomatterInt.format(valueInt);
                              }
                            }
                          },
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: _dailyCaloriesEditorScreenViewModel.kJouleWednesdayValid,
                      builder: (_, _, _) {
                        if (!_dailyCaloriesEditorScreenViewModel.kJouleWednesdayValid.value) {
                          return Text(
                            AppLocalizations.of(context)!.input_invalid(
                              AppLocalizations.of(context)!.wednesday_kcals,
                              ConvertValidate.numberFomatterInt.format(
                                NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJouleWednesday.value),
                              ),
                            ),
                            style: textTheme.labelMedium!.copyWith(color: Colors.red),
                          );
                        } else {
                          return SizedBox();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.thursday_kcals_label, style: textTheme.titleMedium)),
              Flexible(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SettingsTextField(
                      controller: _kJouleThursdayController,
                      keyboardType: TextInputType.numberWithOptions(signed: false),
                      inputFormatters: [
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final String text = newValue.text;
                          if (text.isEmpty) {
                            _dailyCaloriesEditorScreenViewModel.kJouleThursdayValid.value = false;
                            return newValue;
                          } else {
                            if (ConvertValidate.validateKJoule(kJoule: text, thousandSeparator: thousandSeparator) &&
                                ConvertValidate.convertLocalStringToDouble(numberString: text, languageCode: languageCode)! >= 1) {
                              _dailyCaloriesEditorScreenViewModel.kJouleThursdayValid.value = true;
                              return newValue;
                            } else {
                              return oldValue;
                            }
                          }
                        }),
                      ],
                      onChanged: (value) {
                        kCalThursdayDebouncer.run(
                          callback: () {
                            if (value.isNotEmpty && ConvertValidate.validateKJoule(kJoule: value, thousandSeparator: thousandSeparator)) {
                              int valueInt = ConvertValidate.convertLocalStringToInt(numberString: value, languageCode: languageCode)!;
                              if (valueInt >= 1) {
                                _dailyCaloriesEditorScreenViewModel.kJouleThursday.value = NutritionCalculator.getKJoulesFromKCals(valueInt);
                                _kJouleThursdayController.text = ConvertValidate.numberFomatterInt.format(valueInt);
                              }
                            }
                          },
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: _dailyCaloriesEditorScreenViewModel.kJouleThursdayValid,
                      builder: (_, _, _) {
                        if (!_dailyCaloriesEditorScreenViewModel.kJouleThursdayValid.value) {
                          return Text(
                            AppLocalizations.of(context)!.input_invalid(
                              AppLocalizations.of(context)!.thursday_kcals,
                              ConvertValidate.numberFomatterInt.format(
                                NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJouleThursday.value),
                              ),
                            ),
                            style: textTheme.labelMedium!.copyWith(color: Colors.red),
                          );
                        } else {
                          return SizedBox();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.friday_kcals_label, style: textTheme.titleMedium)),
              Flexible(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SettingsTextField(
                      controller: _kJouleFridayController,
                      keyboardType: TextInputType.numberWithOptions(signed: false),
                      inputFormatters: [
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final String text = newValue.text;
                          if (text.isEmpty) {
                            _dailyCaloriesEditorScreenViewModel.kJouleFridayValid.value = false;
                            return newValue;
                          } else {
                            if (ConvertValidate.validateKJoule(kJoule: text, thousandSeparator: thousandSeparator) &&
                                ConvertValidate.convertLocalStringToDouble(numberString: text, languageCode: languageCode)! >= 1) {
                              _dailyCaloriesEditorScreenViewModel.kJouleFridayValid.value = true;
                              return newValue;
                            } else {
                              return oldValue;
                            }
                          }
                        }),
                      ],
                      onChanged: (value) {
                        kCalFridayDebouncer.run(
                          callback: () {
                            if (value.isNotEmpty && ConvertValidate.validateKJoule(kJoule: value, thousandSeparator: thousandSeparator)) {
                              int valueInt = ConvertValidate.convertLocalStringToInt(numberString: value, languageCode: languageCode)!;
                              if (valueInt >= 1) {
                                _dailyCaloriesEditorScreenViewModel.kJouleFriday.value = NutritionCalculator.getKJoulesFromKCals(valueInt);
                                _kJouleFridayController.text = ConvertValidate.numberFomatterInt.format(valueInt);
                              }
                            }
                          },
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: _dailyCaloriesEditorScreenViewModel.kJouleFridayValid,
                      builder: (_, _, _) {
                        if (!_dailyCaloriesEditorScreenViewModel.kJouleFridayValid.value) {
                          return Text(
                            AppLocalizations.of(context)!.input_invalid(
                              AppLocalizations.of(context)!.friday_kcals,
                              ConvertValidate.numberFomatterInt.format(
                                NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJouleFriday.value),
                              ),
                            ),
                            style: textTheme.labelMedium!.copyWith(color: Colors.red),
                          );
                        } else {
                          return SizedBox();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.saturday_kcals_label, style: textTheme.titleMedium)),
              Flexible(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SettingsTextField(
                      controller: _kJouleSaturdayController,
                      keyboardType: TextInputType.numberWithOptions(signed: false),
                      inputFormatters: [
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final String text = newValue.text;
                          if (text.isEmpty) {
                            _dailyCaloriesEditorScreenViewModel.kJouleSaturdayValid.value = false;
                            return newValue;
                          } else {
                            if (ConvertValidate.validateKJoule(kJoule: text, thousandSeparator: thousandSeparator) &&
                                ConvertValidate.convertLocalStringToDouble(numberString: text, languageCode: languageCode)! >= 1) {
                              _dailyCaloriesEditorScreenViewModel.kJouleSaturdayValid.value = true;
                              return newValue;
                            } else {
                              return oldValue;
                            }
                          }
                        }),
                      ],
                      onChanged: (value) {
                        kCalSaturdayDebouncer.run(
                          callback: () {
                            if (value.isNotEmpty && ConvertValidate.validateKJoule(kJoule: value, thousandSeparator: thousandSeparator)) {
                              int valueInt = ConvertValidate.convertLocalStringToInt(numberString: value, languageCode: languageCode)!;
                              if (valueInt >= 1) {
                                _dailyCaloriesEditorScreenViewModel.kJouleSaturday.value = NutritionCalculator.getKJoulesFromKCals(valueInt);
                                _kJouleSaturdayController.text = ConvertValidate.numberFomatterInt.format(valueInt);
                              }
                            }
                          },
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: _dailyCaloriesEditorScreenViewModel.kJouleSaturdayValid,
                      builder: (_, _, _) {
                        if (!_dailyCaloriesEditorScreenViewModel.kJouleSaturdayValid.value) {
                          return Text(
                            AppLocalizations.of(context)!.input_invalid(
                              AppLocalizations.of(context)!.saturday_kcals,
                              ConvertValidate.numberFomatterInt.format(
                                NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJouleSaturday.value),
                              ),
                            ),
                            style: textTheme.labelMedium!.copyWith(color: Colors.red),
                          );
                        } else {
                          return SizedBox();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.sunday_kcals_label, style: textTheme.titleMedium)),
              Flexible(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SettingsTextField(
                      controller: _kJouleSundayController,
                      keyboardType: TextInputType.numberWithOptions(signed: false),
                      inputFormatters: [
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final String text = newValue.text;
                          if (text.isEmpty) {
                            _dailyCaloriesEditorScreenViewModel.kJouleSundayValid.value = false;
                            return newValue;
                          } else {
                            if (ConvertValidate.validateKJoule(kJoule: text, thousandSeparator: thousandSeparator) &&
                                ConvertValidate.convertLocalStringToDouble(numberString: text, languageCode: languageCode)! >= 1) {
                              _dailyCaloriesEditorScreenViewModel.kJouleSundayValid.value = true;
                              return newValue;
                            } else {
                              return oldValue;
                            }
                          }
                        }),
                      ],
                      onChanged: (value) {
                        kCalSundayDebouncer.run(
                          callback: () {
                            if (value.isNotEmpty && ConvertValidate.validateKJoule(kJoule: value, thousandSeparator: thousandSeparator)) {
                              int valueInt = ConvertValidate.convertLocalStringToInt(numberString: value, languageCode: languageCode)!;
                              if (valueInt >= 1) {
                                _dailyCaloriesEditorScreenViewModel.kJouleSunday.value = NutritionCalculator.getKJoulesFromKCals(valueInt);
                                _kJouleSundayController.text = ConvertValidate.numberFomatterInt.format(valueInt);
                              }
                            }
                          },
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: _dailyCaloriesEditorScreenViewModel.kJouleSundayValid,
                      builder: (_, _, _) {
                        if (!_dailyCaloriesEditorScreenViewModel.kJouleSundayValid.value) {
                          return Text(
                            AppLocalizations.of(context)!.input_invalid(
                              AppLocalizations.of(context)!.sunday_kcals,
                              ConvertValidate.numberFomatterInt.format(
                                NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJouleSunday.value),
                              ),
                            ),
                            style: textTheme.labelMedium!.copyWith(color: Colors.red),
                          );
                        } else {
                          return SizedBox();
                        }
                      },
                    ),
                  ],
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
                kJouleMonday: _dailyCaloriesEditorScreenViewModel.kJouleMonday.value,
                kJouleTuesday: _dailyCaloriesEditorScreenViewModel.kJouleTuesday.value,
                kJouleWednesday: _dailyCaloriesEditorScreenViewModel.kJouleWednesday.value,
                kJouleThursday: _dailyCaloriesEditorScreenViewModel.kJouleThursday.value,
                kJouleFriday: _dailyCaloriesEditorScreenViewModel.kJouleFriday.value,
                kJouleSaturday: _dailyCaloriesEditorScreenViewModel.kJouleSaturday.value,
                kJouleSunday: _dailyCaloriesEditorScreenViewModel.kJouleSunday.value,
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
