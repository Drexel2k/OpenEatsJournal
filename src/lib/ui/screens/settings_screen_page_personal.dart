import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:intl/intl.dart";
import "package:openeatsjournal/domain/gender.dart";
import "package:openeatsjournal/domain/kjoule_per_day.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/global_navigator_key.dart";
import "package:openeatsjournal/ui/utils/error_handlers.dart";
import "package:openeatsjournal/domain/weight_target.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/daily_calories_editor_screen.dart";
import "package:openeatsjournal/ui/screens/daily_calories_editor_screen_viewmodel.dart";
import "package:openeatsjournal/ui/screens/settings_screen_viewmodel.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/ui/utils/debouncer.dart";
import "package:openeatsjournal/ui/widgets/round_outlined_button.dart";
import "package:openeatsjournal/ui/widgets/settings_textfield.dart";
import "package:openeatsjournal/ui/widgets/transparent_choice_chip.dart";

class SettingsScreenPagePersonal extends StatelessWidget {
  SettingsScreenPagePersonal({super.key, required SettingsScreenViewModel settingsViewModel})
    : _settingsScreenViewModel = settingsViewModel,
      _birthDayController = TextEditingController(),
      _heightController = TextEditingController(),
      _weightController = TextEditingController();

  final SettingsScreenViewModel _settingsScreenViewModel;
  final TextEditingController _birthDayController;
  final TextEditingController _heightController;
  final TextEditingController _weightController;

