import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:openeatsjournal/domain/gender.dart";
import "package:openeatsjournal/domain/kjoule_per_day.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/domain/weight_target.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/repositories.dart";
import "package:openeatsjournal/ui/screens/daily_calories_editor_screen.dart";
import "package:openeatsjournal/ui/screens/daily_calories_editor_screen_viewmodel.dart";
import "package:openeatsjournal/ui/screens/settings_screen_viewmodel.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/ui/widgets/round_outlined_button.dart";
import "package:openeatsjournal/ui/widgets/settings_textfield.dart";
import "package:openeatsjournal/ui/widgets/transparent_choice_chip.dart";
import "package:provider/provider.dart";

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

  final FocusNode _heightFocusNode = FocusNode();
  final FocusNode _weightFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _birthDayController.text = ConvertValidate.dateFormatterDisplayLongDateOnly.format(widget._settingsScreenViewModel.birthday.value);

    _heightController.text = ConvertValidate.getCleanDoubleString3DecimalDigits(doubleValue: widget._settingsScreenViewModel.height.value!);
    _weightController.text = ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: widget._settingsScreenViewModel.weight.value!);
  }

  @override
  Widget build(BuildContext context) {
    final String languageCode = Localizations.localeOf(context).toString();
    final TextTheme textTheme = Theme.of(context).textTheme;

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
                          Expanded(
                            flex: 8,
                            child: Text(
                              "${AppLocalizations.of(context)!.daily_target} ${ConvertValidate.getLocalizedEnergyUnit(context: context)}",
                              style: textTheme.titleSmall,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: ValueListenableBuilder(
                              valueListenable: widget._settingsScreenViewModel.dailyTargetKJoule,
                              builder: (_, _, _) {
                                return Text(
                                  ConvertValidate.numberFomatterInt.format(widget._settingsScreenViewModel.dailyTargetKJoule.value),
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
                          Expanded(
                            flex: 8,
                            child: Text(
                              "${AppLocalizations.of(context)!.daily_need} ${ConvertValidate.getLocalizedEnergyUnit(context: context)}",
                              style: textTheme.bodySmall,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: ValueListenableBuilder(
                              valueListenable: widget._settingsScreenViewModel.dailyKJoule,
                              builder: (_, _, _) {
                                return Text(
                                  ConvertValidate.numberFomatterInt.format(widget._settingsScreenViewModel.dailyKJoule.value),
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
                                child: ChangeNotifierProvider<DailyCaloriesEditorScreenViewModel>(
                                  create: (context) => DailyCaloriesEditorScreenViewModel(
                                    kJoulePerDay: KJoulePerDay(
                                      kJouleMonday: widget._settingsScreenViewModel.kJouleMonday,
                                      kJouleTuesday: widget._settingsScreenViewModel.kJouleTuesday,
                                      kJouleWednesday: widget._settingsScreenViewModel.kJouleWednesday,
                                      kJouleThursday: widget._settingsScreenViewModel.kJouleThursday,
                                      kJouleFriday: widget._settingsScreenViewModel.kJouleFriday,
                                      kJouleSaturday: widget._settingsScreenViewModel.kJouleSaturday,
                                      kJouleSunday: widget._settingsScreenViewModel.kJouleSunday,
                                    ),
                                    settingsRepository: Provider.of<Repositories>(context, listen: false).settingsRepository,
                                  ),
                                  child: DailyCaloriesEditorScreen(
                                    dailyKJoule: widget._settingsScreenViewModel.dailyKJoule.value,
                                    originalDailyTargetKJoule: widget._settingsScreenViewModel.dailyTargetKJoule.value,
                                  ),
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
                Expanded(
                  child: Text(
                    "${AppLocalizations.of(context)!.your_height} (${ConvertValidate.getLocalizedHeightUnitAbbreviated(context: context)}):",
                    style: textTheme.titleSmall,
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: widget._settingsScreenViewModel.height,
                        builder: (_, _, _) {
                          //when widget._settingsScreenViewModel.height was changed programatically we need to update the controller
                          _heightController.text = widget._settingsScreenViewModel.height.value != null
                              ? ConvertValidate.numberFomatterInt.format(widget._settingsScreenViewModel.height.value)
                              : OpenEatsJournalStrings.emptyString;

                          return SettingsTextField(
                            controller: _heightController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                            inputFormatters: [
                              TextInputFormatter.withFunction((oldValue, newValue) {
                                final String text = newValue.text.trim();
                                if (text.isEmpty) {
                                  return newValue;
                                }

                                num? doubleValue = ConvertValidate.numberFomatterDouble3DecimalDigits.tryParse(text);
                                if (doubleValue != null) {
                                  if (ConvertValidate.decimalHasMoreThan3DecimalDigits(decimalstring: text)) {
                                    return oldValue;
                                  }

                                  return newValue;
                                } else {
                                  return oldValue;
                                }
                              }),
                            ],
                            focusNode: _heightFocusNode,
                            onTap: () {
                              //selectAllOnFocus works only when virtual keyboard comes up, changing textfields when keyboard is already on screen has no
                              //effect.
                              if (!_heightFocusNode.hasFocus) {
                                _heightController.selection = TextSelection(baseOffset: 0, extentOffset: _heightController.text.length);
                              }
                            },
                            onChanged: (value) {
                              double? doubleValue = ConvertValidate.numberFomatterDouble3DecimalDigits.tryParse(value) as double?;
                              widget._settingsScreenViewModel.setHeight(height: doubleValue);

                              if (doubleValue != null) {
                                _heightController.text = ConvertValidate.getCleanDoubleEditString3DecimalDigits(
                                  doubleValue: doubleValue,
                                  doubleValueString: value,
                                );
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
                              "${AppLocalizations.of(context)!.input_invalid_value(AppLocalizations.of(context)!.height, ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: widget._settingsScreenViewModel.repositoryHeight))} ${AppLocalizations.of(context)!.valid_height} (1-${ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: ConvertValidate.getDisplayHeight(heightCm: ConvertValidate.maxHeightCm.toDouble()))}).",
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
                      Text(
                        "${AppLocalizations.of(context)!.your_weight} (${ConvertValidate.getLocalizedWeightUnitKgAbbreviated(context: context)}):",
                        style: textTheme.titleSmall,
                      ),
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
                      //when widget._settingsScreenViewModel.weight was changed programatically we need to update the controller
                      if (widget._settingsScreenViewModel.weight.value != null) {
                        _weightController.text = ConvertValidate.getCleanDoubleEditString1DecimalDigit(
                          doubleValue: widget._settingsScreenViewModel.weight.value!,
                          doubleValueString: OpenEatsJournalStrings.emptyString,
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SettingsTextField(
                            controller: _weightController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                            inputFormatters: [
                              //If filter is not matched, the value is set to empty string which feels strange in the ui.
                              //FilteringTextInputFormatter.allow(RegExp(weightRegExp)),
                              TextInputFormatter.withFunction((oldValue, newValue) {
                                final String text = newValue.text.trim();
                                if (text.isEmpty) {
                                  return newValue;
                                }

                                num? doubleValue = ConvertValidate.numberFomatterDouble1DecimalDigit.tryParse(text);
                                if (doubleValue != null) {
                                  if (ConvertValidate.decimalHasMoreThan1DecimalDigit(decimalstring: text)) {
                                    return oldValue;
                                  }

                                  return newValue;
                                } else {
                                  return oldValue;
                                }
                              }),
                            ],
                            focusNode: _weightFocusNode,
                            onTap: () {
                              if (!_weightFocusNode.hasFocus) {
                                _weightController.selection = TextSelection(baseOffset: 0, extentOffset: _weightController.text.length);
                              }
                            },
                            onChanged: (value) {
                              num? doubleValue = ConvertValidate.numberFomatterDouble1DecimalDigit.tryParse(value);
                              widget._settingsScreenViewModel.setWeight(weight: doubleValue as double?);

                              if (doubleValue != null) {
                                _weightController.text = ConvertValidate.getCleanDoubleEditString1DecimalDigit(
                                  doubleValue: doubleValue,
                                  doubleValueString: value,
                                );
                              }
                            },
                          ),
                          ValueListenableBuilder(
                            valueListenable: widget._settingsScreenViewModel.weightValid,
                            builder: (_, _, _) {
                              if (!widget._settingsScreenViewModel.weightValid.value) {
                                return Text(
                                  "${AppLocalizations.of(context)!.input_invalid_value(AppLocalizations.of(context)!.weight_capital, ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: widget._settingsScreenViewModel.lastValidWeight))} ${AppLocalizations.of(context)!.valid_weight} (1-${ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: ConvertValidate.getDisplayWeightKg(weightKg: ConvertValidate.maxWeightKg.toDouble()))}).",
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
                            label:
                                "-${ConvertValidate.getCleanDoubleString3DecimalDigits(doubleValue: widget._settingsScreenViewModel.displayWeightTarget1)}${ConvertValidate.getLocalizedWeightUnitKgAbbreviated(context: context)} ${AppLocalizations.of(contextBuilder)!.per_week}",
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
                            label:
                                "-${ConvertValidate.getCleanDoubleString3DecimalDigits(doubleValue: widget._settingsScreenViewModel.displayWeightTarget2)}${ConvertValidate.getLocalizedWeightUnitKgAbbreviated(context: context)} ${AppLocalizations.of(contextBuilder)!.per_week}",
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
                            label:
                                "-${ConvertValidate.getCleanDoubleString3DecimalDigits(doubleValue: widget._settingsScreenViewModel.displayWeightTarget3)}${ConvertValidate.getLocalizedWeightUnitKgAbbreviated(context: context)} ${AppLocalizations.of(contextBuilder)!.per_week}",
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
    _heightFocusNode.dispose();
    _weightController.dispose();
    _weightFocusNode.dispose();

    super.dispose();
  }
}
