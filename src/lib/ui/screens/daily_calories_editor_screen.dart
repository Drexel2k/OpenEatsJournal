import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/daily_calories_editor_screen_viewmodel.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/ui/widgets/settings_textfield.dart";

class DailyCaloriesEditorScreen extends StatelessWidget {
  DailyCaloriesEditorScreen({
    super.key,
    required DailyCaloriesEditorScreenViewModel dailyCaloriesEditorScreenViewModel,
    required int dailyKJoule,
    required int originalDailyTargetKJoule,
  }) : _dailyCaloriesEditorScreenViewModel = dailyCaloriesEditorScreenViewModel,
       _dailyKJoule = dailyKJoule,
       _originalDailyTargetKJoule = originalDailyTargetKJoule,
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
    final TextTheme textTheme = Theme.of(context).textTheme;

    _kJouleMondayController.text = ConvertValidate.numberFomatterInt.format(
      NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJouleMonday.value!),
    );
    _kJouleTuesdayController.text = ConvertValidate.numberFomatterInt.format(
      NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJouleTuesday.value!),
    );
    _kJouleWednesdayController.text = ConvertValidate.numberFomatterInt.format(
      NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJouleWednesday.value!),
    );
    _kJouleThursdayController.text = ConvertValidate.numberFomatterInt.format(
      NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJouleThursday.value!),
    );
    _kJouleFridayController.text = ConvertValidate.numberFomatterInt.format(
      NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJouleFriday.value!),
    );
    _kJouleSaturdayController.text = ConvertValidate.numberFomatterInt.format(
      NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJouleSaturday.value!),
    );
    _kJouleSundayController.text = ConvertValidate.numberFomatterInt.format(
      NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJouleSunday.value!),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(backgroundColor: Color.fromARGB(0, 0, 0, 0), title: Text(AppLocalizations.of(context)!.edit_calories_target)),
        Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
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
                  Expanded(child: Text(AppLocalizations.of(context)!.daily_target_original, style: textTheme.bodySmall)),
                  Flexible(
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
                  Expanded(child: Text(AppLocalizations.of(context)!.daily_need_calories, style: textTheme.bodySmall)),
                  Flexible(
                    child: Text(
                      AppLocalizations.of(
                        context,
                      )!.amount_kcal(ConvertValidate.numberFomatterInt.format(NutritionCalculator.getKCalsFromKJoules(_dailyKJoule))),
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
                          onChanged: (value) {
                            int? intValue = int.tryParse(value);
                            _dailyCaloriesEditorScreenViewModel.kJouleMonday.value = intValue != null
                                ? NutritionCalculator.getKJoulesFromKCals(intValue)
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
                                AppLocalizations.of(context)!.input_invalid(
                                  AppLocalizations.of(context)!.monday_kcals,
                                  ConvertValidate.numberFomatterInt.format(
                                    NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJoulePerdayKJouleMonday),
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
                          onChanged: (value) {
                            int? intValue = int.tryParse(value);
                            _dailyCaloriesEditorScreenViewModel.kJouleTuesday.value = intValue != null
                                ? NutritionCalculator.getKJoulesFromKCals(intValue)
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
                                AppLocalizations.of(context)!.input_invalid(
                                  AppLocalizations.of(context)!.tuesday_kcals,
                                  ConvertValidate.numberFomatterInt.format(
                                    NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJoulePerdayKJouleTuesday),
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
                          onChanged: (value) {
                            int? intValue = int.tryParse(value);
                            _dailyCaloriesEditorScreenViewModel.kJouleWednesday.value = intValue != null
                                ? NutritionCalculator.getKJoulesFromKCals(intValue)
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
                                AppLocalizations.of(context)!.input_invalid(
                                  AppLocalizations.of(context)!.wednesday_kcals,
                                  ConvertValidate.numberFomatterInt.format(
                                    NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJoulePerdayKJouleWednesday),
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
                          onChanged: (value) {
                            int? intValue = int.tryParse(value);
                            _dailyCaloriesEditorScreenViewModel.kJouleThursday.value = intValue != null
                                ? NutritionCalculator.getKJoulesFromKCals(intValue)
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
                                AppLocalizations.of(context)!.input_invalid(
                                  AppLocalizations.of(context)!.thursday_kcals,
                                  ConvertValidate.numberFomatterInt.format(
                                    NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJoulePerdayKJouleThursday),
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
                          onChanged: (value) {
                            int? intValue = int.tryParse(value);
                            _dailyCaloriesEditorScreenViewModel.kJouleFriday.value = intValue != null
                                ? NutritionCalculator.getKJoulesFromKCals(intValue)
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
                                AppLocalizations.of(context)!.input_invalid(
                                  AppLocalizations.of(context)!.friday_kcals,
                                  ConvertValidate.numberFomatterInt.format(
                                    NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJoulePerdayKJouleFriday),
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
                          onChanged: (value) {
                            int? intValue = int.tryParse(value);
                            _dailyCaloriesEditorScreenViewModel.kJouleSaturday.value = intValue != null
                                ? NutritionCalculator.getKJoulesFromKCals(intValue)
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
                                AppLocalizations.of(context)!.input_invalid(
                                  AppLocalizations.of(context)!.saturday_kcals,
                                  ConvertValidate.numberFomatterInt.format(
                                    NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJoulePerdayKJouleSaturday),
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
                          onChanged: (value) {
                            int? intValue = int.tryParse(value);
                            _dailyCaloriesEditorScreenViewModel.kJouleSunday.value = intValue != null
                                ? NutritionCalculator.getKJoulesFromKCals(intValue)
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
                                AppLocalizations.of(context)!.input_invalid(
                                  AppLocalizations.of(context)!.sunday_kcals,
                                  ConvertValidate.numberFomatterInt.format(
                                    NutritionCalculator.getKCalsFromKJoules(_dailyCaloriesEditorScreenViewModel.kJoulePerdayKJouleSunday),
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
      ],
    );
  }
}
