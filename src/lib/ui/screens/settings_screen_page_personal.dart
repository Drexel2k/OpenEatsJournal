import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:intl/intl.dart";
import "package:openeatsjournal/domain/gender.dart";
import "package:openeatsjournal/domain/kcal_settings.dart";
import "package:openeatsjournal/global_navigator_key.dart";
import "package:openeatsjournal/ui/utils/error_handlers.dart";
import "package:openeatsjournal/domain/weight_target.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/daily_calories_editor_screen.dart";
import "package:openeatsjournal/ui/screens/daily_calories_editor_viewmodel.dart";
import "package:openeatsjournal/ui/screens/settings_viewmodel.dart";
import "package:openeatsjournal/ui/utils/convert_validate.dart";
import "package:openeatsjournal/ui/utils/debouncer.dart";
import "package:openeatsjournal/ui/widgets/settings_textfield.dart";
import "package:openeatsjournal/ui/widgets/transparent_choice_chip.dart";

class SettingsScreenPagePersonal extends StatelessWidget {
  SettingsScreenPagePersonal({super.key, required SettingsViewModel settingsViewModel})
    : _settingsViewModel = settingsViewModel,
      _birthDayController = TextEditingController(),
      _heightController = TextEditingController(),
      _weightController = TextEditingController();

  final SettingsViewModel _settingsViewModel;
  final TextEditingController _birthDayController;
  final TextEditingController _heightController;
  final TextEditingController _weightController;

