import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:openeatsjournal/domain/gender.dart";
import "package:openeatsjournal/domain/kjoule_per_day.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/domain/weight_target.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/daily_calories_editor_screen.dart";
import "package:openeatsjournal/ui/screens/daily_calories_editor_screen_viewmodel.dart";
import "package:openeatsjournal/ui/screens/settings_screen_viewmodel.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/ui/widgets/round_outlined_button.dart";
import "package:openeatsjournal/ui/widgets/settings_textfield.dart";
import "package:openeatsjournal/ui/widgets/transparent_choice_chip.dart";

class SettingsScreenPagePersonal extends StatefulWidget {
  const SettingsScreenPagePersonal({super.key, required SettingsScreenViewModel settingsScreenViewModel}) : _settingsScreenViewModel = settingsScreenViewModel;

  final SettingsScreenViewModel _settingsScreenViewModel;

  @override
  State<SettingsScreenPagePersonal> createState() => _SettingsScreenPagePersonalState();
}

class _SettingsScreenPagePersonalState extends State<SettingsScreenPagePersonal> {
  final TextEditingController _birthDayController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final String languageCode = Localizations.localeOf(context).toString();
    final TextTheme textTheme = Theme.of(context).textTheme;

    _birthDayController.text = ConvertValidate.dateFormatterDisplayLongDateOnly.format(widget._settingsScreenViewModel.birthday.value);

