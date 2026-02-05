import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/daily_calories_editor_screen_viewmodel.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/ui/widgets/settings_textfield.dart";

class DailyCaloriesEditorScreen extends StatefulWidget {
  const DailyCaloriesEditorScreen({
    super.key,
    required DailyCaloriesEditorScreenViewModel dailyCaloriesEditorScreenViewModel,
    required int dailyKJoule,
    required int originalDailyTargetKJoule,
  }) : _dailyCaloriesEditorScreenViewModel = dailyCaloriesEditorScreenViewModel,
       _dailyKJoule = dailyKJoule,
       _originalDailyTargetKJoule = originalDailyTargetKJoule;

  final DailyCaloriesEditorScreenViewModel _dailyCaloriesEditorScreenViewModel;
  final int _dailyKJoule;
  final int _originalDailyTargetKJoule;

  @override
  State<DailyCaloriesEditorScreen> createState() => _DailyCaloriesEditorScreenState();
}

class _DailyCaloriesEditorScreenState extends State<DailyCaloriesEditorScreen> {
  late DailyCaloriesEditorScreenViewModel _dailyCaloriesEditorScreenViewModel;
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

  //only called once even if the widget is recreated on opening the virtual keyboard e.g.
  @override
  void initState() {
    _dailyCaloriesEditorScreenViewModel = widget._dailyCaloriesEditorScreenViewModel;
    _dailyKJoule = widget._dailyKJoule;
    _originalDailyTargetKJoule = widget._originalDailyTargetKJoule;

    _kJouleMondayController.text = ConvertValidate.numberFomatterInt.format(
      NutritionCalculator.getKCalsFromKJoules(kJoules: _dailyCaloriesEditorScreenViewModel.kJouleMonday.value!),
    );
    _kJouleTuesdayController.text = ConvertValidate.numberFomatterInt.format(
      NutritionCalculator.getKCalsFromKJoules(kJoules: _dailyCaloriesEditorScreenViewModel.kJouleTuesday.value!),
    );
    _kJouleWednesdayController.text = ConvertValidate.numberFomatterInt.format(
      NutritionCalculator.getKCalsFromKJoules(kJoules: _dailyCaloriesEditorScreenViewModel.kJouleWednesday.value!),
    );
    _kJouleThursdayController.text = ConvertValidate.numberFomatterInt.format(
      NutritionCalculator.getKCalsFromKJoules(kJoules: _dailyCaloriesEditorScreenViewModel.kJouleThursday.value!),
    );
    _kJouleFridayController.text = ConvertValidate.numberFomatterInt.format(
      NutritionCalculator.getKCalsFromKJoules(kJoules: _dailyCaloriesEditorScreenViewModel.kJouleFriday.value!),
    );
    _kJouleSaturdayController.text = ConvertValidate.numberFomatterInt.format(
      NutritionCalculator.getKCalsFromKJoules(kJoules: _dailyCaloriesEditorScreenViewModel.kJouleSaturday.value!),
    );
    _kJouleSundayController.text = ConvertValidate.numberFomatterInt.format(
      NutritionCalculator.getKCalsFromKJoules(kJoules: _dailyCaloriesEditorScreenViewModel.kJouleSunday.value!),
    );
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
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
                      Expanded(child: Text(AppLocalizations.of(context)!.daily_target_new, style: textTheme.titleMedium)),
                      Flexible(
                        child: ValueListenableBuilder(
                          valueListenable: _dailyCaloriesEditorScreenViewModel.kJouleTargetDaily,
                          builder: (_, _, _) {
                            return Text(
                              AppLocalizations.of(context)!.amount_kcal(
                                ConvertValidate.numberFomatterInt.format(
                                  NutritionCalculator.getKCalsFromKJoules(kJoules: _dailyCaloriesEditorScreenViewModel.kJouleTargetDaily.value),
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
                      Expanded(child: Text(AppLocalizations.of(context)!.daily_target_original, style: textTheme.bodySmall)),
                      Flexible(
                        child: Text(
                          AppLocalizations.of(context)!.amount_kcal(
                            ConvertValidate.numberFomatterInt.format(NutritionCalculator.getKCalsFromKJoules(kJoules: _originalDailyTargetKJoule)),
                          ),
                          style: textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Text(AppLocalizations.of(context)!.daily_need_calories, style: textTheme.bodySmall)),
                      Flexible(
                        child: Text(
                          AppLocalizations.of(
                            context,
                          )!.amount_kcal(ConvertValidate.numberFomatterInt.format(NutritionCalculator.getKCalsFromKJoules(kJoules: _dailyKJoule))),
                          style: textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Text(AppLocalizations.of(context)!.monday_kcals_label, style: textTheme.titleMedium)),
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
                                _dailyCaloriesEditorScreenViewModel.kJouleMonday.value = intValue != null
                                    ? NutritionCalculator.getKJoulesFromKCals(kCals: intValue)
                                    : intValue;

                                if (intValue != null) {
                                  _kJouleMondayController.text = ConvertValidate.numberFomatterInt.format(intValue);
                                }
                              },
                            ),
                            ValueListenableBuilder(
                              valueListenable: _dailyCaloriesEditorScreenViewModel.kJouleMondayValid,
                              builder: (_, _, _) {
                                if (!_dailyCaloriesEditorScreenViewModel.kJouleMondayValid.value) {
                                  return Text(
                                    AppLocalizations.of(context)!.input_invalid_value(
                                      AppLocalizations.of(context)!.monday_kcals,
                                      ConvertValidate.numberFomatterInt.format(
                                        NutritionCalculator.getKCalsFromKJoules(kJoules: _dailyCaloriesEditorScreenViewModel.kJoulePerdayKJouleMonday),
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
                      Expanded(child: Text(AppLocalizations.of(context)!.tuesday_kcals_label, style: textTheme.titleMedium)),
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
                                _dailyCaloriesEditorScreenViewModel.kJouleTuesday.value = intValue != null
                                    ? NutritionCalculator.getKJoulesFromKCals(kCals: intValue)
                                    : intValue;

                                if (intValue != null) {
                                  _kJouleTuesdayController.text = ConvertValidate.numberFomatterInt.format(intValue);
                                }
                              },
                            ),
                            ValueListenableBuilder(
                              valueListenable: _dailyCaloriesEditorScreenViewModel.kJouleTuesdayValid,
                              builder: (_, _, _) {
                                if (!_dailyCaloriesEditorScreenViewModel.kJouleTuesdayValid.value) {
                                  return Text(
                                    AppLocalizations.of(context)!.input_invalid_value(
                                      AppLocalizations.of(context)!.tuesday_kcals,
                                      ConvertValidate.numberFomatterInt.format(
                                        NutritionCalculator.getKCalsFromKJoules(kJoules: _dailyCaloriesEditorScreenViewModel.kJoulePerdayKJouleTuesday),
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
                      Expanded(child: Text(AppLocalizations.of(context)!.wednesday_kcals_label, style: textTheme.titleMedium)),
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
                                _dailyCaloriesEditorScreenViewModel.kJouleWednesday.value = intValue != null
                                    ? NutritionCalculator.getKJoulesFromKCals(kCals: intValue)
                                    : intValue;

                                if (intValue != null) {
                                  _kJouleWednesdayController.text = ConvertValidate.numberFomatterInt.format(intValue);
                                }
                              },
                            ),
                            ValueListenableBuilder(
                              valueListenable: _dailyCaloriesEditorScreenViewModel.kJouleWednesdayValid,
                              builder: (_, _, _) {
                                if (!_dailyCaloriesEditorScreenViewModel.kJouleWednesdayValid.value) {
                                  return Text(
                                    AppLocalizations.of(context)!.input_invalid_value(
                                      AppLocalizations.of(context)!.wednesday_kcals,
                                      ConvertValidate.numberFomatterInt.format(
                                        NutritionCalculator.getKCalsFromKJoules(kJoules: _dailyCaloriesEditorScreenViewModel.kJoulePerdayKJouleWednesday),
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
                      Expanded(child: Text(AppLocalizations.of(context)!.thursday_kcals_label, style: textTheme.titleMedium)),
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
                                _dailyCaloriesEditorScreenViewModel.kJouleThursday.value = intValue != null
                                    ? NutritionCalculator.getKJoulesFromKCals(kCals: intValue)
                                    : intValue;

                                if (intValue != null) {
                                  _kJouleThursdayController.text = ConvertValidate.numberFomatterInt.format(intValue);
                                }
                              },
                            ),
                            ValueListenableBuilder(
                              valueListenable: _dailyCaloriesEditorScreenViewModel.kJouleThursdayValid,
                              builder: (_, _, _) {
                                if (!_dailyCaloriesEditorScreenViewModel.kJouleThursdayValid.value) {
                                  return Text(
                                    AppLocalizations.of(context)!.input_invalid_value(
                                      AppLocalizations.of(context)!.thursday_kcals,
                                      ConvertValidate.numberFomatterInt.format(
                                        NutritionCalculator.getKCalsFromKJoules(kJoules: _dailyCaloriesEditorScreenViewModel.kJoulePerdayKJouleThursday),
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
                      Expanded(child: Text(AppLocalizations.of(context)!.friday_kcals_label, style: textTheme.titleMedium)),
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
                                _dailyCaloriesEditorScreenViewModel.kJouleFriday.value = intValue != null
                                    ? NutritionCalculator.getKJoulesFromKCals(kCals: intValue)
                                    : intValue;

                                if (intValue != null) {
                                  _kJouleFridayController.text = ConvertValidate.numberFomatterInt.format(intValue);
                                }
                              },
                            ),
                            ValueListenableBuilder(
                              valueListenable: _dailyCaloriesEditorScreenViewModel.kJouleFridayValid,
                              builder: (_, _, _) {
                                if (!_dailyCaloriesEditorScreenViewModel.kJouleFridayValid.value) {
                                  return Text(
                                    AppLocalizations.of(context)!.input_invalid_value(
                                      AppLocalizations.of(context)!.friday_kcals,
                                      ConvertValidate.numberFomatterInt.format(
                                        NutritionCalculator.getKCalsFromKJoules(kJoules: _dailyCaloriesEditorScreenViewModel.kJoulePerdayKJouleFriday),
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
                      Expanded(child: Text(AppLocalizations.of(context)!.saturday_kcals_label, style: textTheme.titleMedium)),
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
                                _dailyCaloriesEditorScreenViewModel.kJouleSaturday.value = intValue != null
                                    ? NutritionCalculator.getKJoulesFromKCals(kCals: intValue)
                                    : intValue;

                                if (intValue != null) {
                                  _kJouleSaturdayController.text = ConvertValidate.numberFomatterInt.format(intValue);
                                }
                              },
                            ),
                            ValueListenableBuilder(
                              valueListenable: _dailyCaloriesEditorScreenViewModel.kJouleSaturdayValid,
                              builder: (_, _, _) {
                                if (!_dailyCaloriesEditorScreenViewModel.kJouleSaturdayValid.value) {
                                  return Text(
                                    AppLocalizations.of(context)!.input_invalid_value(
                                      AppLocalizations.of(context)!.saturday_kcals,
                                      ConvertValidate.numberFomatterInt.format(
                                        NutritionCalculator.getKCalsFromKJoules(kJoules: _dailyCaloriesEditorScreenViewModel.kJoulePerdayKJouleSaturday),
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
                      Expanded(child: Text(AppLocalizations.of(context)!.sunday_kcals_label, style: textTheme.titleMedium)),
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
                                _dailyCaloriesEditorScreenViewModel.kJouleSunday.value = intValue != null
                                    ? NutritionCalculator.getKJoulesFromKCals(kCals: intValue)
                                    : intValue;

                                if (intValue != null) {
                                  _kJouleSundayController.text = ConvertValidate.numberFomatterInt.format(intValue);
                                }
                              },
                            ),
                            ValueListenableBuilder(
                              valueListenable: _dailyCaloriesEditorScreenViewModel.kJouleSundayValid,
                              builder: (_, _, _) {
                                if (!_dailyCaloriesEditorScreenViewModel.kJouleSundayValid.value) {
                                  return Text(
                                    AppLocalizations.of(context)!.input_invalid_value(
                                      AppLocalizations.of(context)!.sunday_kcals,
                                      ConvertValidate.numberFomatterInt.format(
                                        NutritionCalculator.getKCalsFromKJoules(kJoules: _dailyCaloriesEditorScreenViewModel.kJoulePerdayKJouleSunday),
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
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget._dailyCaloriesEditorScreenViewModel.dispose();
    if (widget._dailyCaloriesEditorScreenViewModel != _dailyCaloriesEditorScreenViewModel) {
      _dailyCaloriesEditorScreenViewModel.dispose();
    }

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