  @override
  Widget build(BuildContext context) {
    final String languageCode = Localizations.localeOf(context).toString();
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String decimalSeparator = NumberFormat.decimalPattern(languageCode).symbols.DECIMAL_SEP;

    final NumberFormat formatter = NumberFormat(null, Localizations.localeOf(context).languageCode);

    final Debouncer heightDebouncer = Debouncer();
    final Debouncer weightDebouncer = Debouncer();

    _birthDayController.text = DateFormat.yMMMMd(languageCode).format(_settingsViewModel.birthday.value);

    _heightController.text = formatter.format(_settingsViewModel.height.value);
    _weightController.text = formatter.format(_settingsViewModel.weight.value);

    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),

      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 11,
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 8,
                            child: Text(
                              AppLocalizations.of(context)!.daily_target_calories,
                              style: textTheme.titleMedium,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: ValueListenableBuilder(
                              valueListenable: _settingsViewModel.dailyTargetCalories,
                              builder: (_, _, _) {
                                return Text(
                                  formatter.format(_settingsViewModel.dailyTargetCalories.value),
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
                            flex: 8,
                            child: Text(AppLocalizations.of(context)!.daily_need_calories, style: textTheme.bodySmall),
                          ),
                          Expanded(
                            flex: 3,
                            child: ValueListenableBuilder(
                              valueListenable: _settingsViewModel.dailyCalories,
                              builder: (_, _, _) {
                                return Text(
                                  formatter.format(_settingsViewModel.dailyCalories.value),
                                  style: textTheme.bodySmall,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 5,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton(
                        onPressed: () async {
                          try {
                            if ((await _showRecalulateCaloriesCOnfirmDialog(context: context))!) {
                              await _settingsViewModel.recalculateDailykCalTargetsAndSave();
                            }
                          } on Exception catch (exc, stack) {
                            await ErrorHandlers.showException(
                              context: navigatorKey.currentContext!,
                              exception: exc,
                              stackTrace: stack,
                            );
                          } on Error catch (error, stack) {
                            await ErrorHandlers.showException(
                              context: navigatorKey.currentContext!,
                              error: error,
                              stackTrace: stack,
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          shape: CircleBorder(),
                          minimumSize: Size(40, 40),
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Icon(Icons.calculate),
                      ),
                      SizedBox(width: 5),
                      OutlinedButton(
                        onPressed: () async {
                          try {
                            KCalSettings? kCalSettings = await _showDailyCaloriesEditDialog(
                              context: context,
                              dailyCalories: _settingsViewModel.dailyCalories.value,
                              originalDailyTargetCalories: _settingsViewModel.dailyTargetCalories.value,
                              initialKCalSettings: KCalSettings(
                                kCalsMonday: _settingsViewModel.kCalsMonday,
                                kCalsTuesday: _settingsViewModel.kCalsTuesday,
                                kCalsWednesday: _settingsViewModel.kCalsWednesday,
                                kCalsThursday: _settingsViewModel.kCalsThursday,
                                kCalsFriday: _settingsViewModel.kCalsFriday,
                                kCalsSaturday: _settingsViewModel.kCalsSaturday,
                                kCalsSunday: _settingsViewModel.kCalsSunday,
                              ),
                            );
                            if (kCalSettings != null) {
                              await _settingsViewModel.setDailyCaloriesAndSave(kCalSettings);
                            }
                          } on Exception catch (exc, stack) {
                            await ErrorHandlers.showException(
                              context: navigatorKey.currentContext!,
                              exception: exc,
                              stackTrace: stack,
                            );
                          } on Error catch (error, stack) {
                            await ErrorHandlers.showException(
                              context: navigatorKey.currentContext!,
                              error: error,
                              stackTrace: stack,
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          shape: CircleBorder(),
                          minimumSize: Size(40, 40),
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Icon(Icons.edit),
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
                Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.your_gender, style: textTheme.titleMedium)),
                Flexible(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: _settingsViewModel.gender,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            icon: Icons.male,
                            label: AppLocalizations.of(contextBuilder)!.male,
                            selected: _settingsViewModel.gender.value == Gender.male,
                            onSelected: (bool selected) {
                              _settingsViewModel.gender.value = Gender.male;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ValueListenableBuilder(
                        valueListenable: _settingsViewModel.gender,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            icon: Icons.female,
                            label: AppLocalizations.of(contextBuilder)!.female,
                            selected: _settingsViewModel.gender.value == Gender.femail,
                            onSelected: (bool selected) {
                              _settingsViewModel.gender.value = Gender.femail;
                            },
                          );
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
                Expanded(
                  flex: 1,
                  child: Text(AppLocalizations.of(context)!.your_birthday, style: textTheme.titleMedium),
                ),
                Flexible(
                  flex: 1,
                  child: SettingsTextField(
                    controller: _birthDayController,
                    onTap: () {
                      _selectDate(
                        initialDate: _settingsViewModel.birthday.value,
                        context: context,
                        languageCode: languageCode,
                      );
                    },
                    readOnly: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.your_height, style: textTheme.titleMedium)),
                Flexible(
                  flex: 1,
                  child: ValueListenableBuilder(
                    valueListenable: _settingsViewModel.height,
                    builder: (_, _, _) {
                      return SettingsTextField(
                        controller: _heightController,
                        keyboardType: TextInputType.numberWithOptions(signed: false),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            final String text = newValue.text.trim();
                            return text.isEmpty
                                ? TextEditingValue(text: "1")
                                : text.length <= 3 && int.parse(text) >= 1
                                ? newValue
                                : oldValue;
                          }),
                        ],
                        onChanged: (value) {
                          heightDebouncer.run(
                            callback: () {
                              _settingsViewModel.height.value = int.parse(value);
                            },
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
                Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.your_weight, style: textTheme.titleMedium)),
                Flexible(
                  flex: 1,

                  child: ValueListenableBuilder(
                    valueListenable: _settingsViewModel.weight,
                    builder: (_, _, _) {
                      return SettingsTextField(
                        controller: _weightController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                        inputFormatters: [
                          //if filter is not matched, the value is set to empty string
                          //which feels strange in the ui
                          //FilteringTextInputFormatter.allow(RegExp(weightRegExp)),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            final String text = newValue.text.trim();
                            return text.isEmpty
                                ? TextEditingValue(text: "1")
                                : ConvertValidate.validateWeight(weight: text, decimalSeparator: decimalSeparator) &&
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
                          weightDebouncer.run(
                            callback: () {
                              num weightNum = NumberFormat(null, languageCode).parse(value);
                              _settingsViewModel.weight.value = weightNum as double;
                            },
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(AppLocalizations.of(context)!.your_acitivty_level, style: textTheme.titleMedium),
                      Tooltip(
                        triggerMode: TooltipTriggerMode.tap,
                        showDuration: Duration(seconds: 60),
                        message: AppLocalizations.of(context)!.acitivity_level_explanation,
                        child: Icon(Icons.help_outline),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: _settingsViewModel.activityFactor,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            label: AppLocalizations.of(contextBuilder)!.very_low,
                            selected: _settingsViewModel.activityFactor.value == 1.2,
                            onSelected: (bool selected) {
                              _settingsViewModel.activityFactor.value = 1.2;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ValueListenableBuilder(
                        valueListenable: _settingsViewModel.activityFactor,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            label: AppLocalizations.of(contextBuilder)!.low,
                            selected: _settingsViewModel.activityFactor.value == 1.4,
                            onSelected: (bool selected) {
                              _settingsViewModel.activityFactor.value = 1.4;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ValueListenableBuilder(
                        valueListenable: _settingsViewModel.activityFactor,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            label: AppLocalizations.of(contextBuilder)!.medium,
                            selected: _settingsViewModel.activityFactor.value == 1.6,
                            onSelected: (bool selected) {
                              _settingsViewModel.activityFactor.value = 1.6;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ValueListenableBuilder(
                        valueListenable: _settingsViewModel.activityFactor,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            label: AppLocalizations.of(contextBuilder)!.high,
                            selected: _settingsViewModel.activityFactor.value == 1.8,
                            onSelected: (bool selected) {
                              _settingsViewModel.activityFactor.value = 1.8;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ValueListenableBuilder(
                        valueListenable: _settingsViewModel.activityFactor,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            label: AppLocalizations.of(contextBuilder)!.very_high,
                            selected: _settingsViewModel.activityFactor.value == 2.1,
                            onSelected: (bool selected) {
                              _settingsViewModel.activityFactor.value = 2.1;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ValueListenableBuilder(
                        valueListenable: _settingsViewModel.activityFactor,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            label: AppLocalizations.of(contextBuilder)!.professional_athlete,
                            selected: _settingsViewModel.activityFactor.value == 2.4,
                            onSelected: (bool selected) {
                              _settingsViewModel.activityFactor.value = 2.4;
                            },
                          );
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
                Expanded(
                  flex: 1,
                  child: Text(AppLocalizations.of(context)!.your_weight_target, style: textTheme.titleMedium),
                ),
                Flexible(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: _settingsViewModel.weightTarget,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            label: AppLocalizations.of(contextBuilder)!.keep_weight,
                            selected: _settingsViewModel.weightTarget.value == WeightTarget.keep,
                            onSelected: (bool selected) {
                              _settingsViewModel.weightTarget.value = WeightTarget.keep;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ValueListenableBuilder(
                        valueListenable: _settingsViewModel.weightTarget,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            label: AppLocalizations.of(contextBuilder)!.lose025,
                            selected: _settingsViewModel.weightTarget.value == WeightTarget.lose025,
                            onSelected: (bool selected) {
                              _settingsViewModel.weightTarget.value = WeightTarget.lose025;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ValueListenableBuilder(
                        valueListenable: _settingsViewModel.weightTarget,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            label: AppLocalizations.of(contextBuilder)!.lose05,
                            selected: _settingsViewModel.weightTarget.value == WeightTarget.lose05,
                            onSelected: (bool selected) {
                              _settingsViewModel.weightTarget.value = WeightTarget.lose05;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ValueListenableBuilder(
                        valueListenable: _settingsViewModel.weightTarget,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            label: AppLocalizations.of(contextBuilder)!.lose075,
                            selected: _settingsViewModel.weightTarget.value == WeightTarget.lose075,
                            onSelected: (bool selected) {
                              _settingsViewModel.weightTarget.value = WeightTarget.lose075;
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showRecalulateCaloriesCOnfirmDialog({required BuildContext context}) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext contextBuilder) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.recalculate_calories_target),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.recalculate_calories_target_hint),
              Text(AppLocalizations.of(context)!.are_you_sure),
            ],
          ),

          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () async {
                try {
                  Navigator.pop(contextBuilder, false);
                } on Exception catch (exc, stack) {
                  await ErrorHandlers.showException(
                    context: navigatorKey.currentContext!,
                    exception: exc,
                    stackTrace: stack,
                  );
                } on Error catch (error, stack) {
                  await ErrorHandlers.showException(
                    context: navigatorKey.currentContext!,
                    error: error,
                    stackTrace: stack,
                  );
                }
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.ok),
              onPressed: () async {
                try {
                  Navigator.pop(contextBuilder, true);
                } on Exception catch (exc, stack) {
                  await ErrorHandlers.showException(
                    context: navigatorKey.currentContext!,
                    exception: exc,
                    stackTrace: stack,
                  );
                } on Error catch (error, stack) {
                  await ErrorHandlers.showException(
                    context: navigatorKey.currentContext!,
                    error: error,
                    stackTrace: stack,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<KCalSettings?> _showDailyCaloriesEditDialog({
    required BuildContext context,
    required int dailyCalories,
    required int originalDailyTargetCalories,
    required KCalSettings initialKCalSettings,
  }) async {
    return showDialog<KCalSettings>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (_) {
        return DailyCaloriesEditorScreen(
          dailyCaloriesEditorViewModel: DailyCaloriesEditorViewModel(
            KCalSettings(
              kCalsMonday: _settingsViewModel.kCalsMonday,
              kCalsTuesday: _settingsViewModel.kCalsTuesday,
              kCalsWednesday: _settingsViewModel.kCalsWednesday,
              kCalsThursday: _settingsViewModel.kCalsThursday,
              kCalsFriday: _settingsViewModel.kCalsFriday,
              kCalsSaturday: _settingsViewModel.kCalsSaturday,
              kCalsSunday: _settingsViewModel.kCalsSunday,
            ),
          ),
          dailyCalories: _settingsViewModel.dailyCalories.value,
          originalDailyTargetCalories: _settingsViewModel.dailyTargetCalories.value,
        );
      },
    );
  }

  Future<void> _selectDate({
    required DateTime initialDate,
    required BuildContext context,
    required String languageCode,
  }) async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      _birthDayController.text = DateFormat.yMMMMd(languageCode).format(date);
      _settingsViewModel.birthday.value = date;
    }
  }
}