    _heightController.text = ConvertValidate.numberFomatterInt.format(widget._settingsScreenViewModel.height.value);
    _weightController.text = ConvertValidate.getCleanDoubleString(doubleValue: widget._settingsScreenViewModel.weight.value!);

    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 0, 10),

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
                          Expanded(flex: 8, child: Text(AppLocalizations.of(context)!.daily_target_calories, style: textTheme.titleSmall)),
                          Expanded(
                            flex: 3,
                            child: ValueListenableBuilder(
                              valueListenable: widget._settingsScreenViewModel.dailyTargetKJoule,
                              builder: (_, _, _) {
                                return Text(
                                  ConvertValidate.numberFomatterInt.format(
                                    NutritionCalculator.getKCalsFromKJoules(kJoules: widget._settingsScreenViewModel.dailyTargetKJoule.value),
                                  ),
                                  style: textTheme.titleSmall,
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
                              valueListenable: widget._settingsScreenViewModel.dailyKJoule,
                              builder: (_, _, _) {
                                return Text(
                                  ConvertValidate.numberFomatterInt.format(
                                    NutritionCalculator.getKCalsFromKJoules(kJoules: widget._settingsScreenViewModel.dailyKJoule.value),
                                  ),
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
                          if ((await _showRecalulateKJouleConfirmDialog(context: context))!) {
                            await widget._settingsScreenViewModel.recalculateDailykJouleTargetsAndSave();
                          }
                        },
                        child: Icon(Icons.calculate),
                      ),
                      SizedBox(width: 5),
                      RoundOutlinedButton(
                        onPressed: () async {
                          await showDialog<void>(
                            useSafeArea: true,
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext contextBuilder) {
                              double horizontalPadding = MediaQuery.sizeOf(contextBuilder).width * 0.07;
                              double verticalPadding = MediaQuery.sizeOf(contextBuilder).height * 0.05;

                              return Dialog(
                                insetPadding: EdgeInsets.fromLTRB(horizontalPadding, verticalPadding, horizontalPadding, verticalPadding),
                                child: DailyCaloriesEditorScreen(
                                  dailyCaloriesEditorScreenViewModel: DailyCaloriesEditorScreenViewModel(
                                    kJoulePerDay: KJoulePerDay(
                                      kJouleMonday: widget._settingsScreenViewModel.kJouleMonday,
                                      kJouleTuesday: widget._settingsScreenViewModel.kJouleTuesday,
                                      kJouleWednesday: widget._settingsScreenViewModel.kJouleWednesday,
                                      kJouleThursday: widget._settingsScreenViewModel.kJouleThursday,
                                      kJouleFriday: widget._settingsScreenViewModel.kJouleFriday,
                                      kJouleSaturday: widget._settingsScreenViewModel.kJouleSaturday,
                                      kJouleSunday: widget._settingsScreenViewModel.kJouleSunday,
                                    ),
                                    settingsRepository: widget._settingsScreenViewModel.settingsRepository,
                                  ),
                                  dailyKJoule: widget._settingsScreenViewModel.dailyKJoule.value,
                                  originalDailyTargetKJoule: widget._settingsScreenViewModel.dailyTargetKJoule.value,
                                ),
                              );
                            },
                          );
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
                Expanded(child: Text(AppLocalizations.of(context)!.your_gender, style: textTheme.titleSmall)),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: widget._settingsScreenViewModel.gender,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            icon: Icons.male,
                            label: AppLocalizations.of(contextBuilder)!.male,
                            selected: widget._settingsScreenViewModel.gender.value == Gender.male,
                            onSelected: (bool selected) {
                              widget._settingsScreenViewModel.gender.value = Gender.male;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ValueListenableBuilder(
                        valueListenable: widget._settingsScreenViewModel.gender,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            icon: Icons.female,
                            label: AppLocalizations.of(contextBuilder)!.female,
                            selected: widget._settingsScreenViewModel.gender.value == Gender.female,
                            onSelected: (bool selected) {
                              widget._settingsScreenViewModel.gender.value = Gender.female;
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
                Expanded(child: Text(AppLocalizations.of(context)!.your_birthday, style: textTheme.titleSmall)),
                Flexible(
                  child: SettingsTextField(
                    controller: _birthDayController,
                    onTap: () async {
                      await _selectDate(initialDate: widget._settingsScreenViewModel.birthday.value, context: context, languageCode: languageCode);
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
                Expanded(child: Text(AppLocalizations.of(context)!.your_height, style: textTheme.titleSmall)),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: widget._settingsScreenViewModel.height,
                        builder: (_, _, _) {
                          return SettingsTextField(
                            controller: _heightController,
                            keyboardType: TextInputType.numberWithOptions(signed: false),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            onChanged: (value) {
                              int? intValue = int.tryParse(value);
                              widget._settingsScreenViewModel.height.value = intValue;
                              if (intValue != null) {
                                _heightController.text = ConvertValidate.numberFomatterInt.format(intValue);
                              }
                            },
                          );
                        },
                      ),
                      ValueListenableBuilder(
                        valueListenable: widget._settingsScreenViewModel.heightValid,
                        builder: (_, _, _) {
                          if (!widget._settingsScreenViewModel.heightValid.value) {
                            return Text(
                              AppLocalizations.of(
                                context,
                              )!.input_invalid_value(AppLocalizations.of(context)!.height, widget._settingsScreenViewModel.repositoryHeight),
                              style: textTheme.labelSmall!.copyWith(color: Colors.red),
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
                Expanded(
                  child: Row(
                    children: [
                      Text(AppLocalizations.of(context)!.your_weight, style: textTheme.titleSmall),
                      Tooltip(
                        triggerMode: TooltipTriggerMode.tap,
                        showDuration: Duration(seconds: 60),
                        message: AppLocalizations.of(context)!.settings_weight_explanation,
                        child: Icon(Icons.help_outline),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ValueListenableBuilder(
                    valueListenable: widget._settingsScreenViewModel.weight,
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
                                  return newValue;
                                }

                                num? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(text);
                                if (doubleValue != null) {
                                  return newValue;
                                } else {
                                  return oldValue;
                                }
                              }),
                            ],
                            onChanged: (value) {
                              num? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(value);
                              widget._settingsScreenViewModel.weight.value = doubleValue as double?;

                              if (doubleValue != null) {
                                _weightController.text = ConvertValidate.getCleanDoubleEditString(doubleValue: doubleValue, doubleValueString: value);
                              }
                            },
                          ),
                          ValueListenableBuilder(
                            valueListenable: widget._settingsScreenViewModel.weightValid,
                            builder: (_, _, _) {
                              if (!widget._settingsScreenViewModel.weightValid.value) {
                                return Text(
                                  AppLocalizations.of(context)!.input_invalid_value(
                                    AppLocalizations.of(context)!.weight_capital,
                                    ConvertValidate.getCleanDoubleString(doubleValue: widget._settingsScreenViewModel.lastValidWeight),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(AppLocalizations.of(context)!.your_acitivty_level, style: textTheme.titleSmall),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: widget._settingsScreenViewModel.activityFactor,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            label: AppLocalizations.of(contextBuilder)!.very_low,
                            selected: widget._settingsScreenViewModel.activityFactor.value == 1.2,
                            onSelected: (bool selected) {
                              widget._settingsScreenViewModel.activityFactor.value = 1.2;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ValueListenableBuilder(
                        valueListenable: widget._settingsScreenViewModel.activityFactor,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            label: AppLocalizations.of(contextBuilder)!.low,
                            selected: widget._settingsScreenViewModel.activityFactor.value == 1.4,
                            onSelected: (bool selected) {
                              widget._settingsScreenViewModel.activityFactor.value = 1.4;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ValueListenableBuilder(
                        valueListenable: widget._settingsScreenViewModel.activityFactor,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            label: AppLocalizations.of(contextBuilder)!.medium,
                            selected: widget._settingsScreenViewModel.activityFactor.value == 1.6,
                            onSelected: (bool selected) {
                              widget._settingsScreenViewModel.activityFactor.value = 1.6;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ValueListenableBuilder(
                        valueListenable: widget._settingsScreenViewModel.activityFactor,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            label: AppLocalizations.of(contextBuilder)!.high,
                            selected: widget._settingsScreenViewModel.activityFactor.value == 1.8,
                            onSelected: (bool selected) {
                              widget._settingsScreenViewModel.activityFactor.value = 1.8;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ValueListenableBuilder(
                        valueListenable: widget._settingsScreenViewModel.activityFactor,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            label: AppLocalizations.of(contextBuilder)!.very_high,
                            selected: widget._settingsScreenViewModel.activityFactor.value == 2.1,
                            onSelected: (bool selected) {
                              widget._settingsScreenViewModel.activityFactor.value = 2.1;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ValueListenableBuilder(
                        valueListenable: widget._settingsScreenViewModel.activityFactor,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            label: AppLocalizations.of(contextBuilder)!.professional_athlete,
                            selected: widget._settingsScreenViewModel.activityFactor.value == 2.4,
                            onSelected: (bool selected) {
                              widget._settingsScreenViewModel.activityFactor.value = 2.4;
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
                Expanded(child: Text(AppLocalizations.of(context)!.your_weight_target, style: textTheme.titleSmall)),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: widget._settingsScreenViewModel.weightTarget,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            label: AppLocalizations.of(contextBuilder)!.keep_weight,
                            selected: widget._settingsScreenViewModel.weightTarget.value == WeightTarget.keep,
                            onSelected: (bool selected) {
                              widget._settingsScreenViewModel.weightTarget.value = WeightTarget.keep;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ValueListenableBuilder(
                        valueListenable: widget._settingsScreenViewModel.weightTarget,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            label: AppLocalizations.of(contextBuilder)!.lose025,
                            selected: widget._settingsScreenViewModel.weightTarget.value == WeightTarget.lose025,
                            onSelected: (bool selected) {
                              widget._settingsScreenViewModel.weightTarget.value = WeightTarget.lose025;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ValueListenableBuilder(
                        valueListenable: widget._settingsScreenViewModel.weightTarget,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            label: AppLocalizations.of(contextBuilder)!.lose05,
                            selected: widget._settingsScreenViewModel.weightTarget.value == WeightTarget.lose05,
                            onSelected: (bool selected) {
                              widget._settingsScreenViewModel.weightTarget.value = WeightTarget.lose05;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ValueListenableBuilder(
                        valueListenable: widget._settingsScreenViewModel.weightTarget,
                        builder: (contextBuilder, _, _) {
                          return TransparentChoiceChip(
                            label: AppLocalizations.of(contextBuilder)!.lose075,
                            selected: widget._settingsScreenViewModel.weightTarget.value == WeightTarget.lose075,
                            onSelected: (bool selected) {
                              widget._settingsScreenViewModel.weightTarget.value = WeightTarget.lose075;
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
              onPressed: () {
                Navigator.pop(contextBuilder, false);
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.ok),
              onPressed: () {
                Navigator.pop(contextBuilder, true);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate({required DateTime initialDate, required BuildContext context, required String languageCode}) async {
    DateTime? date = await showDatePicker(context: context, initialDate: initialDate, firstDate: DateTime(1900), lastDate: DateTime.now());

    if (date != null) {
      _birthDayController.text = ConvertValidate.dateFormatterDisplayLongDateOnly.format(date);
      widget._settingsScreenViewModel.birthday.value = date;
    }
  }

  @override
  void dispose() {
    _birthDayController.dispose();
    _heightController.dispose();
    _weightController.dispose();

    super.dispose();
  }
}
