import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/daily_calories_editor_screen_viewmodel.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/ui/widgets/settings_textfield.dart";
import "package:provider/provider.dart";

class DailyCaloriesEditorScreen extends StatefulWidget {
  const DailyCaloriesEditorScreen({super.key, required int dailyKJoule, required int originalDailyTargetKJoule})
    : _dailyKJoule = dailyKJoule,
      _originalDailyTargetKJoule = originalDailyTargetKJoule;

  final int _dailyKJoule;
  final int _originalDailyTargetKJoule;

  @override
  State<DailyCaloriesEditorScreen> createState() => _DailyCaloriesEditorScreenState();
}

class _DailyCaloriesEditorScreenState extends State<DailyCaloriesEditorScreen> {
  late int _dailyKJoule;
  late int _originalDailyTargetKJoule;

  final TextEditingController _kJouleMondayController = TextEditingController();
  final TextEditingController _kJouleTuesdayController = TextEditingController();
  final TextEditingController _kJouleWednesdayController = TextEditingController();
  final TextEditingController _kJouleThursdayController = TextEditingController();
  final TextEditingController _kJouleFridayController = TextEditingController();
  final TextEditingController _kJouleSaturdayController = TextEditingController();
  final TextEditingController _kJouleSundayController = TextEditingController();

  final FocusNode _kJouleMondayFocusNode = FocusNode();
  final FocusNode _kJouleTuesdayFocusNode = FocusNode();
  final FocusNode _kJouleWednesdayFocusNode = FocusNode();
  final FocusNode _kJouleThursdayFocusNode = FocusNode();
  final FocusNode _kJouleFridayFocusNode = FocusNode();
  final FocusNode _kJouleSaturdayFocusNode = FocusNode();
  final FocusNode _kJouleSundayFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    DailyCaloriesEditorScreenViewModel dailyCaloriesEditorScreenViewModel = Provider.of<DailyCaloriesEditorScreenViewModel>(context, listen: false);
    _dailyKJoule = widget._dailyKJoule;
    _originalDailyTargetKJoule = widget._originalDailyTargetKJoule;

    _kJouleMondayController.text = ConvertValidate.numberFomatterInt.format(dailyCaloriesEditorScreenViewModel.energyMonday.value!);
    _kJouleTuesdayController.text = ConvertValidate.numberFomatterInt.format(dailyCaloriesEditorScreenViewModel.energyTuesday.value!);
    _kJouleWednesdayController.text = ConvertValidate.numberFomatterInt.format(dailyCaloriesEditorScreenViewModel.energyWednesday.value!);
    _kJouleThursdayController.text = ConvertValidate.numberFomatterInt.format(dailyCaloriesEditorScreenViewModel.energyThursday.value!);
    _kJouleFridayController.text = ConvertValidate.numberFomatterInt.format(dailyCaloriesEditorScreenViewModel.energyFriday.value!);
    _kJouleSaturdayController.text = ConvertValidate.numberFomatterInt.format(dailyCaloriesEditorScreenViewModel.energySaturday.value!);
    _kJouleSundayController.text = ConvertValidate.numberFomatterInt.format(dailyCaloriesEditorScreenViewModel.energySunday.value!);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Consumer<DailyCaloriesEditorScreenViewModel>(
      builder: (context, dailyCaloriesEditorScreenViewModel, _) => Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 0, 10),