  @override
  Widget build(BuildContext context) {
    final String languageCode = Localizations.localeOf(context).toString();
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String decimalSeparator = NumberFormat.decimalPattern(languageCode).symbols.DECIMAL_SEP;

    final Debouncer heightDebouncer = Debouncer();
    final Debouncer weightDebouncer = Debouncer();

    _birthDayController.text = DateFormat.yMMMMd(languageCode).format(_settingsScreenViewModel.birthday.value);

    _heightController.text = ConvertValidate.numberFomatterInt.format(_settingsScreenViewModel.height.value);
    _weightController.text = ConvertValidate.numberFomatterInt.format(_settingsScreenViewModel.weight.value);

    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),

      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
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
                          Expanded(flex: 8, child: Text(AppLocalizations.of(context)!.daily_target_calories, style: textTheme.titleMedium)),
                          Expanded(
                            flex: 3,
                            child: ValueListenableBuilder(
                              valueListenable: _settingsScreenViewModel.dailyTargetKJoule,
                              builder: (_, _, _) {
                                return Text(
                                  ConvertValidate.numberFomatterInt.format(
                                    NutritionCalculator.getKCalsFromKJoules(_settingsScreenViewModel.dailyTargetKJoule.value),
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
                          Expanded(flex: 8, child: Text(AppLocalizations.of(context)!.daily_need_calories, style: textTheme.bodySmall)),
                          Expanded(
                            flex: 3,
                            child: ValueListenableBuilder(
                              valueListenable: _settingsScreenViewModel.dailyKJoule,
                              builder: (_, _, _) {
                                return Text(
                                  ConvertValidate.numberFomatterInt.format(NutritionCalculator.getKCalsFromKJoules(_settingsScreenViewModel.dailyKJoule.value)),
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
                      RoundOutlinedButton(
                        onPressed: () async {
                          try {
                            if ((await _showRecalulateKJouleConfirmDialog(context: context))!) {
                              await _settingsScreenViewModel.recalculateDailykJouleTargetsAndSave();
                            }
                          } on Exception catch (exc, stack) {
                            await ErrorHandlers.showException(context: navigatorKey.currentContext!, exception: exc, stackTrace: stack);
                          } on Error catch (error, stack) {
                            await ErrorHandlers.showException(context: navigatorKey.currentContext!, error: error, stackTrace: stack);
                          }
                        },
                        child: Icon(Icons.calculate),
                      ),
                      SizedBox(width: 5),
                      RoundOutlinedButton(
                        onPressed: () async {
                          try {
                            KJoulePerDay? kJouleSettings = await _showDailyCaloriesEditDialog(
                              context: context,
                              dailyKJoule: _settingsScreenViewModel.dailyKJoule.value,
                              originalDailyTargetKJoule: _settingsScreenViewModel.dailyTargetKJoule.value,
                              initialkJouleSettings: KJoulePerDay(
                                kJouleMonday: _settingsScreenViewModel.kJouleMonday,
                                kJouleTuesday: _settingsScreenViewModel.kJouleTuesday,
                                kJouleWednesday: _settingsScreenViewModel.kJouleWednesday,
                                kJouleThursday: _settingsScreenViewModel.kJouleThursday,
                                kJouleFriday: _settingsScreenViewModel.kJouleFriday,
                                kJouleSaturday: _settingsScreenViewModel.kJouleSaturday,
                                kJouleSunday: _settingsScreenViewModel.kJouleSunday,
                              ),
                            );
                            if (kJouleSettings != null) {
                              await _settingsScreenViewModel.setDailyKJouleAndSave(kJouleSettings);
                            }
                          } on Exception catch (exc, stack) {
                            await ErrorHandlers.showException(context: navigatorKey.currentContext!, exception: exc, stackTrace: stack);
                          } on Error catch (error, stack) {
                            await ErrorHandlers.showException(context: navigatorKey.currentContext!, error: error, stackTrace: stack);
                          }
                        },
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
                        valueListenable: _settingsScreenViewModel.gender,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            icon: Icons.male,
                            label: AppLocalizations.of(contextBuilder)!.male,
                            selected: _settingsScreenViewModel.gender.value == Gender.male,
                            onSelected: (bool selected) {
                              _settingsScreenViewModel.gender.value = Gender.male;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ValueListenableBuilder(
                        valueListenable: _settingsScreenViewModel.gender,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            icon: Icons.female,
                            label: AppLocalizations.of(contextBuilder)!.female,
                            selected: _settingsScreenViewModel.gender.value == Gender.femail,
                            onSelected: (bool selected) {
                              _settingsScreenViewModel.gender.value = Gender.femail;
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
                Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.your_birthday, style: textTheme.titleMedium)),
                Flexible(
                  flex: 1,
                  child: SettingsTextField(
                    controller: _birthDayController,
                    onTap: () {
                      _selectDate(initialDate: _settingsScreenViewModel.birthday.value, context: context, languageCode: languageCode);
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
                    valueListenable: _settingsScreenViewModel.height,
                    builder: (_, _, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SettingsTextField(
                            controller: _heightController,
                            keyboardType: TextInputType.numberWithOptions(signed: false),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              TextInputFormatter.withFunction((oldValue, newValue) {
                                final String text = newValue.text.trim();
                                if (text.isEmpty) {
                                  _settingsScreenViewModel.heightValid.value = false;
                                  return newValue;
                                } else {
                                  if (text.length <= 3) {
                                    _settingsScreenViewModel.heightValid.value = true;
                                    return newValue;
                                  } else {
                                    return oldValue;
                                  }
                                }
                              }),
                            ],
                            onChanged: (value) {
                              heightDebouncer.run(
                                callback: () {
                                  if (value.isNotEmpty && value.length <= 3 && int.parse(value) >= 1) {
                                    _settingsScreenViewModel.height.value = int.parse(value);
                                  }
                                },
                              );
                            },
                          ),
                          ValueListenableBuilder(
                            valueListenable: _settingsScreenViewModel.heightValid,
                            builder: (_, _, _) {
                              if (!_settingsScreenViewModel.heightValid.value) {
                                return Text(
                                  AppLocalizations.of(context)!.input_invalid(AppLocalizations.of(context)!.height, _settingsScreenViewModel.height.value),
                                  style: textTheme.labelSmall!.copyWith(color: Colors.red),
                                );
                              } else {
                                return SizedBox();
                              }
                            },
                          ),
                        ],
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
                    valueListenable: _settingsScreenViewModel.weight,
                    builder: (_, _, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SettingsTextField(
                            controller: _weightController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                            inputFormatters: [
                              //if filter is not matched, the value is set to empty string
                              //which feels strange in the ui
                              //FilteringTextInputFormatter.allow(RegExp(weightRegExp)),
                              TextInputFormatter.withFunction((oldValue, newValue) {
                                final String text = newValue.text.trim();
                                if (text.isEmpty) {
                                  _settingsScreenViewModel.weightValid.value = false;
                                  return newValue;
                                } else {
                                  if (ConvertValidate.validateWeight(weight: text, decimalSeparator: decimalSeparator)) {
                                    _settingsScreenViewModel.weightValid.value = true;
                                    return newValue;
                                  } else {
                                    return oldValue;
                                  }
                                }
                              }),
                            ],
                            onChanged: (value) {
                              weightDebouncer.run(
                                callback: () {
                                  if (value.isNotEmpty && ConvertValidate.validateWeight(weight: value, decimalSeparator: decimalSeparator)) {
                                    _settingsScreenViewModel.weight.value = (ConvertValidate.numberFomatterInt.parse(value) as double);
                                  }
                                },
                              );
                            },
                          ),
                          ValueListenableBuilder(
                            valueListenable: _settingsScreenViewModel.weightValid,
                            builder: (_, _, _) {
                              if (!_settingsScreenViewModel.weightValid.value) {
                                return Text(
                                  AppLocalizations.of(context)!.input_invalid(
                                    AppLocalizations.of(context)!.weight,
                                    ConvertValidate.numberFomatterDouble.format(_settingsScreenViewModel.weight.value),
                                  ),
                                  style: textTheme.labelMedium!.copyWith(color: Colors.red),
                                );
                              } else {
                                return SizedBox();
                              }
                            },
                          ),
                        ],
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
                        valueListenable: _settingsScreenViewModel.activityFactor,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            label: AppLocalizations.of(contextBuilder)!.very_low,
                            selected: _settingsScreenViewModel.activityFactor.value == 1.2,
                            onSelected: (bool selected) {
                              _settingsScreenViewModel.activityFactor.value = 1.2;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ValueListenableBuilder(
                        valueListenable: _settingsScreenViewModel.activityFactor,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            label: AppLocalizations.of(contextBuilder)!.low,
                            selected: _settingsScreenViewModel.activityFactor.value == 1.4,
                            onSelected: (bool selected) {
                              _settingsScreenViewModel.activityFactor.value = 1.4;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ValueListenableBuilder(
                        valueListenable: _settingsScreenViewModel.activityFactor,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            label: AppLocalizations.of(contextBuilder)!.medium,
                            selected: _settingsScreenViewModel.activityFactor.value == 1.6,
                            onSelected: (bool selected) {
                              _settingsScreenViewModel.activityFactor.value = 1.6;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ValueListenableBuilder(
                        valueListenable: _settingsScreenViewModel.activityFactor,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            label: AppLocalizations.of(contextBuilder)!.high,
                            selected: _settingsScreenViewModel.activityFactor.value == 1.8,
                            onSelected: (bool selected) {
                              _settingsScreenViewModel.activityFactor.value = 1.8;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ValueListenableBuilder(
                        valueListenable: _settingsScreenViewModel.activityFactor,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            label: AppLocalizations.of(contextBuilder)!.very_high,
                            selected: _settingsScreenViewModel.activityFactor.value == 2.1,
                            onSelected: (bool selected) {
                              _settingsScreenViewModel.activityFactor.value = 2.1;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ValueListenableBuilder(
                        valueListenable: _settingsScreenViewModel.activityFactor,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            label: AppLocalizations.of(contextBuilder)!.professional_athlete,
                            selected: _settingsScreenViewModel.activityFactor.value == 2.4,
                            onSelected: (bool selected) {
                              _settingsScreenViewModel.activityFactor.value = 2.4;
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
                Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.your_weight_target, style: textTheme.titleMedium)),
                Flexible(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: _settingsScreenViewModel.weightTarget,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            label: AppLocalizations.of(contextBuilder)!.keep_weight,
                            selected: _settingsScreenViewModel.weightTarget.value == WeightTarget.keep,
                            onSelected: (bool selected) {
                              _settingsScreenViewModel.weightTarget.value = WeightTarget.keep;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ValueListenableBuilder(
                        valueListenable: _settingsScreenViewModel.weightTarget,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            label: AppLocalizations.of(contextBuilder)!.lose025,
                            selected: _settingsScreenViewModel.weightTarget.value == WeightTarget.lose025,
                            onSelected: (bool selected) {
                              _settingsScreenViewModel.weightTarget.value = WeightTarget.lose025;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ValueListenableBuilder(
                        valueListenable: _settingsScreenViewModel.weightTarget,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            label: AppLocalizations.of(contextBuilder)!.lose05,
                            selected: _settingsScreenViewModel.weightTarget.value == WeightTarget.lose05,
                            onSelected: (bool selected) {
                              _settingsScreenViewModel.weightTarget.value = WeightTarget.lose05;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ValueListenableBuilder(
                        valueListenable: _settingsScreenViewModel.weightTarget,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            label: AppLocalizations.of(contextBuilder)!.lose075,
                            selected: _settingsScreenViewModel.weightTarget.value == WeightTarget.lose075,
                            onSelected: (bool selected) {
                              _settingsScreenViewModel.weightTarget.value = WeightTarget.lose075;
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

  Future<bool?> _showRecalulateKJouleConfirmDialog({required BuildContext context}) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext contextBuilder) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.recalculate_calories_target),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(AppLocalizations.of(context)!.recalculate_calories_target_hint), Text(AppLocalizations.of(context)!.are_you_sure)],
          ),

          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () async {
                try {
                  Navigator.pop(contextBuilder, false);
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
                  Navigator.pop(contextBuilder, true);
                } on Exception catch (exc, stack) {
                  await ErrorHandlers.showException(context: navigatorKey.currentContext!, exception: exc, stackTrace: stack);
                } on Error catch (error, stack) {
                  await ErrorHandlers.showException(context: navigatorKey.currentContext!, error: error, stackTrace: stack);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<KJoulePerDay?> _showDailyCaloriesEditDialog({
    required BuildContext context,
    required int dailyKJoule,
    required int originalDailyTargetKJoule,
    required KJoulePerDay initialkJouleSettings,
  }) async {
    return showDialog<KJoulePerDay>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (_) {
        return DailyCaloriesEditorScreen(
          dailyCaloriesEditorScreenViewModel: DailyCaloriesEditorScreenViewModel(
            KJoulePerDay(
              kJouleMonday: _settingsScreenViewModel.kJouleMonday,
              kJouleTuesday: _settingsScreenViewModel.kJouleTuesday,
              kJouleWednesday: _settingsScreenViewModel.kJouleWednesday,
              kJouleThursday: _settingsScreenViewModel.kJouleThursday,
              kJouleFriday: _settingsScreenViewModel.kJouleFriday,
              kJouleSaturday: _settingsScreenViewModel.kJouleSaturday,
              kJouleSunday: _settingsScreenViewModel.kJouleSunday,
            ),
          ),
          dailyKJoule: _settingsScreenViewModel.dailyKJoule.value,
          originalDailyTargetKjoule: _settingsScreenViewModel.dailyTargetKJoule.value,
        );
      },
    );
  }

  Future<void> _selectDate({required DateTime initialDate, required BuildContext context, required String languageCode}) async {
    DateTime? date = await showDatePicker(context: context, initialDate: initialDate, firstDate: DateTime(1900), lastDate: DateTime.now());

    if (date != null) {
      _birthDayController.text = DateFormat.yMMMMd(languageCode).format(date);
      _settingsScreenViewModel.birthday.value = date;
    }
  }
}