        child: Column(
          children: [
            AppBar(backgroundColor: Color.fromARGB(0, 0, 0, 0), title: Text(AppLocalizations.of(context)!.edit_calories_target)),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            "${AppLocalizations.of(context)!.daily_target} ${ConvertValidate.getLocalizedEnergyUnitAbbreviated(context: context)} ${AppLocalizations.of(context)!.new_word}:",
                            style: textTheme.titleMedium,
                          ),
                        ),
                        Flexible(
                          child: ValueListenableBuilder(
                            valueListenable: dailyCaloriesEditorScreenViewModel.kJouleTargetDaily,
                            builder: (_, _, _) {
                              return Text(
                                "${ConvertValidate.numberFomatterInt.format(dailyCaloriesEditorScreenViewModel.kJouleTargetDaily.value)}${ConvertValidate.getLocalizedEnergyUnitAbbreviated(context: context)}",
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
                          child: Text(
                            "${AppLocalizations.of(context)!.daily_target} ${ConvertValidate.getLocalizedEnergyUnitAbbreviated(context: context)} ${AppLocalizations.of(context)!.original}:",
                            style: textTheme.bodySmall,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            "${ConvertValidate.numberFomatterInt.format(_originalDailyTargetKJoule)}${ConvertValidate.getLocalizedEnergyUnitAbbreviated(context: context)}",
                            style: textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            "${AppLocalizations.of(context)!.daily_need} ${ConvertValidate.getLocalizedEnergyUnitAbbreviated(context: context)}:",
                            style: textTheme.bodySmall,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            "${ConvertValidate.numberFomatterInt.format(_dailyKJoule)}${ConvertValidate.getLocalizedEnergyUnitAbbreviated(context: context)}",
                            style: textTheme.bodySmall,
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
                            "${AppLocalizations.of(context)!.monday} ${ConvertValidate.getLocalizedEnergyUnit(context: context)}:",
                            style: textTheme.titleMedium,
                          ),
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SettingsTextField(
                                controller: _kJouleMondayController,
                                keyboardType: TextInputType.numberWithOptions(signed: false),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                focusNode: _kJouleMondayFocusNode,
                                onTap: () {
                                  //selectAllOnFocus works only when virtual keyboard comes up, changing textfields when keyboard is already on screen has no
                                  //effect.
                                  if (!_kJouleMondayFocusNode.hasFocus) {
                                    _kJouleMondayController.selection = TextSelection(baseOffset: 0, extentOffset: _kJouleMondayController.text.length);
                                  }
                                },
                                onChanged: (value) {
                                  int? intValue = int.tryParse(value);
                                  dailyCaloriesEditorScreenViewModel.energyMonday.value = intValue ?? intValue;

                                  if (intValue != null) {
                                    _kJouleMondayController.text = ConvertValidate.numberFomatterInt.format(intValue);
                                  }
                                },
                              ),
                              ValueListenableBuilder(
                                valueListenable: dailyCaloriesEditorScreenViewModel.energyMondayValid,
                                builder: (_, _, _) {
                                  if (!dailyCaloriesEditorScreenViewModel.energyMondayValid.value) {
                                    return Text(
                                      "${AppLocalizations.of(context)!.input_invalid_value("${AppLocalizations.of(context)!.monday} ${ConvertValidate.getLocalizedEnergyUnit(context: context)}", ConvertValidate.numberFomatterInt.format(dailyCaloriesEditorScreenViewModel.energyPerdayMonday))} ${AppLocalizations.of(context)!.valid_energy} (1-${ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: ConvertValidate.getDisplayEnergy(energyKJ: ConvertValidate.maxKJoulePerDay).toDouble())}).",
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
                        Expanded(
                          child: Text(
                            "${AppLocalizations.of(context)!.tuesday} ${ConvertValidate.getLocalizedEnergyUnit(context: context)}:",
                            style: textTheme.titleMedium,
                          ),
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SettingsTextField(
                                controller: _kJouleTuesdayController,
                                keyboardType: TextInputType.numberWithOptions(signed: false),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                focusNode: _kJouleTuesdayFocusNode,
                                onTap: () {
                                  //selectAllOnFocus works only when virtual keyboard comes up, changing textfields when keyboard is already on screen has no
                                  //effect.
                                  if (!_kJouleTuesdayFocusNode.hasFocus) {
                                    _kJouleTuesdayController.selection = TextSelection(baseOffset: 0, extentOffset: _kJouleTuesdayController.text.length);
                                  }
                                },
                                onChanged: (value) {
                                  int? intValue = int.tryParse(value);
                                  dailyCaloriesEditorScreenViewModel.energyTuesday.value = intValue ?? intValue;

                                  if (intValue != null) {
                                    _kJouleTuesdayController.text = ConvertValidate.numberFomatterInt.format(intValue);
                                  }
                                },
                              ),
                              ValueListenableBuilder(
                                valueListenable: dailyCaloriesEditorScreenViewModel.energyTuesdayValid,
                                builder: (_, _, _) {
                                  if (!dailyCaloriesEditorScreenViewModel.energyTuesdayValid.value) {
                                    return Text(
                                      "${AppLocalizations.of(context)!.input_invalid_value("${AppLocalizations.of(context)!.tuesday} ${ConvertValidate.getLocalizedEnergyUnit(context: context)}", ConvertValidate.numberFomatterInt.format(dailyCaloriesEditorScreenViewModel.energyPerdayTuesday))} ${AppLocalizations.of(context)!.valid_energy} (1-${ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: ConvertValidate.getDisplayEnergy(energyKJ: ConvertValidate.maxKJoulePerDay).toDouble())}).",
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
                        Expanded(
                          child: Text(
                            "${AppLocalizations.of(context)!.wednesday} ${ConvertValidate.getLocalizedEnergyUnit(context: context)}:",
                            style: textTheme.titleMedium,
                          ),
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SettingsTextField(
                                controller: _kJouleWednesdayController,
                                keyboardType: TextInputType.numberWithOptions(signed: false),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                focusNode: _kJouleWednesdayFocusNode,
                                onTap: () {
                                  //selectAllOnFocus works only when virtual keyboard comes up, changing textfields when keyboard is already on screen has no
                                  //effect.
                                  if (!_kJouleWednesdayFocusNode.hasFocus) {
                                    _kJouleWednesdayController.selection = TextSelection(baseOffset: 0, extentOffset: _kJouleWednesdayController.text.length);
                                  }
                                },
                                onChanged: (value) {
                                  int? intValue = int.tryParse(value);
                                  dailyCaloriesEditorScreenViewModel.energyWednesday.value = intValue ?? intValue;

                                  if (intValue != null) {
                                    _kJouleWednesdayController.text = ConvertValidate.numberFomatterInt.format(intValue);
                                  }
                                },
                              ),
                              ValueListenableBuilder(
                                valueListenable: dailyCaloriesEditorScreenViewModel.energyWednesdayValid,
                                builder: (_, _, _) {
                                  if (!dailyCaloriesEditorScreenViewModel.energyWednesdayValid.value) {
                                    return Text(
                                      "${AppLocalizations.of(context)!.input_invalid_value("${AppLocalizations.of(context)!.wednesday} ${ConvertValidate.getLocalizedEnergyUnit(context: context)}", ConvertValidate.numberFomatterInt.format(dailyCaloriesEditorScreenViewModel.energyPerdayWednesday))} ${AppLocalizations.of(context)!.valid_energy} (1-${ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: ConvertValidate.getDisplayEnergy(energyKJ: ConvertValidate.maxKJoulePerDay).toDouble())}).",
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
                        Expanded(
                          child: Text(
                            "${AppLocalizations.of(context)!.thursday} ${ConvertValidate.getLocalizedEnergyUnit(context: context)}:",
                            style: textTheme.titleMedium,
                          ),
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SettingsTextField(
                                controller: _kJouleThursdayController,
                                keyboardType: TextInputType.numberWithOptions(signed: false),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                focusNode: _kJouleThursdayFocusNode,
                                onTap: () {
                                  //selectAllOnFocus works only when virtual keyboard comes up, changing textfields when keyboard is already on screen has no
                                  //effect.
                                  if (!_kJouleThursdayFocusNode.hasFocus) {
                                    _kJouleThursdayController.selection = TextSelection(baseOffset: 0, extentOffset: _kJouleThursdayController.text.length);
                                  }
                                },
                                onChanged: (value) {
                                  int? intValue = int.tryParse(value);
                                  dailyCaloriesEditorScreenViewModel.energyThursday.value = intValue ?? intValue;

                                  if (intValue != null) {
                                    _kJouleThursdayController.text = ConvertValidate.numberFomatterInt.format(intValue);
                                  }
                                },
                              ),
                              ValueListenableBuilder(
                                valueListenable: dailyCaloriesEditorScreenViewModel.energyThursdayValid,
                                builder: (_, _, _) {
                                  if (!dailyCaloriesEditorScreenViewModel.energyThursdayValid.value) {
                                    return Text(
                                      "${AppLocalizations.of(context)!.input_invalid_value("${AppLocalizations.of(context)!.thursday} ${ConvertValidate.getLocalizedEnergyUnit(context: context)}", ConvertValidate.numberFomatterInt.format(dailyCaloriesEditorScreenViewModel.energyPerdayThursday))} ${AppLocalizations.of(context)!.valid_energy} (1-${ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: ConvertValidate.getDisplayEnergy(energyKJ: ConvertValidate.maxKJoulePerDay).toDouble())}).",
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
                        Expanded(
                          child: Text(
                            "${AppLocalizations.of(context)!.friday} ${ConvertValidate.getLocalizedEnergyUnit(context: context)}:",
                            style: textTheme.titleMedium,
                          ),
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SettingsTextField(
                                controller: _kJouleFridayController,
                                keyboardType: TextInputType.numberWithOptions(signed: false),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                focusNode: _kJouleFridayFocusNode,
                                onTap: () {
                                  //selectAllOnFocus works only when virtual keyboard comes up, changing textfields when keyboard is already on screen has no
                                  //effect.
                                  if (!_kJouleFridayFocusNode.hasFocus) {
                                    _kJouleFridayController.selection = TextSelection(baseOffset: 0, extentOffset: _kJouleFridayController.text.length);
                                  }
                                },
                                onChanged: (value) {
                                  int? intValue = int.tryParse(value);
                                  dailyCaloriesEditorScreenViewModel.energyFriday.value = intValue ?? intValue;

                                  if (intValue != null) {
                                    _kJouleFridayController.text = ConvertValidate.numberFomatterInt.format(intValue);
                                  }
                                },
                              ),
                              ValueListenableBuilder(
                                valueListenable: dailyCaloriesEditorScreenViewModel.energyFridayValid,
                                builder: (_, _, _) {
                                  if (!dailyCaloriesEditorScreenViewModel.energyFridayValid.value) {
                                    return Text(
                                      "${AppLocalizations.of(context)!.input_invalid_value("${AppLocalizations.of(context)!.friday} ${ConvertValidate.getLocalizedEnergyUnit(context: context)}", ConvertValidate.numberFomatterInt.format(dailyCaloriesEditorScreenViewModel.energyPerdayFriday))} ${AppLocalizations.of(context)!.valid_energy} (1-${ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: ConvertValidate.getDisplayEnergy(energyKJ: ConvertValidate.maxKJoulePerDay).toDouble())}).",
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
                        Expanded(
                          child: Text(
                            "${AppLocalizations.of(context)!.saturday} ${ConvertValidate.getLocalizedEnergyUnit(context: context)}:",
                            style: textTheme.titleMedium,
                          ),
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SettingsTextField(
                                controller: _kJouleSaturdayController,
                                keyboardType: TextInputType.numberWithOptions(signed: false),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                focusNode: _kJouleSaturdayFocusNode,
                                onTap: () {
                                  //selectAllOnFocus works only when virtual keyboard comes up, changing textfields when keyboard is already on screen has no
                                  //effect.
                                  if (!_kJouleSaturdayFocusNode.hasFocus) {
                                    _kJouleSaturdayController.selection = TextSelection(baseOffset: 0, extentOffset: _kJouleSaturdayController.text.length);
                                  }
                                },
                                onChanged: (value) {
                                  int? intValue = int.tryParse(value);
                                  dailyCaloriesEditorScreenViewModel.energySaturday.value = intValue ?? intValue;

                                  if (intValue != null) {
                                    _kJouleSaturdayController.text = ConvertValidate.numberFomatterInt.format(intValue);
                                  }
                                },
                              ),
                              ValueListenableBuilder(
                                valueListenable: dailyCaloriesEditorScreenViewModel.energySaturdayValid,
                                builder: (_, _, _) {
                                  if (!dailyCaloriesEditorScreenViewModel.energySaturdayValid.value) {
                                    return Text(
                                      "${AppLocalizations.of(context)!.input_invalid_value("${AppLocalizations.of(context)!.saturday} ${ConvertValidate.getLocalizedEnergyUnit(context: context)}", ConvertValidate.numberFomatterInt.format(dailyCaloriesEditorScreenViewModel.energyPerdaySaturday))} ${AppLocalizations.of(context)!.valid_energy} (1-${ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: ConvertValidate.getDisplayEnergy(energyKJ: ConvertValidate.maxKJoulePerDay).toDouble())}).",
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
                        Expanded(
                          child: Text(
                            "${AppLocalizations.of(context)!.sunday} ${ConvertValidate.getLocalizedEnergyUnit(context: context)}:",
                            style: textTheme.titleMedium,
                          ),
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SettingsTextField(
                                controller: _kJouleSundayController,
                                keyboardType: TextInputType.numberWithOptions(signed: false),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                focusNode: _kJouleSundayFocusNode,
                                onTap: () {
                                  //selectAllOnFocus works only when virtual keyboard comes up, changing textfields when keyboard is already on screen has no
                                  //effect.
                                  if (!_kJouleSundayFocusNode.hasFocus) {
                                    _kJouleSundayController.selection = TextSelection(baseOffset: 0, extentOffset: _kJouleSundayController.text.length);
                                  }
                                },
                                onChanged: (value) {
                                  int? intValue = int.tryParse(value);
                                  dailyCaloriesEditorScreenViewModel.energySunday.value = intValue ?? intValue;

                                  if (intValue != null) {
                                    _kJouleSundayController.text = ConvertValidate.numberFomatterInt.format(intValue);
                                  }
                                },
                              ),
                              ValueListenableBuilder(
                                valueListenable: dailyCaloriesEditorScreenViewModel.energySundayValid,
                                builder: (_, _, _) {
                                  if (!dailyCaloriesEditorScreenViewModel.energySundayValid.value) {
                                    return Text(
                                      "${AppLocalizations.of(context)!.input_invalid_value("${AppLocalizations.of(context)!.sunday} ${ConvertValidate.getLocalizedEnergyUnit(context: context)}", ConvertValidate.numberFomatterInt.format(dailyCaloriesEditorScreenViewModel.energyPerdaySunday))} ${AppLocalizations.of(context)!.valid_energy} (1-${ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: ConvertValidate.getDisplayEnergy(energyKJ: ConvertValidate.maxKJoulePerDay).toDouble())}).",
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _kJouleMondayController.dispose();
    _kJouleTuesdayController.dispose();
    _kJouleWednesdayController.dispose();
    _kJouleThursdayController.dispose();
    _kJouleFridayController.dispose();
    _kJouleSaturdayController.dispose();
    _kJouleSundayController.dispose();

    _kJouleMondayFocusNode.dispose();
    _kJouleTuesdayFocusNode.dispose();
    _kJouleWednesdayFocusNode.dispose();
    _kJouleThursdayFocusNode.dispose();
    _kJouleFridayFocusNode.dispose();
    _kJouleSaturdayFocusNode.dispose();
    _kJouleSundayFocusNode.dispose();

    super.dispose();
  }
}
